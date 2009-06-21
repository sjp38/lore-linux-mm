Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 699C06B004F
	for <linux-mm@kvack.org>; Sun, 21 Jun 2009 04:42:12 -0400 (EDT)
Date: Sun, 21 Jun 2009 10:52:12 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 12/15] HWPOISON: per process early kill option prctl(PR_MEMORY_FAILURE_EARLY_KILL)
Message-ID: <20090621085212.GC8218@one.firstfloor.org>
References: <20090620031608.624240019@intel.com> <20090620031626.237671605@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090620031626.237671605@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jun 20, 2009 at 11:16:20AM +0800, Wu Fengguang wrote:
> The default option is late kill, ie. only kill the process when it actually
> tries to access the corrupted data. But an admin can still request a legacy
> application to be early killed by writing a wrapper tool which calls prctl()
> and exec the application:
> 
> 	# this_app_shall_be_early_killed  legacy_app
> 
> KVM needs the early kill signal. At early kill time it has good opportunity
> to isolate the corruption in guest kernel pages. It will be too late to do
> anything useful on late kill.
> 
> Proposed by Nick Pidgin.

If anything you would need two flags per process: one to signify
that the application set the flag and another what the actual
value is.

Also you broke the existing qemu implementation now which obviously
doesn't know about this new flag.

I don't think we need this patch right now.

> +static bool task_early_kill_elegible(struct task_struct *tsk)
> +{
> +	if (!tsk->mm)
> +		return false;

I don't think this can happen.

> +
> +	return tsk->flags & PF_EARLY_KILL;

This type mixing is also dangerous, if someone create e.g. a char bool
it would be always false.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
