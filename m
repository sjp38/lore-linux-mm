Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 61DF06B0055
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 22:02:06 -0500 (EST)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1S2xiVJ027370
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 21:59:44 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n1S324F12613374
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 22:02:04 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1S324x5021362
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 22:02:04 -0500
Date: Fri, 27 Feb 2009 19:02:00 -0800
From: Gary Hade <garyhade@us.ibm.com>
Subject: Re: [PATCH] mm: get_nid_for_pfn() returns int
Message-ID: <20090228030200.GA7342@us.ibm.com>
References: <4973AEEC.70504@gmail.com> <20090119175919.GA7476@us.ibm.com> <20090126223350.610b0283.akpm@linux-foundation.org> <20090127210727.GA9592@us.ibm.com> <25e057c00902270656x1781d04er5703058e47df455f@mail.gmail.com> <20090227213340.GB7174@us.ibm.com> <20090227134616.982fb73a.akpm@linux-foundation.org> <20090228001400.GC7174@us.ibm.com> <20090227162249.bcd0813a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090227162249.bcd0813a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gary Hade <garyhade@us.ibm.com>, roel.kluin@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, Feb 27, 2009 at 04:22:49PM -0800, Andrew Morton wrote:
> On Fri, 27 Feb 2009 16:14:00 -0800
> Gary Hade <garyhade@us.ibm.com> wrote:
> 
> > On Fri, Feb 27, 2009 at 01:46:16PM -0800, Andrew Morton wrote:
> >
> > > > It is still lingering in -mm:
> > > > http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-get_nid_for_pfn-returns-int.patch
> > > > 
> > > 
> > > Should it unlinger?  I have it in the 2.6.30 pile.
> > 
> > Yes, that would be good. :)
> 
> What would be good?  Your answer is ambiguous.

Sorry, I was just trying to agree that your plan to wait
until 2.6.30 works for me.  Unless someone else objects
leave it in your 2.6.30 pile.

> 
> > > Does it actually fix a demonstrable bug?  
> > 
> > I am not aware of anyone that has actually reproduced the
> > problem.
> 
> What problem?

During a memory remove operation there is a chance on 
yet to be discovered system(s) that a mem section symlink
for a removed memory section could incorrectly persist.
Earlier in this thread I described the possible problem
as follows.
===
On Mon, Jan 26, 2009 at 10:33:50PM -0800, Andrew Morton wrote:
            ...
> Presumably the (nid < 0) case has never happened.

We do know that it is happening on one system while creating
a symlink for a memory section so it should also happen on
the same system if unregister_mem_sect_under_nodes() were
called to remove the same symlink.

The test was actually added in response to a problem with an
earlier version reported by Yasunori Goto where one or more
of the leading pages of a memory section on the 2nd node of
one of his systems was uninitialized because I believe they
coincided with a memory hole.  The earlier version did not
ignore uninitialized pages and determined the nid by considering
only the 1st page of each memory section.  This caused the
symlink to the 1st memory section on the 2nd node to be
incorrectly created in /sys/devices/system/node/node0 instead
of /sys/devices/system/node/node1.  The problem was fixed by
adding the test to skip over uninitialized pages.

I suspect we have not seen any reports of the non-removal
of a symlink due to the incorrect declaration of the nid
variable in unregister_mem_sect_under_nodes() because
  - systems where a memory section could have an uninitialized
    range of leading pages are probably rare.
  - memory remove is probably not done very frequently on the
    systems that are capable of demonstrating the problem.
  - lingering symlink(s) that should have been removed may
    have simply gone unnoticed.
===

> 
> All I gave at present is
> 
>   From: Roel Kluin <roel.kluin@gmail.com>
> 
>   get_nid_for_pfn() returns int
> 
>   Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>   Cc: Gary Hade <garyhade@us.ibm.com>
> 
> >  I do not believe that we have any systems where 
> > it can be reproduced since it would require both
> >   (1) a memory section with an uninitialized range of
> >       pages and
> >   (2) a memory remove event for that memory section.
> > As far as I know, none of our systems have (1).  Yasunori Goto
> > has a system with (1) but I am not sure if he can do (2).
> 
> Please send a new changelog for this patch.

Can you include the above words? 

> 
> If you believe this patch should be merged into 2.6.29 then please
> explain why.

2.6.30 is fine with me.

> Please also consider whether it should be backported into
> 2.6.28.x and eariler.

The "mm: show node to memory section relationship with symlinks
in sysfs" code that it improves was not introduced until 2.6.29-rc1.

Thanks,
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
