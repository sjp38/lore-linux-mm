Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5811C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:21:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D5AE22C7B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:21:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fA9HlS2N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D5AE22C7B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDAF48E0005; Thu, 25 Jul 2019 10:21:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8B5F8E0003; Thu, 25 Jul 2019 10:21:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D530A8E0005; Thu, 25 Jul 2019 10:21:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC9328E0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:21:47 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id f143so19628811oig.22
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:21:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=p0zCRge4IyR2wlfjUSbezvebKIU/ZeQqbglizi25Hnc=;
        b=LcZz5c8mMMNv6QzIQsw9FiqMU+RJpQc75SQxHnaN/T4o69qzHzEsYcaKglD2D/hc7l
         TLwI5kbFckLf+AgwanprEvHyele3EfGFSoLae2TcBV5anQDRfGKT0w6eTYCiYTTVgjyo
         lboBz5Ah1mGYOAtSe6khbikly1thq/ITBpqYi5XT+9XGPgaa8lRROTd7alLHSVjaEcwS
         OfzkfLMfY8XZj2/Cv4l11rFoKS9BXV4wZIIAs2BHWoQH+XwNURORUTkc0D95a1yIW6JQ
         K3rnC+UZDx8IYNfkl0a4eEfq9eiHoTq3IopM0JPf2o6NFUVFfberRMl47k3v37rMEEIz
         BU/A==
X-Gm-Message-State: APjAAAU/HQ5XHT5QSa9hsmrrpJCafs8Jned/SURq8vrjaGHB60C2XEBa
	wD7YxwY43PGa8ZHASst5VGmk0ppUJCov9gItC7Q8oz9ys+44l1UoXSmyySWtnwDwQrkL/Kwgp5d
	MB5P0EkWLPoZfI/kEoHqfCBGH2hJxepA35WJYBWZ8Q4hXesz6g9EGH9pptqmzs2xDBw==
X-Received: by 2002:aca:3808:: with SMTP id f8mr42224487oia.158.1564064507245;
        Thu, 25 Jul 2019 07:21:47 -0700 (PDT)
X-Received: by 2002:aca:3808:: with SMTP id f8mr42224450oia.158.1564064506468;
        Thu, 25 Jul 2019 07:21:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564064506; cv=none;
        d=google.com; s=arc-20160816;
        b=rALa99Z33UH6OYZjn7rLNFKTp5N10NepIUyGReaRrpTMIzy5n4p+zLX+p4Vfk54YVC
         DuRnj+OTP2qDLzoED4RGmOXktFwq/Lb0Y1d1m+Eb/jtr7HhFB2hod+A5mHWHQpPkpK5L
         n9eZDbh7rroDrY3c9FARSohqxlyJ9sMOWKV0K+KqEs4J/7UWxBeVvlxqwqO0coyztBv0
         BhBPrLz3EMXJ/RKyWfTjJsID+9QNxVAY7hf12rFmR2n8z0EpYe44fFt3eKAmClP3YJMG
         8m8YrWhXvuBcFIHZXKfm+0wNZP6pr6WVC9lXrWO0qNf3XKgO24pkIBjeTaXORBxWrEsj
         wMew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=p0zCRge4IyR2wlfjUSbezvebKIU/ZeQqbglizi25Hnc=;
        b=GAZy2yZKAKSf86TjlTYCZ/ILERjdDtJY3eC62qC6X2NQHGCtSflla/LAfvazwHK98O
         n37msJMQKM2vnJdwziG2p1/Tti363oe6fBeXedWRlZ7gv1bUt892CkPJZljgbZcsWzO0
         irQSl+0Y1eZi4tPsTs62ehorVuOTuH/j326i6c11Elrn8aLoOCxKnClrRsoAqUdn3mnV
         kvb9MdtVzbYQwDEZ+ivrC42VqO0ojAuj+lkYuNFhNpTtXyD93VJ/LNsbmJc7oNvEo/XE
         rOk1BemYgfs+nN7wxevwpGgiHowH/yHVcdFUcIQuEyO1ShL2m7pWBC1bf/Owf4M7Dwml
         VkbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fA9HlS2N;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t17sor26795673otl.150.2019.07.25.07.21.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 07:21:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fA9HlS2N;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=p0zCRge4IyR2wlfjUSbezvebKIU/ZeQqbglizi25Hnc=;
        b=fA9HlS2NA+mqlLSk8D6kP778L1e3wK4+NbKw7veEzErPD2TgOeK3SY+5AXDqI8qkok
         6xoRISMUNVjk3vANwDKjwCLy8Grl5UaqrIpDyDMwYSb9aKRg0Cv5yeVQCORdHWHQLuZj
         O1TBBjM5fbgumkoW9ecLGcude/8nHJa54JktiPhZTagj37GJHLwvwXNLfxiTwhMmnped
         mYHWRpmvr6PwPAtfwIoCGsv9bn06rejj2xLY280jWBQaXI7A3CbGaR2lnH9IXX/m+iSv
         926o5fJKEbVpp1C4wpXSiyvRKtwfAZxVY6joaUzc4DrY+LYkXMR4KXs1E5V6Fmk8n2f3
         GNNg==
