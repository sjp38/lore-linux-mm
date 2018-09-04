Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 452E96B6E25
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 11:18:54 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u45-v6so4310794qte.12
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 08:18:54 -0700 (PDT)
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id d5-v6si792428qkf.371.2018.09.04.08.18.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 04 Sep 2018 08:18:53 -0700 (PDT)
Date: Tue, 4 Sep 2018 15:18:52 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v6 11/18] khwasan, mm: perform untagged pointers comparison
 in krealloc
In-Reply-To: <a13a41e3ca65116eb5614c4dd396b23182e98fed.1535462971.git.andreyknvl@google.com>
Message-ID: <01000165a52a3a0b-f9832a6e-358f-4400-b941-47984458b754-000000@email.amazonses.com>
References: <cover.1535462971.git.andreyknvl@google.com> <a13a41e3ca65116eb5614c4dd396b23182e98fed.1535462971.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-mm@kvack.org


Reviewed-by: Christoph Lameter <cl@linux.com>


On Wed, 29 Aug 2018, Andrey Konovalov wrote:

> The krealloc function checks where the same buffer was reused or a new one
> allocated by comparing kernel pointers. KHWASAN changes memory tag on the
> krealloc'ed chunk of memory and therefore also changes the pointer tag of
> the returned pointer. Therefore we need to perform comparison on untagged
> (with tags reset) pointers to check whether it's the same memory region or
> not.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  mm/slab_common.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 3abfa0f86118..0d588dfebd7d 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1513,7 +1513,7 @@ void *krealloc(const void *p, size_t new_size, gfp_t flags)
>  	}
>
>  	ret = __do_krealloc(p, new_size, flags);
> -	if (ret && p != ret)
> +	if (ret && khwasan_reset_tag(p) != khwasan_reset_tag(ret))
>  		kfree(p);
>
>  	return ret;
>
