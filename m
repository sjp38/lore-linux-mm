Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 8B5C26B0005
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 16:51:39 -0500 (EST)
Message-ID: <510AE763.6090907@zytor.com>
Date: Thu, 31 Jan 2013 13:51:31 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] rip out x86_32 NUMA remapping code
References: <20130131005616.1C79F411@kernel.stglabs.ibm.com>
In-Reply-To: <20130131005616.1C79F411@kernel.stglabs.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/30/2013 04:56 PM, Dave Hansen wrote:
> This code was an optimization for 32-bit NUMA systems.
> 
> It has probably been the cause of a number of subtle bugs over
> the years, although the conditions to excite them would have
> been hard to trigger.  Essentially, we remap part of the kernel
> linear mapping area, and then sometimes part of that area gets
> freed back in to the bootmem allocator.  If those pages get
> used by kernel data structures (say mem_map[] or a dentry),
> there's no big deal.  But, if anyone ever tried to use the
> linear mapping for these pages _and_ cared about their physical
> address, bad things happen.
> 
> For instance, say you passed __GFP_ZERO to the page allocator
> and then happened to get handed one of these pages, it zero the
> remapped page, but it would make a pte to the _old_ page.
> There are probably a hundred other ways that it could screw
> with things.
> 
> We don't need to hang on to performance optimizations for
> these old boxes any more.  All my 32-bit NUMA systems are long
> dead and buried, and I probably had access to more than most
> people.
> 
> This code is causing real things to break today:
> 
> 	https://lkml.org/lkml/2013/1/9/376
> 
> I looked in to actually fixing this, but it requires surgery
> to way too much brittle code, as well as stuff like
> per_cpu_ptr_to_phys().
> 

I get a build failure on i386 allyesconfig with this patch:

arch/x86/power/built-in.o: In function `swsusp_arch_resume':
(.text+0x14e4): undefined reference to `resume_map_numa_kva'

It looks trivial to fix up; I assume resume_map_numa_kva() just goes
away like it does in the non-NUMA case, but it would be nice if you
could confirm that.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
