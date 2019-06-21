Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2FB6C48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 01:14:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D7F32089C
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 01:14:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="djrFsjLH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D7F32089C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 283D26B0005; Thu, 20 Jun 2019 21:14:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 234ED8E0002; Thu, 20 Jun 2019 21:14:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 122CE8E0001; Thu, 20 Jun 2019 21:14:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D220B6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 21:14:36 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id c18so2981254pgk.2
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 18:14:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=+Rqfc2bA+fnXQgN7YQtYM/1zIcaEIZPnWRvBpDXqHkw=;
        b=MCIfGGK5nymv3+UOrO5Lo5c3TvkoiDzSEulv7PqDCEmMQiRQgi4//tPj3hRFZUqeIq
         DfZiAmCngIUyp9ikZD9470Ntim9naA3eisDxueOpc4KRbB4RBMsAOW6tjwv4IHJz2jaY
         MyVbix+k4kX2wEQ5zoNzCOMNnLjIjvMmcsFvfQE5g0nfi8xSV3F3iqzYy+N3FkfFM6PL
         wFYs7iBMgpKwDqwHWHHaHbgCHn2wFHUaAVjGNhjaAoWZ41fMdv3cwFpUlxd6/82tKNmo
         nBvvOFqT96+SP8Xz/uXlSVnKGEUxFGWM+SEBdKrjNYFuNTIdMUAxFv2vtzBORAAaxClU
         mTCA==
X-Gm-Message-State: APjAAAWATgrqfGo1YVGZXArl7n8vpwzt6qGBt/8rs00PghrnMgEnCofL
	dT0szoI/gbxGrzvwnEesQnGV8PCfmU/0lMP5acDZbVL+yu7kKrpjfiafXtjC21xZRKBvylAMfzG
	xKIxEowVoZ0IewxcyUJnsTZJ6pQSd1RJNQoaiYZIN5D4qXBuPhGhumVPurEAQTO2Rrw==
X-Received: by 2002:a65:448b:: with SMTP id l11mr15152831pgq.74.1561079676338;
        Thu, 20 Jun 2019 18:14:36 -0700 (PDT)
X-Received: by 2002:a65:448b:: with SMTP id l11mr15152773pgq.74.1561079675503;
        Thu, 20 Jun 2019 18:14:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561079675; cv=none;
        d=google.com; s=arc-20160816;
        b=sAkwC36ZBAl26J8cHBp3PnH2UPNbSCAaU4X7g2nMiLv/CCulhPLTbtTA5gFGthN3BI
         xGVyrV5gg9QeYomELcfCwn/x0o+fhiZ5ME6WdTtsTL9fSxZFOW211nKx/LaOVxJxVX7h
         Mf/DEFDKDG0HHFFd7Kd741GKqvkoSbYk0EzK5W90SefgsgIDtQaC6wEP/16UvpiskdX0
         Xn/81vXlvmw9aJc+MwiqTcgMXQ8tzM0e1+IUDIkfIyZg9DNSMMZs9qJm9tAGV7gppwLJ
         GRpvuYdxqcTTnTlIt1+YnryItUFqHuzn97xO6twDD9PcqBUBZbmQA/GCErM33Wn/mdeA
         eHiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=+Rqfc2bA+fnXQgN7YQtYM/1zIcaEIZPnWRvBpDXqHkw=;
        b=BTxhAAqouV+s5Uu2L8pH5OmPB5hOBxM1r/SBp47MACP06s9CCjvZPMsmqQU/e1GR0X
         InmvT7ELE91Oy2rxSSTGYq8hY8w3NapqOsmjjBVbXprjVjoK/GsdLQFMULG3pliYWunt
         bJ6ozf+YUvY1ZFJizgIh53UoTmOurYypo1xYuKuxkbQe5kDOAEWJUUubMKkIFE6P9MZg
         Ir0LstaUw0TYV7NC39GAiQfb/+t26RGaBHOzweZlFAzEyu16LXKtmfd3WTbtkJdARHmf
         M/a74oVJGGKbb6F3uh0Fts+T1OlQDyd2QnxPIeVjoMKclXYQVL/7Npg0ZaNiB4z+dz6f
         30uQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=djrFsjLH;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20sor1119440pgv.84.2019.06.20.18.14.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 18:14:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=djrFsjLH;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=+Rqfc2bA+fnXQgN7YQtYM/1zIcaEIZPnWRvBpDXqHkw=;
        b=djrFsjLHM1Ly2V/j+y8EH1ORnAnQiQZnJSaXoqrrE9VvHJrKlTYIkkm4GoTDkqKH2h
         C0U/Vl+BrxUqvwW9F1OqjYIrgyoPDLasJllGOYU0q+rBAK7v5sCIK0lL4/JHf9t0rpbX
         bzAYUdfByH01xkNH3xG1AwkNY6l8Se0ZghAuE=
