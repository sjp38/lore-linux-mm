Date: Wed, 29 Sep 2004 00:03:25 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: get_user_pages() still broken in 2.6
Message-ID: <20040929000325.A6758@infradead.org>
References: <4159E85A.6080806@ammasso.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4159E85A.6080806@ammasso.com>; from timur.tabi@ammasso.com on Tue, Sep 28, 2004 at 05:40:26PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <timur.tabi@ammasso.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 28, 2004 at 05:40:26PM -0500, Timur Tabi wrote:
> I was hoping that this bug would be fixed in the 2.6 kernels, but 
> apparently it hasn't been.
> 
> Function get_user_pages() is supposed to lock user memory.  However, 
> under extreme memory constraints, the kernel will swap out the "locked" 
> memory.
> 
> I have a test app which does this:
> 
> 1) Calls our driver, which issues a get_user_pages() call for one page.
> 2) Calls our driver again to get the physical address of that page (the 
> driver uses pgd/pmd/pte_offset).
> 3) Tries allocate 1GB of memory (this system has 1GB of physical RAM).
> 4) Tries to get the physical address again.
> 
> In step 4, the physical address is usually zero, which means either 
> pgd_offset or pmd_offset failed.  This indicates the page was swapped out.
> 
> I don't understand how this bug can continue to exist after all this 
> time.  get_user_pages() is supposed to lock the memory, because drivers 
> use it for DMA'ing directly into user memory.

get_user_pages locks the page in memory.  It doesn't do anything about ptes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
