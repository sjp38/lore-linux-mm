Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BD05E6B026B
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 10:12:48 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i10-v6so2369593eds.19
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 07:12:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c4-v6si891771edf.296.2018.06.25.07.12.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jun 2018 07:12:47 -0700 (PDT)
Date: Mon, 25 Jun 2018 16:12:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Message-ID: <20180625141246.GN28965@dhcp22.suse.cz>
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180620115531.GL13685@dhcp22.suse.cz>
 <3d27f26e-68ba-d3c0-9518-cebeb2689aec@sony.com>
 <20180625130756.GK28965@dhcp22.suse.cz>
 <9a14d554-6470-e0d6-19cc-1ecec17a47c7@sony.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9a14d554-6470-e0d6-19cc-1ecec17a47c7@sony.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sony.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Mon 25-06-18 16:04:04, peter enderborg wrote:
> On 06/25/2018 03:07 PM, Michal Hocko wrote:
> 
> > On Mon 25-06-18 15:03:40, peter enderborg wrote:
> >> On 06/20/2018 01:55 PM, Michal Hocko wrote:
> >>> On Wed 20-06-18 20:20:38, Tetsuo Handa wrote:
> >>>> Sleeping with oom_lock held can cause AB-BA lockup bug because
> >>>> __alloc_pages_may_oom() does not wait for oom_lock. Since
> >>>> blocking_notifier_call_chain() in out_of_memory() might sleep, sleeping
> >>>> with oom_lock held is currently an unavoidable problem.
> >>> Could you be more specific about the potential deadlock? Sleeping while
> >>> holding oom lock is certainly not nice but I do not see how that would
> >>> result in a deadlock assuming that the sleeping context doesn't sleep on
> >>> the memory allocation obviously.
> >> It is a mutex you are supposed to be able to sleep.A  It's even exported.
> > What do you mean? oom_lock is certainly not exported for general use. It
> > is not local to oom_killer.c just because it is needed in other _mm_
> > code.
> >  
> 
> ItA  is in the oom.h file include/linux/oom.h, if it that sensitive it should
> be in mm/ and a documented note about the special rules. It is only used
> in drivers/tty/sysrq.c and that be replaced by a help function in mm that
> do theA  oom stuff.

Well, there are many things defined in kernel header files and not meant
for wider use. Using random locks is generally discouraged I would say
unless you are sure you know what you are doing. We could do some more
work to hide internals for sure, though.
 
> >>>> As a preparation for not to sleep with oom_lock held, this patch brings
> >>>> OOM notifier callbacks to outside of OOM killer, with two small behavior
> >>>> changes explained below.
> >>> Can we just eliminate this ugliness and remove it altogether? We do not
> >>> have that many notifiers. Is there anything fundamental that would
> >>> prevent us from moving them to shrinkers instead?
> >> @Hocko Do you remember the lowmemorykiller from android? Some things
> >> might not be the right thing for shrinkers.
> > Just that lmk did it wrong doesn't mean others have to follow.
> >
> If all you have is a hammer, everything looks like a nail. (I dona??t argument that it was right)
> But if you dona??t have a way to interact with the memory system we will get attempts like lmk.A 
> Oom notifiers and vmpressure is for this task better than shrinkers.

A lack of feature should be a trigger for a discussion rather than a
quick hack that seems to work for a particular usecase and live out of
tree, then get to staging and hope it will fix itself. Seriously, the
kernel development is not a nail hammering.
-- 
Michal Hocko
SUSE Labs
