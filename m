Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD2E0C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:47:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DDA421855
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:47:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="UPba+k+Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DDA421855
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF9278E00F3; Mon, 11 Feb 2019 10:47:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAADD8E00E9; Mon, 11 Feb 2019 10:47:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC0068E00F3; Mon, 11 Feb 2019 10:47:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 977908E00E9
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:47:19 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o9so8607785pgv.19
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:47:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eBZ8wmS5srFcgTYc5C3Sy0EQsf5bbpobNEiqppPAhpY=;
        b=V0H15npQWmIwizyZZgzbLKGEr+MxqvxGo3jOuSw8cQaZjWNC/VYmqdD8zoVuTZPtyx
         zTY2kB6pL5lqyYSkP1lR2dLS/uvRQ26NK4LxLh429sNwIwGnZbtrBOrMUkCqAL6TIw24
         SXq4KxRSN6Yp8Lvt08dvlKFqjxpnqYN3g75GXQpSjZFjboA/zFgFQM+xtqbpS4f7VjcS
         +V4jPwK6t4hcMzRIqfrb/6QAc3nFasxVguaaOLW+71bVewmZ99i1cih8OtelZ4fqAoKm
         b3ednUKCNDARVzEBNgPJxPLh/UyWRZm8zVPnckMusYCFI/wO70OqfDwcE0HADH67rOsA
         bxOg==
X-Gm-Message-State: AHQUAuaDdpBbf9nr9L4Ieog/+fOb/O1k5hsuDqY1+xdhlNCikW61Hzc9
	mSojdn8+Ustk2DGTgiehx8fDx+OIdboQnERmYfj3DB1ctNJGoR8VuZHIuTAtU38sa/RnR4ha7/I
	Q6N2UwgOnO00/Vxssxy/fJtkfvUNQinclJ7/mnA1fPIdgm3kzRxY0SWfqE7evxXRGisNl8fgYDE
	ts8FKzuhnLGMeFs/1cU/qI5ZX8MR6UDdL3B8fvrNLt8bIV258ZjKOBs39cK0YMuCpj0yJ2L+Lv+
	BIS06Kc+7bGdZ3SrVw9hPgLCz/wLEnoUTkN5ZkSF1bW86HpCYWwssTEOq/yn2030t3FxI342aZy
	BEmplCA2GQHAAX+hR67tIVFpApJG88S2HA+CShz8XFuz3rT0leiHmUXgZnrYOgpYB8w0aPP3vQW
	o
X-Received: by 2002:a62:190e:: with SMTP id 14mr37257668pfz.70.1549900039247;
        Mon, 11 Feb 2019 07:47:19 -0800 (PST)
X-Received: by 2002:a62:190e:: with SMTP id 14mr37257585pfz.70.1549900037880;
        Mon, 11 Feb 2019 07:47:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549900037; cv=none;
        d=google.com; s=arc-20160816;
        b=ndPtg57VUBoN8s/y2+xCOk4dKH65FTL6MdjS/22THdiee0XpS1ll/gy1ikjG2OQn++
         B/v3rn3ohrg3y/SGpbi8Auvwbb9zUeYwtnkk0q5m+fAh5Zy1kOfqegB/tF15SD8r5O2N
         +Bis/E7ZBanHv6q5Z3K76Dd0tLeXvBqvQdhFSTl60fmU7fbznzM1QkY/ZjxN6obFiEHq
         UOvq4lUMXHOOZfUfAjGjj1fsjva+hF4iYlDpwgzhx4ztwkt23t0M0S9rJlq8imRc9XBS
         DKAMGTzAlUNZkJ+1wYNPCfBWGvK54FGM0VJpDuLV06jTiCLDbhfhwJgK0qzeecj7DrzF
         4rnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eBZ8wmS5srFcgTYc5C3Sy0EQsf5bbpobNEiqppPAhpY=;
        b=NpjPxReMsXUzX5sUERlWPiGaf1LMcKB7i0WY3zLCAcZBwG+VfR0Ge145InoRTzrCkx
         9QwYSJChIQNt8Xv1erp9n717o9iEIei2a2HRW5ZGCzz9SShXeMs2Kzz5hSzoxfcVN3ZI
         rnexTknVBLdyScsKZfPSJn7RYB96eO+kRPOVK3nZHbx8pmlqnyypl72TxlHL4YHSTJMP
         JNVRywVs8fJ87oayag+LsI2R920q3Xx4msdqwC/SGdbn32ytIOzxseMZ3Ng+e7IQRsWS
         NF1lHdONk1h9jvt5byDDRUBMRUESo+C770JoAU/N7kcRMu/5emq8FTAZPqv624euxypA
         1KtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UPba+k+Q;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g188sor15626227pfc.61.2019.02.11.07.47.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 07:47:17 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UPba+k+Q;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eBZ8wmS5srFcgTYc5C3Sy0EQsf5bbpobNEiqppPAhpY=;
        b=UPba+k+QxDSXAHWgOHSqtNEgEvS1KUz8tFh2uTQSPnh3PQJOsmYqY6y4K3iHOjxKHf
         cgwopRnTGnxw01Y7QTkNCjLVtYNsn37wjpUu36jWC9qrKDsMWFc0VKuizHdErkb/jzmy
         383kI42iR+Z4Q34lMdlGgf2GMJhw6qs0LeJ7YrC46SPSgY3Tnc8TbOg4RiGctTzRllaK
         Hv16Sej7VdQ8OgPhCSmkNDL+12U/3i0pg9yXXGazBuiMttUCFTooMNi9NySE2NA8v6UN
         pjZa2FLT026g3t08HW8rqIz3CpfNGrCuqN/PA4yyp1zRFIrP+lVLGiRpv2fY7XESdIeD
         WVIQ==
