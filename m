Date: Wed, 20 Feb 2008 08:30:46 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 22/28] mm: add support for non block device backed swap
 files
Message-Id: <20080220083046.a3ab16d3.randy.dunlap@oracle.com>
In-Reply-To: <20080220150308.142619000@chello.nl>
References: <20080220144610.548202000@chello.nl>
	<20080220150308.142619000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008 15:46:32 +0100 Peter Zijlstra wrote:

> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  Documentation/filesystems/Locking |   19 +++++++++++++
>  Documentation/filesystems/vfs.txt |   17 ++++++++++++
>  include/linux/buffer_head.h       |    2 -
>  include/linux/fs.h                |    8 +++++
>  include/linux/swap.h              |    4 ++
>  mm/page_io.c                      |   52 ++++++++++++++++++++++++++++++++++++++
>  mm/swap_state.c                   |    4 +-
>  mm/swapfile.c                     |   26 ++++++++++++++++++-
>  8 files changed, 128 insertions(+), 4 deletions(-)

> Index: linux-2.6/Documentation/filesystems/Locking
> ===================================================================
> --- linux-2.6.orig/Documentation/filesystems/Locking
> +++ linux-2.6/Documentation/filesystems/Locking

> @@ -291,6 +297,19 @@ cleaned, or an error value if not. Note 
>  getting mapped back in and redirtied, it needs to be kept locked
>  across the entire operation.
>  
> +	->swapfile() will be called with a non zero argument on address spaces

                                           non-zero

> +backing non block device backed swapfiles. A return value of zero indicates
> +success. In which case this address space can be used for backing swapspace.

   success, in which case

> +The swapspace operations will be proxied to the address space operations.
> +Swapoff will call this method with a zero argument to release the address
> +space.
> +
> +	->swap_out() when swapfile() returned success, this method is used to
> +write the swap page.
> +
> +	->swap_in() when swapfile() returned success, this method is used to
> +read the swap page.
> +
>  	Note: currently almost all instances of address_space methods are
>  using BKL for internal serialization and that's one of the worst sources
>  of contention. Normally they are calling library functions (in fs/buffer.c)

> Index: linux-2.6/Documentation/filesystems/vfs.txt
> ===================================================================
> --- linux-2.6.orig/Documentation/filesystems/vfs.txt
> +++ linux-2.6/Documentation/filesystems/vfs.txt
> @@ -728,6 +732,19 @@ struct address_space_operations {
>    	prevent redirtying the page, it is kept locked during the whole
>  	operation.
>  
> +  swapfile: Called with a non-zero argument when swapon is used on a file. A
> +	return value of zero indicates success. In which case this

                                       success, in which case this

> +	address_space can be used to back swapspace. The swapspace operations
> +	will be proxied to this address space's ->swap_{out,in} methods.
> +	Swapoff will call this method with a zero argument to release the
> +	address space.
> +
> +  swap_out: Called to write a swapcache page to a backing store, similar to
> +	writepage.
> +
> +  swap_in: Called to read a swapcache page from a backing store, similar to
> +	readpage.
> +
>  The File Object
>  ===============

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
