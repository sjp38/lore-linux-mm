Date: Mon, 16 Feb 2004 21:38:26 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] mremap NULL pointer dereference fix
In-Reply-To: <Pine.SOL.4.44.0402162331580.20215-100000@blue.engin.umich.edu>
Message-ID: <Pine.LNX.4.58.0402162127220.30742@home.osdl.org>
References: <Pine.SOL.4.44.0402162331580.20215-100000@blue.engin.umich.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajesh Venkatasubramanian <vrajesh@umich.edu>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 16 Feb 2004, Rajesh Venkatasubramanian wrote:
> 
> This path fixes a NULL pointer dereference bug in mremap. In
> move_one_page we need to re-check the src because an allocation
> for the dst page table can drop page_table_lock, and somebody
> else can invalidate the src.

Ugly, but yes. The "!page_table_present(mm, new_addr))" code just before
the "alloc_one_pte_map()" should already have done this, but while the 
page tables themselves are safe due to us holding the mm semaphore, the 
pte entry itself at "src" is not.

I hate that code, and your patch makes it even uglier. This code could do 
with a real clean-up, but for now I think your patch will do.

Thanks,

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
