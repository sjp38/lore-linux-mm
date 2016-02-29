Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id DE889828E6
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:04:39 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id s6so91584969obg.3
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:04:39 -0800 (PST)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com. [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id d7si1539598oby.86.2016.02.29.10.04.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 10:04:39 -0800 (PST)
Received: by mail-ob0-x236.google.com with SMTP id ts10so142176336obc.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:04:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1456738445-876239-1-git-send-email-arnd@arndb.de>
References: <1456738445-876239-1-git-send-email-arnd@arndb.de>
Date: Mon, 29 Feb 2016 10:04:38 -0800
Message-ID: <CAPcyv4jJzUieZ0i2jBqANwmYPUBVmQmhoDTPnr0KjPQXnoZqWQ@mail.gmail.com>
Subject: Re: [PATCH] crypto/async_pq: use __free_page() instead of put_page()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux MM <linux-mm@kvack.org>, Herbert Xu <herbert@gondor.apana.org.au>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Nazarewicz <mina86@mina86.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, NeilBrown <neilb@suse.com>, Markus Stockhausen <stockhausen@collogia.de>, Vinod Koul <vinod.koul@intel.com>, linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Feb 29, 2016 at 1:33 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> The addition of tracepoints to the page reference tracking had an
> unfortunate side-effect in at least one driver that calls put_page
> from its exit function, resulting in a link error:
>
> `.exit.text' referenced in section `__jump_table' of crypto/built-in.o: defined in discarded section `.exit.text' of crypto/built-in.o
>
> From a cursory look at that this driver, it seems that it may be
> doing the wrong thing here anyway, as the page gets allocated
> using 'alloc_page()', and should be freed using '__free_page()'
> rather than 'put_page()'.
>
> With this patch, I no longer get any other build errors from the
> page_ref patch, so hopefully we can assume that it's always wrong
> to call any of those functions from __exit code, and that no other
> driver does it.
>
> Fixes: 0f80830dd044 ("mm/page_ref: add tracepoint to track down page reference manipulation")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Dan Williams <dan.j.williams@intel.com>

Vinod, will you take this one?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