X-Google-Smtp-Source: APXvYqwmXc5yVMJE6L7+bhpGYYiXCwSadkoyKo4JYb9tEs1Es0bf1DgrK5Xaxq2GT032GnRfxzVy/ElYYbZfmB8Qy/w=
X-Received: by 2002:a9d:73c4:: with SMTP id m4mr38862075otk.369.1564064506211;
 Thu, 25 Jul 2019 07:21:46 -0700 (PDT)
MIME-Version: 1.0
References: <20190716152656.12255-1-lpf.vector@gmail.com> <20190716152656.12255-2-lpf.vector@gmail.com>
 <20190724193637.44ced3b82dd76649df28ecf5@linux-foundation.org>
In-Reply-To: <20190724193637.44ced3b82dd76649df28ecf5@linux-foundation.org>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Thu, 25 Jul 2019 22:21:34 +0800
Message-ID: <CAD7_sbEGno-o=zh=VJQOXPZ=ppcTF3h_UWAXo6dXFnBJcTNTrA@mail.gmail.com>
Subject: Re: [PATCH v6 1/2] mm/vmalloc: do not keep unpurged areas in the busy tree
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Uladzislau Rezki <urezki@gmail.com>, rpenyaev@suse.de, 
	peterz@infradead.org, guro@fb.com, rick.p.edgecombe@intel.com, 
	rppt@linux.ibm.com, aryabinin@virtuozzo.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>

On Thu, Jul 25, 2019 at 10:36 AM Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> On Tue, 16 Jul 2019 23:26:55 +0800 Pengfei Li <lpf.vector@gmail.com> wrote:
>
> > From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
> >
> > The busy tree can be quite big, even though the area is freed
> > or unmapped it still stays there until "purge" logic removes
> > it.
> >
> > 1) Optimize and reduce the size of "busy" tree by removing a
> > node from it right away as soon as user triggers free paths.
> > It is possible to do so, because the allocation is done using
> > another augmented tree.
> >
> > The vmalloc test driver shows the difference, for example the
> > "fix_size_alloc_test" is ~11% better comparing with default
> > configuration:
> >
> > sudo ./test_vmalloc.sh performance
> >
> > <default>
> > Summary: fix_size_alloc_test loops: 1000000 avg: 993985 usec
> > Summary: full_fit_alloc_test loops: 1000000 avg: 973554 usec
> > Summary: long_busy_list_alloc_test loops: 1000000 avg: 12617652 usec
> > <default>
> >
> > <this patch>
> > Summary: fix_size_alloc_test loops: 1000000 avg: 882263 usec
> > Summary: full_fit_alloc_test loops: 1000000 avg: 973407 usec
> > Summary: long_busy_list_alloc_test loops: 1000000 avg: 12593929 usec
> > <this patch>
> >
> > 2) Since the busy tree now contains allocated areas only and does
> > not interfere with lazily free nodes, introduce the new function
> > show_purge_info() that dumps "unpurged" areas that is propagated
> > through "/proc/vmallocinfo".
> >
> > 3) Eliminate VM_LAZY_FREE flag.
> >
> > Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
>
> This should have included your signed-off-by, since you were on the
> patch delivery path.  (Documentation/process/submitting-patches.rst,
> section 11).
>
> Please send along your signed-off-by?

