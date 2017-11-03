Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6F16B0038
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 09:31:22 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id m198so2731468oig.20
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 06:31:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i7sor2186735oia.266.2017.11.03.06.31.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Nov 2017 06:31:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171103112121.23597-1-jack@suse.cz>
References: <20171103112121.23597-1-jack@suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 3 Nov 2017 06:31:19 -0700
Message-ID: <CAPcyv4jkf4b=xoNVNxt2x7_MmXAprunMHGt02=ue602atJt-Pw@mail.gmail.com>
Subject: Re: [PATCH] mm: Handle 0 flags in _calc_vm_trans() macro
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Christoph Hellwig <hch@infradead.org>

On Fri, Nov 3, 2017 at 4:21 AM, Jan Kara <jack@suse.cz> wrote:
> _calc_vm_trans() does not handle the situation when some of the passed
> flags are 0 (which can happen if these VM flags do not make sense for
> the architecture). Improve the _calc_vm_trans() macro to return 0 in
> such situation. Since all passed flags are constant, this does not add
> any runtime overhead.
>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  include/linux/mman.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> Dan, can you please prepend this patch before my series so that we don't
> break bisectability? This fixes the reported problem for me when arch
> does not define MAP_SYNC. Thanks!
>
> diff --git a/include/linux/mman.h b/include/linux/mman.h
> index 8f7cc87828e6..3427bf3daef5 100644
> --- a/include/linux/mman.h
> +++ b/include/linux/mman.h
> @@ -105,8 +105,9 @@ static inline bool arch_validate_prot(unsigned long prot)
>   * ("bit1" and "bit2" must be single bits)
>   */
>  #define _calc_vm_trans(x, bit1, bit2) \
> +  ((!(bit1) || !(bit2)) ? 0 : \
>    ((bit1) <= (bit2) ? ((x) & (bit1)) * ((bit2) / (bit1)) \
> -   : ((x) & (bit1)) / ((bit1) / (bit2)))
> +   : ((x) & (bit1)) / ((bit1) / (bit2))))
>

Looks good to me, thanks Jan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
