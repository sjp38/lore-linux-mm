Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id A863F6B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 15:51:55 -0400 (EDT)
Received: by igbsb11 with SMTP id sb11so651123igb.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 12:51:55 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id w1si1251574igl.17.2015.06.08.12.51.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 12:51:55 -0700 (PDT)
Received: by igbsb11 with SMTP id sb11so650966igb.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 12:51:55 -0700 (PDT)
Date: Mon, 8 Jun 2015 12:51:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: always panic on OOM when panic_on_oom is
 configured
In-Reply-To: <20150605111302.GB26113@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1506081242250.13272@chino.kir.corp.google.com>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz> <alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com> <20150605111302.GB26113@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 5 Jun 2015, Michal Hocko wrote:

> > Nack, this is not the appropriate response to exit path livelocks.  By 
> > doing this, you are going to start unnecessarily panicking machines that 
> > have panic_on_oom set when it would not have triggered before.  If there 
> > is no reclaimable memory and a process that has already been signaled to 
> > die to is in the process of exiting has to allocate memory, it is 
> > perfectly acceptable to give them access to memory reserves so they can 
> > allocate and exit.  Under normal circumstances, that allows the process to 
> > naturally exit.  With your patch, it will cause the machine to panic.
> 
> Isn't that what the administrator of the system wants? The system
> is _clearly_ out of memory at this point. A coincidental exiting task
> doesn't change a lot in that regard. Moreover it increases a risk of
> unnecessarily unresponsive system which is what panic_on_oom tries to
> prevent from. So from my POV this is a clear violation of the user
> policy.
> 

We rely on the functionality that this patch is short cutting because we 
rely on userspace to trigger oom kills.  For system oom conditions, we 
must then rely on the kernel oom killer to set TIF_MEMDIE since userspace 
cannot grant it itself.  (I think the memcg case is very similar in that 
this patch is short cutting it, but I'm more concerned for the system oom 
in this case because it's a show stopper for us.)

We want to send the SIGKILL, which will interrupt things like 
get_user_pages() which we find is our culprit most of the time.  When the 
process enters the exit path, it must allocate other memory (slab, 
coredumping and the very problematic proc_exit_connector()) to free 
memory.  This patch would cause the machine to panic rather than utilizing 
memory reserves so that it can exit, not as a result of a kernel oom kill 
but rather a userspace kill.

Panic_on_oom is to suppress the kernel oom killer.  It's not a sysctl that 
triggers whenever watermarks are hit and it doesn't suppress memory 
reserves from being used for things like GFP_ATOMIC.  Setting TIF_MEMDIE 
for an exiting process is another type of memory reserves and is 
imperative that we have it to make forward progress.  Panic_on_oom should 
only trigger when the kernel can't make forward progress without killing 
something (not true in this case).  I believe that's how the documentation 
has always been interpreted and the tunable used in the wild.

It would be interesting to consider your other patch that refactors the 
sysrq+f tunable.  I think we should make that never trigger panic_on_oom 
(the sysadmin can use other sysrqs for that) and allow userspace to use 
sysrq+f as a trigger when it is responsive to handle oom conditions.

But this patch itself can't possibly be merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
