Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1946B0255
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:12:08 -0500 (EST)
Received: by wmuu63 with SMTP id u63so191496524wmu.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:12:08 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id lh10si5806200wjc.81.2015.12.08.10.12.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 10:12:07 -0800 (PST)
Date: Tue, 8 Dec 2015 19:11:18 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 17/34] x86, pkeys: check VMAs and PTEs for protection
 keys
In-Reply-To: <20151204011448.23DC574D@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081911000.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011448.23DC574D@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Thu, 3 Dec 2015, Dave Hansen wrote:
> Today, for normal faults and page table walks, we check the VMA
> and/or PTE to ensure that it is compatible with the action.  For
> instance, if we get a write fault on a non-writeable VMA, we
> SIGSEGV.
> 
> We try to do the same thing for protection keys.  Basically, we
> try to make sure that if a user does this:
> 
> 	mprotect(ptr, size, PROT_NONE);
> 	*ptr = foo;
> 
> they see the same effects with protection keys when they do this:
> 
> 	mprotect(ptr, size, PROT_READ|PROT_WRITE);
> 	set_pkey(ptr, size, 4);
> 	wrpkru(0xffffff3f); // access disable pkey 4
> 	*ptr = foo;
> 
> The state to do that checking is in the VMA, but we also
> sometimes have to do it on the page tables only, like when doing
> a get_user_pages_fast() where we have no VMA.
> 
> We add two functions and expose them to generic code:
> 
> 	arch_pte_access_permitted(pte_flags, write)
> 	arch_vma_access_permitted(vma, write)
> 
> These are, of course, backed up in x86 arch code with checks
> against the PTE or VMA's protection key.
> 
> But, there are also cases where we do not want to respect
> protection keys.  When we ptrace(), for instance, we do not want
> to apply the tracer's PKRU permissions to the PTEs from the
> process being traced.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
