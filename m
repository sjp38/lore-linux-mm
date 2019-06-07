Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74458C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:08:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31FDE208C0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:08:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CI1ZG2by"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31FDE208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC91A6B0269; Fri,  7 Jun 2019 16:08:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C79956B026A; Fri,  7 Jun 2019 16:08:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B405F6B026B; Fri,  7 Jun 2019 16:08:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA156B0269
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:08:10 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id e20so356266ljg.11
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:08:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QDK3Ccwx6XT9W6QHiKSRwInuQJSgvhMen0AzjEbYCA8=;
        b=KE3LntD2cnM4f3Ng5Ooa8foPuaFQZkRdRdaxbxI2B7/nxZLXDg2Pm63PRjgt7tVMM1
         TBgW33W627rjXD4PCPANhElbJabzicWyOCcYtixjEfiu5vQ60GQglzuoT/TcBTfLSgI6
         6Mq49ZySUKHYgQCkkFwMUjNBpE2N8vsn6+OT3bAtYyF7b4Y7SRQjokjJCchsoh6DNAxQ
         L3SVUZ5ZUSvy+zSkZZsTXtf7Gj31ndWm+u22gSltmysxMjZduTm5NaBxGqPSi+DG8Dnf
         H9mf0u9kX/l/IHA0kn/qY2R3VfyuZbLnt+6T/ReeXX4TK49ww9on/ceXBSRcr5rX1dHX
         /PyQ==
X-Gm-Message-State: APjAAAVHw7NLzxZFwf2F6fqJ+sOeswFP8MhQZsAjsIWfnn8WSmXL4PdS
	GI+6Y0jM/dFxeywPp9Buq964mcMF/BPrdltONCs75UtINL28qAet3EAfOsg/bTcrI/1Jb1ehNJW
	KCHVyw0vRPF9QbwcF6ELBzrtiIRRrMD1pXU8M2PDpLS4eZWp+I/UUndsLgxw4VecDeA==
X-Received: by 2002:a2e:9a13:: with SMTP id o19mr5228375lji.102.1559938089651;
        Fri, 07 Jun 2019 13:08:09 -0700 (PDT)
X-Received: by 2002:a2e:9a13:: with SMTP id o19mr5228337lji.102.1559938088949;
        Fri, 07 Jun 2019 13:08:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559938088; cv=none;
        d=google.com; s=arc-20160816;
        b=mzBuU2KZJOQZEaLlSXGooDJS3TAs65pZb24gd6VZn5WkZYoUCV1lbMDGlEAUvcJ0/1
         YZKkQdeOjyUiXhQlYuMS7JnkrM0582LCoVOse+Xe4rXu2rAOYBPp7NKLZGRKKj77LjkA
         uwSrRlJReUfxmYPu+vQGMGnhplRQ1q077deDrd9PCPQWhcy2JUmuYHoouyb5VN6O6Wh0
         fGDeopV3GG72uxSKqphmLalvR/8zI0rkkJlit0cb7mu8fgZKCPwnCYQZqVivjfXaJkw5
         mhiBujG/NTu7c0RyT354FFaXUfmpQr2jJbDsXrisTIvPo4v44V7mOw/B5q4zi6NS4Nv9
         eYlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QDK3Ccwx6XT9W6QHiKSRwInuQJSgvhMen0AzjEbYCA8=;
        b=N5Bnpbkuot3Khl5ZTLon2hxzeECrrtEFOE5fzodeWglCMzUikq7e+nliF4t4Nr/8X9
         FxvIxLHO+4zfs2uDrh+/7DAnPmaHN1z5dG6w16wLryRY53jBtzPYusT8l5mDhwerQKcD
         Odbed5Nnf5OnPCn5Dwf203KNERkWFQqTx6Uv2zbEkopVrLrtzuO4MqgCjPULEg84ffF2
         qYZKGPem0KN3kwgTv5sku0TwI2Dw5xwOicX9F7WMJ0PR7Hml+XM0cGMP0M+L+DwV9Esf
         HG+0GUYzBC6mwT8fSAJy5UKO+KChH/dAsUSIJ3KnIxQos0e5qi7PFoRZqKyvKDJTM51f
         8zeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CI1ZG2by;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p25sor1065412lfo.24.2019.06.07.13.08.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 13:08:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CI1ZG2by;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QDK3Ccwx6XT9W6QHiKSRwInuQJSgvhMen0AzjEbYCA8=;
        b=CI1ZG2byPK/1Kx8LZGxmpQVJbJPwAqQiJocZJTlvpGxmCbijp6s/MCkHKaIeulCqHm
         jkzBrAdWPEJYL7EChVEhSiSL7fH/uls6StJKdkrQ5+Q01AJSmPLrW82w/L+Hn1S73z+Q
         eyuKALMZREPHrLDajs0j38+UZFCBbs1bFRfrvM40LOT8ZeGSwORrXT3ZIw6l6e+DYtyO
         WHj3L2BKr8MObeNnmJF4CZwwqvoF+GvIu23HNTC/PhyX1ZAprAr1cMW2llBY8qa9UfbT
         n0rS9y7xpuoSaMNzM0KoPozltJ5AIo5wBfdosSEzNtv1l1F1knPWA4PyuP18dJYg4v87
         a46w==
X-Google-Smtp-Source: APXvYqwqkSPR8EIsmRv7XptKwGZtNlG6WGTa+Aw0Rgt8bmKe6Kk78did3YSh+DNFgKoB7girGDdcu1ECBFa9wEIQIxM=
X-Received: by 2002:ac2:4ac5:: with SMTP id m5mr4305451lfp.95.1559938088611;
 Fri, 07 Jun 2019 13:08:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190523153436.19102-1-jgg@ziepe.ca> <20190523153436.19102-11-jgg@ziepe.ca>
In-Reply-To: <20190523153436.19102-11-jgg@ziepe.ca>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 8 Jun 2019 01:43:12 +0530
Message-ID: <CAFqt6zatjZdCzd=cg-kZiajsSwF6Jr+d-rL_vQ9kMtHjcDx8uQ@mail.gmail.com>
Subject: Re: [RFC PATCH 10/11] mm/hmm: Poison hmm_range during unregister
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-rdma@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	Jerome Glisse <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 9:05 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> From: Jason Gunthorpe <jgg@mellanox.com>
>
> Trying to misuse a range outside its lifetime is a kernel bug. Use WARN_ON
> and poison bytes to detect this condition.
>
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

Acked-by: Souptick Joarder <jrdr.linux@gmail.com>

> ---
>  mm/hmm.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 6c3b7398672c29..02752d3ef2ed92 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -936,8 +936,7 @@ EXPORT_SYMBOL(hmm_range_register);
>   */
>  void hmm_range_unregister(struct hmm_range *range)
>  {
> -       /* Sanity check this really should not happen. */
> -       if (range->hmm == NULL || range->end <= range->start)
> +       if (WARN_ON(range->end <= range->start))
>                 return;

Does it make any sense to sanity check for range == NULL as well ?
>
>         mutex_lock(&range->hmm->lock);
> @@ -945,9 +944,13 @@ void hmm_range_unregister(struct hmm_range *range)
>         mutex_unlock(&range->hmm->lock);
>
>         /* Drop reference taken by hmm_range_register() */
> -       range->valid = false;
>         hmm_put(range->hmm);
> -       range->hmm = NULL;
> +
> +       /* The range is now invalid, leave it poisoned. */
> +       range->valid = false;
> +       range->start = ULONG_MAX;
> +       range->end = 0;
> +       memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));
>  }
>  EXPORT_SYMBOL(hmm_range_unregister);
>
> --
> 2.21.0
>

