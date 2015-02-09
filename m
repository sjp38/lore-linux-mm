Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8116B0032
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 16:23:53 -0500 (EST)
Received: by pdno5 with SMTP id o5so11718258pdn.8
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 13:23:53 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n3si24179993pap.106.2015.02.09.13.23.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Feb 2015 13:23:52 -0800 (PST)
Date: Mon, 9 Feb 2015 13:23:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: actually remap enough memory
Message-Id: <20150209132351.f8b95644a1304543e5118820@linux-foundation.org>
In-Reply-To: <1423364112-15487-1-git-send-email-notasas@gmail.com>
References: <1423364112-15487-1-git-send-email-notasas@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grazvydas Ignotas <notasas@gmail.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Sun,  8 Feb 2015 04:55:12 +0200 Grazvydas Ignotas <notasas@gmail.com> wrote:

> For whatever reason, generic_access_phys() only remaps one page, but
> actually allows to access arbitrary size. It's quite easy to trigger
> large reads, like printing out large structure with gdb, which leads to
> a crash. Fix it by remapping correct size.
> 
> ...
>
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3829,7 +3829,7 @@ int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
>  	if (follow_phys(vma, addr, write, &prot, &phys_addr))
>  		return -EINVAL;
>  
> -	maddr = ioremap_prot(phys_addr, PAGE_SIZE, prot);
> +	maddr = ioremap_prot(phys_addr, PAGE_ALIGN(len + offset), prot);
>  	if (write)
>  		memcpy_toio(maddr + offset, buf, len);
>  	else

hm, shouldn't this be PAGE_ALIGN(len)?

Do we need the PAGE_ALIGN at all?  It's probably safer/saner to have it
there, but x86 (at least) should be OK with arbitrary alignment on both
addr and len?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
