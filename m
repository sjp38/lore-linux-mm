Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3P0p3iS028446
	for <linux-mm@kvack.org>; Tue, 24 Apr 2007 20:51:03 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3P0p2Sv182490
	for <linux-mm@kvack.org>; Tue, 24 Apr 2007 18:51:02 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3P0p2ua014721
	for <linux-mm@kvack.org>; Tue, 24 Apr 2007 18:51:02 -0600
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <20070424155151.644e88b7.akpm@linux-foundation.org>
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>
	 <1177453661.1281.1.camel@dyn9047017100.beaverton.ibm.com>
	 <20070424155151.644e88b7.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 24 Apr 2007 17:51:27 -0700
Message-Id: <1177462288.1281.11.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-04-24 at 15:51 -0700, Andrew Morton wrote:
> Andy, I'm looking at the power4 build:
> 
> http://test.kernel.org/abat/84751/debug/test.log.0
> 
> which has
> 
>   LD      init/built-in.o
>   LD      .tmp_vmlinux1
> init/built-in.o(.init.text+0x32e4): In function `.rd_load_image':
> : undefined reference to `.__kmalloc_size_too_large'
> fs/built-in.o(.text+0xa60f0): In function `.ext3_fill_super':
> : undefined reference to `.__kmalloc_size_too_large'
> fs/built-in.o(.text+0xbe934): In function `.ext2_fill_super':
> : undefined reference to `.__kmalloc_size_too_large'
> fs/built-in.o(.text+0xf3370): In function `.nfs4_proc_lookup':
> 
> something has gone stupid with kmalloc there, and I cannot reproduce it
> with my compiler and with your (very old) .config at
> http://ftp.kernel.org/pub/linux/kernel/people/mbligh/config/abat/power4
> 
> So I'm a bit stumped.  Does autotest just do `yes "" | make oldconfig' or
> what?  When I do that, I get SLUB, but no compile errors.
> 
> And do you know what compiler version is being used there?

include/linux/slub_def.h:

static inline struct kmem_cache *kmalloc_slab(size_t size)
{
        int index = kmalloc_index(size);

        if (index == 0)
                return NULL;

        if (index < 0) {
                /*
                 * Generate a link failure. Would be great if we could
                 * do something to stop the compile here.
                 */
                extern void __kmalloc_size_too_large(void);
                __kmalloc_size_too_large();
        }
        return &kmalloc_caches[index];
}

hmm.. 

gcc version 3.3.3 -- generates those link failures
gcc version 4.1.0 -- doesn't generate this error

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
