Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E45B56B00A0
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 20:48:44 -0400 (EDT)
Received: by iwn6 with SMTP id 6so15557iwn.14
        for <linux-mm@kvack.org>; Tue, 02 Nov 2010 17:48:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4CCF8151.3010202@redhat.com>
References: <20101028191523.GA14972@google.com>
	<20101101012322.605C.A69D9226@jp.fujitsu.com>
	<20101101182416.GB31189@google.com>
	<4CCF0BE3.2090700@redhat.com>
	<AANLkTi=src1L0gAFsogzCmejGOgg5uh=9O4Uw+ZmfBg4@mail.gmail.com>
	<4CCF8151.3010202@redhat.com>
Date: Wed, 3 Nov 2010 09:48:42 +0900
Message-ID: <AANLkTi=JJ-0ae+QybtR+e=4_4mpQghh61c4=TZYAw8uF@mail.gmail.com>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: multipart/mixed; boundary=0003255750fe293c3d04941b67f9
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mandeep Singh Baines <msb@chromium.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

--0003255750fe293c3d04941b67f9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Rik,

On Tue, Nov 2, 2010 at 12:11 PM, Rik van Riel <riel@redhat.com> wrote:
> On 11/01/2010 03:43 PM, Mandeep Singh Baines wrote:
>
>> Yes, this prevents you from reclaiming the active list all at once. But =
if
>> the
>> memory pressure doesn't go away, you'll start to reclaim the active list
>> little by little. First you'll empty the inactive list, and then
>> you'll start scanning
>> the active list and pulling pages from inactive to active. The problem i=
s
>> that
>> there is no minimum time limit to how long a page will sit in the inacti=
ve
>> list
>> before it is reclaimed. Just depends on scan rate which does not depend
>> on time.
>>
>> In my experiments, I saw the active list get smaller and smaller
>> over time until eventually it was only a few MB at which point the syste=
m
>> came
>> grinding to a halt due to thrashing.
>
> I believe that changing the active/inactive ratio has other
> potential thrashing issues. =A0Specifically, when the inactive
> list is too small, pages may not stick around long enough to
> be accessed multiple times and get promoted to the active
> list, even when they are in active use.
>
> I prefer a more flexible solution, that automatically does
> the right thing.

I agree. Ideally, it's the best if we handle it well in kernel internal.

>
> The problem you see is that the file list gets reclaimed
> very quickly, even when it is already very small.
>
> I wonder if a possible solution would be to limit how fast
> file pages get reclaimed, when the page cache is very small.
> Say, inactive_file * active_file < 2 * zone->pages_high ?

Why do you multiply inactive_file and active_file?
What's meaning?

I think it's very difficult to fix _a_ threshold.
At least, user have to set it with proper value to use the feature.
Anyway, we need default value. It needs some experiments in desktop
and embedded.

>
> At that point, maybe we could slow down the reclaiming of
> page cache pages to be significantly slower than they can
> be refilled by the disk. =A0Maybe 100 pages a second - that
> can be refilled even by an actual spinning metal disk
> without even the use of readahead.
>
> That can be rounded up to one batch of SWAP_CLUSTER_MAX
> file pages every 1/4 second, when the number of page cache
> pages is very low.

How about reducing scanning window size?
I think it could approximate the idea.

>
> This way HPC and virtual machine hosting nodes can still
> get rid of totally unused page cache, but on any system
> that actually uses page cache, some minimal amount of
> cache will be protected under heavy memory pressure.
>
> Does this sound like a reasonable approach?
>
> I realize the threshold may have to be tweaked...

Absolutely.

>
> The big question is, how do we integrate this with the
> OOM killer? =A0Do we pretend we are out of memory when
> we've hit our file cache eviction quota and kill something?

I think "Yes".
But I think killing isn't best if oom_badness can't select proper victim.
Normally, embedded system doesn't have swap. And it could try to keep
many task in memory due to application startup latency.
It means some tasks never executed during long time and just stay in
memory with consuming the memory.
OOM have to kill it. Anyway it's off topic.

>
> Would there be any downsides to this approach?

