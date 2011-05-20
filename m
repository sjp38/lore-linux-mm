Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 464266B0024
	for <linux-mm@kvack.org>; Fri, 20 May 2011 10:12:11 -0400 (EDT)
Received: by pxi9 with SMTP id 9so3068103pxi.14
        for <linux-mm@kvack.org>; Fri, 20 May 2011 07:12:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110520101120.GC11729@random.random>
References: <BANLkTi=TOm3aLQCD6j=4va6B+Jn2nSfwAg@mail.gmail.com>
 <BANLkTi=9W6-JXi94rZfTtTpAt3VUiY5fNw@mail.gmail.com> <BANLkTikHMUru=w4zzRmosrg2bDbsFWrkTQ@mail.gmail.com>
 <BANLkTima0hPrPwe_x06afAh+zTi-bOcRMg@mail.gmail.com> <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
 <BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com> <4DD5DC06.6010204@jp.fujitsu.com>
 <BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com> <BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
 <20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com> <20110520101120.GC11729@random.random>
From: Andrew Lutomirski <luto@mit.edu>
Date: Fri, 20 May 2011 10:11:47 -0400
Message-ID: <BANLkTikAFMvpgHR2dopd+Nvjfyw_XT5=LA@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
Content-Type: multipart/mixed; boundary=bcaec5430b56f2f55404a3b5b445
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

--bcaec5430b56f2f55404a3b5b445
Content-Type: text/plain; charset=ISO-8859-1

On Fri, May 20, 2011 at 6:11 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> I figure it's not easily reproducible but you can easily rule out THP
> issues by reproducing at least once after booting with
> transparent_hugepage=never or by building the kernel with
> CONFIG_TRANSPARENT_HUGEPAGE=n.

Reproduced with CONFIG_TRANSPARENT_HUGEPAGE=n with and without
compaction and migration.

I applied the attached patch (which includes Minchan's !pgdat_balanced
and need_resched changes).  I see:

[  121.468339] firefox shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea00019217a8) w/ prev = 100000000002000D
[  121.469236] firefox shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea00016596b8) w/ prev = 100000000002000D
[  121.470207] firefox: shrink_page_list (nr_scanned=94
nr_reclaimed=19 nr_to_reclaim=32 gfp_mask=201DA) found inactive page
ffffea00019217a8 with flags=100000000002004D
[  121.472451] firefox: shrink_page_list (nr_scanned=94
nr_reclaimed=19 nr_to_reclaim=32 gfp_mask=201DA) found inactive page
ffffea00016596b8 with flags=100000000002004D
[  121.482782] dd shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea00013a8938) w/ prev = 100000000002000D
[  121.489820] dd shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea00017a4e88) w/ prev = 1000000000000801
[  121.490626] dd shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea000005edb0) w/ prev = 1000000000000801
[  121.491499] dd: shrink_page_list (nr_scanned=62 nr_reclaimed=0
nr_to_reclaim=32 gfp_mask=200D2) found inactive page ffffea00017a4e88
with flags=1000000000000841
[  121.494337] dd: shrink_page_list (nr_scanned=62 nr_reclaimed=0
nr_to_reclaim=32 gfp_mask=200D2) found inactive page ffffea000005edb0
with flags=1000000000000841
[  121.499219] dd shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea000129c788) w/ prev = 1000000000080009
[  121.500363] dd shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea000129c830) w/ prev = 1000000000080009
[  121.502270] kswapd0 shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea0001146470) w/ prev = 100000000008001D
[  121.661545] kworker/1:1 shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea0000058168) w/ prev = 1000000000000801
[  121.662791] kworker/1:1 shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea000166f288) w/ prev = 1000000000000801
[  121.665727] kworker/1:1 shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea0001681c40) w/ prev = 1000000000000801
[  121.666857] kworker/1:1 shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea0001693130) w/ prev = 1000000000000801
[  121.667988] kworker/1:1 shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea0000c790d8) w/ prev = 1000000000000801
[  121.669105] kworker/1:1 shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea000113fe48) w/ prev = 1000000000000801
[  121.670238] kworker/1:1: shrink_page_list (nr_scanned=102
nr_reclaimed=20 nr_to_reclaim=32 gfp_mask=11212) found inactive page
ffffea0000058168 with flags=1000000000000841
[  121.674061] kworker/1:1: shrink_page_list (nr_scanned=102
nr_reclaimed=20 nr_to_reclaim=32 gfp_mask=11212) found inactive page
ffffea000166f288 with flags=1000000000000841
[  121.678054] kworker/1:1: shrink_page_list (nr_scanned=102
nr_reclaimed=20 nr_to_reclaim=32 gfp_mask=11212) found inactive page
ffffea0001681c40 with flags=1000000000000841
[  121.682069] kworker/1:1: shrink_page_list (nr_scanned=102
nr_reclaimed=20 nr_to_reclaim=32 gfp_mask=11212) found inactive page
ffffea0001693130 with flags=1000000000000841
[  121.686074] kworker/1:1: shrink_page_list (nr_scanned=102
nr_reclaimed=20 nr_to_reclaim=32 gfp_mask=11212) found inactive page
ffffea0000c790d8 with flags=1000000000000841
[  121.690045] kworker/1:1: shrink_page_list (nr_scanned=102
nr_reclaimed=20 nr_to_reclaim=32 gfp_mask=11212) found inactive page
ffffea000113fe48 with flags=1000000000000841
[  121.866205] test_mempressur shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea000165d5b8) w/ prev = 100000000002000D
[  121.868204] test_mempressur shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea0001661288) w/ prev = 100000000002000D
[  121.870203] test_mempressur shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea0001661250) w/ prev = 100000000002000D
[  121.872195] test_mempressur shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea000100cee8) w/ prev = 100000000002000D
[  121.873486] test_mempressur shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea0000eafab8) w/ prev = 100000000002000D
[  121.874718] test_mempressur shrink_page_list+0x4f3/0x5ca:
SetPageActive(ffffea0000eafaf0) w/ prev = 100000000002000D

