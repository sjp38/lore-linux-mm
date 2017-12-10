Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE1A46B0253
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 05:17:11 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l4so8688459wre.10
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 02:17:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v61si8932970wrc.23.2017.12.10.02.17.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Dec 2017 02:17:10 -0800 (PST)
Date: Sun, 10 Dec 2017 11:17:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: terminate shrink_slab loop if signal is pending
Message-ID: <20171210101709.GB20234@dhcp22.suse.cz>
References: <20171208082220.GQ20234@dhcp22.suse.cz>
 <d5cc35f6-57a4-adb9-5b32-07c1db7c2a7a@I-love.SAKURA.ne.jp>
 <20171208114806.GU20234@dhcp22.suse.cz>
 <201712082303.DDG90166.FOLSHOOFVQJMtF@I-love.SAKURA.ne.jp>
 <CAJuCfpHmdcA=t9p8kjJYrgkrreQZt9Sa1=_up+1yV9BE4xJ-8g@mail.gmail.com>
 <201712091708.GHG60458.MHFOVSFOQtOFLJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712091708.GHG60458.MHFOVSFOQtOFLJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: surenb@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, timmurray@google.com, tkjos@google.com

On Sat 09-12-17 17:08:42, Tetsuo Handa wrote:
> Suren Baghdasaryan wrote:
> > On Fri, Dec 8, 2017 at 6:03 AM, Tetsuo Handa
> > <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > >> > >> This change checks for pending
> > >> > >> fatal signals inside shrink_slab loop and if one is detected
> > >> > >> terminates this loop early.
> > >> > >
> > >> > > This changelog doesn't really address my previous review feedback, I am
> > >> > > afraid. You should mention more details about problems you are seeing
> > >> > > and what causes them.
> > 
> > The problem I'm facing is that a SIGKILL sent from user space to kill
> > the least important process is delayed enough for OOM-killer to get a
> > chance to kill something else, possibly a more important process. Here
> > "important" is from user's point of view. So the delay in SIGKILL
> > delivery effectively causes extra kills. Traces indicate that this
> > delay happens when process being killed is in direct reclaim and
> > shrinkers (before I fixed them) were the biggest cause for the delay.
> 
> Sending SIGKILL from userspace is not releasing memory fast enough to prevent
> the OOM killer from invoking? Yes, under memory pressure, even an attempt to
> send SIGKILL from userspace could be delayed due to e.g. page fault.
> 
> Unless it is memcg OOM, you could try OOM notifier callback for checking
> whether there are SIGKILL pending processes and wait for timeout if any.

Hell no! You surely do not want all the OOM livelocks you were pushing
so hard to get fixed, do you?

The whole problem here is that there are two implementations of the OOM
handling and they do not use any synchronization. You cannot be really
surprise they step on each others toes. That is one of the reasons why I
really hated the LMK in the kernel btw.

Stalling shrinkers is a real problem and it should be addressed but
let's not screw an already nasty/fragile code all around that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
