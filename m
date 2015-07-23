Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 476DB6B025D
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 16:59:13 -0400 (EDT)
Received: by iecri3 with SMTP id ri3so3805546iec.2
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 13:59:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i99si6012164iod.100.2015.07.23.13.59.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 13:59:12 -0700 (PDT)
Date: Thu, 23 Jul 2015 13:59:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2 2/6] x86, mpx: do not set ->vm_ops on mpx VMAs
Message-Id: <20150723135911.af81b6a685f5b779ca66f3c3@linux-foundation.org>
In-Reply-To: <1437133993-91885-3-git-send-email-kirill.shutemov@linux.intel.com>
References: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1437133993-91885-3-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>

On Fri, 17 Jul 2015 14:53:09 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> MPX setups private anonymous mapping, but uses vma->vm_ops too.
> This can confuse core VM, as it relies on vm->vm_ops to distinguish
> file VMAs from anonymous.
> 
> As result we will get SIGBUS, because handle_pte_fault() thinks it's
> file VMA without vm_ops->fault and it doesn't know how to handle the
> situation properly.
> 
> Let's fix that by not setting ->vm_ops.
> 
> We don't really need ->vm_ops here: MPX VMA can be detected with VM_MPX
> flag. And vma_merge() will not merge MPX VMA with non-MPX VMA, because
> ->vm_flags won't match.
> 
> The only thing left is name of VMA. I'm not sure if it's part of ABI, or
> we can just drop it. The patch keep it by providing arch_vma_name() on x86.
> 
> Build tested only.

mpx.c has changed.

arch/x86/mm/mpx.c: In function 'try_unmap_single_bt':
arch/x86/mm/mpx.c:930: error: implicit declaration of function 'is_mpx_vma'

I'll drop this patch and see what happens.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
