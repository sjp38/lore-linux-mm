Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 031986B005D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 16:49:09 -0500 (EST)
Date: Tue, 11 Dec 2012 16:48:59 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [RFC PATCH 0/8] remove vm_struct list management
Message-ID: <20121211214859.GG5580@redhat.com>
References: <1354810175-4338-1-git-send-email-js1304@gmail.com>
 <20121206145020.93fd7128.akpm@linux-foundation.org>
 <CAAmzW4N-=uXBdgjbkdL=aNVtKvvXZs-6BNgpDzi7CLkeo0-jBg@mail.gmail.com>
 <20121207145909.GA4928@redhat.com>
 <CAAmzW4NHO=y=utmK_at+JxvyYMd4O_7W_6n541GEA0aeDfukyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4NHO=y=utmK_at+JxvyYMd4O_7W_6n541GEA0aeDfukyw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russell King <rmk+kernel@arm.linux.org.uk>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Anderson <anderson@redhat.com>, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>

On Mon, Dec 10, 2012 at 11:40:47PM +0900, JoonSoo Kim wrote:

[..]
> > So without knowing details of both the data structures, I think if vmlist
> > is going away, then user space tools should be able to traverse vmap_area_root
> > rb tree. I am assuming it is sorted using ->addr field and we should be
> > able to get vmalloc area start from there. It will just be a matter of
> > exporting right fields to user space (instead of vmlist).
> 
> There is address sorted list of vmap_area, vmap_area_list.
> So we can use it for traversing vmalloc areas if it is necessary.
> But, as I mentioned before, kexec write *just* address of vmlist and
> offset of vm_struct's address field.
> It imply that they don't traverse vmlist,
> because they didn't write vm_struct's next field which is needed for traversing.
> Without vm_struct's next field, they have no method for traversing.
> So, IMHO, assigning dummy vm_struct to vmlist which is implemented by [7/8] is
> a safe way to maintain a compatibility of userspace tool. :)

Actually the design of "makedumpfile" and "crash" tool is that they know
about kernel data structures and they adopt to changes. So for major
changes they keep track of kernel version numbers and if access the
data structures accordingly.

Currently we access first element of vmlist to determine start of vmalloc
address. True we don't have to traverse the list.

But as you mentioned we should be able to get same information by
traversing to left most element of vmap_area_list rb tree. So I think
instead of trying to retain vmlist first element just for backward
compatibility, I will rather prefer get rid of that code completely
from kernel and let user space tool traverse rbtree. Just export
minimum needed info for traversal in user space.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
