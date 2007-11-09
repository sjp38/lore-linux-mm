Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA9I8jqG020990
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 13:08:45 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA9I8jKl128660
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 13:08:45 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA9I8jaM022884
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 13:08:45 -0500
Subject: Re: [patch] hugetlb: fix i_blocks accounting
From: aglitke <agl@us.ibm.com>
In-Reply-To: <b040c32a0711090942x45e89356kcc7d3282b2dedcb2@mail.gmail.com>
References: <b040c32a0711082343t2b94b495r1608d99ec0e28a4c@mail.gmail.com>
	 <1194617837.14675.45.camel@localhost.localdomain>
	 <b040c32a0711090942x45e89356kcc7d3282b2dedcb2@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 09 Nov 2007 12:09:57 -0600
Message-Id: <1194631797.14675.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Thanks for that explanation.  It makes complete sense to me now.

On Fri, 2007-11-09 at 09:42 -0800, Ken Chen wrote:
> On Nov 9, 2007 6:17 AM, aglitke <agl@us.ibm.com> wrote:
> > > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > > index 770dbed..65371bd 100644
> > > --- a/include/linux/hugetlb.h
> > > +++ b/include/linux/hugetlb.h
> > > @@ -168,6 +168,8 @@ struct file *hugetlb_file_setup(const char *name, size_t);
> > >  int hugetlb_get_quota(struct address_space *mapping, long delta);
> > >  void hugetlb_put_quota(struct address_space *mapping, long delta);
> > >
> > > +#define BLOCKS_PER_HUGEPAGE  (HPAGE_SIZE / 512)
> >
> > Sorry if this is an obvious question, but where does 512 above come
> > from?
> 
> out of stat(2) man page:
> 
> The st_blocks field indicates the number of blocks allocated to the
> file,  512-byte
> units.   (This  may  be  smaller  than  st_size/512, for example, when
> the file has
> holes.)
> 
> I looked at what other fs do with the i_blocks field (ext2, tmpfs),
> they all follow the above convention, regardless what the underlying
> fs block size is or arch page size.
> 
> > Is this just establishing a new convention that a block is equal
> > to 1/512th of whatever size a huge page happens to be?
> 
> I'm trying to be consistent with other fs.
> 
> > What about on
> > ia64 where the hugepage size is set at boot?  Wouldn't that be confusing
> > to have the block size change between boots?  What if we just make the
> > block size equal to PAGE_SIZE (which is a more stable quantity)?
> 
> It shouldn't matter, as there is another field st_blksize which
> indicate block size for the filesystem.  i_blocks is just an
> accounting on number of blocks allocated and it appears to me that it
> was intentionally set to 512 byte unit in the man page (to cut down
> confusion?  I have no idea).
> 
> - Ken
> 
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
