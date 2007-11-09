Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id lA9HgUfq018390
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 09:42:30 -0800
Received: from rv-out-0910.google.com (rvbg11.prod.google.com [10.140.83.11])
	by zps76.corp.google.com with ESMTP id lA9HgR3N023647
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 09:42:27 -0800
Received: by rv-out-0910.google.com with SMTP id g11so509799rvb
        for <linux-mm@kvack.org>; Fri, 09 Nov 2007 09:42:26 -0800 (PST)
Message-ID: <b040c32a0711090942x45e89356kcc7d3282b2dedcb2@mail.gmail.com>
Date: Fri, 9 Nov 2007 09:42:26 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [patch] hugetlb: fix i_blocks accounting
In-Reply-To: <1194617837.14675.45.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0711082343t2b94b495r1608d99ec0e28a4c@mail.gmail.com>
	 <1194617837.14675.45.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: aglitke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Nov 9, 2007 6:17 AM, aglitke <agl@us.ibm.com> wrote:
> > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > index 770dbed..65371bd 100644
> > --- a/include/linux/hugetlb.h
> > +++ b/include/linux/hugetlb.h
> > @@ -168,6 +168,8 @@ struct file *hugetlb_file_setup(const char *name, size_t);
> >  int hugetlb_get_quota(struct address_space *mapping, long delta);
> >  void hugetlb_put_quota(struct address_space *mapping, long delta);
> >
> > +#define BLOCKS_PER_HUGEPAGE  (HPAGE_SIZE / 512)
>
> Sorry if this is an obvious question, but where does 512 above come
> from?

out of stat(2) man page:

The st_blocks field indicates the number of blocks allocated to the
file,  512-byte
units.   (This  may  be  smaller  than  st_size/512, for example, when
the file has
holes.)

I looked at what other fs do with the i_blocks field (ext2, tmpfs),
they all follow the above convention, regardless what the underlying
fs block size is or arch page size.

> Is this just establishing a new convention that a block is equal
> to 1/512th of whatever size a huge page happens to be?

I'm trying to be consistent with other fs.

> What about on
> ia64 where the hugepage size is set at boot?  Wouldn't that be confusing
> to have the block size change between boots?  What if we just make the
> block size equal to PAGE_SIZE (which is a more stable quantity)?

It shouldn't matter, as there is another field st_blksize which
indicate block size for the filesystem.  i_blocks is just an
accounting on number of blocks allocated and it appears to me that it
was intentionally set to 512 byte unit in the man page (to cut down
confusion?  I have no idea).

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
