Return-Path: <SRS0=ybLw=TL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2141DC04AB1
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 08:11:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF7C12173B
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 08:11:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="al5AmLsP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF7C12173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D9796B0003; Sat, 11 May 2019 04:11:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13B536B0005; Sat, 11 May 2019 04:11:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0035C6B0006; Sat, 11 May 2019 04:11:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9094D6B0003
	for <linux-mm@kvack.org>; Sat, 11 May 2019 04:11:00 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id y62so1251057lfc.16
        for <linux-mm@kvack.org>; Sat, 11 May 2019 01:11:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TQtZc3FelJBQESxVUuXzQ1cko0sOiYknE7Ka8Kps1YY=;
        b=NVpEA6CgYph9gnlAM2KZPhACdMEgmhCyT6TKsDTtDbwC0bRzuoB7d6EQAueOAXodjf
         FBN+8vyEll0iV6iIl+QZemx0qVmnrIMhDRxEqk36likmGmDqd1C8BSSXB+MDaieCchMB
         Id5sJCoIixX/Xl0egEh058maAa5UeoaCVug1r7DqV1YB5hhDQg89akQWiurOacfykz08
         j8b6aUmY964qjLPKJJSXv2N0qOXmTMD+CTJl5FJAjUO0FXLs62nov3fzq2RCuRu/m6Vc
         M0CDBc1OGeSaqBsFZ4WxAKF0NyX0+P/BDlw431SNpbhmHfpnUTSuo0l5JboFdM1Whbio
         Ui4Q==
X-Gm-Message-State: APjAAAXa8KgSDwSqqA9KrynDzGvkQq21fKqB2ppc4pLBbj3k1bj5oi6n
	X+f57fbXZu5u558nzCGl+onQWsPNpfN6ekVqx7VvOAPaF1qDrDA8OSsMhJN8yKv/E3FhESvymyb
	nLn+jnocM5sa69BslFKUw0eLkMfQI5ZTuUudBCzquDw/WASBpQM5MtW91YeqIglF2Qw==
X-Received: by 2002:a19:385e:: with SMTP id d30mr8245146lfj.119.1557562259985;
        Sat, 11 May 2019 01:10:59 -0700 (PDT)
X-Received: by 2002:a19:385e:: with SMTP id d30mr8245109lfj.119.1557562258955;
        Sat, 11 May 2019 01:10:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557562258; cv=none;
        d=google.com; s=arc-20160816;
        b=yl1gxuL3WaDIS1jCrdVBbX74J9G+9N2BW/GyMv9abZDynYKnvSB/rC6NXJ/SY5RFp8
         BlYXTJgJkSCMCXf6pj3ZP7AzjeRXxJgXmxknZNSHZuELh/39jF0ql/6joYUt+t27OA/K
         3kxLtVnoFiG54KLBR06eH7tFAUmf710f8xWLkPArSlFUsjApNOhl3ECQGx6nvhJNbX50
         Jlc913dRbXDQrSF+pj3ak5QvIHHbqv6geFu3Ph0kidAablqmxLVa5LVxyKewBwM6UCpx
         mfFBcmOn/Q+6EjoFmMSadBQXMLiT2OMejaZY9tnxqW0GAAtwB15SrKsRafOKa14zUmi6
         6fXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TQtZc3FelJBQESxVUuXzQ1cko0sOiYknE7Ka8Kps1YY=;
        b=XK2/3cUapyutgNN+8Nxsz2T1ZQddG/ERKmzm87CzYizYejRIxHqkc2CxNa4ZIhNp4Y
         Y7cvcGyHE7nIo5R4/lqtTYeNuguqxAFFRvuB+gaqPBXLLZTcg0qQDwg7IMz45omnmJod
         jTYYVtIZ3Ak8Zqfnva0tNPiVhRyVJcHSUyrnhSu7zfY0FpC5tbk9MnsuT0XYcbLmRsN9
         fizbJbtpXI0ndZdmxUDOkS5WqI4ZsCjKKjCcTNTlJQEeNquA97jVSy1y3jndJ5t1pSRK
         qp+vZXSMBb5G8fkHyWI1tanG17dKMc5L8kS5Eiy6l56NyiVTHDejTj3GQGhGFrCq1gbt
         ktmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=al5AmLsP;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 28sor2343738lfy.68.2019.05.11.01.10.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 11 May 2019 01:10:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=al5AmLsP;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TQtZc3FelJBQESxVUuXzQ1cko0sOiYknE7Ka8Kps1YY=;
        b=al5AmLsPkWUP0wa7q0iB6soqaQEuPYfX4SBDqvRrM0p/UG1oSWSpI4uNt/e02ZYUJU
         ahKoI6IbQiLLSO2qJNCJ+iLlPoZiBoqJ7Y77f3M1n/ssjjspcwc+BLvCwnyoDdd+2i5X
         B4bb4q7z832ZXkXDdErEgNiR6qZGw0NySHHYrvkbmHApj8T48VHfhQ2NpHlUIax39SuG
         gjtzq0os4UsjlL3tNwLrSLeXPcYM6zyUJEJheNKUCzLtCiTOPdet5sIRf2LijH/mcb3M
         +B7XJ+y2W2dsTnKRaGxST00J5dhR7uYmSLk4T/T1/Mx2gI8Namq4U7SRp5w1l/QFp9+U
         hWAg==
X-Google-Smtp-Source: APXvYqxrR+0F7Mtq0iFNk+3yrcIt+6zmntJ4b75xneeACJzPfrZqvtqgBurz7OcyTbIj1wp+pPTqYud6j7415sWrUmI=
X-Received: by 2002:ac2:5621:: with SMTP id b1mr8593193lff.27.1557562258490;
 Sat, 11 May 2019 01:10:58 -0700 (PDT)
MIME-Version: 1.0
References: <20190422103836.48566-1-swkhack@gmail.com>
In-Reply-To: <20190422103836.48566-1-swkhack@gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 11 May 2019 13:40:47 +0530
Message-ID: <CAFqt6zbxMKydJa=-TbPTWwxK-XJYyg=d-tV8AWfNSAA1Q2ugfA@mail.gmail.com>
Subject: Re: [PATCH] mm: Change count_mm_mlocked_page_nr return type
To: Weikang shi <swkhack@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 22, 2019 at 4:08 PM Weikang shi <swkhack@gmail.com> wrote:
>
> From: swkhack <swkhack@gmail.com>
>
> In 64-bit machine,the value of "vma->vm_end - vma->vm_start"
> maybe negative in 32bit int and the "count >> PAGE_SHIFT"'s rusult

s/rusult/result.

> will be wrong.So change the local variable and return
> value to unsigned long will fix the problem.
>
> Signed-off-by: swkhack <swkhack@gmail.com>
> ---
>  mm/mlock.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/mlock.c b/mm/mlock.c
> index 080f3b364..d614163f5 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -636,11 +636,11 @@ static int apply_vma_lock_flags(unsigned long start, size_t len,
>   * is also counted.
>   * Return value: previously mlocked page counts
>   */
> -static int count_mm_mlocked_page_nr(struct mm_struct *mm,
> +static unsigned long count_mm_mlocked_page_nr(struct mm_struct *mm,
>                 unsigned long start, size_t len)
>  {
>         struct vm_area_struct *vma;
> -       int count = 0;
> +       unsigned long count = 0;
>
>         if (mm == NULL)
>                 mm = current->mm;
> --
> 2.17.1
>

