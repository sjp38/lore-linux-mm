Message-ID: <3807B5BA.151F676B@colorfullife.com>
Date: Sat, 16 Oct 1999 01:16:10 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kanoj-mm17-2.3.21 kswapd vma scanning protection
References: <Pine.LNX.4.10.9910151417360.852-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, sct@redhat.com, andrea@suse.de, viro@math.psu.edu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
>         .. hold a spinlock - we can probably just reuse the
>            page_table_lock for this to avoid multiple levels of locking
>            here..
> 
>         file = fget(vma->vm_file);
		^^^^^^^
>         offset = file->f_offset + (address - vma->vm_start);
>         flush_tlb_page(vma, address);
>         spin_unlock(&vma->vm_mm->page_table_lock);
> 
>         error = file->f_ops->swapout(file, offset, page);
>         fput(file);
> 
>         ...
> 
> and then the other requirement would be that whenever the vma chain is
> physically modified, you also have to hold the page_table_lock.
> 

What about shm? vma->vm_file is NULL, this would oops.
I think that both "prepare for possible vma removal" and the parameters
which are passed to ->swapout() should be vma-specific: what about a
vm_ops->swapprepare()? This function should not allocate memory, ie
parameter passing should be stack based:

<<<<< mm.h
struct private_data
{
	void* private[4];
};
struct vm_ops
{
...
void (*swapprepare)(struct vm_area_struct * vma, struct page * page,
struct private_data * info);
void (*swapout)(struct private_data * info, struct page* page);
...
};
>>>>>>>>>
<<<<<<<< vmscan.c

if(vma->vm_ops && vma->vm_ops->swapout) {
	int error;
	struct private_data info;
	void (*swapout)(...);

	pte_clear(page_table);
	swapout = vma->vm_ops->swapout;
	vma->vm_ops->swapprepare(vma,page,&info);
	spin_unlock(page_table_lock);
	flush_tlb_page();
	error = swapout(&info,page);
	...
}
>>>>>>>>>>>>>>>>


--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
