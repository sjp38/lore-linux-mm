Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8B03F6B003D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 19:14:05 -0500 (EST)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1S0Bdki016360
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 19:11:39 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n1S0E3RJ185962
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 19:14:03 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1S0ClJQ026837
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 19:12:48 -0500
Date: Fri, 27 Feb 2009 16:14:00 -0800
From: Gary Hade <garyhade@us.ibm.com>
Subject: Re: [PATCH] mm: get_nid_for_pfn() returns int
Message-ID: <20090228001400.GC7174@us.ibm.com>
References: <4973AEEC.70504@gmail.com> <20090119175919.GA7476@us.ibm.com> <20090126223350.610b0283.akpm@linux-foundation.org> <20090127210727.GA9592@us.ibm.com> <25e057c00902270656x1781d04er5703058e47df455f@mail.gmail.com> <20090227213340.GB7174@us.ibm.com> <20090227134616.982fb73a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090227134616.982fb73a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gary Hade <garyhade@us.ibm.com>, roel.kluin@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, Feb 27, 2009 at 01:46:16PM -0800, Andrew Morton wrote:
> On Fri, 27 Feb 2009 13:33:40 -0800
> Gary Hade <garyhade@us.ibm.com> wrote:
> 
> > On Fri, Feb 27, 2009 at 03:56:40PM +0100, roel kluin wrote:
> > > >> > > get_nid_for_pfn() returns int
> > > 
> > > >> > My mistake. __Good catch.
> > > 
> > > >> Presumably the (nid < 0) case has never happened.
> > > >
> > > > We do know that it is happening on one system while creating
> > > > a symlink for a memory section so it should also happen on
> > > > the same system if unregister_mem_sect_under_nodes() were
> > > > called to remove the same symlink.
> > > >
> > > > The test was actually added in response to a problem with an
> > > > earlier version reported by Yasunori Goto where one or more
> > > > of the leading pages of a memory section on the 2nd node of
> > > > one of his systems was uninitialized because I believe they
> > > > coincided with a memory hole. __The earlier version did not
> > > > ignore uninitialized pages and determined the nid by considering
> > > > only the 1st page of each memory section. __This caused the
> > > > symlink to the 1st memory section on the 2nd node to be
> > > > incorrectly created in /sys/devices/system/node/node0 instead
> > > > of /sys/devices/system/node/node1. __The problem was fixed by
> > > > adding the test to skip over uninitialized pages.
> > > >
> > > > I suspect we have not seen any reports of the non-removal
> > > > of a symlink due to the incorrect declaration of the nid
> > > > variable in unregister_mem_sect_under_nodes() because
> > > > __- systems where a memory section could have an uninitialized
> > > > __ __range of leading pages are probably rare.
> > > > __- memory remove is probably not done very frequently on the
> > > > __ __systems that are capable of demonstrating the problem.
> > > > __- lingering symlink(s) that should have been removed may
> > > > __ __have simply gone unnoticed.
> > > >>
> > > >> Should we retain the test?
> > > >
> > > > Yes.
> > > >
> > > >>
> > > >> Is silently skipping the node in that case desirable behaviour?
> > > >
> > > > It actually silently skips pages (not nodes) in it's quest
> > > > for valid nids for all the nodes that the memory section scans.
> > > > This is definitely desirable.
> > > >
> > > > I hope this answers your questions.
> > > 
> > > This still isn't applied, was it lost?
> > 
> > It is still lingering in -mm:
> > http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-get_nid_for_pfn-returns-int.patch
> > 
> 
> Should it unlinger?  I have it in the 2.6.30 pile.

Yes, that would be good. :)

> Does it actually fix a demonstrable bug?  

I am not aware of anyone that has actually reproduced the
problem.  I do not believe that we have any systems where 
it can be reproduced since it would require both
  (1) a memory section with an uninitialized range of
      pages and
  (2) a memory remove event for that memory section.
As far as I know, none of our systems have (1).  Yasunori Goto
has a system with (1) but I am not sure if he can do (2).

Gary

-- 
Gary Hade
System x Enablement
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
