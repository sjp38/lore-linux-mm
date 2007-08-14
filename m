Date: Tue, 14 Aug 2007 13:42:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 4/9] Atomic reclaim: Save irq flags in vmscan.c
In-Reply-To: <20070814203329.GA22202@one.firstfloor.org>
Message-ID: <Pine.LNX.4.64.0708141341120.31513@schroedinger.engr.sgi.com>
References: <20070814153021.446917377@sgi.com> <20070814153501.766137366@sgi.com>
 <p73vebhnauo.fsf@bingen.suse.de> <Pine.LNX.4.64.0708141209270.29498@schroedinger.engr.sgi.com>
 <20070814203329.GA22202@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Aug 2007, Andi Kleen wrote:

> > There are other lock interactions that may cause problems. If we do not 
> > switch to the saving of irq flags then all involved spinlocks must become 
> > trylocks because the interrupt could have happened while the spinlock is 
> > held. So interrupts must be disabled on locks acquired during an 
> > interrupt.
> 
> I was thinking of a per cpu flag that is set before and unset after
> taking the lock in process context. If the flag is set the interrupt
> will never try to take the spinlock and return NULL instead. 
> That should be equivalent to cli/sti for this special case.

Hmmmm... The spinlock is its own flag. If the lock is taken then the flag 
is set. So if we check all relevant spinlocks before going into reclaim 
then we could return NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
