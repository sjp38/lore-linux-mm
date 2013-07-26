Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 988A66B0031
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 11:16:34 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rcj@linux.vnet.ibm.com>;
	Fri, 26 Jul 2013 20:39:33 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 0DC93E0058
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 20:46:29 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6QFGKxp44302540
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 20:46:21 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6QFGMV4014848
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 15:16:23 GMT
Date: Fri, 26 Jul 2013 10:16:21 -0500
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/2] vmsplice unmap gifted pages for recipient
Message-ID: <20130726151621.GA5037@linux.vnet.ibm.com>
References: <1374772906-21511-1-git-send-email-rcj@linux.vnet.ibm.com>
 <1374772906-21511-2-git-send-email-rcj@linux.vnet.ibm.com>
 <51F160A5.2040004@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F160A5.2040004@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <aliguori@us.ibm.com>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>

* Dave Hansen (dave@sr71.net) wrote:
> On 07/25/2013 10:21 AM, Robert Jennings wrote:
> > +static void zap_buf_page(unsigned long useraddr)
> > +{
> > +	struct vm_area_struct *vma;
> > +
> > +	down_read(&current->mm->mmap_sem);
> > +	vma = find_vma_intersection(current->mm, useraddr,
> > +			useraddr + PAGE_SIZE);
> > +	if (!IS_ERR_OR_NULL(vma))
> > +		zap_page_range(vma, useraddr, PAGE_SIZE, NULL);
> > +	up_read(&current->mm->mmap_sem);
> > +}
> > +
> >  /**
> >   * splice_to_pipe - fill passed data into a pipe
> >   * @pipe:	pipe to fill
> > @@ -212,8 +224,16 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
> >  			buf->len = spd->partial[page_nr].len;
> >  			buf->private = spd->partial[page_nr].private;
> >  			buf->ops = spd->ops;
> > -			if (spd->flags & SPLICE_F_GIFT)
> > +			if (spd->flags & SPLICE_F_GIFT) {
> > +				unsigned long useraddr =
> > +						spd->partial[page_nr].useraddr;
> > +
> > +				if ((spd->flags & SPLICE_F_MOVE) &&
> > +				    !buf->offset && (buf->len == PAGE_SIZE))
> > +					/* Can move page aligned buf */
> > +					zap_buf_page(useraddr);
> >  				buf->flags |= PIPE_BUF_FLAG_GIFT;
> > +			}
> 
> There isn't quite enough context here, but is it going to do this
> zap_buf_page() very often?  Seems a bit wasteful to do the up/down and
> find_vma() every trip through the loop.

The call to zap_buf_page() is in a loop where each pipe buffer is being
processed, but in that loop we have a pipe_wait() where we schedule().
So as things are structured I don't have the ability to hold mmap_sem
for multiple find_vma() calls.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
