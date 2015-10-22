Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 610976B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 16:57:56 -0400 (EDT)
Received: by qgad10 with SMTP id d10so68243857qga.3
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 13:57:56 -0700 (PDT)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id r67si15180821qha.65.2015.10.22.13.57.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 13:57:55 -0700 (PDT)
Received: by qgem9 with SMTP id m9so68258077qge.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 13:57:55 -0700 (PDT)
Date: Thu, 22 Oct 2015 16:57:47 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 15/25] x86, pkeys: check VMAs and PTEs for protection keys
Message-ID: <20151022205746.GA3045@gmail.com>
References: <20150928191817.035A64E2@viggo.jf.intel.com>
 <20150928191823.CAE64CF3@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150928191823.CAE64CF3@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

On Mon, Sep 28, 2015 at 12:18:23PM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
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
> 	arch_pte_access_permitted(pte, write)
> 	arch_vma_access_permitted(vma, write)
> 
> These are, of course, backed up in x86 arch code with checks
> against the PTE or VMA's protection key.
> 
> But, there are also cases where we do not want to respect
> protection keys.  When we ptrace(), for instance, we do not want
> to apply the tracer's PKRU permissions to the PTEs from the
> process being traced.


Well i am bit puzzle here because this will not provide consistant
protection as far as GUP (get_user_pages) is concern, assuming i
understand the pkru thing properly. Those are register local to CPU
and they are writeable by userspace thread so thread can temporarily
revoke access to range while executing untrusted subfunctions.

I have not read all the patches, but here i assume that for GUP you do
not first call arch_vma_access_permitted(). So issue i see is that GUP
for a process might happen inside another process and that process might
have different pkru protection keys, effectively randomly allowing or
forbidding a device driver to perform a GUP from say some workqueue that
just happen to be schedule against a different processor/thread than the
one against which it is doing the GUP for.

Second and more fundamental thing i have issue with is that this whole
pkru keys are centric to CPU POV ie this is a CPU feature. So i do not
believe that device driver should be forbidden to do GUP base on pkru
keys.

Tying this to the pkru reg value of whatever processor happens to be
running some device driver kernel function that try to do a GUP seems
broken to me.

Sadly setting properties like pkru keys per device is not something that
is easy to do. I would do it on a per device file basis and allow user
space program to change them against the device file, then device driver
doing GUP would use that to check against the pte key and allow forbid
GUP.

Also doing it on per device file makes it harder for program to leverage
this feature as now they have to think about all device file they have
open. Maybe we need to keep a list of device that are use by a process
in the task struct and allow to set pkey globaly for all devices, while
allowing overriding this common default on per device basis.

So as first i would just allow GUP to always work and then come up with
syscall to allow to set pkey on device file. This obviously is a lot more
work as you need to go over all device driver using GUP.

This are my thoughts so far.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
