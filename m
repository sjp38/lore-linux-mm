Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 980D56B0036
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 15:11:32 -0500 (EST)
Received: by mail-qc0-f182.google.com with SMTP id e16so1916005qcx.27
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 12:11:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id b3si3311741qab.77.2013.12.13.12.11.29
        for <linux-mm@kvack.org>;
        Fri, 13 Dec 2013 12:11:30 -0800 (PST)
Date: Fri, 13 Dec 2013 15:11:13 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386965473-eiomxx6m-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386964742-df8sz3d6-mutt-n-horiguchi@ah.jp.nec.com>
References: <20131212222527.GD8605@mcs.anl.gov>
 <1386964742-df8sz3d6-mutt-n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/memory-failure.c: send action optional signal to an
 arbitrary thread
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamil Iskra <iskra@mcs.anl.gov>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>

On Fri, Dec 13, 2013 at 02:59:02PM -0500, Naoya Horiguchi wrote:
> Hi Kamil,
> 
> # Cced: Andi
> 
> On Thu, Dec 12, 2013 at 04:25:27PM -0600, Kamil Iskra wrote:
> > Please find below a trivial patch that changes the sending of BUS_MCEERR_AO
> > SIGBUS signals so that they can be handled by an arbitrary thread of the
> > target process.  The current implementation makes it impossible to create a
> > separate, dedicated thread to handle such errors, as the signal is always
> > sent to the main thread.
> 
> This can be done in application side by letting the main thread create a
> dedicated thread for error handling, or by waking up existing/sleeping one.
> It might not be optimal in overhead, but note that an action optional error
> does not require to be handled ASAP.

> And we need only one process to handle
> an action optional error, so no need to send SIGBUS(BUS_MCEERR_AO) for every
> processes/threads.

Sorry, let me correct the above: "We need only one thread (not one process)
to handle an action optional error."

Thanks,
Naoya

> 
> > Also, do I understand it correctly that "action required" faults *must* be
> > handled by the thread that triggered the error?  I guess it makes sense for
> > it to be that way, even if it circumvents the "dedicated handling thread"
> > idea...
> 
> Yes. Unlike action optional errors, action required faults can happen on
> all processes/threads which map the error affected page, so in memory error
> aware applications every thread must be able to handle SIGBUS(BUS_MCEERR_AR)
> or just be killed.
> 
> > The patch is against the 3.12.4 kernel.
> > 
> > --- mm/memory-failure.c.orig	2013-12-08 10:18:58.000000000 -0600
> > +++ mm/memory-failure.c	2013-12-12 11:43:03.973334767 -0600
> > @@ -219,7 +219,7 @@ static int kill_proc(struct task_struct
> >  		 * to SIG_IGN, but hopefully no one will do that?
> >  		 */
> >  		si.si_code = BUS_MCEERR_AO;
> > -		ret = send_sig_info(SIGBUS, &si, t);  /* synchronous? */
> > +		ret = group_send_sig_info(SIGBUS, &si, t);  /* synchronous? */
> 
> Personally, I don't think we need this change for the above mentioned reason.
> And another concern is if this change can affect/break existing applications.
> If it can, maybe you need to add (for example) a prctl attribute to show that
> the process expects kernel to send SIGBUS(BUS_MCEERR_AO) only to the main
> thread, or to all threads belonging to the process.
> 
> Thanks,
> Naoya Horiguchi
> 
> >  	}
> >  	if (ret < 0)
> >  		printk(KERN_INFO "MCE: Error sending signal to %s:%d: %d\n",
> > 
> > Thanks,
> > 
> > Kamil
> > 
> > -- 
> > Kamil Iskra, PhD
> > Argonne National Laboratory, Mathematics and Computer Science Division
> > 9700 South Cass Avenue, Building 240, Argonne, IL 60439, USA
> > phone: +1-630-252-7197  fax: +1-630-252-5986
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
