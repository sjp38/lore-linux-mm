Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 65E516B005A
	for <linux-mm@kvack.org>; Sun, 25 Nov 2012 20:21:58 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id c14so2410445ieb.14
        for <linux-mm@kvack.org>; Sun, 25 Nov 2012 17:21:57 -0800 (PST)
Message-ID: <50B2C428.8010908@gmail.com>
Date: Mon, 26 Nov 2012 09:21:44 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,vmscan: free pages if compaction_suitable tells us
 to
References: <20121119202152.4B0E420004E@hpza10.eem.corp.google.com> <20121125175728.3db4ac6a@fem.tu-ilmenau.de> <20121125132950.11b15e38@annuminas.surriel.com> <20121125224433.GB2799@cmpxchg.org>
In-Reply-To: <20121125224433.GB2799@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, akpm@linux-foundation.org, mgorman@suse.de, Valdis.Kletnieks@vt.edu, jirislaby@gmail.com, jslaby@suse.cz, zkabelac@redhat.com, mm-commits@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On 11/26/2012 06:44 AM, Johannes Weiner wrote:
> On Sun, Nov 25, 2012 at 01:29:50PM -0500, Rik van Riel wrote:
>> On Sun, 25 Nov 2012 17:57:28 +0100
>> Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de> wrote:
>>
>>> With kernel 3.7-rc6 I've still problems with kswapd0 on my laptop
>>> And this is most of the time. I've only observed this behavior on the
>>> laptop. Other systems don't show this.
>> This suggests it may have something to do with small memory zones,
>> where we end up with the "funny" situation that the high watermark
>> (+ balance gap) for a particular zone is less than the low watermark
>> + 2<<order pages, which is the number of free pages required to keep
>> compaction_suitable happy.
>>
>> Could you try this patch?
> It's not quite enough because it's not reaching the conditions you
> changed, see analysis in https://lkml.org/lkml/2012/11/20/567
>
> But even fixing it up (by adding the compaction_suitable() test in
> this preliminary scan over the zones and setting end_zone accordingly)
> is not enough because no actual reclaim happens at priority 12 in a

The preliminary scan is in the highmem->dma direction, it will miss high 
zone which not meet compaction_suitable() test instead of lowest zone.

> small zone.  So the number of free pages is not actually changing and
> the compaction_suitable() checks keep the loop going.
>
> The problem is fairly easy to reproduce, by the way.  Just boot with
> mem=800M to have a relatively small lowmem reserve in the DMA zone.
> Fill it up with page cache, then allocate transparent huge pages.
>
> With your patch and my fix to the preliminary zone loop, there won't
> be any hung task warnings anymore because kswapd actually calls
> shrink_slab() and there is a rescheduling point in there, but it still
> loops forever.
>
> It also seems a bit aggressive to try to balance a small zone like DMA
> for a huge page when it's not a GFP_DMA allocation, but none of these
> checks actually take the classzone into account.  Do we have any
> agreement over what this whole thing is supposed to be doing?
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b99ecba..f7e54df 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2412,6 +2412,9 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
>    *     would need to be at least 256M for it to be balance a whole node.
>    *     Similarly, on x86-64 the Normal zone would need to be at least 1G
>    *     to balance a node on its own. These seemed like reasonable ratios.
> + *
> + * The kswapd source code is brought to you by Advil(R).  "For today's
> + * tough pain, one might not be enough."
>    */
>   static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
>   						int classzone_idx)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
