Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B52A36B0044
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 16:07:37 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n0RL5w8Y003756
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 14:05:58 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0RL7W3g029034
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 14:07:33 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n0RL7UcD021534
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 14:07:31 -0700
Date: Tue, 27 Jan 2009 13:07:27 -0800
From: Gary Hade <garyhade@us.ibm.com>
Subject: Re: [PATCH] mm: get_nid_for_pfn() returns int
Message-ID: <20090127210727.GA9592@us.ibm.com>
References: <4973AEEC.70504@gmail.com> <20090119175919.GA7476@us.ibm.com> <20090126223350.610b0283.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090126223350.610b0283.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gary Hade <garyhade@us.ibm.com>, Roel Kluin <roel.kluin@gmail.com>, Ingo Molnar <mingo@elte.hu>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, Jan 26, 2009 at 10:33:50PM -0800, Andrew Morton wrote:
> On Mon, 19 Jan 2009 09:59:19 -0800 Gary Hade <garyhade@us.ibm.com> wrote:
> 
> > On Sun, Jan 18, 2009 at 11:36:28PM +0100, Roel Kluin wrote:
> > > get_nid_for_pfn() returns int
> > > 
> > > Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> > > ---
> > > vi drivers/base/node.c +256
> > > static int get_nid_for_pfn(unsigned long pfn)
> > > 
> > > diff --git a/drivers/base/node.c b/drivers/base/node.c
> > > index 43fa90b..f8f578a 100644
> > > --- a/drivers/base/node.c
> > > +++ b/drivers/base/node.c
> > > @@ -303,7 +303,7 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
> > >  	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
> > >  	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
> > >  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> > > -		unsigned int nid;
> > > +		int nid;
> > > 
> > >  		nid = get_nid_for_pfn(pfn);
> > >  		if (nid < 0)
> > 
> > My mistake.  Good catch.
> > 
> 
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
> 
> Should we retain the test?

Yes.

> 
> Is silently skipping the node in that case desirable behaviour?

It actually silently skips pages (not nodes) in it's quest
for valid nids for all the nodes that the memory section scans.
This is definitely desirable.

I hope this answers your questions.

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
