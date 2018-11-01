Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4CAA96B0007
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 02:38:38 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id w20-v6so679735itb.6
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 23:38:38 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id d62-v6si10853829iog.115.2018.10.31.23.38.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 23:38:37 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [PATCH] mm/gup_benchmark: prevent integer overflow in ioctl
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181025061546.hnhkv33diogf2uis@kili.mountain>
Date: Thu, 1 Nov 2018 00:38:22 -0600
Content-Transfer-Encoding: quoted-printable
Message-Id: <CF4F3932-68A1-4D92-9E4F-6DCD3A3A0447@oracle.com>
References: <20181025061546.hnhkv33diogf2uis@kili.mountain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Keith Busch <keith.busch@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>, Kees Cook <keescook@chromium.org>, YueHaibing <yuehaibing@huawei.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org



> On Oct 25, 2018, at 12:15 AM, Dan Carpenter <dan.carpenter@oracle.com> =
wrote:
>=20
> The concern here is that "gup->size" is a u64 and "nr_pages" is =
unsigned
> long.  On 32 bit systems we could trick the kernel into allocating =
fewer
> pages than expected.
>=20
> Fixes: 64c349f4ae78 ("mm: add infrastructure for get_user_pages_fast() =
benchmarking")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> mm/gup_benchmark.c | 3 +++
> 1 file changed, 3 insertions(+)
>=20
> diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
> index debf11388a60..5b42d3d4b60a 100644
> --- a/mm/gup_benchmark.c
> +++ b/mm/gup_benchmark.c
> @@ -27,6 +27,9 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
> 	int nr;
> 	struct page **pages;
>=20
> +	if (gup->size > ULONG_MAX)
> +		return -EINVAL;
> +
> 	nr_pages =3D gup->size / PAGE_SIZE;
> 	pages =3D kvcalloc(nr_pages, sizeof(void *), GFP_KERNEL);
> 	if (!pages)

Given gup->size is in bytes, if your goal is to avoid an overflow of =
nr_pages on 32-bit
systems, shouldn't you be checking something like:

    if ((gup_size / PAGE_SIZE) > ULONG_MAX)

instead?

    William Kucharski=