At first feeling, I have a concern unbalance aging of anon/file.
But I think it's no problem. It a result user want. User want to
protect file-backed page(ex, code page) so many anon swapout is
natural result to go on the system. If the system has no swap, we have
no choice except OOM.

>
> Are there any volunteers for implementing this idea?
> (Maybe someone who needs the feature?)

I made quick patch to discuss as combining your idea and Mandeep.
(Just pass the compile test.)


diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7687228..98380ec 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -29,6 +29,7 @@ extern unsigned long num_physpages;
 extern unsigned long totalram_pages;
 extern void * high_memory;
 extern int page_cluster;
+extern int min_filelist_kbytes;

 #ifdef CONFIG_SYSCTL
 extern int sysctl_legacy_va_layout;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 3a45c22..c61f0c9 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1320,6 +1320,14 @@ static struct ctl_table vm_table[] =3D {
                .extra2         =3D &one,
        },
 #endif
+       {
+               .procname       =3D "min_filelist_kbytes",
+               .data           =3D &min_filelist_kbytes,
+               .maxlen         =3D sizeof(min_filelist_kbytes),
+               .mode           =3D 0644,
+               .proc_handler   =3D &proc_dointvec,
+               .extra1         =3D &zero,
+       },

 /*
  * NOTE: do not add new entries to this table unless you have read
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c5dfabf..3b0e95d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -130,6 +130,11 @@ struct scan_control {
 int vm_swappiness =3D 60;
 long vm_total_pages;   /* The total number of pages which the VM controls =
*/

+/*
+ * Low watermark used to prevent fscache thrashing during low memory.
+ * 20M is a arbitrary value. We need more discussion.
+ */
+int min_filelist_kbytes =3D 1024 * 20;
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);

