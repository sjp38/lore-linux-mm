Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39C5E6B2A79
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 10:02:15 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m25-v6so2896230pgv.14
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 07:02:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v34-v6si4265794plg.491.2018.08.23.07.02.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 07:02:13 -0700 (PDT)
Date: Thu, 23 Aug 2018 16:02:09 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, oom: Always call tlb_finish_mmu().
Message-ID: <20180823140209.GO29735@dhcp22.suse.cz>
References: <1535023848-5554-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180823115957.GF29735@dhcp22.suse.cz>
 <6bf40c7f-3e68-8702-b087-9e37abb2d547@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6bf40c7f-3e68-8702-b087-9e37abb2d547@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu 23-08-18 22:48:22, Tetsuo Handa wrote:
> On 2018/08/23 20:59, Michal Hocko wrote:
> > On Thu 23-08-18 20:30:48, Tetsuo Handa wrote:
> >> Commit 93065ac753e44438 ("mm, oom: distinguish blockable mode for mmu
> >> notifiers") added "continue;" without calling tlb_finish_mmu(). I don't
> >> know whether tlb_flush_pending imbalance causes problems other than
> >> extra cost, but at least it looks strange.
> > 
> > tlb_flush_pending has mm scope and it would confuse
> > mm_tlb_flush_pending. At least ptep_clear_flush could get confused and
> > flush unnecessarily for prot_none entries AFAICS. Other paths shouldn't
> > trigger for oom victims. Even ptep_clear_flush is unlikely to happen.
> > So nothing really earth shattering but I do agree that it looks weird
> > and should be fixed.
> 
> OK. But what is the reason we call tlb_gather_mmu() before
> mmu_notifier_invalidate_range_start_nonblock() ?
> I want that the fix explains why we can't do
> 
> -			tlb_gather_mmu(&tlb, mm, start, end);
>  			if (mmu_notifier_invalidate_range_start_nonblock(mm, start, end)) {
>  				ret = false;
>  				continue;
>  			}
> +			tlb_gather_mmu(&tlb, mm, start, end);

This should be indeed doable because mmu notifiers have no way to know
about tlb_gather. I have no idea why we used to have tlb_gather_mmu like
that before. Most probably a C&P from munmap path where it didn't make
any difference either. A quick check shows that tlb_flush_pending is the
only mm scope thing and none of the notifiers really depend on it.

I would be calmer if both paths were in sync in that regards. So I think
it would be better to go with your previous version first. Maybe it
makes sense to switch the order but I do not really see a huge win for
doing so.
-- 
Michal Hocko
SUSE Labs
