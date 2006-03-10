Date: Thu, 9 Mar 2006 20:46:53 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] hugetlb strict commit accounting - v3
Message-Id: <20060309204653.0f780ba1.akpm@osdl.org>
In-Reply-To: <20060310043737.GG9776@localhost.localdomain>
References: <200603100314.k2A3Evg28313@unix-os.sc.intel.com>
	<20060310043737.GG9776@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: kenneth.w.chen@intel.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"'David Gibson'" <david@gibson.dropbear.id.au> wrote:
>
> On Thu, Mar 09, 2006 at 07:14:58PM -0800, Chen, Kenneth W wrote:
> > hugetlb strict commit accounting for shared mapping - v3
> > 
> > The a region reservation list is implementation as a linked list
> > hanging off address_space i_data->private_list.  It turns out that
> > clear_inode() was also looking at inode->i_data->private_list and
> > if not empty, it think inode has dirty buffers and start clearing.
> > Except it won't go very far before oops-ing.  That could happen if
> > a reservation is made but no actual faulting. hugetlbfs_delete_inode
> > and hugetlbfs_forget_inode doesn't call truncate_hugepages if there
> > are no actual page in the page cache, leading to clear_inode to do
> > bad thing.  Change that to always call truncate_hugepages even if
> > there are no pages in page cache and to let the unreserve code to
> > clear out the reservation linked list.
> 
> Hrm.. overloading the private_list in this manner sounds fragile.
> Maybe we should move the list into the hugetlbfs specific inode data.

private_list and private_lock are available for use by the subsystem which
owns this mapping's address_space_operations.  ie: hugetlbfs.

It's been this way for several years but afaik this is the first time
that's actually been taken advantage of.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
