Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10B66828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 05:59:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so162138364pfa.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 02:59:57 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a8si6039024pfj.35.2016.06.23.02.59.56
        for <linux-mm@kvack.org>;
        Thu, 23 Jun 2016 02:59:56 -0700 (PDT)
Date: Thu, 23 Jun 2016 10:59:51 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: prevent KASAN false positives in kmemleak
Message-ID: <20160623095951.GH6521@e104818-lin.cambridge.arm.com>
References: <1466617631-68387-1-git-send-email-dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466617631-68387-1-git-send-email-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, ryabinin.a.a@gmail.com, kasan-dev@googlegroups.com, glider@google.com

On Wed, Jun 22, 2016 at 07:47:11PM +0200, Dmitry Vyukov wrote:
> When kmemleak dumps contents of leaked objects it reads whole
> objects regardless of user-requested size. This upsets KASAN.
> Disable KASAN checks around object dump.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> ---
>  mm/kmemleak.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index e642992..04320d3 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -307,8 +307,10 @@ static void hex_dump_object(struct seq_file *seq,
>  	len = min_t(size_t, object->size, HEX_MAX_LINES * HEX_ROW_SIZE);
>  
>  	seq_printf(seq, "  hex dump (first %zu bytes):\n", len);
> +	kasan_disable_current();
>  	seq_hex_dump(seq, "    ", DUMP_PREFIX_NONE, HEX_ROW_SIZE,
>  		     HEX_GROUP_SIZE, ptr, len, HEX_ASCII);
> +	kasan_enable_current();
>  }

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
