Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9360E6B29E9
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 08:00:01 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 57-v6so638505edt.15
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 05:00:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5-v6si100044ede.255.2018.08.23.04.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 04:59:59 -0700 (PDT)
Date: Thu, 23 Aug 2018 13:59:57 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, oom: Always call tlb_finish_mmu().
Message-ID: <20180823115957.GF29735@dhcp22.suse.cz>
References: <1535023848-5554-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1535023848-5554-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu 23-08-18 20:30:48, Tetsuo Handa wrote:
> Commit 93065ac753e44438 ("mm, oom: distinguish blockable mode for mmu
> notifiers") added "continue;" without calling tlb_finish_mmu(). I don't
> know whether tlb_flush_pending imbalance causes problems other than
> extra cost, but at least it looks strange.

tlb_flush_pending has mm scope and it would confuse
mm_tlb_flush_pending. At least ptep_clear_flush could get confused and
flush unnecessarily for prot_none entries AFAICS. Other paths shouldn't
trigger for oom victims. Even ptep_clear_flush is unlikely to happen.
So nothing really earth shattering but I do agree that it looks weird
and should be fixed.

> More worrisome part in that patch is that I don't know whether using
> trylock if blockable == false at entry is really sufficient. For example,
> since __gnttab_unmap_refs_async() from gnttab_unmap_refs_async() from
> gnttab_unmap_refs_sync() from __unmap_grant_pages() from
> unmap_grant_pages() from unmap_if_in_range() from mn_invl_range_start()
> involves schedule_delayed_work() which could be blocked on memory
> allocation under OOM situation, wait_for_completion() from
> gnttab_unmap_refs_sync() might deadlock? I don't know...

Not really sure why this is in the changelog as it is unrelated to the
fix. Anyway let me try to check...

OK, so I've added in_range(map, start, end) check to not go that
direction. But for some reason that check doesn't consider blockable
value. So it looks definitely wrong. I must have screwed up when
rebasing or something. Thanks for catching that up. I will send a fix.

> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index b5b25e4..4f431c1 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -522,6 +522,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
>  
>  			tlb_gather_mmu(&tlb, mm, start, end);
>  			if (mmu_notifier_invalidate_range_start_nonblock(mm, start, end)) {
> +				tlb_finish_mmu(&tlb, start, end);
>  				ret = false;
>  				continue;
>  			}
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
