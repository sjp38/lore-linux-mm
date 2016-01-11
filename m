Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id E1B2D828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 12:21:02 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id f206so280017427wmf.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 09:21:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si19141108wjz.107.2016.01.11.09.21.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Jan 2016 09:21:01 -0800 (PST)
Date: Mon, 11 Jan 2016 18:20:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm,oom: do not loop !__GFP_FS allocation if the OOM
 killer is disabled.
Message-ID: <20160111172058.GK27317@dhcp22.suse.cz>
References: <1452488836-6772-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160111170047.GB32132@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160111170047.GB32132@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, linux-mm@kvack.org

On Mon 11-01-16 12:00:47, Johannes Weiner wrote:
> On Mon, Jan 11, 2016 at 02:07:16PM +0900, Tetsuo Handa wrote:
> > After the OOM killer is disabled during suspend operation,
> > any !__GFP_NOFAIL && __GFP_FS allocations are forced to fail.
> > Thus, any !__GFP_NOFAIL && !__GFP_FS allocations should be
> > forced to fail as well.
> > 
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> Why? We had to acknowledge that !__GFP_FS allocations can not fail
> even when they can't invoke the OOM killer. They are NOFAIL. Just like
> an explicit __GFP_NOFAIL they should trigger a warning when they occur
> after the OOM killer has been disabled and then keep looping.

They are more like GFP_KERNEL than GFP_NOFAIL IMO because unlike
GFP_NOFAIL they are already allowed to fail due to fatal_signals_pending
and this has been the case for a really long time.  Even semantically
they are basically GFP_KERNEL with FS recursion protection in majority
cases. And I believe that we should allow them to fail long term after
some FS (btrfs at least) catch up and start handling failures properly.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
