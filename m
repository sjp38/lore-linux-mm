Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 974E66B00EC
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 21:29:05 -0500 (EST)
Received: by vbbey12 with SMTP id ey12so2680425vbb.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2012 18:29:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F514E09.5060801@redhat.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB9455FE2@USINDEVS02.corp.hds.com>
	<4F514E09.5060801@redhat.com>
Date: Sat, 3 Mar 2012 10:29:04 +0800
Message-ID: <CAJd=RBBdnA-gCXo8w5afng_v+AgfQF797pKW0eDdVJbszULvhg@mail.gmail.com>
Subject: Re: [RFC][PATCH] avoid swapping out with swappiness==0
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>

On Sat, Mar 3, 2012 at 6:47 AM, Rik van Riel <riel@redhat.com> wrote:
> On 03/02/2012 12:36 PM, Satoru Moriya wrote:
>>
>> Sometimes we'd like to avoid swapping out anonymous memory
>> in particular, avoid swapping out pages of important process or
>> process groups while there is a reasonable amount of pagecache
>> on RAM so that we can satisfy our customers' requirements.
>>
>> OTOH, we can control how aggressive the kernel will swap memory pages
>> with /proc/sys/vm/swappiness for global and
>> /sys/fs/cgroup/memory/memory.swappiness for each memcg.
>>
>> But with current reclaim implementation, the kernel may swap out
>> even if we set swappiness=3D=3D0 and there is pagecache on RAM.
>>
>> This patch changes the behavior with swappiness=3D=3D0. If we set
>> swappiness=3D=3D0, the kernel does not swap out completely
>> (for global reclaim until the amount of free pages and filebacked
>> pages in a zone has been reduced to something very very small
>> (nr_free + nr_filebacked< =C2=A0high watermark)).
>>
>> Any comments are welcome.
>>
>> Regards,
>> Satoru Moriya
>>
>> Signed-off-by: Satoru Moriya<satoru.moriya@hds.com>
>> ---
>> =C2=A0mm/vmscan.c | =C2=A0 =C2=A06 +++---
>> =C2=A01 files changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index c52b235..27dc3e8 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1983,10 +1983,10 @@ static void get_scan_count(struct mem_cgroup_zon=
e
>> *mz, struct scan_control *sc,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * proportional to the fraction of recently s=
canned pages on
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * each list that were recently referenced an=
d in active use.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> - =C2=A0 =C2=A0 =C2=A0 ap =3D (anon_prio + 1) * (reclaim_stat->recent_sc=
anned[0] + 1);
>> + =C2=A0 =C2=A0 =C2=A0 ap =3D anon_prio * (reclaim_stat->recent_scanned[=
0] + 1);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0ap /=3D reclaim_stat->recent_rotated[0] + 1;
>>
>> - =C2=A0 =C2=A0 =C2=A0 fp =3D (file_prio + 1) * (reclaim_stat->recent_sc=
anned[1] + 1);
>> + =C2=A0 =C2=A0 =C2=A0 fp =3D file_prio * (reclaim_stat->recent_scanned[=
1] + 1);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0fp /=3D reclaim_stat->recent_rotated[1] + 1;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irq(&mz->zone->lru_lock);
>
>
> ACK on this bit of the patch.
>
>> @@ -1999,7 +1999,7 @@ out:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long sca=
n;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scan =3D zone_nr_=
lru_pages(mz, lru);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (priority || noswa=
p) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (priority || noswa=
p || !vmscan_swappiness(mz, sc)) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0scan>>=3D priority;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0if (!scan&& =C2=A0force_scan)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scan =3D SWAP_CLUSTER_MAX;
>
>
> However, I do not understand why we fail to scale
> the number of pages we want to scan with priority
> if "noswap".
>
> For that matter, surely if we do not want to swap
> out anonymous pages, we WANT to go into this if
> branch, in order to make sure we set "scan" to 0?
>
> scan =3D div64_u64(scan * fraction[file], denominator);
>
> With your patch and swappiness=3D0, or no swap space, it
> looks like we do not zero out "scan" and may end up
> scanning anonymous pages.
>
> Am I overlooking something? =C2=A0Is this correct?
>

Try to simplify the complex a bit :)

Good weekend
-hd

--- a/mm/vmscan.c	Wed Feb  8 20:10:14 2012
+++ b/mm/vmscan.c	Sat Mar  3 10:02:10 2012
@@ -1997,15 +1997,23 @@ static void get_scan_count(struct mem_cg
 out:
 	for_each_evictable_lru(lru) {
 		int file =3D is_file_lru(lru);
-		unsigned long scan;
+		unsigned long scan =3D 0;

-		scan =3D zone_nr_lru_pages(mz, lru);
-		if (priority || noswap) {
-			scan >>=3D priority;
-			if (!scan && force_scan)
-				scan =3D SWAP_CLUSTER_MAX;
+		/* First, check noswap */
+		if (noswap && !file)
+			goto set;
+
+		/* Second, apply priority */
+		scan =3D zone_nr_lru_pages(mz, lru) >> priority;
+
+		/* Third, check force */
+		if (!scan && force_scan)
+			scan =3D SWAP_CLUSTER_MAX;
+
+		/* Finally, try to avoid div64 */
+		if (scan)
 			scan =3D div64_u64(scan * fraction[file], denominator);
-		}
+set:
 		nr[lru] =3D scan;
 	}
 }
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
