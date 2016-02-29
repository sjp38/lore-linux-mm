Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1151C6B0257
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 02:40:03 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id jq7so126576322obb.0
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 23:40:03 -0800 (PST)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id u133si20491117oib.78.2016.02.28.23.40.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 23:40:02 -0800 (PST)
Received: by mail-oi0-x22b.google.com with SMTP id d205so16832378oia.0
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 23:40:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1456696663-2340682-1-git-send-email-arnd@arndb.de>
References: <1456696663-2340682-1-git-send-email-arnd@arndb.de>
Date: Mon, 29 Feb 2016 16:40:02 +0900
Message-ID: <CAAmzW4N0YJc_O9ArC8e7Q5y4rmbHjj6-Q1yfvZ5LvORvG764cg@mail.gmail.com>
Subject: Re: [PATCH] [RFC] mm/page_ref, crypto/async_pq: don't put_page from __exit
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, Michal Nazarewicz <mina86@mina86.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, linux-crypto@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

2016-02-29 6:57 GMT+09:00 Arnd Bergmann <arnd@arndb.de>:
> The addition of tracepoints to the page reference tracking had an
> unfortunate side-effect in at least one driver that calls put_page
> from its exit function, resulting in a link error:
>
> `.exit.text' referenced in section `__jump_table' of crypto/built-in.o: defined in discarded section `.exit.text' of crypto/built-in.o
>
> I could not come up with a nice solution that ignores __jump_table
> entries in discarded code, so we probably now have to treat this
> as something a driver is not allowed to do. Removing the __exit
> annotation avoids the problem in this particular driver, but the
> same problem could come back any time in other code.
>
> On a related problem regarding the runtime patching for SMP
> operations on ARM uniprocessor systems, we resorted to not
> drop the .exit section at link time, but that doesn't seem
> appropriate here.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 0f80830dd044 ("mm/page_ref: add tracepoint to track down page reference manipulation")
> ---
>  crypto/async_tx/async_pq.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/crypto/async_tx/async_pq.c b/crypto/async_tx/async_pq.c
> index c0748bbd4c08..be167145aa55 100644
> --- a/crypto/async_tx/async_pq.c
> +++ b/crypto/async_tx/async_pq.c
> @@ -442,7 +442,7 @@ static int __init async_pq_init(void)
>         return -ENOMEM;
>  }
>
> -static void __exit async_pq_exit(void)
> +static void async_pq_exit(void)
>  {
>         put_page(pq_scribble_page);
>  }

Hello, Arnd.

I think that we can avoid this error by using __free_page().
It would not be inlined so calling it would have no problem.

Could you test it, please?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
