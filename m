Message-Id: <200105151339.f4FDdcD09937@cwsys.cwsent.com>
Reply-to: Cy Schubert - ITSD Open Systems Group
	  <Cy.Schubert@uumail.gov.bc.ca>
From: Cy Schubert - ITSD Open Systems Group
        <Cy.Schubert@uumail.gov.bc.ca>
Subject: Re: on load control / process swapping 
In-reply-to: Your message of "Mon, 14 May 2001 23:38:07 PDT."
             <3B00CECF.9A3DEEFA@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Tue, 15 May 2001 06:39:06 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: tlambert2@mindspring.com
Cc: Rik van Riel <riel@conectiva.com.br>, Matt Dillon <dillon@earth.backplane.com>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

In message <3B00CECF.9A3DEEFA@mindspring.com>, Terry Lambert writes:
> Rik van Riel wrote:
> > So we should not allow just one single large job to take all
> > of memory, but we should allow some small jobs in memory too.
> 
> Historically, this problem is solved with a "working set
> quota".
> 
> > If you don't do this very slow swapping, NONE of the big tasks
> > will have the opportunity to make decent progress and the system
> > will never get out of thrashing.
> > 
> > If we simply make the "swap time slices" for larger processes
> > larger than for smaller processes we:
> > 
> > 1) have a better chance of the large jobs getting any work done
> > 2) won't have the large jobs artificially increase memory load,
> >    because all time will be spent removing each other's RSS
> > 3) can have more small jobs in memory at once, due to 2)
> > 4) can be better for interactive performance due to 3)
> > 5) have a better chance of getting out of the overload situation
> >    sooner
> > 
> > I realise this would make the scheduling algorithm slightly
> > more complex and I'm not convinced doing this would be worth
> > it myself, but we may want to do some brainstorming over this ;)
> 
> A per vnode working set quota with a per use count adjust
> would resolve most load thrashing issues.  Programs with
> large working sets can either be granted a case by case
> exception (via rlimit), or, more likely just have their
> pages thrashed out more often.
> 
> You only ever need to do this when you have exhausted
> memory to the point you are swapping, and then only when
> you want to reap cached clean pages; when all you have
> left is dirty pages in memory and swap, you are well and
> truly thrashing -- for the right reason: your system load
> is too high.

An operating system I worked on at one time, MVS, had this feature (not 
sure whether it still does today).  We called it fencing (e.g. fencing 
an address space).  An address space could be limited to the amount of 
real memory used.  Conversely, important address spaces could be given 
a minimum amount of real memory, e.g. online applications such a CICS.  
Additionally instead of limiting an address space to a minimum or 
maximum amount of real memory, an address space could be limited to a 
maximum paging rate, giving the O/S the option of increasing its real 
memory to match its WSS, reducing paging of the specified address space 
to a preset limit.  Of course this could have negative impact on other 
applications running on the system, which is why IBM recommended 
against using this feature.



Regards,                         Phone:  (250)387-8437
Cy Schubert                        Fax:  (250)387-5766
Team Leader, Sun/Alpha Team   Internet:  Cy.Schubert@osg.gov.bc.ca
Open Systems Group, ITSD, ISTA
Province of BC



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