@@ -1635,6 +1640,7 @@ static void get_scan_count(struct zone *zone,
struct scan_control *sc,
        u64 fraction[2], denominator;
        enum lru_list l;
        int noswap =3D 0;
+       int low_pagecache =3D 0;

        /* If we have no swap space, do not bother scanning anon pages. */
        if (!sc->may_swap || (nr_swap_pages <=3D 0)) {
@@ -1651,6 +1657,7 @@ static void get_scan_count(struct zone *zone,
struct scan_control *sc,
                zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);

        if (scanning_global_lru(sc)) {
+               unsigned long pagecache_threshold;
                free  =3D zone_page_state(zone, NR_FREE_PAGES);
                /* If we have very few page cache pages,
                   force-scan anon pages. */
@@ -1660,6 +1667,10 @@ static void get_scan_count(struct zone *zone,
struct scan_control *sc,
                        denominator =3D 1;
                        goto out;
                }
+
+               pagecache_threshold =3D min_filelist_kbytes >> (PAGE_SHIFT =
- 10);
+               if (file < pagecache_threshold)
+                       low_pagecache =3D 1;
        }

        /*
@@ -1715,6 +1726,12 @@ out:
                if (priority || noswap) {
                        scan >>=3D priority;
                        scan =3D div64_u64(scan * fraction[file], denominat=
or);
+                       /*
+                        * If the system has low page cache, we slow down
+                        * scanning speed with 1/8 to protect working set.
+                        */
+                       if (low_pagecache)
+                               scan >>=3D 3;
                }
                nr[l] =3D nr_scan_try_batch(scan,
                                          &reclaim_stat->nr_saved_scan[l]);



> --
> All rights reversed
>



--=20
Kind regards,
Minchan Kim

--0003255750fe293c3d04941b67f9
Content-Type: text/x-patch; charset=US-ASCII; name="slow_down_file_lru.patch"
Content-Disposition: attachment; filename="slow_down_file_lru.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gg1hg9qr0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvbW0uaCBiL2luY2x1ZGUvbGludXgvbW0uaAppbmRl
eCA3Njg3MjI4Li45ODM4MGVjIDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L21tLmgKKysrIGIv
aW5jbHVkZS9saW51eC9tbS5oCkBAIC0yOSw2ICsyOSw3IEBAIGV4dGVybiB1bnNpZ25lZCBsb25n
IG51bV9waHlzcGFnZXM7CiBleHRlcm4gdW5zaWduZWQgbG9uZyB0b3RhbHJhbV9wYWdlczsKIGV4
dGVybiB2b2lkICogaGlnaF9tZW1vcnk7CiBleHRlcm4gaW50IHBhZ2VfY2x1c3RlcjsKK2V4dGVy
biBpbnQgbWluX2ZpbGVsaXN0X2tieXRlczsKIAogI2lmZGVmIENPTkZJR19TWVNDVEwKIGV4dGVy
biBpbnQgc3lzY3RsX2xlZ2FjeV92YV9sYXlvdXQ7CmRpZmYgLS1naXQgYS9rZXJuZWwvc3lzY3Rs
LmMgYi9rZXJuZWwvc3lzY3RsLmMKaW5kZXggM2E0NWMyMi4uYzYxZjBjOSAxMDA2NDQKLS0tIGEv
a2VybmVsL3N5c2N0bC5jCisrKyBiL2tlcm5lbC9zeXNjdGwuYwpAQCAtMTMyMCw2ICsxMzIwLDE0
IEBAIHN0YXRpYyBzdHJ1Y3QgY3RsX3RhYmxlIHZtX3RhYmxlW10gPSB7CiAJCS5leHRyYTIJCT0g
Jm9uZSwKIAl9LAogI2VuZGlmCisJeworCQkucHJvY25hbWUgICAgICAgPSAibWluX2ZpbGVsaXN0
X2tieXRlcyIsCisJCS5kYXRhICAgICAgICAgICA9ICZtaW5fZmlsZWxpc3Rfa2J5dGVzLAorCQku
bWF4bGVuICAgICAgICAgPSBzaXplb2YobWluX2ZpbGVsaXN0X2tieXRlcyksCisJCS5tb2RlICAg
ICAgICAgICA9IDA2NDQsCisJCS5wcm9jX2hhbmRsZXIgICA9ICZwcm9jX2RvaW50dmVjLAorCQku
ZXh0cmExICAgICAgICAgPSAmemVybywKKwl9LAogCiAvKgogICogTk9URTogZG8gbm90IGFkZCBu
ZXcgZW50cmllcyB0byB0aGlzIHRhYmxlIHVubGVzcyB5b3UgaGF2ZSByZWFkCmRpZmYgLS1naXQg
YS9tbS92bXNjYW4uYyBiL21tL3Ztc2Nhbi5jCmluZGV4IGM1ZGZhYmYuLjNiMGU5NWQgMTAwNjQ0
Ci0tLSBhL21tL3Ztc2Nhbi5jCisrKyBiL21tL3Ztc2Nhbi5jCkBAIC0xMzAsNiArMTMwLDExIEBA
IHN0cnVjdCBzY2FuX2NvbnRyb2wgewogaW50IHZtX3N3YXBwaW5lc3MgPSA2MDsKIGxvbmcgdm1f
dG90YWxfcGFnZXM7CS8qIFRoZSB0b3RhbCBudW1iZXIgb2YgcGFnZXMgd2hpY2ggdGhlIFZNIGNv
bnRyb2xzICovCiAKKy8qIAorICogTG93IHdhdGVybWFyayB1c2VkIHRvIHByZXZlbnQgZnNjYWNo
ZSB0aHJhc2hpbmcgZHVyaW5nIGxvdyBtZW1vcnkuCisgKiAyME0gaXMgYSBhcmJpdHJhcnkgdmFs
dWUuIFdlIG5lZWQgbW9yZSBkaXNjdXNzaW9uLgorICovCitpbnQgbWluX2ZpbGVsaXN0X2tieXRl
cyA9IDEwMjQgKiAyMDsKIHN0YXRpYyBMSVNUX0hFQUQoc2hyaW5rZXJfbGlzdCk7CiBzdGF0aWMg
REVDTEFSRV9SV1NFTShzaHJpbmtlcl9yd3NlbSk7CiAKQEAgLTE2MzUsNiArMTY0MCw3IEBAIHN0
YXRpYyB2b2lkIGdldF9zY2FuX2NvdW50KHN0cnVjdCB6b25lICp6b25lLCBzdHJ1Y3Qgc2Nhbl9j
b250cm9sICpzYywKIAl1NjQgZnJhY3Rpb25bMl0sIGRlbm9taW5hdG9yOwogCWVudW0gbHJ1X2xp
c3QgbDsKIAlpbnQgbm9zd2FwID0gMDsKKwlpbnQgbG93X3BhZ2VjYWNoZSA9IDA7CiAKIAkvKiBJ
ZiB3ZSBoYXZlIG5vIHN3YXAgc3BhY2UsIGRvIG5vdCBib3RoZXIgc2Nhbm5pbmcgYW5vbiBwYWdl
cy4gKi8KIAlpZiAoIXNjLT5tYXlfc3dhcCB8fCAobnJfc3dhcF9wYWdlcyA8PSAwKSkgewpAQCAt
MTY1MSw2ICsxNjU3LDcgQEAgc3RhdGljIHZvaWQgZ2V0X3NjYW5fY291bnQoc3RydWN0IHpvbmUg
KnpvbmUsIHN0cnVjdCBzY2FuX2NvbnRyb2wgKnNjLAogCQl6b25lX25yX2xydV9wYWdlcyh6b25l
LCBzYywgTFJVX0lOQUNUSVZFX0ZJTEUpOwogCiAJaWYgKHNjYW5uaW5nX2dsb2JhbF9scnUoc2Mp
KSB7CisJCXVuc2lnbmVkIGxvbmcgcGFnZWNhY2hlX3RocmVzaG9sZDsKIAkJZnJlZSAgPSB6b25l
X3BhZ2Vfc3RhdGUoem9uZSwgTlJfRlJFRV9QQUdFUyk7CiAJCS8qIElmIHdlIGhhdmUgdmVyeSBm
ZXcgcGFnZSBjYWNoZSBwYWdlcywKIAkJICAgZm9yY2Utc2NhbiBhbm9uIHBhZ2VzLiAqLwpAQCAt
MTY2MCw2ICsxNjY3LDEwIEBAIHN0YXRpYyB2b2lkIGdldF9zY2FuX2NvdW50KHN0cnVjdCB6b25l
ICp6b25lLCBzdHJ1Y3Qgc2Nhbl9jb250cm9sICpzYywKIAkJCWRlbm9taW5hdG9yID0gMTsKIAkJ
CWdvdG8gb3V0OwogCQl9CisKKwkJcGFnZWNhY2hlX3RocmVzaG9sZCA9IG1pbl9maWxlbGlzdF9r
Ynl0ZXMgPj4gKFBBR0VfU0hJRlQgLSAxMCk7CisJCWlmIChmaWxlIDwgcGFnZWNhY2hlX3RocmVz
aG9sZCkKKwkJCWxvd19wYWdlY2FjaGUgPSAxOwogCX0KIAogCS8qCkBAIC0xNzE1LDYgKzE3MjYs
MTIgQEAgb3V0OgogCQlpZiAocHJpb3JpdHkgfHwgbm9zd2FwKSB7CiAJCQlzY2FuID4+PSBwcmlv
cml0eTsKIAkJCXNjYW4gPSBkaXY2NF91NjQoc2NhbiAqIGZyYWN0aW9uW2ZpbGVdLCBkZW5vbWlu
YXRvcik7CisJCQkvKgorCQkJICogSWYgdGhlIHN5c3RlbSBoYXMgbG93IHBhZ2UgY2FjaGUsIHdl
IHNsb3cgZG93biAKKwkJCSAqIHNjYW5uaW5nIHNwZWVkIHdpdGggMS84IHRvIHByb3RlY3Qgd29y
a2luZyBzZXQuCisJCQkgKi8KKwkJCWlmIChsb3dfcGFnZWNhY2hlKQorCQkJCXNjYW4gPj49IDM7
CiAJCX0KIAkJbnJbbF0gPSBucl9zY2FuX3RyeV9iYXRjaChzY2FuLAogCQkJCQkgICZyZWNsYWlt
X3N0YXQtPm5yX3NhdmVkX3NjYW5bbF0pOwo=
--0003255750fe293c3d04941b67f9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
