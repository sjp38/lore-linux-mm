Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CFC1D6B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 05:39:03 -0400 (EDT)
Date: Wed, 19 Aug 2009 10:39:05 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: HTLB mapping for drivers. Driver example
Message-ID: <20090819093905.GD24809@csn.ul.ie>
References: <alpine.LFD.2.00.0908172346460.32114@casper.infradead.org> <20090818083024.GB31469@csn.ul.ie> <202cde0e0908190201p4c2e2701xf18bdecbc53df905@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <202cde0e0908190201p4c2e2701xf18bdecbc53df905@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 19, 2009 at 09:01:17PM +1200, Alexey Korolev wrote:
> > This seems a lot of burden to put on a device driver, particularly with
> > respect to the reservations.
> 
> Thanks a lot for review you did. That is right.  I don't like this
> burden as well.
> >
> >> File operations of /dev/hpage_map do the following:
> >>
> >> In file open we  associate mappings of /dev/xxx with the file on hugetlbfs (like it is done in ipc/shm.c)
> >>       file->f_mapping = h_file->f_mapping;
> >>
> >> In get_unmapped_area we should tell about addressing constraints in case of huge pages by calling hugetlbfs procedures. (as in ipc/shm.c)
> >>       return get_unmapped_area(h_file, addr, len, pgoff, flags);
> >>
> >> We need to let hugetlbfs do architecture specific operations with mapping in mmap call. This driver does not reserve any memory for private mappings
> >> so driver requests reservation from hugetlbfs. (Actually driver can do this as well but it will make it more complex)
> >>
> >> The exit procedure:
> >> * removes memory from page cache
> >> * deletes file on hugetlbfs vfs mount
> >> *  free pages
> >>
> >> Application example is not shown here but it is very simple. It does the following: open file /dev/hpage_map, mmap a region, read/write memory, unmap file, close file.
> >>
> >
> > For the use-model you have in mind, could you look at Eric Munson's patches
> > and determine if the target application would have been happy to call the
> > following please?
> >
> > mmap(0, len, prot, MAP_ANONYMOUS|MAP_HUGETLB, 0, 0)
> >
> Hmm. But how can I at least identify which driver this call is addressed to?
> 

The example you gave was for /dev/hpage_map so in this specific case, it
would have appeared that the application didn't want hugepages belonging to
a particular driver, but huge pages in general. Furthermore, your example
driver was not populating the hugepages with data so in this case, calling
mmap(MAP_ANONYMOUS|MAP_HUGETLB) would have been sufficient. If all the data
in your target application is populated from userspace, it's worth considering
instead of a different driver.

However, lets assume you have a driver that provides the data from
somewher. The implementation for MAP_HUGETLB is basically a call to a
hugetlbfs_file_setup()-like function that is very straight-forward. It
creates a hugetlbfs file and ensures that the reservations are there which
is important and tricky to get right.

Would it be possible for your driver to do

On file open
	Create hugetlbfs-backed-file using helper similar to Eric's
		or maybe even Eric's helper for MAP_HUGETLB
	Copy get_unmapped_area handle from hugetlbfs-file so mappings
		are properly placed on mmap()

On file mmap
	Use a new helper to get a reference to each page within the
		file and populate it with driver-specific data. You
		would need a new patch for this helper because it
		doesn't exist.
	Call h_file->f_op->mmap(h_file, vma)

On file fault
	The data is already in the page cache so the normal hugetlbfs
		handlers should do the job

On file close
	Drop the hugetlbfs inode

Using the helper for getting a reference to a hugetlbfs-file, your driver
would no longer be responsible for placing the mapping, handling reservations
or handling page cache manipulations.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
