Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DFF656B2BB2
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 15:23:43 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c16-v6so2688812edc.21
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 12:23:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5-v6si2989637edx.32.2018.08.23.12.23.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 12:23:42 -0700 (PDT)
Date: Thu, 23 Aug 2018 21:23:39 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm, oom: Fix missing tlb_finish_mmu() in
 __oom_reap_task_mm().
Message-ID: <20180823192339.GR29735@dhcp22.suse.cz>
References: <1535023848-5554-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180823115957.GF29735@dhcp22.suse.cz>
 <6bf40c7f-3e68-8702-b087-9e37abb2d547@i-love.sakura.ne.jp>
 <20180823140209.GO29735@dhcp22.suse.cz>
 <b752d1d5-81ad-7a35-2394-7870641be51c@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b752d1d5-81ad-7a35-2394-7870641be51c@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu 23-08-18 23:11:26, Tetsuo Handa wrote:
> Commit 93065ac753e44438 ("mm, oom: distinguish blockable mode for mmu
> notifiers") added "continue;" without calling tlb_finish_mmu(). It should
> not cause a critical problem but fix anyway because it looks strange.

I would suggest the following wording instead

93065ac753e44438 ("mm, oom: distinguish blockable mode for mmu
notifiers") has added an ability to skip over vmas with blockable mmu
notifiers. This however didn't call tlb_finish_mmu as it should. As
a result inc_tlb_flush_pending has been called without its pairing
dec_tlb_flush_pending and all callers mm_tlb_flush_pending would flush
even though this is not really needed. This alone is not harmful and
it seems there shouldn't be any such callers for oom victims at all but
there is no real reason to skip tlb_finish_mmu on early skip either so
call it.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

In any case
Acked-by: Michal Hocko <mhocko@suse.com>

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
