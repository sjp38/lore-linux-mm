Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D06FF6B0093
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 17:31:04 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1HMTnq5026128
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 15:29:49 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1HMUs9U082298
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 15:30:56 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1HMUrpP005661
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 15:30:54 -0700
Subject: Re: What can OpenVZ do?
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090217222319.GA10546@elte.hu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	 <1234285547.30155.6.camel@nimitz>
	 <20090211141434.dfa1d079.akpm@linux-foundation.org>
	 <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx>
	 <20090212114207.e1c2de82.akpm@linux-foundation.org>
	 <1234475483.30155.194.camel@nimitz>
	 <20090212141014.2cd3d54d.akpm@linux-foundation.org>
	 <20090213105302.GC4608@elte.hu> <1234817490.30155.287.camel@nimitz>
	 <20090217222319.GA10546@elte.hu>
Content-Type: text/plain
Date: Tue, 17 Feb 2009 14:30:49 -0800
Message-Id: <1234909849.4816.9.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mpm@selenic.com, tglx@linutronix.de, torvalds@linux-foundation.org, xemul@openvz.org, Nathan Lynch <nathanl@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-02-17 at 23:23 +0100, Ingo Molnar wrote:
> * Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> > On Fri, 2009-02-13 at 11:53 +0100, Ingo Molnar wrote:
> > > In any case, by designing checkpointing to reuse the existing LSM
> > > callbacks, we'd hit multiple birds with the same stone. (One of
> > > which is the constant complaints about the runtime costs of the LSM
> > > callbacks - with checkpointing we get an independent, non-security
> > > user of the facility which is a nice touch.)
> > 
> > There's a fundamental problem with using LSM that I'm seeing 
> > now that I look at using it for file descriptors.  The LSM 
> > hooks are there to say, "No, you can't do this" and abort 
> > whatever kernel operation was going on.  That's good for 
> > detecting when we do something that's "bad" for checkpointing.
> > 
> > *But* it completely falls on its face when we want to find out 
> > when we are doing things that are *good*.  For instance, let's 
> > say that we open a network socket.  The LSM hook sees it and 
> > marks us as uncheckpointable.  What about when we close it?  
> > We've become checkpointable again.  But, there's no LSM hook 
> > for the close side because we don't currently have a need for 
> > it.
> 
> Uncheckpointable should be a one-way flag anyway. We want this 
> to become usable, so uncheckpointable functionality should be as 
> painful as possible, to make sure it's getting fixed ...

Again, as these patches stand, we don't support checkpointing when
non-simple files are opened.  Basically, if a open()/lseek() pair won't
get you back where you were, we don't deal with them.

init does non-checkpointable things.  If the flag is a one-way trip,
we'll never be able to checkpoint because we'll always inherit init's !
checkpointable flag.  

To fix this, we could start working on making sure we can checkpoint
init, but that's practically worthless.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