X-Google-Smtp-Source: AHgI3IYO/I+emG2hCaNAo0q2p2ln6X81grX0lWg1PQSOLYZY6dYksyp2d8fkbdsnNDDY3dNpW5BKzZaWuS/fm3PT+mA=
X-Received: by 2002:a62:6047:: with SMTP id u68mr36814181pfb.239.1549900036827;
 Mon, 11 Feb 2019 07:47:16 -0800 (PST)
MIME-Version: 1.0
References: <20190209044128.3290-1-cai@lca.pw>
In-Reply-To: <20190209044128.3290-1-cai@lca.pw>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 11 Feb 2019 16:47:04 +0100
Message-ID: <CAAeHK+wKeqt2xvZfF5X4Z0dxLJqrdvDu894tFpGR172z0iVGRw@mail.gmail.com>
Subject: Re: [PATCH] slub: fix SLAB_CONSISTENCY_CHECKS + KASAN_SW_TAGS
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 9, 2019 at 5:41 AM Qian Cai <cai@lca.pw> wrote:
>
> Enabling SLUB_DEBUG's SLAB_CONSISTENCY_CHECKS with KASAN_SW_TAGS
> triggers endless false positives during boot below due to
> check_valid_pointer() checks tagged pointers which have no addresses
> that is valid within slab pages.
>
> [    0.000000] BUG radix_tree_node (Tainted: G    B            ): Freelist Pointer check fails
> [    0.000000] -----------------------------------------------------------------------------
> [    0.000000]
> [    0.000000] INFO: Slab 0x(____ptrval____) objects=69 used=69 fp=0x          (null) flags=0x7ffffffc000200
> [    0.000000] INFO: Object 0x(____ptrval____) @offset=15060037153926966016 fp=0x(____ptrval____)
> [    0.000000]
> [    0.000000] Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 18 6b 06 00 08 80 ff d0  .........k......
> [    0.000000] Object (____ptrval____): 18 6b 06 00 08 80 ff d0 00 00 00 00 00 00 00 00  .k..............
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [    0.000000] Redzone (____ptrval____): bb bb bb bb bb bb bb bb                          ........
> [    0.000000] Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G    B             5.0.0-rc5+ #18
> [    0.000000] Call trace:
> [    0.000000]  dump_backtrace+0x0/0x450
> [    0.000000]  show_stack+0x20/0x2c
> [    0.000000]  __dump_stack+0x20/0x28
> [    0.000000]  dump_stack+0xa0/0xfc
> [    0.000000]  print_trailer+0x1bc/0x1d0
> [    0.000000]  object_err+0x40/0x50
> [    0.000000]  alloc_debug_processing+0xf0/0x19c
> [    0.000000]  ___slab_alloc+0x554/0x704
> [    0.000000]  kmem_cache_alloc+0x2f8/0x440
> [    0.000000]  radix_tree_node_alloc+0x90/0x2fc
> [    0.000000]  idr_get_free+0x1e8/0x6d0
> [    0.000000]  idr_alloc_u32+0x11c/0x2a4
> [    0.000000]  idr_alloc+0x74/0xe0
> [    0.000000]  worker_pool_assign_id+0x5c/0xbc
> [    0.000000]  workqueue_init_early+0x49c/0xd50
> [    0.000000]  start_kernel+0x52c/0xac4
> [    0.000000] FIX radix_tree_node: Marking all objects used
> [    0.000000]
>
> Signed-off-by: Qian Cai <cai@lca.pw>

Reviewed-by: Andrey Konovalov <andreyknvl@google.com>

Thanks!

> ---
>  mm/slub.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 1e3d0ec4e200..075ebc529788 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -507,6 +507,7 @@ static inline int check_valid_pointer(struct kmem_cache *s,
>                 return 1;
>
>         base = page_address(page);
> +       object = kasan_reset_tag(object);
>         object = restore_red_left(s, object);
>         if (object < base || object >= base + page->objects * s->size ||
>                 (object - base) % s->size) {
> --
> 2.17.2 (Apple Git-113)
>

