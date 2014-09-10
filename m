Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id CA4D76B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 05:02:37 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so10834332pdj.20
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 02:02:37 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id kj7si26648317pdb.245.2014.09.10.02.02.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 02:02:36 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Wed, 10 Sep 2014 17:02:25 +0800
Subject: RE: [RFC] Free the reserved memblock when free cma pages
Message-ID: <35FD53F367049845BC99AC72306C23D103CDBFBFB019@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB016@CNBJMBX05.corpusers.net>
 <20140910081816.GA25219@dhcp22.suse.cz>
In-Reply-To: <20140910081816.GA25219@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@suse.cz>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "hughd@google.com" <hughd@google.com>, "b.zolnierkie@samsung.com" <b.zolnierkie@samsung.com>

Hi=20

Yeah, the __ClearPageReserved flag is cleared for each page,
But the memblock still mark these physical address as marked,
Then if you cat /sys/kernel/debug/memblock/reserved
You can still see these physical address are marked as reserved,
This is not correct,
This is because cma_activate_area function release the pages after
Boot_mem free, so we have to free the memblock by ourselves,

The same problem also reside for initrd reserved memory.

-----Original Message-----
From: Michal Hocko [mailto:mstsxfx@gmail.com] On Behalf Of Michal Hocko
Sent: Wednesday, September 10, 2014 4:18 PM
To: Wang, Yalin
Cc: 'linux-mm@kvack.org'; 'akpm@linux-foundation.org'; mm-commits@vger.kern=
el.org; hughd@google.com; b.zolnierkie@samsung.com
Subject: Re: [RFC] Free the reserved memblock when free cma pages

On Tue 09-09-14 14:13:58, Wang, Yalin wrote:
> This patch add memblock_free to also free the reserved memblock, so=20
> that the cma pages are not marked as reserved memory in=20
> /sys/kernel/debug/memblock/reserved debug file

Why and is this even correct? init_cma_reserved_pageblock seems to be doing=
 __ClearPageReserved on each page in the page block.

> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  mm/cma.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/mm/cma.c b/mm/cma.c
> index c17751c..f3ec756 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -114,6 +114,8 @@ static int __init cma_activate_area(struct cma *cma)
>  				goto err;
>  		}
>  		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
> +		memblock_free(__pfn_to_phys(base_pfn),
> +				pageblock_nr_pages * PAGE_SIZE);
>  	} while (--i);
> =20
>  	mutex_init(&cma->lock);
> --
> 2.1.0

--
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
