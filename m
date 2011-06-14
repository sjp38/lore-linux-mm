Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6FCF76B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 04:52:08 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id p5E8jYXn016021
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 18:45:34 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5E8osxL1061010
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 18:50:55 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5E8pi4Q013924
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 18:51:44 +1000
Date: Tue, 14 Jun 2011 14:21:37 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110614085137.GA7614@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <20110610165529.GC2230@linux.vnet.ibm.com>
 <20110610170535.GC25774@srcf.ucam.org>
 <20110610171939.GE2230@linux.vnet.ibm.com>
 <20110610172307.GA27630@srcf.ucam.org>
 <20110610175248.GF2230@linux.vnet.ibm.com>
 <20110610180807.GB28500@srcf.ucam.org>
 <20110610184738.GG2230@linux.vnet.ibm.com>
 <20110610192329.GA30496@srcf.ucam.org>
 <20110610193713.GJ2230@linux.vnet.ibm.com>
 <20110610200233.5ddd5a31@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110610200233.5ddd5a31@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: paulmck@linux.vnet.ibm.com, Matthew Garrett <mjg59@srcf.ucam.org>, Kyungmin Park <kmpark@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

Hi,

On Fri, Jun 10, 2011 at 08:02:33PM -0700, Arjan van de Ven wrote:
> On Fri, 10 Jun 2011 12:37:13 -0700
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
> > On Fri, Jun 10, 2011 at 08:23:29PM +0100, Matthew Garrett wrote:
> > > On Fri, Jun 10, 2011 at 11:47:38AM -0700, Paul E. McKenney wrote:
> > > 
> > > > And if I understand you correctly, then the patches that Ankita
> > > > posted should help your self-refresh case, along with the
> > > > originally intended the power-down case and special-purpose use
> > > > of memory case.
> > > 
> > > Yeah, I'd hope so once we actually have capable hardware.
> > 
> > Cool!!!
> > 
> > So Ankita's patchset might be useful to you at some point, then.
> > 
> > Does it look like a reasonable implementation?
> 
> as someone who is working on hardware that is PASR capable right now,
> I have to admit that our plan was to just hook into the buddy allocator,
> and use PASR on the top level of buddy (eg PASR off blocks that are
> free there, and PASR them back on once an allocation required the block
> to be broken up)..... that looked the very most simple to me.
>

We were looking at a generic approach to exploit the different types of
memory power management features present in the hardware, like PASR,
power off and automatic transition into lower power states. To actively
create opportunities to exploit these features, appropriately guiding
memory allocations/deallocations, reclaim and statistics gathering is
essential. A few usecases are -

- allocating all memory from one region before moving over to the next
  region would theoretically ensure that the second region could be kept
  into lower power state for a longer period or turned off
- regions could be created consisting of only movable memory, thus
  making it possible to evacuate an entire region
- when memory utilization is low, selected memory regions could be
  removed as target for allocation itself. These regions need not be
  only turned off to save power, if the hardware supports, these regions
  could be put into content preserving lower power state if they are not
  being referenced
- depending upon the memory utilization of the different regions,
  targeted reclaim and memory migration could be triggered in a few
  regions with the aim of freeing memory

Grouping memory at the level of the buddy allocator for this purpose
might be tougher. 

> Maybe something much more elaborate is needed, but I didn't see why so
> far.
> 
> 

-- 
Regards,
Ankita Garg (ankita@in.ibm.com)
Linux Technology Center
IBM India Systems & Technology Labs,
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
