Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6A76B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 10:46:35 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 4so16920608pfd.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 07:46:35 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id g7si27708516pat.103.2016.03.03.07.46.34
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 07:46:34 -0800 (PST)
Date: Thu, 3 Mar 2016 21:20:35 +0530
From: Vinod Koul <vinod.koul@intel.com>
Subject: Re: [PATCH] crypto/async_pq: use __free_page() instead of put_page()
Message-ID: <20160303155035.GT11154@localhost>
References: <1456738445-876239-1-git-send-email-arnd@arndb.de>
 <CAPcyv4jJzUieZ0i2jBqANwmYPUBVmQmhoDTPnr0KjPQXnoZqWQ@mail.gmail.com>
 <CAAmzW4Nq8LiFGzyR4YjG8OPev-Pj1dUad+Bus2puSAk_tUcCsA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4Nq8LiFGzyR4YjG8OPev-Pj1dUad+Bus2puSAk_tUcCsA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux MM <linux-mm@kvack.org>, Herbert Xu <herbert@gondor.apana.org.au>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Nazarewicz <mina86@mina86.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, NeilBrown <neilb@suse.com>, Markus Stockhausen <stockhausen@collogia.de>, linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Mar 01, 2016 at 10:54:50PM +0900, Joonsoo Kim wrote:
> 2016-03-01 3:04 GMT+09:00 Dan Williams <dan.j.williams@intel.com>:
> > On Mon, Feb 29, 2016 at 1:33 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> >> The addition of tracepoints to the page reference tracking had an
> >> unfortunate side-effect in at least one driver that calls put_page
> >> from its exit function, resulting in a link error:
> >>
> >> `.exit.text' referenced in section `__jump_table' of crypto/built-in.o: defined in discarded section `.exit.text' of crypto/built-in.o
> >>
> >> From a cursory look at that this driver, it seems that it may be
> >> doing the wrong thing here anyway, as the page gets allocated
> >> using 'alloc_page()', and should be freed using '__free_page()'
> >> rather than 'put_page()'.
> >>
> >> With this patch, I no longer get any other build errors from the
> >> page_ref patch, so hopefully we can assume that it's always wrong
> >> to call any of those functions from __exit code, and that no other
> >> driver does it.
> >>
> >> Fixes: 0f80830dd044 ("mm/page_ref: add tracepoint to track down page reference manipulation")
> >> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> >
> > Acked-by: Dan Williams <dan.j.williams@intel.com>
> >
> > Vinod, will you take this one?
> 
> Problematic patch ("mm/page_ref: ~~~") is not yet merged one. It is on mmotm
> and this fix should go together with it or before it. I think that
> handling this fix by
> Andrew is easier to all.

Okay fine by me.

-- 
~Vinod

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
