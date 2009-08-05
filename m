Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 42B976B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 07:54:52 -0400 (EDT)
Date: Wed, 5 Aug 2009 12:54:49 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 5/12] ksm: keep quiet while list empty
In-Reply-To: <20090804145935.e258cd2f.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0908051239150.13195@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031313030.16754@sister.anvils>
 <20090804145935.e258cd2f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ieidus@redhat.com, aarcange@redhat.com, riel@redhat.com, chrisw@redhat.com, nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Aug 2009, Andrew Morton wrote:
> On Mon, 3 Aug 2009 13:14:03 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> 
> > +		if (ksmd_should_run()) {
> >  			schedule_timeout_interruptible(
> >  				msecs_to_jiffies(ksm_thread_sleep_millisecs));
> >  		} else {
> >  			wait_event_interruptible(ksm_thread_wait,
> > -					(ksm_run & KSM_RUN_MERGE) ||
> > -					kthread_should_stop());
> > +				ksmd_should_run() || kthread_should_stop());
> >  		}
> 
> Yields

(Phew, for a moment I thought you were asking us to use yield() here.)

> 
> 
> 		if (ksmd_should_run()) {
> 			schedule_timeout_interruptible(
> 				msecs_to_jiffies(ksm_thread_sleep_millisecs));
> 		} else {
> 			wait_event_interruptible(ksm_thread_wait,
> 				ksmd_should_run() || kthread_should_stop());
> 		}
> 
> can it be something like
> 
> 		wait_event_interruptible_timeout(ksm_thread_wait,
> 			ksmd_should_run() || kthread_should_stop(),
> 			msecs_to_jiffies(ksm_thread_sleep_millisecs));
> 
> ?

I'd be glad to simplify what we have there, but I think your proposal
ends up doing exactly what we're trying to avoid, doesn't it?  Won't
it briefly wake up ksmd every ksm_thread_sleep_millisecs, even when
there's nothing for it to do?

> 
> That would also reduce the latency in responding to kthread_should_stop().

That's not a high priority consideration.  So far as I can tell, the only
use for that test is at startup, if the sysfs_create_group mysteriously
fails.  It's mostly a leftover from when you could have CONFIG_KSM=m:

I did wonder whether to go back and add some SLAB_PANICs etc now,
but in the end I was either too lazy or too deferential to Izik's
fine error handling (you choose which to believe: both, actually).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
