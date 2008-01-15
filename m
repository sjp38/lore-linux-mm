Date: Tue, 15 Jan 2008 10:16:19 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] mmu notifiers
In-Reply-To: <478CF609.3090304@qumranet.com>
Message-ID: <Pine.LNX.4.64.0801151011380.10265@schroedinger.engr.sgi.com>
References: <20080109181908.GS6958@v2.random>
 <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com>
 <47860512.3040607@qumranet.com> <Pine.LNX.4.64.0801101103470.20353@schroedinger.engr.sgi.com>
 <47891A5C.8060907@qumranet.com> <Pine.LNX.4.64.0801141148540.8300@schroedinger.engr.sgi.com>
 <478C62F8.2070702@qumranet.com> <Pine.LNX.4.64.0801150938260.9893@schroedinger.engr.sgi.com>
 <478CF30F.1010100@qumranet.com> <Pine.LNX.4.64.0801150956040.10089@schroedinger.engr.sgi.com>
 <478CF609.3090304@qumranet.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>, Andrea Arcangeli <andrea@qumranet.com>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jan 2008, Avi Kivity wrote:

> > But each guest has its own page structs. They cannot share page structs.
> > Concurrent access of two independent kernel instances for synchronization
> > and status maintenance to a single page struct?
> >   
> 
> There's a host page struct (that the guest know nothing about and cannot
> touch), and optionally a guest page struct for each guest (that the host and
> the other guest know nothing about).

Ok so if two linux guests want to share memory three page structs are 
involved:

1. Host page struct
2. Guest #1 page struct
3. Guest #2 page struct

I can understand that 1 and 2 point to the same physical page. Even all 
three could point to the same page if the page is readonly. 

However, lets say that Guest #1 allocates some anonymous memory and wants
to share it with Guest #2. In that case something like PFNMAP is likely
going to be used? Or are you remapping the physical page so that #1 and #2 
share it? In that case two page struct describe state of the same physical
page and we have no effective synchronization for writeback etc.

> The host page struct may disappear if the host decides to swap the page into
> its backing store and free the page.  The guest page structs (if any) would
> remain.

Page structs never disappear. The pte's may disappear and the page may be 
unmapped from an address space of a process but the page struct stays. 
Page struct can only disappear if memory hotplug is activated and memory 
is taken out of the system.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
