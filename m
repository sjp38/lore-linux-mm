Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m9BIExQ6012760
	for <linux-mm@kvack.org>; Sun, 12 Oct 2008 05:14:59 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9BIEkKm4690152
	for <linux-mm@kvack.org>; Sun, 12 Oct 2008 05:14:51 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9BIEkuI026571
	for <linux-mm@kvack.org>; Sun, 12 Oct 2008 05:14:46 +1100
Date: Sat, 11 Oct 2008 23:44:26 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH updated] ext4: Fix file fragmentation during large file
	write.
Message-ID: <20081011181426.GB9662@skywalker>
References: <1223661776-20098-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20081011105152.GB29681@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081011105152.GB29681@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: cmm@us.ibm.com, tytso@mit.edu, sandeen@redhat.com, chris.mason@oracle.com, akpm@linux-foundation.org, hch@infradead.org, steve@chygwyn.com, mpatocka@redhat.com, linux-mm@kvack.org, inux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Oct 11, 2008 at 12:51:52PM +0200, Nick Piggin wrote:
> On Fri, Oct 10, 2008 at 11:32:56PM +0530, Aneesh Kumar K.V wrote:
> > The range_cyclic writeback mode use the address_space
> > writeback_index as the start index for writeback. With
> > delayed allocation we were updating writeback_index
> > wrongly resulting in highly fragmented file. Number of
> > extents reduced from 4000 to 27 for a 3GB file with
> > the below patch.
> > 
> > The patch also removes the range_cont writeback mode
> > added for ext4 delayed allocation. Instead we add
> > two new flags in writeback_control which control
> > the behaviour of write_cache_pages.
> 
> The mm/page-writeback.c changes look OK, although it loks like you've
> got rid of range_cont? Should we do a patch to get rid of it entirely
> from the tree first?
> 
> I don't mind rediffing my patchset on top of this, but this seems smaller
> and not strictly a bugfix so I would prefer to go the other way if you
> agree.
> 
> Seems like it could be broken up into several patches (eg. pagevec_lookup).
> 
> The results look very nice.

I actually tried to do that. But to do that and also achieve a working
bisect kernel, I will have to do the patches in below way

a) Introduce ext4_write_cache_pages
b) remove range_cont from write_cache_pages
c) Introduce the new flags to writeback_control
d) switch ext4 to use write_cache_pages.

I thought that involved lot of code which are later getting removed.
So i went for a single patch.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
