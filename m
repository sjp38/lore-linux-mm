Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D4DC16B0036
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 14:33:46 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id x13so4372095wgg.9
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 11:33:42 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id xv4si20227486wjb.86.2014.09.15.11.33.40
        for <linux-mm@kvack.org>;
        Mon, 15 Sep 2014 11:33:41 -0700 (PDT)
Date: Mon, 15 Sep 2014 19:33:34 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] arm64:free_initrd_mem should also free the memblock
Message-ID: <20140915183334.GA30737@arm.com>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB029@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103CDBFBFB029@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: "'linux@arm.linux.org.uk'" <linux@arm.linux.org.uk>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>

On Fri, Sep 12, 2014 at 11:17:18AM +0100, Wang, Yalin wrote:
> this patch fix the memblock statics for memblock
> in file /sys/kernel/debug/memblock/reserved
> if we don't call memblock_free the initrd will still
> be marked as reserved, even they are freed.
> 
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  arch/arm64/mm/init.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 5472c24..34605c8 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -334,8 +334,10 @@ static int keep_initrd;
>  
>  void free_initrd_mem(unsigned long start, unsigned long end)
>  {
> -	if (!keep_initrd)
> +	if (!keep_initrd) {
>  		free_reserved_area((void *)start, (void *)end, 0, "initrd");
> +		memblock_free(__pa(start), end - start);
> +	}

I don't think it makes any technical difference, but doing the memblock_free
before the free_reserved_area makes more sense to me.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
