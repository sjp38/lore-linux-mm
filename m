Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id C01166B0006
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 03:48:58 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id i79-v6so11821425ywc.23
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 00:48:58 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id p65-v6si3088372ywf.272.2018.10.15.00.48.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 00:48:57 -0700 (PDT)
Subject: Re: [PATCH] mm: don't clobber partially overlapping VMA with
 MAP_FIXED_NOREPLACE
References: <20181010152736.99475-1-jannh@google.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <bf9a1b9e-1a5d-4e89-62d5-53d8f7c84849@oracle.com>
Date: Mon, 15 Oct 2018 01:47:58 -0600
MIME-Version: 1.0
In-Reply-To: <20181010152736.99475-1-jannh@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees Cook <keescook@chromium.org>, Jason Evans <jasone@google.com>, David Goldblatt <davidtgoldblatt@gmail.com>, =?UTF-8?Q?Edward_Tomasz_Napiera=c5=82a?= <trasz@FreeBSD.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Daniel Micay <danielmicay@gmail.com>

On 10/10/2018 09:27 AM, Jann Horn wrote:
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
> ---
>   mm/mmap.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 5f2b2b184c60..f7cd9cb966c0 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1410,7 +1410,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>   	if (flags & MAP_FIXED_NOREPLACE) {
>   		struct vm_area_struct *vma = find_vma(mm, addr);
>   
> -		if (vma && vma->vm_start <= addr)
> +		if (vma && vma->vm_start < addr + len)
>   			return -EEXIST;
>   	}
>   
> 

Makes sense.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>

--
Khalid
