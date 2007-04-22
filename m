Date: Sun, 22 Apr 2007 10:16:58 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
Message-ID: <20070422091658.GB1558@infradead.org>
References: <46247427.6000902@redhat.com> <20070422011810.e76685cc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070422011810.e76685cc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "David S. Miller" <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 22, 2007 at 01:18:10AM -0700, Andrew Morton wrote:
> On Tue, 17 Apr 2007 03:15:51 -0400 Rik van Riel <riel@redhat.com> wrote:
> 
> > Make it possible for applications to have the kernel free memory
> > lazily.  This reduces a repeated free/malloc cycle from freeing
> > pages and allocating them, to just marking them freeable.  If the
> > application wants to reuse them before the kernel needs the memory,
> > not even a page fault will happen.
> > 
> > This patch, together with Ulrich's glibc change, increases
> > MySQL sysbench performance by a factor of 2 on my quad core
> > test system.
> > 
> 
> In file included from include/linux/mman.h:4,
>                  from arch/sparc64/kernel/sys_sparc.c:19:
> include/asm/mman.h:36:1: "MADV_FREE" redefined
> In file included from include/asm/mman.h:5,
>                  from include/linux/mman.h:4,
>                  from arch/sparc64/kernel/sys_sparc.c:19:
> include/asm-generic/mman.h:32:1: this is the location of the previous definition
> 
> sparc32 and sparc64 already defined MADV_FREE:
> 
> 
> #define MADV_FREE       0x5             /* (Solaris) contents can be freed */
> 
> I'll remove the sparc definitions for now, but we need to work out what
> we're going to do here.  Your patch changes the values of MADV_FREE on
> sparc.
> 
> Perhaps this should be renamed to MADV_FREE_LINUX and given a different
> number.  It depends on how close your proposed behaviour is to Solaris's.

Why isn't MADV_FREE defined to 5 for linux?  It's our first free madv
value?  Also the behaviour should better match the one in solaris or BSD,
the last thing we need is slightly different behaviour from operating
systems supporting this for ages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
