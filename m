Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <akpm@digeo.com>) (for <helgehaf@aitel.hist.no>)
	(for <linux-kernel@vger.kernel.org>) (for <linux-mm@kvack.org>) By
	tone With Smtp ; Sun, 16 Mar 2003 07:43:03 +1100
From: Neil Brown <neilb@cse.unsw.edu.au>
Date: Sun, 16 Mar 2003 07:42:34 +1100
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15987.36922.848433.245061@notabene.cse.unsw.edu.au>
Subject: Re: 2.5.64-mm7 - dies on smp with raid
In-Reply-To: message from Andrew Morton on Saturday March 15
References: <20030315011758.7098b006.akpm@digeo.com>
	<3E736505.2000106@aitel.hist.no>
	<20030315120343.71faf732.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Helge Hafting <helgehaf@aitel.hist.no>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday March 15, akpm@digeo.com wrote:
> 
> A lot of md updates went into Linus's tree overnight.  Can you get some more
> details for Neil?
> 
> Here is a wild guess:
> 
> diff -puN drivers/md/md.c~a drivers/md/md.c
> --- 25/drivers/md/md.c~a	2003-03-15 12:02:04.000000000 -0800
> +++ 25-akpm/drivers/md/md.c	2003-03-15 12:02:14.000000000 -0800
> @@ -2818,6 +2818,8 @@ int md_thread(void * arg)
>  
>  void md_wakeup_thread(mdk_thread_t *thread)
>  {
> +	if (!thread)
> +		return;
>  	dprintk("md: waking up MD thread %p.\n", thread);
>  	set_bit(THREAD_WAKEUP, &thread->flags);
>  	wake_up(&thread->wqueue);
> 

Looks like a good guess to me.

I hadn't considered raid0/linear properly in that last change suite.
They don't have a thread so there is nothing to wake up.

There are two places where the wrong thing will happen:
  do_md_run where it also calls md_update_sb which doesn't
    hurt but isn't really needed (there is never any point
    updating the superblock metadata for raid0/linear).
  restart_array where we switch back to read/write and wakeup
    the thread to see if there is anything to do.

We either need this "if(!thread)" test inside md_wakeup_thread
or at those two call sites, in which case we can avoid md_update_sb
as well.

I send one to Linus later...

Thanks,
NeilBrown
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
