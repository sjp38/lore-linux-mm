Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id A88F36B025C
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 17:09:01 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so1746974wib.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 14:09:01 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id iv2si10730792wjb.141.2015.07.23.14.08.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 14:09:00 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so1746224wib.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 14:08:59 -0700 (PDT)
Date: Fri, 24 Jul 2015 00:08:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 2/6] x86, mpx: do not set ->vm_ops on mpx VMAs
Message-ID: <20150723210856.GA26354@node.dhcp.inet.fi>
References: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1437133993-91885-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20150723135911.af81b6a685f5b779ca66f3c3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150723135911.af81b6a685f5b779ca66f3c3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>

On Thu, Jul 23, 2015 at 01:59:11PM -0700, Andrew Morton wrote:
> On Fri, 17 Jul 2015 14:53:09 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > MPX setups private anonymous mapping, but uses vma->vm_ops too.
> > This can confuse core VM, as it relies on vm->vm_ops to distinguish
> > file VMAs from anonymous.
> > 
> > As result we will get SIGBUS, because handle_pte_fault() thinks it's
> > file VMA without vm_ops->fault and it doesn't know how to handle the
> > situation properly.
> > 
> > Let's fix that by not setting ->vm_ops.
> > 
> > We don't really need ->vm_ops here: MPX VMA can be detected with VM_MPX
> > flag. And vma_merge() will not merge MPX VMA with non-MPX VMA, because
> > ->vm_flags won't match.
> > 
> > The only thing left is name of VMA. I'm not sure if it's part of ABI, or
> > we can just drop it. The patch keep it by providing arch_vma_name() on x86.
> > 
> > Build tested only.
> 
> mpx.c has changed.
> 
> arch/x86/mm/mpx.c: In function 'try_unmap_single_bt':
> arch/x86/mm/mpx.c:930: error: implicit declaration of function 'is_mpx_vma'
> 
> I'll drop this patch and see what happens.

Ingo has applied an updated version to x86/urgent:

https://git.kernel.org/cgit/linux/kernel/git/tip/tip.git/commit/?h=x86/urgent&id=a89652769470d12cd484ee3d3f7bde0742be8d96

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
