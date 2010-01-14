Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8418F6B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 03:01:23 -0500 (EST)
Date: Thu, 14 Jan 2010 10:01:17 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v5] add MAP_UNLOCKED mmap flag
Message-ID: <20100114080117.GL18808@redhat.com>
References: <20100114155229.6735.A69D9226@jp.fujitsu.com>
 <20100114072210.GK18808@redhat.com>
 <20100114162327.673E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100114162327.673E.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 14, 2010 at 04:30:51PM +0900, KOSAKI Motohiro wrote:
> > On Thu, Jan 14, 2010 at 04:02:42PM +0900, KOSAKI Motohiro wrote:
> > > > On Thu, Jan 14, 2010 at 09:31:03AM +0900, KOSAKI Motohiro wrote:
> > > > > > If application does mlockall(MCL_FUTURE) it is no longer possible to mmap
> > > > > > file bigger than main memory or allocate big area of anonymous memory
> > > > > > in a thread safe manner. Sometimes it is desirable to lock everything
> > > > > > related to program execution into memory, but still be able to mmap
> > > > > > big file or allocate huge amount of memory and allow OS to swap them on
> > > > > > demand. MAP_UNLOCKED allows to do that.
> > > > > >  
> > > > > > Signed-off-by: Gleb Natapov <gleb@redhat.com>
> > > > > > ---
> > > > > > 
> > > > > > I get reports that people find this useful, so resending.
> > > > > 
> > > > > This description is still wrong. It doesn't describe why this patch is useful.
> > > > > 
> > > > I think the text above describes the feature it adds and its use
> > > > case quite well. Can you elaborate what is missing in your opinion,
> > > > or suggest alternative text please?
> > > 
> > > My point is, introducing mmap new flags need strong and clearly use-case.
> > > All patch should have good benefit/cost balance. the code can describe the cost,
> > > but the benefit can be only explained by the patch description.
> > > 
> > > I don't think this poor description explained bit benefit rather than cost.
> > > you should explain why this patch is useful and not just pretty toy.
> > > 
> > The benefit is that with this patch I can lock all of my application in
> > memory except some very big memory areas. My use case is that I want to
> > run virtual machine in such a way that everything related to machine
> > emulator is locked into the memory, but guest address space can be
> > swapped out at will. Guest address space is so huge that it is not
> > possible to allocated it locked and then unlock. I was very surprised
> > that current Linux API has no way to do it hence this patch. It may look
> > like a pretty toy to you until some day you need this and has no way to
> > do it.
> 
> Hmm..
> Your answer didn't match I wanted.
Then I don't get what you want.

> few additional questions.
> 
> - Why don't you change your application? It seems natural way than kernel change.
There is no way to change my application and achieve what I've described
in a multithreaded app.

> - Why do you want your virtual machine have mlockall? AFAIK, current majority
>   virtual machine doesn't.
It is absolutely irrelevant for that patch, but just because you ask I
want to measure the cost of swapping out of a guest memory.

> - If this feature added, average distro user can get any benefit?
> 
?! Is this some kind of new measure? There are plenty of much more
invasive features that don't bring benefits to an average distro user.
This feature can bring benefit to embedded/RT developers.

> I mean, many application developrs want to add their specific feature
> into kernel. but if we allow it unlimitedly, major syscall become
> the trushbox of pretty toy feature soon.
> 
And if application developer wants to extend kernel in a way that it
will be possible to do something that was not possible before why is
this a bad thing? I would agree with you if for my problem was userspace
solution, but there is none. The mmap interface is asymmetric in regards
to mlock currently. There is MAP_LOCKED, but no MAP_UNLOCKED. Why
MAP_LOCKED is useful then?


--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
