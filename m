Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8F51A6B0072
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 18:28:42 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so22379527igb.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 15:28:42 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com. [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id mk9si7456731icb.2.2015.06.09.15.28.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 15:28:42 -0700 (PDT)
Received: by ieclw1 with SMTP id lw1so22911250iec.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 15:28:42 -0700 (PDT)
Date: Tue, 9 Jun 2015 15:28:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: always panic on OOM when panic_on_oom is
 configured
In-Reply-To: <20150609094356.GB29057@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1506091516000.30516@chino.kir.corp.google.com>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz> <alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com> <20150605111302.GB26113@dhcp22.suse.cz> <alpine.DEB.2.10.1506081242250.13272@chino.kir.corp.google.com> <20150608213218.GB18360@dhcp22.suse.cz>
 <alpine.DEB.2.10.1506081606500.17040@chino.kir.corp.google.com> <20150609094356.GB29057@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 9 Jun 2015, Michal Hocko wrote:

> > > On Mon 08-06-15 12:51:53, David Rientjes wrote:
> > > Do you actually have panic_on_oops enabled?
> > > 
> > 
> > CONFIG_PANIC_ON_OOPS_VALUE should be 0, I'm not sure why that's relevant.
> 
> No I meant panic_on_oops > 0.
> 

CONFIG_PANIC_ON_OOPS_VALUE sets panic_on_oops, so it's 0.

> > The functionality I'm referring to is that your patch now panics the 
> > machine for configs where /proc/sys/vm/panic_on_oom is set and the same 
> > scenario occurs as described above.  You're introducing userspace breakage 
> > because you are using panic_on_oom in a way that it hasn't been used in 
> > the past and isn't described as working in the documentation.
> 
> I am sorry, but I do not follow. The knob has been always used to
> _panic_ the OOM system. Nothing more and nothing less. Now you
> are arguing about the change being buggy because a task might be
> killed but that argument doesn't make much sense to me because
> basically _any_ other allocation which allows OOM to trigger might hit
> check_panic_on_oom() and panic the system well before your killed task
> gets a chance to terminate.
> 

Not necessarily.  We pin a lot of memory with get_user_pages() and 
short-circuit it by checking for fatal_signal_pending() specifically for 
oom conditions.  This was done over six years ago by commit 4779280d1ea4 
("mm: make get_user_pages() interruptible").  When such a process is 
faulting in memory, and it is killed by userspace as a result of an oom 
condition, it needs to be able to allocate (TIF_MEMDIE set by the oom 
killer due to SIGKILL), return to __get_user_pages(), abort, handle the 
signal, and exit.

I can't possibly make that any more clear.

Your patch causes that to instead panic the system if panic_on_oom is set.  
It's inappropriate and userspace breakage.  The fact that I don't 
personally use panic_on_oom is completely and utterly irrelevant.

There is absolutely nothing wrong with a process that has been killed 
either directly by userspace or as part of a group exit, or a process that 
is already in the exit path and needs to allocate memory to be able to 
free its memory, to get access to memory reserves.  That's not an oom 
condition, that's memory reserves.  Panic_on_oom has nothing to do with 
this scenario whatsoever.

Panic_on_oom is not panic_when_reclaim_fails.  It's to suppress a kernel 
oom kill.  That's why it's checked where it is checked and always has 
been.  This patch cannot possibly be merged.

> I would understand your complain if we waited for oom victim(s) before
> check_panic_on_oom but we have not been doing that.
> 

I don't think anybody is changing panic_on_oom after boot, so we wouldn't 
have any oom victims if the oom killer never did anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
