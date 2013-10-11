Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1345A6B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 22:23:31 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so3446766pbc.23
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 19:23:30 -0700 (PDT)
Received: by mail-ie0-f180.google.com with SMTP id e14so2428487iej.25
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 19:23:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131010022627.GA8535@variantweb.net>
References: <1381159541-13981-1-git-send-email-k.kozlowski@samsung.com>
	<20131007150338.1fdee18b536bb1d9fe41a07b@linux-foundation.org>
	<1381220000.16135.10.camel@AMDC1943>
	<20131008130853.96139b79a0a4d3aaacc79ed2@linux-foundation.org>
	<20131009144045.GA5406@variantweb.net>
	<525602E3.3080501@oracle.com>
	<20131010022627.GA8535@variantweb.net>
Date: Fri, 11 Oct 2013 10:23:28 +0800
Message-ID: <CAL1ERfOnb7DZXH87cq2ZWhRiDuU9btmmRbOURLA5SV7zsho1VA@mail.gmail.com>
Subject: Re: [PATCH] frontswap: enable call to invalidate area on swapoff
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Bob Liu <bob.liu@oracle.com>, Seth Jennings <spartacus06@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>

Thanks, Seth

On Thu, Oct 10, 2013 at 10:26 AM, Seth Jennings
<sjennings@variantweb.net> wrote:
> On Thu, Oct 10, 2013 at 09:29:07AM +0800, Bob Liu wrote:
>> On 10/09/2013 10:40 PM, Seth Jennings wrote:
>> >
>> > The reason we never noticed this for zswap is that zswap has no
>> > dynamically allocated per-type resources.  In the expected case,
>> > where all of the pages have been drained from zswap,
>> > zswap_frontswap_invalidate_area() is a no-op.
>> >
>>
>> Not exactly, see the bug fix "mm/zswap: bugfix: memory leak when
>> re-swapon" from Weijie.
>> Zswap needs invalidate_area() also.
>
> I remembered this patch as soon as I sent out this note.  What I said
> about zswap_frontswap_invalidate_area() being a no-op in the expected
> case is true as of v3.12-rc4, but it shouldn't be :)
>
> I sent a note to Andrew reminding him to pull in that patch.
>
> Thanks,
> Seth
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

I am sorry to interrupt this topic, but I found an tiny issue near that:

we can not "set_blocksize(bdev, p->old_block_size);" at the end of swapoff()
because swap_info p may be reused by concurrent swapon called
I think we need to  save the p->old_block_size in a local var and use it instead

to Krzysztof : would you please add this in your patch?
Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
