Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D93BC31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 13:40:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 534BE20823
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 13:40:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="QooPXmn9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 534BE20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAB608E0002; Tue, 18 Jun 2019 09:40:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E34E28E0001; Tue, 18 Jun 2019 09:40:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D22A78E0002; Tue, 18 Jun 2019 09:40:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B09A08E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:40:40 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p43so12385195qtk.23
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 06:40:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZI5wHdiFgtuzsQeLY+E22h5PJMnK0tB2yGyNBxZfSqI=;
        b=H7iH4wojhANq55iYM2J/o2Cry7JFtyEXaPrL6S/oSB8AzxqRfH90Al11Z+OaahKN+g
         soOtZjZ/eco9BlL3JU8cnCzDm//PNTV5c3qRSckpETjF65/C/uGpFv38HpJQph1xGHJE
         rqQ74CQAFr9vo+GVlgvNvQpj5P8bEWg0WuBDbdSNM9+znrsw53M/8uYe/bOlWiWkviH4
         SlDsHSa2QXInb8SAIoTwIdyS0Z7fIea+vdViF1ChLgywucDabmc3ui/U0mhDzZIZD2PZ
         G8MOSRWHPW8F3JyfDI9hDDU3v2wJZ4HxUIKR0kDpZle+30xU9xNDkMvWjESR+HWO/NhB
         MX2A==
X-Gm-Message-State: APjAAAXGneP3dHRtVb6MOkHi8J5Ym9WkLSvU+ITJNuMPLfUO1QnreH70
	tJ3q2uLSLLxvIOGSqw4JS8fmSyig/xgtSxBfgND8MP+aPO+pWanhIDVonMwm3dx+g43rLUMSiIP
	mvdfDkmYQtdoEJnIIHIcU3xwwFk7vn0hw64AO9PeZGZzexmLaPzhH9vJSwvE1EQPkhg==
X-Received: by 2002:a37:7bc3:: with SMTP id w186mr94328215qkc.225.1560865240459;
        Tue, 18 Jun 2019 06:40:40 -0700 (PDT)
