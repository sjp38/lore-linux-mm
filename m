Date: Thu, 8 Nov 2007 15:25:47 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Some interesting observations when trying to optimize vmstat
 handling
In-Reply-To: <200711090007.43424.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0711081522040.11074@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711081141180.9694@schroedinger.engr.sgi.com>
 <200711090007.43424.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Nov 2007, Andi Kleen wrote:

> 
> > There is an interrupt enable overhead of 48 cycles that would be good to
> > be able to eliminate (Kernel code usually moves counter increments into
> > a neighboring interrupt disable section so that __ function can be used).
> 
> Replace the push flags ; popf  with test $IFMASK,flags ; jz 1f; sti ; 1:
> That will likely make it much faster (but also bigger) 

Well maybe we should change local_irq_save/restore in general?

The result would be:


if (!in_interrupt())
	local_irq_disable()

<critical section>

if (!in_interrupt())
	local_irq_enable();



Somehow we need to remember that we disabled interrupts.

Then it get more complicated.


int interrupts_disabled = 0;

if (!in_interrupt()) {
	local_irq_disable():
	interrrupts_disabled = 1;
}

<critical section>

if (interrupts_disabled)
	local_irq_enable();



Not sure that this actually better.


> The only problem is that there might be some code who relies on 
> restore_flags() restoring other flags that IF, but at least for interrupts
> and local_irq_save/restore it should be fine to change.

The statistics code surely does not rely on that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
