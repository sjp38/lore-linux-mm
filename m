Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 07F146B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 14:27:16 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id 10so11838236ied.30
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 11:27:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1361471962-25164-2-git-send-email-vgupta@synopsys.com>
References: <1361471962-25164-1-git-send-email-vgupta@synopsys.com>
	<1361471962-25164-2-git-send-email-vgupta@synopsys.com>
Date: Thu, 21 Feb 2013 11:27:16 -0800
Message-ID: <CAE9FiQXSPHjRsCWcHpz7s1gQjNGuj5_X_YE2Ln=EA7_-Ka_cNg@mail.gmail.com>
Subject: Re: [PATCH 1/2] memblock: add assertion for zero allocation size
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Marc Gauthier <marc@tensilica.com>, Tejun Heo <tj@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

[+Cc: hpa]

On Thu, Feb 21, 2013 at 10:39 AM, Vineet Gupta
<Vineet.Gupta1@synopsys.com> wrote:
> This came to light when calling memblock allocator from arc port (for
> copying flattended DT). If a "0" alignment is passed, the allocator
> round_up() call incorrectly rounds up the size to 0.
>
> round_up(num, alignto) => ((num - 1) | (alignto -1)) + 1
>
> While the obvious allocation failure causes kernel to panic, it is
> better to BUG_ON() if effective size for allocation (as passed by caller
> and/or computed after alignemtn rounding) is zero.

should we just make align to 1 instead of 0 ?

or BUG_ON(!align) instead?

>
> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Yinghai Lu <yinghai@kernel.org>
> Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/memblock.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 1bcd9b9..32b36d0 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -824,6 +824,8 @@ static phys_addr_t __init memblock_alloc_base_nid(phys_addr_t size,
>         /* align @size to avoid excessive fragmentation on reserved array */
>         size = round_up(size, align);
>
> +       BUG_ON(!size);
> +
>         found = memblock_find_in_range_node(0, max_addr, size, align, nid);
>         if (found && !memblock_reserve(found, size))
>                 return found;
> --
> 1.7.4.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
