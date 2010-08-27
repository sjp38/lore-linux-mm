Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 80BF16B01F1
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 01:00:43 -0400 (EDT)
Received: by iwn33 with SMTP id 33so2952805iwn.14
        for <linux-mm@kvack.org>; Thu, 26 Aug 2010 22:00:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=xUMSZ7wX-2BtJ0-+2BYLCTW=VPTAErinb5Zd2@mail.gmail.com>
References: <1282867897-31201-1-git-send-email-yinghan@google.com>
	<AANLkTimaLBJa9hmufqQy3jk7GD-mJDbg=Dqkaja0nOMk@mail.gmail.com>
	<AANLkTi=xUMSZ7wX-2BtJ0-+2BYLCTW=VPTAErinb5Zd2@mail.gmail.com>
Date: Fri, 27 Aug 2010 14:00:41 +0900
Message-ID: <AANLkTinP_q7S4_O921hdBoedmTp-7gw0+=4DPHZGmysi@mail.gmail.com>
Subject: Re: [PATCH] vmscan: fix missing place to check nr_swap_pages.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2010 at 12:31 PM, Ying Han <yinghan@google.com> wrote:
> On Thu, Aug 26, 2010 at 6:03 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
>>
>> Hello.
>>
>> On Fri, Aug 27, 2010 at 9:11 AM, Ying Han <yinghan@google.com> wrote:
>> > Fix a missed place where checks nr_swap_pages to do shrink_active_list. Make the
>> > change that moves the check to common function inactive_anon_is_low.
>> >
>>
>> Hmm.. AFAIR, we discussed it at that time but we concluded it's not good.
>> That's because nr_swap_pages < 0 means both "NO SWAP" and "NOT enough
>> swap space now". If we have a swap device or file but not enough space
>> now, we need to aging anon pages to make inactive list enough size.
>> Otherwise, working set pages would be swapped out more fast before
>> promotion.
>
> We found the problem on one of our workloads where more TLB flush
> happens without the change. Kswapd seems to be calling
> shrink_active_list() which eventually clears access bit of those ptes
> and does TLB flush
> with ptep_clear_flush_young(). This system does not have swap
> configured, and why aging the anon lru in that
> case?

True. I also wanted it but we have to care swap configured but
non-enabling still yet system as well as non-swap configured system at
that time.

If your system is no swap configured, how about this?
(It's a not formal proper patch but just quick patch to show the concept).

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3109ff7..641c6a6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1580,6 +1580,11 @@ static void shrink_active_list(unsigned long
nr_pages, struct zone *zone,
        spin_unlock_irq(&zone->lru_lock);
 }

+/*
+ * If system doesn't have a swap configuration,
+ * it doesn't need to age anon pages in kswapd.
+ */
+#ifdef CONFIG_SWAP
 static int inactive_anon_is_low_global(struct zone *zone)
 {
        unsigned long active, inactive;
@@ -1611,6 +1616,12 @@ static int inactive_anon_is_low(struct zone
*zone, struct scan_control *sc)
                low = mem_cgroup_inactive_anon_is_low(sc->mem_cgroup);
        return low;
 }
+#else
+static inline int inactive_anon_is_low(struct zone *zone, struct
scan_control *sc)
+{
+       return 0;
+}
+#endif

 static int inactive_file_is_low_global(struct zone *zone)
 {


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
