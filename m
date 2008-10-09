Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m99DbKKm029488
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 09:37:20 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m99DbKi0150154
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 09:37:20 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m99DbItk011844
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 09:37:20 -0400
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081009131701.GA21112@elte.hu>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
	 <20081009124658.GE2952@elte.hu> <1223557122.11830.14.camel@nimitz>
	 <20081009131701.GA21112@elte.hu>
Content-Type: text/plain
Date: Thu, 09 Oct 2008 06:34:06 -0700
Message-Id: <1223559246.11830.23.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Oren Laadan <orenl@cs.columbia.edu>, jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-10-09 at 15:17 +0200, Ingo Molnar wrote:
> * Dave Hansen <dave@linux.vnet.ibm.com> wrote
> > On Thu, 2008-10-09 at 14:46 +0200, Ingo Molnar wrote:
> > > i'm wondering about the following productization aspect: it would be 
> > > very useful to applications and users if they knew whether it is safe to 
> > > checkpoint a given app. I.e. whether that app has any state that cannot 
> > > be stored/restored yet.
> > 
> > Absolutely!
> > 
> > My first inclination was to do this at checkpoint time: detect and 
> > tell users why an app or container can't actually be checkpointed.  
> > But, if I get you right, you're talking about something that happens 
> > more during the runtime of the app than during the checkpoint.  This 
> > sounds like a wonderful approach to me, and much better than what I 
> > was thinking of.
> > 
> > What kind of mechanism do you have in mind?
> > 
> > int sys_remap_file_pages(...)
> > {
> >       ...
> >       oh_crap_we_dont_support_this_yet(current);
> > }
> > 
> > Then the oh_crap..() function sets a task flag or something?
> 
> yeah, something like that. A key aspect of it is that is has to be very 
> low-key on the source code level - we dont want to sprinkle the kernel 
> with anything ugly. Perhaps something pretty explicit:
> 
>   current->flags |= PF_NOCR;

Am I miscounting, or are we out of these suckers on 32-bit platforms?

> as we do the same thing today for certain facilities:
> 
>   current->flags |= PF_NOFREEZE;
> 
> you probably want to hide it behind:
> 
>   set_current_nocr();

Yeah, that all looks reasonable.  Letting this be a dynamic thing where
you can move back and forth between the two states would make a lot of
sense too.  But, for now, I guess it can be a one-way trip.

I'll cook something up real fast.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
