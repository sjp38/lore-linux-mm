Date: Mon, 25 Sep 2000 09:22:17 -0600
From: yodaiken@fsmlabs.com
Subject: Re: the new VM
Message-ID: <20000925092217.A11078@hq.fsmlabs.com>
References: <20000925172412.A25814@athlon.random> <Pine.LNX.4.21.0009251724530.9122-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0009251724530.9122-100000@elte.hu>; from Ingo Molnar on Mon, Sep 25, 2000 at 05:26:59PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 05:26:59PM +0200, Ingo Molnar wrote:
> 
> On Mon, 25 Sep 2000, Andrea Arcangeli wrote:
> 
> > > i think the GFP_USER case should do the oom logic within __alloc_pages(),
> > 
> > What's the difference of implementing the logic outside alloc_pages?
> > Putting the logic inside looks not clean design to me.
> 
> it gives consistency and simplicity. The allocators themselves do not have
> to care about oom.


There are many cases where it is simple to do:
        
          if( alloc(r1) == fail) goto freeall
          if( alloc(r2) == fail) goto freeall
          if( alloc(r3) == fail) goto freeall

And the alloc functions don't know how to "freeall".

Perhaps it would be good to do an alloc_vec allocation in these cases.
      alloc_vec[0].size = n;
      ..
      alloc_vec[n].size = 0;
      if(kmalloc_all(alloc_vec) == FAIL) return -ENOMEM;
      else  alloc_vec[i].ptr is the pointer.




-- 
---------------------------------------------------------
Victor Yodaiken 
Finite State Machine Labs: The RTLinux Company.
 www.fsmlabs.com  www.rtlinux.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
