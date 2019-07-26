Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79C50C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 21:10:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 286DD22BE8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 21:10:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="J0efhXeS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 286DD22BE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B44266B0003; Fri, 26 Jul 2019 17:10:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF5748E0003; Fri, 26 Jul 2019 17:10:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E2378E0002; Fri, 26 Jul 2019 17:10:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7EBDB6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 17:10:30 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id y13so60025954iol.6
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 14:10:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CnFsEo54QQCUj7cKXF+4BGmh5A92hzW17n6M7jlYUc0=;
        b=Ax74C/zhgZbdKAolSWDjFRkUOZADyLvVdi18W+LJVl/3MTk55YW2Y14iEuQuu8XgDN
         6jl+Eoc8gk7lZMpyaZ4TKO/7dJyTBpXzCtnt4VrNSOlettAfHcAlzanqqWa8IQRMBKRM
         nzxP0oBUdFJmEIKtiff5TqhRqRISbparJsqkFvVLbFirH+NX8qNMAaoEB6FOL7jpSWZ+
         OCh9jCtivXsLifeDH0nhmWMlYKMgQPF3GnmjlNk7TyWf5SIRKms4fOxtTrP7Hcdtpt4c
         yp59JIhPUL64vADvsPC4L7jXKSw1HQ6oHg1auIacwihXUWSbpGKRl8hNl+wjFWTUboLe
         atmA==
X-Gm-Message-State: APjAAAVNtCm/aQR1i3FSetpC/M3Aoc3FaCcDoWZAHrAmSSgC0naRH/5M
	SMsnerH+CFGXWBlvLZE9g6+DXzl3wsgceQzVhytG3XthpUg5lg66+jMlM1+kw9O4eVRQ0ZY/Wfg
	ABXqTfU89yVyO3vIWCoiFRiJQP39P7e7OtnT/4M97v0NU9jaHnu/gE225Bu/Z7WzUBw==
X-Received: by 2002:a02:9004:: with SMTP id w4mr75353167jaf.111.1564175430272;
        Fri, 26 Jul 2019 14:10:30 -0700 (PDT)
X-Received: by 2002:a02:9004:: with SMTP id w4mr75353110jaf.111.1564175429586;
        Fri, 26 Jul 2019 14:10:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564175429; cv=none;
        d=google.com; s=arc-20160816;
        b=QF5hhbO+lA9GrImGkCcU6SNrc2rk0EIg+jKdgEeUmBvFr0Ma13A+pQUKP93S0aTWgd
         P7hNfK/l6LV3k5IrViy1PInHVraT5jTB6AQKkO9tarDxwIUlRSYFEs5rbTA8/DdE1Z5s
         KxTa4mKiAIRefmJFl5GTpWopTBcArxgG6IzzNg7OR4/Meh7krKi4k8IIrBH+xJfMbL7u
         SAJaL+2TGJLFZqUzHaRYJph9AfhEozLuJIwGpgXavL/KibdpObKLEx3ef37BoyQhW1jy
         kBXzynjEVhY9g2XvLW6Wl/yNjJuHPn9UD9JSuSZIbcit1R3zE+MkMQ9W02bAGFPkAwfg
         dr/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CnFsEo54QQCUj7cKXF+4BGmh5A92hzW17n6M7jlYUc0=;
        b=mzhnUJnQatwxG2SePuYz+x6rfcH8E4S3n5QMeGyX+yTdIXMa5vz+1HWbwpjP+NAW5Z
         xvDVPGCm5dNt8rgQ1DFMtncg7yPAWlU+s0Uo13/QV4A3oeA4zAbsMfbUuPB9bv+Vd+69
         qyFAUGM1q/vh/f0CdZAgIn+XxfWIyuKzPiX3Hbi+M4RhhYV45NqBf+P6daoyCQHOydjC
         0c2fvCAkeC/uSGne/mATQ8CRV6YuvsQSkAIGMrNX6eEixdbzbwkGP+R50dqw53Eh3Krm
         Zk9qO2MsCQguHbuOzB/ivGVW1rxRwSO+9gfRSpsQrXzpnugqdi1z3DEUPWAef2PYXIPu
         VjhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=J0efhXeS;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l9sor36704683iom.67.2019.07.26.14.10.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 14:10:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=J0efhXeS;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CnFsEo54QQCUj7cKXF+4BGmh5A92hzW17n6M7jlYUc0=;
        b=J0efhXeSqIUk7WkBdOyv4VzzdnTeBgFVPjWAZe5wML9pAmd1SbqhR4oq66HWtOqUJU
         2712cWU2K32JLLUedtqpPz+8xMM2Wa+pMNGDyxeOs8f35KCXzq5SXBgjpc+JFQyskZVp
         A2y98FWuywv+ypUeMd0Dk5/2FbSSTdv/vkv2PxAB1Dp/djLa6qRapUKsRhQhbNVJGMUx
         HTgThLjpxOdu+6GthZrTfiIUagwZ0b/SKUru19GOCcdaAK/nLgXfJFZbzq92JvIXidX5
         RJj4OpOG5GuTmNCqpQ9h0UkJGotM2gtIPpBiX88lkuV03qQ98felCFHcPBBA2Nm+gi1Z
         59zw==
