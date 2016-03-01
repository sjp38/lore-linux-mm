Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id E26596B0009
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 16:44:05 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id p65so54510407wmp.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 13:44:05 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id l67si1257673wmg.76.2016.03.01.13.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 13:44:04 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id l68so52485746wml.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 13:44:04 -0800 (PST)
Date: Wed, 2 Mar 2016 00:44:02 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86, pkeys: fix access_error() denial of writes to
 write-only VMA
Message-ID: <20160301214402.GA20162@node.shutemov.name>
References: <20160301194133.65D0110C@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160301194133.65D0110C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com, avagin@gmail.com, linux-next@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Tue, Mar 01, 2016 at 11:41:33AM -0800, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Andrey Wagin reported that a simple test case was broken by:
> 
> 	2b5f7d013fc ("mm/core, x86/mm/pkeys: Add execute-only protection keys support")
> 
> This test case creates an unreadable VMA and my patch assumed
> that all writes must be to readable VMAs.
> 
> The simplest fix for this is to remove the pkey-related bits
> in access_error().  For execute-only support, I believe the
> existing version is sufficient because the permissions we
> are trying to enforce are entirely expressed in vma->vm_flags.
> We just depend on pkeys to get *an* exception, it does not
> matter that PF_PK was set, or even what state PKRU is in.
> 
> I will re-add the necessary bits with the full pkeys
> implementation that includes the new syscalls.
> 
> The three cases that matter are:
> 
> 1. If a write to an execute-only VMA occurs, we will see PF_WRITE
>    set, but !VM_WRITE on the VMA, and return 1.  All execute-only
>    VMAs have VM_WRITE clear by definition.
> 2. If a read occurs on a present PTE, we will fall in to the "read,
>    present" case and return 1.
> 3. If a read occurs to a non-present PTE, we will miss the "read,
>    not present" case, because the execute-only VMA will have
>    VM_EXEC set, and we will properly return 0 allowing the PTE to
>    be populated.
> 
> Test program:
> 
> #include <sys/mman.h>
> #include <stdlib.h>
> 
> int main()
> {
> 	int *p;
> 	p = mmap(NULL, 4096, PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
> 	p[0] = 1;
> 
> 	return 0;
> }
> 
> Fixes: 62b5f7d013fc ("mm/core, x86/mm/pkeys: Add execute-only protection keys support")
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> Cc: Andrey Wagin <avagin@gmail.com>,
> Cc: linux-next@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: x86@kernel.org

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
