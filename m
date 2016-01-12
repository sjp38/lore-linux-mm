Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC9C4403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 03:18:00 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id b14so306594483wmb.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 00:18:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fa10si130781038wjd.246.2016.01.12.00.17.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 12 Jan 2016 00:17:58 -0800 (PST)
Date: Tue, 12 Jan 2016 09:17:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm,oom: do not loop !__GFP_FS allocation if the OOM
 killer is disabled.
Message-ID: <20160112081756.GD25337@dhcp22.suse.cz>
References: <1452488836-6772-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160111170047.GB32132@cmpxchg.org>
 <20160111172058.GK27317@dhcp22.suse.cz>
 <20160111174329.GA377@cmpxchg.org>
 <20160111174958.GM27317@dhcp22.suse.cz>
 <201601120630.ICG86454.FFMFVSOOtHJOQL@I-love.SAKURA.ne.jp>
 <20160111220216.GA5452@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160111220216.GA5452@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, linux-mm@kvack.org

On Mon 11-01-16 17:02:16, Johannes Weiner wrote:
> On Tue, Jan 12, 2016 at 06:30:15AM +0900, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > Scratch my objection to this patch then. But please do add to/update
> > > > that XXX comment above that line, or it'll be confusing. Hm?
> > > > 
> > > > 			/*
> > > > 			 * XXX: Page reclaim didn't yield anything,
> > > > 			 * and the OOM killer can't be invoked, but
> > > > 			 * keep looping as per tradition. Unless the
> > > > 			 * system is trying to enter a quiescent state
> > > > 			 * during suspend and the OOM killer has been
> > > > 			 * shut off already. Give up like with other
> > > > 			 * !__GFP_NOFAIL allocations in that case.
> > > > 			 */
> > > > 			*did_some_progress = !oom_killer_disabled;
> > > 
> > > Yes this makes it more clear IMO.
> > > 
> > If you don't want to expose oom_killer_disabled outside of the OOM proper,
> > can't we move this "if (!(gfp_mask & __GFP_FS)) { ... }" block to before
> > constraint = constrained_alloc(oc, &totalpages) line in out_of_memory() ?
> 
> I think your patch is fine as it is.
> 
> It's better to pull out oom_killer_disabled. We want the logic that
> filters OOM invocation based on allocation type in one place. And as
> per the XXX we eventually want to drop that bogus *did_some_progress
> setting anyway.

Completely agreed.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