X-Google-Smtp-Source: APXvYqwCY2wDc1hmXYnJZNoj6DLIuQys/RphK6WMSWlX/M3S6waa0t3YkBmQ3MMP1SIV4lt841KTJFqYoFyiTmFdjjA=
X-Received: by 2002:a05:6602:2256:: with SMTP id o22mr3863805ioo.95.1564175429170;
 Fri, 26 Jul 2019 14:10:29 -0700 (PDT)
MIME-Version: 1.0
References: <20190726210137.23395-1-willy@infradead.org>
In-Reply-To: <20190726210137.23395-1-willy@infradead.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 26 Jul 2019 14:10:18 -0700
Message-ID: <CAKgT0UcMND12oZ1869howDjcbvRj+KwabaMuRk8bmLZPWbJWcg@mail.gmail.com>
Subject: Re: [PATCH] mm: Make kvfree safe to call
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Luis Henriques <lhenriques@suse.com>, 
	Christoph Hellwig <hch@lst.de>, Carlos Maiolino <cmaiolino@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 2:01 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
>
> Since vfree() can sleep, calling kvfree() from contexts where sleeping
> is not permitted (eg holding a spinlock) is a bit of a lottery whether
> it'll work.  Introduce kvfree_safe() for situations where we know we can
> sleep, but make kvfree() safe by default.
>
> Reported-by: Jeff Layton <jlayton@kernel.org>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Luis Henriques <lhenriques@suse.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Carlos Maiolino <cmaiolino@redhat.com>
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

So you say you are adding kvfree_safe() in the patch description, but
it looks like you are introducing kvfree_fast() below. Did something
change and the patch description wasn't updated, or is this just the
wrong description for this patch?

> ---
>  mm/util.c | 26 ++++++++++++++++++++++++--
>  1 file changed, 24 insertions(+), 2 deletions(-)
>
> diff --git a/mm/util.c b/mm/util.c
> index bab284d69c8c..992f0332dced 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -470,6 +470,28 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  }
>  EXPORT_SYMBOL(kvmalloc_node);
>
> +/**
> + * kvfree_fast() - Free memory.
> + * @addr: Pointer to allocated memory.
> + *
> + * kvfree_fast frees memory allocated by any of vmalloc(), kmalloc() or
> + * kvmalloc().  It is slightly more efficient to use kfree() or vfree() if
> + * you are certain that you know which one to use.
> + *
> + * Context: Either preemptible task context or not-NMI interrupt.  Must not
> + * hold a spinlock as it can sleep.
> + */
> +void kvfree_fast(const void *addr)
> +{
> +       might_sleep();
> +
> +       if (is_vmalloc_addr(addr))
> +               vfree(addr);
> +       else
> +               kfree(addr);
> +}
> +EXPORT_SYMBOL(kvfree_fast);
> +
>  /**
>   * kvfree() - Free memory.
>   * @addr: Pointer to allocated memory.
> @@ -478,12 +500,12 @@ EXPORT_SYMBOL(kvmalloc_node);
>   * It is slightly more efficient to use kfree() or vfree() if you are certain
>   * that you know which one to use.
>   *
> - * Context: Either preemptible task context or not-NMI interrupt.
> + * Context: Any context except NMI.
>   */
>  void kvfree(const void *addr)
>  {
>         if (is_vmalloc_addr(addr))
> -               vfree(addr);
> +               vfree_atomic(addr);
>         else
>                 kfree(addr);
>  }
> --
> 2.20.1
>

