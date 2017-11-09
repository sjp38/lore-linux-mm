Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFC416B0335
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 17:19:38 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b9so4351162wmh.5
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 14:19:38 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id y16si6311997wmc.264.2017.11.09.14.19.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 14:19:37 -0800 (PST)
Date: Thu, 9 Nov 2017 23:19:31 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 04/30] x86, kaiser: disable global pages by default with
 KAISER
In-Reply-To: <20171108194653.D6C7EFF4@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1711092250280.2690@nanos>
References: <20171108194646.907A1942@viggo.jf.intel.com> <20171108194653.D6C7EFF4@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Wed, 8 Nov 2017, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Global pages stay in the TLB across context switches.  Since all
> contexts share the same kernel mapping, we use global pages to
> allow kernel entries in the TLB to survive when we context
> switch.
> 
> But, even having these entries in the TLB opens up something that
> an attacker can use [1].
> 
> Disable global pages so that kernel TLB entries are flushed when
> we run userspace. This way, all accesses to kernel memory result
> in a TLB miss whether there is good data there or not.  Without
> this, even when KAISER switches pages tables, the kernel entries
> might remain in the TLB.
> 
> We keep _PAGE_GLOBAL available so that we can use it for things
> that are global even with KAISER like the entry/exit code and
> data.

Just a nitpick which applies to a lot of the changelogs in this
series. Describing ourself (we) running/doing something is (understandable)
but not a really technical way to describe things. Aside of that some of
the descriptions are slightly convoluted. Let me rephrase the above
paragraphs:

 Global pages stay in the TLB across context switches.  Since all contexts
 share the same kernel mapping, these mappings are marked as global pages
 so kernel entries in the TLB are not flushed out on a context switch.
 
 But, even having these entries in the TLB opens up something that an
 attacker can use [1].

 That means that even when KAISER switches page tables on return to user
 space the global pages would stay in the TLB cache.

 Disable global pages so that kernel TLB entries can be flushed before
 returning to user space. This way, all accesses to kernel addresses from
 userspace result in a TLB miss independent of the existance of a kernel
 mapping.

 Replace _PAGE_GLOBAL by __PAGE_KERNEL_GLOBAL and keep _PAGE_GLOBAL
 available so that it can still be used for a few selected kernel mappings
 which must be visible to userspace, when KAISER is enabled, like the
 entry/exit code and data.

I admit it's a pet pieve, but having very precise changelogs for this kind
of changes makes review a lot easier and is really usefulwhen you have to
stare at a commit 3 month later.

Other than that:

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
