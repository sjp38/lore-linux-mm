Date: Wed, 03 Dec 2003 11:41:01 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: memory hotremove prototype, take 3
Message-ID: <187360000.1070480461@flay>
In-Reply-To: <20031201034155.11B387007A@sv1.valinux.co.jp>
References: <20031201034155.11B387007A@sv1.valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> this is a new version of my memory hotplug prototype patch, against
> linux-2.6.0-test11.
> 
> Freeing 100% of a specified memory zone is non-trivial and necessary
> for memory hot removal.  This patch splits memory into 1GB zones, and
> implements complete zone memory freeing using kswapd or "remapping".
> 
> A bit more detailed explanation and some test scripts are at:
> 	http://people.valinux.co.jp/~iwamoto/mh.html
> 
> Main changes against previous versions are:
> - The stability is greatly improved.  Kernel crashes (probably related
>   with kswapd) still happen, but they are rather rare so that I'm
>   having difficulty reproducing crashes.
>   Page remapping under simultaneous tar + rm -rf works.
> - Implemented a solution to a deadlock caused by ext2_rename, which
>   increments a refcount of a directory page twice.
> 
> Questions and comments are welcome.

I really think that doing this over zones and pgdats isn't the best approach.
You're going to make memory allocation and reclaim vastly less efficient,
and you're exposing a bunch of very specialised code inside the main
memory paths. 

Have you looked at Daniel's CONFIG_NONLINEAR stuff? That provides a much
cleaner abstraction for getting rid of discontiguous memory in the non
truly-NUMA case, and should work really well for doing mem hot add / remove
as well.

M.

PS. What's this bit of the patch for?

 void *vmalloc(unsigned long size)
 {
+#ifdef CONFIG_MEMHOTPLUGTEST
+       return __vmalloc(size, GFP_KERNEL, PAGE_KERNEL);
+#else
        return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL);
+#endif
 }
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