X-Google-Smtp-Source: APXvYqwQqyZ1NK7/fCgJr+y9F1qgcpuG2veGPcIMSQHKtad6ZYQCS1s/ZEmnw66xSlH5lSt873b4Ow==
X-Received: by 2002:a63:456:: with SMTP id 83mr10284584pge.67.1561079675028;
        Thu, 20 Jun 2019 18:14:35 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id r88sm900755pjb.8.2019.06.20.18.14.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 20 Jun 2019 18:14:34 -0700 (PDT)
Date: Thu, 20 Jun 2019 18:14:33 -0700
From: Kees Cook <keescook@chromium.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, glider@google.com, cl@linux.com,
	penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH -next] slub: play init_on_free=1 well with SLAB_RED_ZONE
Message-ID: <201906201812.8B49A36@keescook>
References: <1561058881-9814-1-git-send-email-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561058881-9814-1-git-send-email-cai@lca.pw>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 03:28:01PM -0400, Qian Cai wrote:
> The linux-next commit "mm: security: introduce init_on_alloc=1 and
> init_on_free=1 boot options" [1] does not play well with SLAB_RED_ZONE
> as it will overwrite the right-side redzone with all zeros and triggers
> endless errors below. Fix it by only wiping out the slab object size and
> leave the redzone along. This has a side-effect that it does not wipe
> out the slab object metadata like the free pointer and the tracking data
> for SLAB_STORE_USER which does seem important anyway, so just to keep
> the code simple.
> 
> [1] https://patchwork.kernel.org/patch/10999465/
> 
> BUG kmalloc-64 (Tainted: G    B            ): Redzone overwritten
> 
> INFO: 0x(____ptrval____)-0x(____ptrval____). First byte 0x0 instead of
> 0xcc
> INFO: Slab 0x(____ptrval____) objects=163 used=4 fp=0x(____ptrval____)
> flags=0x3fffc000000201
> INFO: Object 0x(____ptrval____) @offset=58008 fp=0x(____ptrval____)
> 
> Redzone (____ptrval____): cc cc cc cc cc cc cc cc
> ........
> Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> ................
> Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> ................
> Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> ................
> Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> ................
> Redzone (____ptrval____): 00 00 00 00 00 00 00 00
> ........
> Padding (____ptrval____): 00 00 00 00 00 00 00 00
> ........
> CPU: 0 PID: 1 Comm: swapper/0 Tainted: G    B
> 5.2.0-rc5-next-20190620+ #2
> Call Trace:
> [c00000002b72f4b0] [c00000000089ce5c] dump_stack+0xb0/0xf4 (unreliable)
> [c00000002b72f4f0] [c0000000003e13d8] print_trailer+0x23c/0x264
> [c00000002b72f580] [c0000000003d0468] check_bytes_and_report+0x138/0x160
> [c00000002b72f620] [c0000000003d33dc] check_object+0x2ac/0x3e0
> [c00000002b72f690] [c0000000003da15c] free_debug_processing+0x1ec/0x680
> [c00000002b72f780] [c0000000003da944] __slab_free+0x354/0x6d0
> [c00000002b72f840] [c00000000015600c]
> __kthread_create_on_node+0x15c/0x260
> [c00000002b72f910] [c000000000156144] kthread_create_on_node+0x34/0x50
> [c00000002b72f930] [c000000000146fd0] create_worker+0xf0/0x230
> [c00000002b72f9e0] [c00000000014fc6c] workqueue_prepare_cpu+0xdc/0x280
> [c00000002b72fa60] [c00000000011b27c] cpuhp_invoke_callback+0x1bc/0x1220
> [c00000002b72fb00] [c00000000011e7d8] _cpu_up+0x168/0x340
> [c00000002b72fb80] [c00000000011eafc] do_cpu_up+0x14c/0x210
> [c00000002b72fc10] [c000000000aedc90] smp_init+0x17c/0x1f0
> [c00000002b72fcb0] [c000000000ac4a4c] kernel_init_freeable+0x358/0x7cc
> [c00000002b72fdb0] [c0000000000106ec] kernel_init+0x2c/0x150
> [c00000002b72fe20] [c00000000000b4cc] ret_from_kernel_thread+0x5c/0x70
> FIX kmalloc-64: Restoring 0x(____ptrval____)-0x(____ptrval____)=0xcc
> 
> FIX kmalloc-64: Object at 0x(____ptrval____) not freed
> 
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  mm/slub.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index a384228ff6d3..787971d4fa36 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1437,7 +1437,7 @@ static inline bool slab_free_freelist_hook(struct kmem_cache *s,
>  		do {
>  			object = next;
>  			next = get_freepointer(s, object);
> -			memset(object, 0, s->size);
> +			memset(object, 0, s->object_size);

I think this should be more dynamic -- we _do_ want to wipe all
of object_size in the case where it's just alignment and padding
adjustments. If redzones are enabled, let's remove that portion only.

-Kees

>  			set_freepointer(s, object, next);
>  		} while (object != old_tail);
>  
> -- 
> 1.8.3.1
> 

-- 
Kees Cook