This is interesting: it looks like shrink_page_list is making its way
through the list more than once.  It could be reentering itself
somehow or it could have something screwed up with the linked list.

I'll keep slowly debugging, but maybe this is enough for someone
familiar with this code to beat me to it.

Minchan, I think this means that your fixes are just hiding and not
fixing the underlying problem.

--bcaec5430b56f2f55404a3b5b445
Content-Type: application/octet-stream; name="vm_tests.patch"
Content-Disposition: attachment; filename="vm_tests.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gnx7j31a0

ZGlmZiAtLWdpdCBhL21tL3N3YXAuYyBiL21tL3N3YXAuYwppbmRleCBjMDJmOTM2Li43NDExOGQy
IDEwMDY0NAotLS0gYS9tbS9zd2FwLmMKKysrIGIvbW0vc3dhcC5jCkBAIC00MCw2ICs0MCwyNSBA
QCBpbnQgcGFnZV9jbHVzdGVyOwogc3RhdGljIERFRklORV9QRVJfQ1BVKHN0cnVjdCBwYWdldmVj
W05SX0xSVV9MSVNUU10sIGxydV9hZGRfcHZlY3MpOwogc3RhdGljIERFRklORV9QRVJfQ1BVKHN0
cnVjdCBwYWdldmVjLCBscnVfcm90YXRlX3B2ZWNzKTsKIAorc3RhdGljIG5vaW5saW5lIHZvaWQg
U2V0UGFnZUFjdGl2ZUNoZWNrKHN0cnVjdCBwYWdlICpwYWdlKQoreworCXVuc2lnbmVkIGxvbmcg
eDsKKwl3aGlsZSh0cnVlKSB7CisJCXVuc2lnbmVkIGxvbmcgZmxhZ3MgPSBwYWdlLT5mbGFnczsK
KwkJeCA9IGNtcHhjaGcoJihwYWdlKS0+ZmxhZ3MsIGZsYWdzLAorCQkJICAgIGZsYWdzIHwgKDEg
PDwgUEdfYWN0aXZlKSk7CisJCWlmICh4ID09IGZsYWdzKSBicmVhazsKKwl9CisJaWYgKH54ICYg
KDEgPDwgUEdfbHJ1KSkgeworICAgICAgICAgICAgICAgIGNoYXIgbmFtZVtzaXplb2YoY3VycmVu
dC0+Y29tbSldOworCQlwcmludGsoS0VSTl9FUlIgIiVzICVwUzogU2V0UGFnZUFjdGl2ZSglcCkg
dy8gcHJldiA9ICVsWFxuIiwKKwkJICAgICAgIGdldF90YXNrX2NvbW0obmFtZSwgY3VycmVudCks
CisJCSAgICAgICBfX2J1aWx0aW5fcmV0dXJuX2FkZHJlc3MoMCksIHBhZ2UsIHgpOworCX0KK30K
KworI2RlZmluZSBTZXRQYWdlQWN0aXZlIFNldFBhZ2VBY3RpdmVDaGVjaworCiAvKgogICogVGhp
cyBwYXRoIGFsbW9zdCBuZXZlciBoYXBwZW5zIGZvciBWTSBhY3Rpdml0eSAtIHBhZ2VzIGFyZSBu
b3JtYWxseQogICogZnJlZWQgdmlhIHBhZ2V2ZWNzLiAgQnV0IGl0IGdldHMgdXNlZCBieSBuZXR3
b3JraW5nLgpkaWZmIC0tZ2l0IGEvbW0vdm1zY2FuLmMgYi9tbS92bXNjYW4uYwppbmRleCAzZjQ0
YjgxLi5kYzQxN2FiIDEwMDY0NAotLS0gYS9tbS92bXNjYW4uYworKysgYi9tbS92bXNjYW4uYwpA
QCAtNTMsNiArNTMsMjUgQEAKICNkZWZpbmUgQ1JFQVRFX1RSQUNFX1BPSU5UUwogI2luY2x1ZGUg
PHRyYWNlL2V2ZW50cy92bXNjYW4uaD4KIAorc3RhdGljIG5vaW5saW5lIHZvaWQgU2V0UGFnZUFj
dGl2ZUNoZWNrKHN0cnVjdCBwYWdlICpwYWdlKQoreworCXVuc2lnbmVkIGxvbmcgeDsKKwl3aGls
ZSh0cnVlKSB7CisJCXVuc2lnbmVkIGxvbmcgZmxhZ3MgPSBwYWdlLT5mbGFnczsKKwkJeCA9IGNt
cHhjaGcoJihwYWdlKS0+ZmxhZ3MsIGZsYWdzLAorCQkJICAgIGZsYWdzIHwgKDEgPDwgUEdfYWN0
aXZlKSk7CisJCWlmICh4ID09IGZsYWdzKSBicmVhazsKKwl9CisJaWYgKH54ICYgKDEgPDwgUEdf
bHJ1KSkgeworICAgICAgICAgICAgICAgIGNoYXIgbmFtZVtzaXplb2YoY3VycmVudC0+Y29tbSld
OworCQlwcmludGsoS0VSTl9FUlIgIiVzICVwUzogU2V0UGFnZUFjdGl2ZSglcCkgdy8gcHJldiA9
ICVsWFxuIiwKKwkJICAgICAgIGdldF90YXNrX2NvbW0obmFtZSwgY3VycmVudCksCisJCSAgICAg
ICBfX2J1aWx0aW5fcmV0dXJuX2FkZHJlc3MoMCksIHBhZ2UsIHgpOworCX0KK30KKworI2RlZmlu
ZSBTZXRQYWdlQWN0aXZlIFNldFBhZ2VBY3RpdmVDaGVjaworCiAvKgogICogcmVjbGFpbV9tb2Rl
IGRldGVybWluZXMgaG93IHRoZSBpbmFjdGl2ZSBsaXN0IGlzIHNocnVuawogICogUkVDTEFJTV9N
T0RFX1NJTkdMRTogUmVjbGFpbSBvbmx5IG9yZGVyLTAgcGFnZXMKQEAgLTcyOSw3ICs3NDgsMTcg
QEAgc3RhdGljIHVuc2lnbmVkIGxvbmcgc2hyaW5rX3BhZ2VfbGlzdChzdHJ1Y3QgbGlzdF9oZWFk
ICpwYWdlX2xpc3QsCiAJCWlmICghdHJ5bG9ja19wYWdlKHBhZ2UpKQogCQkJZ290byBrZWVwOwog
Ci0JCVZNX0JVR19PTihQYWdlQWN0aXZlKHBhZ2UpKTsKKwkJaWYgKFBhZ2VBY3RpdmUocGFnZSkp
IHsKKwkJCWNoYXIgbmFtZVtzaXplb2YoY3VycmVudC0+Y29tbSldOworCQkJcHJpbnRrKEtFUk5f
RVJSICIlczogc2hyaW5rX3BhZ2VfbGlzdCAobnJfc2Nhbm5lZD0lbHUgbnJfcmVjbGFpbWVkPSVs
dSBucl90b19yZWNsYWltPSVsdSBnZnBfbWFzaz0lWCkgZm91bmQgaW5hY3RpdmUgcGFnZSAlcCB3
aXRoIGZsYWdzPSVsWFxuIiwKKwkJCSAgICAgICBnZXRfdGFza19jb21tKG5hbWUsIGN1cnJlbnQp
LAorCQkJICAgICAgIHNjLT5ucl9zY2FubmVkLCBzYy0+bnJfcmVjbGFpbWVkLAorCQkJICAgICAg
IHNjLT5ucl90b19yZWNsYWltLCBzYy0+Z2ZwX21hc2ssIHBhZ2UsCisJCQkgICAgICAgcGFnZS0+
ZmxhZ3MpOworCQkJLy9WTV9CVUdfT04oUGFnZUFjdGl2ZShwYWdlKSk7CisJCQltc2xlZXAoMSk7
CisJCQljb250aW51ZTsKKwkJfQogCQlWTV9CVUdfT04ocGFnZV96b25lKHBhZ2UpICE9IHpvbmUp
OwogCiAJCXNjLT5ucl9zY2FubmVkKys7CkBAIC0yMjQ3LDYgKzIyNzYsMTAgQEAgc3RhdGljIGJv
b2wgc2xlZXBpbmdfcHJlbWF0dXJlbHkocGdfZGF0YV90ICpwZ2RhdCwgaW50IG9yZGVyLCBsb25n
IHJlbWFpbmluZywKIAl1bnNpZ25lZCBsb25nIGJhbGFuY2VkID0gMDsKIAlib29sIGFsbF96b25l
c19vayA9IHRydWU7CiAKKwkvKiBJZiBrc3dhcGQgaGFzIGJlZW4gcnVubmluZyB0b28gbG9uZywg
anVzdCBzbGVlcCAqLworCWlmIChuZWVkX3Jlc2NoZWQoKSkKKwkJcmV0dXJuIGZhbHNlOworCiAJ
LyogSWYgYSBkaXJlY3QgcmVjbGFpbWVyIHdva2Uga3N3YXBkIHdpdGhpbiBIWi8xMCwgaXQncyBw
cmVtYXR1cmUgKi8KIAlpZiAocmVtYWluaW5nKQogCQlyZXR1cm4gdHJ1ZTsKQEAgLTIyODIsNyAr
MjMxNSw3IEBAIHN0YXRpYyBib29sIHNsZWVwaW5nX3ByZW1hdHVyZWx5KHBnX2RhdGFfdCAqcGdk
YXQsIGludCBvcmRlciwgbG9uZyByZW1haW5pbmcsCiAJICogbXVzdCBiZSBiYWxhbmNlZAogCSAq
LwogCWlmIChvcmRlcikKLQkJcmV0dXJuIHBnZGF0X2JhbGFuY2VkKHBnZGF0LCBiYWxhbmNlZCwg
Y2xhc3N6b25lX2lkeCk7CisJCXJldHVybiAhcGdkYXRfYmFsYW5jZWQocGdkYXQsIGJhbGFuY2Vk
LCBjbGFzc3pvbmVfaWR4KTsKIAllbHNlCiAJCXJldHVybiAhYWxsX3pvbmVzX29rOwogfQo=
--bcaec5430b56f2f55404a3b5b445--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
