Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB48C6B0007
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 13:19:50 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id i189-v6so4112389pge.6
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 10:19:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i61-v6si25644867plb.193.2018.10.10.10.19.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 10:19:48 -0700 (PDT)
Date: Wed, 10 Oct 2018 19:19:44 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: don't clobber partially overlapping VMA with
 MAP_FIXED_NOREPLACE
Message-ID: <20181010171944.GJ5873@dhcp22.suse.cz>
References: <20181010152736.99475-1-jannh@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010152736.99475-1-jannh@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees Cook <keescook@chromium.org>, Jason Evans <jasone@google.com>, David Goldblatt <davidtgoldblatt@gmail.com>, Edward Tomasz =?utf-8?Q?Napiera=C5=82a?= <trasz@FreeBSD.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Daniel Micay <danielmicay@gmail.com>

On Wed 10-10-18 17:27:36, Jann Horn wrote:
> Daniel Micay reports that attempting to use MAP_FIXED_NOREPLACE in an
> application causes that application to randomly crash. The existing check
> for handling MAP_FIXED_NOREPLACE looks up the first VMA that either
> overlaps or follows the requested region, and then bails out if that VMA
> overlaps *the start* of the requested region. It does not bail out if the
> VMA only overlaps another part of the requested region.

I do not understand. Could you give me an example?
[...]

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 5f2b2b184c60..f7cd9cb966c0 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1410,7 +1410,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>  	if (flags & MAP_FIXED_NOREPLACE) {
>  		struct vm_area_struct *vma = find_vma(mm, addr);
>  
> -		if (vma && vma->vm_start <= addr)
> +		if (vma && vma->vm_start < addr + len)

find_vma is documented to - Look up the first VMA which satisfies addr <
vm_end, NULL if none.
This means that the above check guanratees that
	vm_start <= addr < vm_end
so an overlap is guanrateed. Why should we care how much we overlap?

-- 
Michal Hocko
SUSE Labs
