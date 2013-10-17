Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 482026B0073
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 10:05:06 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so2792555pab.26
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 07:05:05 -0700 (PDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rcj@linux.vnet.ibm.com>;
	Fri, 18 Oct 2013 00:04:59 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 232692BB0040
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 01:03:36 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9HDbVgR27787408
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 00:38:39 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9HDsHAn029569
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 00:54:18 +1100
Date: Thu, 17 Oct 2013 08:54:17 -0500
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] vmsplice: unmap gifted pages for recipient
Message-ID: <20131017135417.GC19741@linux.vnet.ibm.com>
References: <1381177293-27125-1-git-send-email-rcj@linux.vnet.ibm.com>
 <1381177293-27125-2-git-send-email-rcj@linux.vnet.ibm.com>
 <52543185.3060705@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52543185.3060705@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <anthony@codemonkey.ws>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

* Dave Hansen (dave@sr71.net) wrote:
> On 10/07/2013 01:21 PM, Robert C Jennings wrote:
> >  		spd.partial[page_nr].offset = loff;
> >  		spd.partial[page_nr].len = this_len;
> > +		spd.partial[page_nr].useraddr = index << PAGE_CACHE_SHIFT;
> >  		len -= this_len;
> >  		loff = 0;
> >  		spd.nr_pages++;
> > @@ -656,6 +702,7 @@ ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
> >  		this_len = min_t(size_t, vec[i].iov_len, res);
> >  		spd.partial[i].offset = 0;
> >  		spd.partial[i].len = this_len;
> > +		spd.partial[i].useraddr = (unsigned long)vec[i].iov_base;
> >  		if (!this_len) {
> >  			__free_page(spd.pages[i]);
> >  			spd.pages[i] = NULL;
> > @@ -1475,6 +1522,8 @@ static int get_iovec_page_array(const struct iovec __user *iov,
> >  
> >  			partial[buffers].offset = off;
> >  			partial[buffers].len = plen;
> > +			partial[buffers].useraddr = (unsigned long)base;
> > +			base = (void*)((unsigned long)base + PAGE_SIZE);
> >  
> >  			off = 0;
> >  			len -= plen;
> > diff --git a/include/linux/splice.h b/include/linux/splice.h
> > index 74575cb..56661e3 100644
> > --- a/include/linux/splice.h
> > +++ b/include/linux/splice.h
> > @@ -44,6 +44,7 @@ struct partial_page {
> >  	unsigned int offset;
> >  	unsigned int len;
> >  	unsigned long private;
> > +	unsigned long useraddr;
> >  };
> 
> "useraddr" confuses me.  You make it an 'unsigned long', yet two of the
> three assignments are from "void __user *".  The other assignment:
> 
> 	spd.partial[page_nr].useraddr = index << PAGE_CACHE_SHIFT;
> 
> 'index' looks to be the offset inside the file, not a user address, so
> I'm confused what that is doing.
> 
> Could you elaborate a little more on why 'useraddr' is suddenly needed
> in these patches?  How is "index << PAGE_CACHE_SHIFT" a virtual address?
>  Also, are we losing any of the advantages of sparse checking since
> 'useraddr' is without the __user annotation?
> 

I'm working on cleaning this up.  Trying to remove useraddr altogher
through the use of the existing 'private' field just for the
splice_to_user/pipe_to_user flow without upsetting other uses of the
private field.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
