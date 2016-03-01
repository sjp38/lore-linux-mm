Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 260B3828E2
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 08:54:51 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id m82so128916473oif.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 05:54:51 -0800 (PST)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id r15si25829078oie.31.2016.03.01.05.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 05:54:50 -0800 (PST)
Received: by mail-oi0-x22e.google.com with SMTP id d205so46296195oia.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 05:54:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jJzUieZ0i2jBqANwmYPUBVmQmhoDTPnr0KjPQXnoZqWQ@mail.gmail.com>
References: <1456738445-876239-1-git-send-email-arnd@arndb.de>
	<CAPcyv4jJzUieZ0i2jBqANwmYPUBVmQmhoDTPnr0KjPQXnoZqWQ@mail.gmail.com>
Date: Tue, 1 Mar 2016 22:54:50 +0900
Message-ID: <CAAmzW4Nq8LiFGzyR4YjG8OPev-Pj1dUad+Bus2puSAk_tUcCsA@mail.gmail.com>
Subject: Re: [PATCH] crypto/async_pq: use __free_page() instead of put_page()
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux MM <linux-mm@kvack.org>, Herbert Xu <herbert@gondor.apana.org.au>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Nazarewicz <mina86@mina86.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, NeilBrown <neilb@suse.com>, Markus Stockhausen <stockhausen@collogia.de>, Vinod Koul <vinod.koul@intel.com>, linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

2016-03-01 3:04 GMT+09:00 Dan Williams <dan.j.williams@intel.com>:
> On Mon, Feb 29, 2016 at 1:33 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>> The addition of tracepoints to the page reference tracking had an
>> unfortunate side-effect in at least one driver that calls put_page
>> from its exit function, resulting in a link error:
>>
>> `.exit.text' referenced in section `__jump_table' of crypto/built-in.o: defined in discarded section `.exit.text' of crypto/built-in.o
>>
>> From a cursory look at that this driver, it seems that it may be
>> doing the wrong thing here anyway, as the page gets allocated
>> using 'alloc_page()', and should be freed using '__free_page()'
>> rather than 'put_page()'.
>>
>> With this patch, I no longer get any other build errors from the
>> page_ref patch, so hopefully we can assume that it's always wrong
>> to call any of those functions from __exit code, and that no other
>> driver does it.
>>
>> Fixes: 0f80830dd044 ("mm/page_ref: add tracepoint to track down page reference manipulation")
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>
> Acked-by: Dan Williams <dan.j.williams@intel.com>
>
> Vinod, will you take this one?

Problematic patch ("mm/page_ref: ~~~") is not yet merged one. It is on mmotm
and this fix should go together with it or before it. I think that
handling this fix by
Andrew is easier to all.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
