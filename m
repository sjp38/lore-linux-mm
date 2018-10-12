Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AD1C16B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 08:03:26 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w42-v6so7029815edd.0
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 05:03:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a9-v6si658496ejr.153.2018.10.12.05.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 05:03:25 -0700 (PDT)
Subject: Re: [PATCH] mm: don't clobber partially overlapping VMA with
 MAP_FIXED_NOREPLACE
References: <20181010152736.99475-1-jannh@google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <bdb0b0ab-c639-e4ca-4c95-5924eb2be23f@suse.cz>
Date: Fri, 12 Oct 2018 14:03:21 +0200
MIME-Version: 1.0
In-Reply-To: <20181010152736.99475-1-jannh@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, Michal Hocko <mhocko@suse.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees Cook <keescook@chromium.org>, Jason Evans <jasone@google.com>, David Goldblatt <davidtgoldblatt@gmail.com>, =?UTF-8?Q?Edward_Tomasz_Napiera=c5=82a?= <trasz@FreeBSD.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Daniel Micay <danielmicay@gmail.com>

On 10/10/18 5:27 PM, Jann Horn wrote:
> Daniel Micay reports that attempting to use MAP_FIXED_NOREPLACE in an
> application causes that application to randomly crash. The existing check
> for handling MAP_FIXED_NOREPLACE looks up the first VMA that either
> overlaps or follows the requested region, and then bails out if that VMA
> overlaps *the start* of the requested region. It does not bail out if the
> VMA only overlaps another part of the requested region.
> 
> Fix it by checking that the found VMA only starts at or after the end of
> the requested region, in which case there is no overlap.
> 
> Reported-by: Daniel Micay <danielmicay@gmail.com>
> Fixes: a4ff8e8620d3 ("mm: introduce MAP_FIXED_NOREPLACE")
> Cc: stable@vger.kernel.org
> Signed-off-by: Jann Horn <jannh@google.com>

Good catch, thanks.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/mmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
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
>  			return -EEXIST;
>  	}
>  
> 