X-Received: by 2002:a37:7bc3:: with SMTP id w186mr94328133qkc.225.1560865239844;
        Tue, 18 Jun 2019 06:40:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560865239; cv=none;
        d=google.com; s=arc-20160816;
        b=SqdNKrHaEja9DCV4SUOFbBNLaudEz5KjQlal4az5z36gbtySJF7rpM5tQFxZZD8eBU
         3oYEQTsB1fB6nXPwt1SHz1yingTxHLOfvSL1uAnxQFiHzhU5M3gPZkRmAnWuP2rK1+NI
         NBTHe51pzu7yvDXUVqA+MnYUehc7z/EFuOgisRir7HsnAbhsfKVY2jOx2becCukrxqU8
         cQLGlak/DknSc8zELzYnTFU89PpkJlLvtsdSa+R/txWhRjWJPdrWkww9XZjwk8g98CoN
         MMmS4b55ob/qERw2PxXKF9oyQwfk0T+e6AD7l9RaMQLhPradQIR5r6bYigBLMc56baAO
         EP2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZI5wHdiFgtuzsQeLY+E22h5PJMnK0tB2yGyNBxZfSqI=;
        b=l+30Cyp1oC3FAfbCOjYmzZo1wbqPV/tJI7Awcdbijq+sSsjrDQLyfaymJxYDcDuZDT
         zi+tfvZ12hpaoRiGkppDOtvFLZ6nyAgxkcI7CAgf3Li8AXNgHolK/2XhrWmuGtYG/Y3W
         GMliGxF2pT4pYuxVCtCdipOngPj8pLfivLp3SiSweF0YVeDpk2Izbic836ds6v6iPwg6
         +P+HAuZ/mGgUchBpJOdeyfrcLRm/cgF3mOkCbneiPEiBb6SCDk5pkxzXr2Z+R0PuFNZk
         DwSIC/B9F4nC0FS8PFTU/394o5yyDfYJ+7gj0/9pRFYSHc25e2wM9P0zwK3LzTSEgims
         UreA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QooPXmn9;
       spf=pass (google.com: domain of joelaf@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=joelaf@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3sor9000133qki.54.2019.06.18.06.40.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 06:40:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of joelaf@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QooPXmn9;
       spf=pass (google.com: domain of joelaf@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=joelaf@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZI5wHdiFgtuzsQeLY+E22h5PJMnK0tB2yGyNBxZfSqI=;
        b=QooPXmn9aHah5NAlG4PfOfya5KeBRPEo/cvd64QxdYAB2AkodS68j+GjfPi84y88a8
         DuB0moLc60pdiekoXOCOsAxtghv/tzyS0Zmk+0MTZYsCOMvXwdivw9V7wUKoLv6q4Axg
         5s6bDCqaOyBCLr0QLrvUxRJ36c87CczbZqr7489CDIbk5w73LorhbzV6/p+ILdWmi3EO
         QBo9JXpFB/Ht4FqcBxvorRa1+QvlOIMjcuwGXXSs2RW1sMA4cGX4JDaIo7BcsPKhNArX
         7PXLzk7LUCtr49cSwuHKA+oMLhBIasoWAkwIyRCAeENSKRYKtox2kQoezDn3ZK5Mwul7
         Q7yw==
X-Google-Smtp-Source: APXvYqydIfBeJNwoqU7hLKDek16QVNj311nTvALhVsaWemQl/rKnPG8IXP59Ccqe5Lnh87RqflvTK1whFaMyh7g4f+8=
X-Received: by 2002:a37:696:: with SMTP id 144mr91098200qkg.250.1560865239273;
 Tue, 18 Jun 2019 06:40:39 -0700 (PDT)
MIME-Version: 1.0
References: <20190618092650.2943749-1-arnd@arndb.de>
In-Reply-To: <20190618092650.2943749-1-arnd@arndb.de>
From: Joel Fernandes <joelaf@google.com>
Date: Tue, 18 Jun 2019 09:40:28 -0400
Message-ID: <CAJWu+oqzd8MJqusRV0LAK=Xnm7VSRSu3QbNZ-j5h9_MbzcFhhg@mail.gmail.com>
Subject: Re: [PATCH] mm/vmalloc: avoid bogus -Wmaybe-uninitialized warning
To: Arnd Bergmann <arnd@arndb.de>
Cc: Roman Penyaev <rpenyaev@suse.de>, Uladzislau Rezki <urezki@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, 
	Matthew Wilcox <willy@infradead.org>, Thomas Garnier <thgarnie@google.com>, 
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Rick Edgecombe <rick.p.edgecombe@intel.com>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 5:27 AM Arnd Bergmann <arnd@arndb.de> wrote:
>
> gcc gets confused in pcpu_get_vm_areas() because there are too many
> branches that affect whether 'lva' was initialized before it gets
> used:
>
> mm/vmalloc.c: In function 'pcpu_get_vm_areas':
> mm/vmalloc.c:991:4: error: 'lva' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>     insert_vmap_area_augment(lva, &va->rb_node,
>     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>      &free_vmap_area_root, &free_vmap_area_list);
>      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> mm/vmalloc.c:916:20: note: 'lva' was declared here
>   struct vmap_area *lva;
>                     ^~~
>
> Add an intialization to NULL, and check whether this has changed
> before the first use.
>
> Fixes: 68ad4a330433 ("mm/vmalloc.c: keep track of free blocks for vmap allocation")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  mm/vmalloc.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index a9213fc3802d..42a6f795c3ee 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -913,7 +913,12 @@ adjust_va_to_fit_type(struct vmap_area *va,
>         unsigned long nva_start_addr, unsigned long size,
>         enum fit_type type)
>  {
> -       struct vmap_area *lva;
> +       /*
> +        * GCC cannot always keep track of whether this variable
> +        * was initialized across many branches, therefore set
> +        * it NULL here to avoid a warning.
> +        */
> +       struct vmap_area *lva = NULL;

Fair enough, but is this 5-line comment really needed here?

- Joel

