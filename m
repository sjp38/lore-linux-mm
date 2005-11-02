Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA2F2WCP008777
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 10:02:32 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jA2F3Z1K525098
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 08:03:35 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jA2F2UDJ020333
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 08:02:31 -0700
Reply-To: Gerrit Huizenga <gh@us.ibm.com>
From: Gerrit Huizenga <gh@us.ibm.com>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19 
In-reply-to: Your message of Wed, 02 Nov 2005 13:00:48 +0100.
             <20051102120048.GA10081@elte.hu>
Date: Wed, 02 Nov 2005 07:02:23 -0800
Message-Id: <E1EXK87-0008JB-00@w-gerrit.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 02 Nov 2005 13:00:48 +0100, Ingo Molnar wrote:
> 
> * Gerrit Huizenga <gh@us.ibm.com> wrote:
> 
> > 
> > On Wed, 02 Nov 2005 11:41:31 +0100, Ingo Molnar wrote:
> > > 
> > > * Gerrit Huizenga <gh@us.ibm.com> wrote:
> > > 
> > > > > generic unpluggable kernel RAM _will not work_.
> > > > 
> > > > Actually, it will.  Well, depending on terminology.
> > > 
> > > 'generic unpluggable kernel RAM' means what it says: any RAM seen by the 
> > > kernel can be unplugged, always. (as long as the unplug request is 
> > > reasonable and there is enough free space to migrate in-use pages to).
> >  
> >  Okay, I understand your terminology.  Yes, I can not point to any
> >  particular piece of memory and say "I want *that* one" and have that
> >  request succeed.  However, I can say "find me 50 chunks of memory
> >  of your choosing" and have a very good chance of finding enough
> >  memory to satisfy my request.
> 
> but that's obviously not 'generic unpluggable kernel RAM'. It's very 
> special RAM: RAM that is free or easily freeable. I never argued that 
> such RAM is not returnable to the hypervisor.
 
 Okay - and 'generic unpluggable kernel RAM' has not been a goal for
 the hypervisor based environments.  I believe it is closer to being
 a goal for those machines which want to hot-remove DIMMs or physical
 memory, e.g. those with IA64 machines wishing to remove entire nodes.

> > > reliable unmapping of "generic kernel RAM" is not possible even in a 
> > > virtualized environment. Think of the 'live pointers' problem i outlined 
> > > in an earlier mail in this thread today.
> > 
> >  Yeah - and that isn't what is being proposed here.  The goal is to 
> >  ask the kernel to identify some memory which can be legitimately 
> >  freed and hasten the freeing of that memory.
> 
> but that's very easy to identify: check the free list or the clean 
> list(s). No defragmentation necessary. [unless the unit of RAM mapping 
> between hypervisor and guest is too coarse (i.e. not 4K pages).]

 Ah, but the hypervisor often manages large page sizes, e.g. 64 MB.
 It doesn't manage page rights for each guest OS at the 4 K granularity.
 Hypervisors are theoretically light in terms of memory needs and
 general footprint.  Picture the overhead of tracking rights/permissions
 of each page of memory and its assignment to any of, say, 256 different
 guest operating systems.  For a machine of any size, that would be
 a huge amount of state for a hypervisor to maintain.  Would you
 really want a hypervisor to keep that much state?  Or is it more
 reasonably for a hypervisor to track, say, 64 MB chunks and the
 rights of that memory for a number of guest operating systems?  Even
 if the number of guests is small, the data structures for fast
 memory management would grow quickly.

gerrit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
