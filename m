Date: Thu, 26 Jul 2001 07:04:39 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Consistent page aging....
In-Reply-To: <m1itghgfpj.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.21.0107260701290.3707-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 25 Jul 2001, Eric W. Biederman wrote:

> Marcelo Tosatti <marcelo@conectiva.com.br> writes:
> 
> > On 25 Jul 2001, Eric W. Biederman wrote:
> > 
> > > Marcelo Tosatti <marcelo@conectiva.com.br> writes:
> > > 
> > > > Sorry, Eric.
> > > >
> > > > The biggest 2.4 swapping bug is that we need to allocate swap space for a
> > > > page to be able to age it. 
> > > 
> > > Well I guess biggest bug is a debatable title.  
> > > 
> > > > We had to be able to age pages without allocating swap space...
> > > 
> > > That sounds reasonable.  I haven't been over the aging code lately it
> > > keeps changing.  You say this hasn't been fixed?  Looking... O.k. I
> > > see what you are talking about.  
> > > 
> > > I don't see any technical reasons why we can't do this.  Doing it
> > > without adding many extra special cases would require some thinking
> > > but nothing fundamental says you can't have anonymous pages in the
> > > active list. 
> > 
> > Right.
> 
> Let me clarify just a pinch.  I meant anonymous pages that have yet to
> become swap cache pages.
>  
> > > You can't move mapped pages off of the active list but this holds true
> > > anyway.
> > > 
> > > The only benefit this would bring is that after anonymous pages have
> > > been converted to swappable pages they wouldn't start at the end of
> > > the active_list.
> > 
> > Right now we have to allocate space on swap for any page which we want to
> > add to the active list. (so we are able to age the anon pages as other
> > cache pages)
> > 
> > > I can see how this would be helpful, but unless you benchmark this
> > > I don't see how this can as the biggest 2.4 swapping bug.
> > 
> > Its the "2xRAM swap rule" problem.
> 
> I have trouble believing that.  We have nearly the same behavior
> in 2.2.  The only intentional difference in 2.4 versus 2.2 is that 
> 2.2 removed pages from the swap cache when they become dirty, and 2.4
> reuses the swap space.  This difference prompted Linus's message.
> 
> The "2xRAM swap rule problem", is a problem where a user uses 2.4 and
> notices that they need more swap.  Since there has been publicity
> that 2.4 needs more swap when swapping heavily, peoply commmonly to
> jump to the conclusion that it is a known problem, and simply
> complain.   That is the "2xRAM swap rule problem".
> 
> Given that a number of "2xRAM swap rule problem" reports tracked back
> to having something like 90% of ram in dead swap cache pages, I know
> that was one of the problems people complained about.  The classic
> symptoms were:  a) swapoff locked up the system b) A large program was
> started and filled most of swap.  The program ended.  The program
> was restarted, and couldn't run because all of ram was now in dead
> swap cache pages.
> 
> As far as actually requiring swap = 2xRAM the combination of keeping
> pages in the swap cache after they are dirtied, and allocating the
> swap space a little early achieves this, seems to achieve this
> property, I admit.  Until I seem problem reports tracked back to this
> I don't consider this at the top of my canidate list for the "2xRAM
> swap rule problem".
> 
> > IMO having to allocate swap space to be able to do _aging_ on anonymous
> > pages is just nonsense.
> 
> Be very clear on this because I sense some confusion.  We don't
> ``require'' allocation of swap space to do aging. 

Right now, we have to make anon pages become swap cache pages (which need
swap space allocated) to be able to age them in the LRU lists.

Sure, we do aging before by just scanning the pte's and the process of
adding a page to the swapcache is already some kind of aging. 

I'm talking about the aging in the LRU lists here. 

There is no confusion. Its the way 2.4 VM works. 

See? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
