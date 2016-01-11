Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 93A81828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 12:44:01 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id u188so224371665wmu.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 09:44:01 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ej8si14872349wjd.175.2016.01.11.09.44.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 09:44:00 -0800 (PST)
Date: Mon, 11 Jan 2016 12:43:29 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm,oom: do not loop !__GFP_FS allocation if the OOM
 killer is disabled.
Message-ID: <20160111174329.GA377@cmpxchg.org>
References: <1452488836-6772-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160111170047.GB32132@cmpxchg.org>
 <20160111172058.GK27317@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160111172058.GK27317@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, linux-mm@kvack.org

On Mon, Jan 11, 2016 at 06:20:58PM +0100, Michal Hocko wrote:
> On Mon 11-01-16 12:00:47, Johannes Weiner wrote:
> > On Mon, Jan 11, 2016 at 02:07:16PM +0900, Tetsuo Handa wrote:
> > > After the OOM killer is disabled during suspend operation,
> > > any !__GFP_NOFAIL && __GFP_FS allocations are forced to fail.
> > > Thus, any !__GFP_NOFAIL && !__GFP_FS allocations should be
> > > forced to fail as well.
> > > 
> > > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > 
> > Why? We had to acknowledge that !__GFP_FS allocations can not fail
> > even when they can't invoke the OOM killer. They are NOFAIL. Just like
> > an explicit __GFP_NOFAIL they should trigger a warning when they occur
> > after the OOM killer has been disabled and then keep looping.
> 
> They are more like GFP_KERNEL than GFP_NOFAIL IMO because unlike
> GFP_NOFAIL they are already allowed to fail due to fatal_signals_pending
> and this has been the case for a really long time.  Even semantically
> they are basically GFP_KERNEL with FS recursion protection in majority
> cases. And I believe that we should allow them to fail long term after
> some FS (btrfs at least) catch up and start handling failures properly.

I see, yeah that's probably a better way to look at it.

Thanks!

Scratch my objection to this patch then. But please do add to/update
that XXX comment above that line, or it'll be confusing. Hm?

			/*
			 * XXX: Page reclaim didn't yield anything,
			 * and the OOM killer can't be invoked, but
			 * keep looping as per tradition. Unless the
			 * system is trying to enter a quiescent state
			 * during suspend and the OOM killer has been
			 * shut off already. Give up like with other
			 * !__GFP_NOFAIL allocations in that case.
			 */
			*did_some_progress = !oom_killer_disabled;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
