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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D8B6C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:31:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30EE920449
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:31:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XL5nzU0/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30EE920449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B266D6B0274; Fri,  7 Jun 2019 18:31:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFC746B0275; Fri,  7 Jun 2019 18:31:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A12B06B0276; Fri,  7 Jun 2019 18:31:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C97C6B0274
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 18:31:20 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id q20so393180ljg.0
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 15:31:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=OBui/9a2CWa3WtJXU/jukEhEgmzQX9Gxf6SYhKMTrpM=;
        b=ESWM760Ii2n6emrbtkB4blJGH0vVRHOY3etpBIm6yKD0ojMhdL4F/DHdIfpGMGsnOh
         3pBldOczCZ1Jn1BjDALWKh1rnKqoHmYwNaeupr2UJNLuyCVc5aE51UOh8rHnNbBDVsrh
         iSAt8eLJ0CzHaXz7+2XTzwl+XeFsiGcs2DXUm55U9rQ3OD0aaDXHArzF+XFnmGle7vsr
         HPC9vjwl1/x8SuBlBzRPrxrZx0+MqXttsGU8aJJi389DoTDS+Od12GWFdPIGJjRSVbiZ
         F2Z7OkUabtygCk5aIDPFMqNmo/ZfqBFZPYZ/ZRvx1uZ8Y+79VeaPZdAt4GYoUagyUqGu
         Zjsw==
X-Gm-Message-State: APjAAAWChvwuitlHHcSqFz7rLyNBT/9fJ7ETVBmASIOvareosM59Pvmk
	w8rYr7uY3SgGAjk9GBxF65+bL1vbsf3c/lBtFhVbgABBtif2Gb9BG8pfDFSqk2hagexT68Wqley
	6yhmToJSnWm4t4/CzfqnVc5dVb8sz0NO3CGr+s4ZkQ9aw48AOlcFEh3bgLN3k8/lX8A==
X-Received: by 2002:a2e:206:: with SMTP id 6mr26221995ljc.59.1559946679582;
        Fri, 07 Jun 2019 15:31:19 -0700 (PDT)
X-Received: by 2002:a2e:206:: with SMTP id 6mr26221976ljc.59.1559946678898;
        Fri, 07 Jun 2019 15:31:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559946678; cv=none;
        d=google.com; s=arc-20160816;
        b=duW9FCECwSKrNj4fHP+BgN8EdeM5T162SW6M28yKlN2ufZabFtfn3XgVVNIwVHzDsI
         6wmOvkD3Ztj+vbhzzgKGxMlUg2Zz0oS0K7EV3fr9wug4bBytM1rLlO3BOJYtA1AFuWMZ
         S43NP67LIdf68LmkNkpClo5tWS61MT1h6ww+ecq/0zwrm7o6MRzA3ioDBsQZuJqM7YiY
         omvSbcEfzHFvAeyfNKVJr1wRYH5ydUGIPBqePE+i9nDZzLDhKT0WfdlHNpEdlMwInyaT
         vG0I916O2nu4rNGSVh0WddgjifRMxdYDnQt15zgT6OhpapNMKHnrVX+rpX/0XjKpGMPf
         0RMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=OBui/9a2CWa3WtJXU/jukEhEgmzQX9Gxf6SYhKMTrpM=;
        b=gPwrtROk9z5/9RiahD6oF8+w8uFIa5g2XEbbkTTAeLLlmcPdN9AutpPqpv5+p7oirf
         k6396s2Kcm+WIAhw05MT6rRcKiNsssNcsCkTcZ+68riayQUb2vD/lXrzBQ9IgGpQb944
         FmM3ZwHSxpOkOSOoy6i0OlhTdQsCdWhA/lEJ8bL9WYVVc4+nmEWESdJqs2kJH7mnJ8YQ
         /YeSPFmkdZLCHGQOfBl16lCChGBrderT4AnDkNTt1OtFrI77PFYw37CrSUcCb/8k2Zj9
         fPNNSeDt6mNmrGlMtmJMcGRuRZzBMYSM19WtaChSAWAm4ISJ9mWd8gI0wjKCudGDebIU
         DDKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="XL5nzU0/";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p16sor1148254lfc.34.2019.06.07.15.31.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 15:31:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="XL5nzU0/";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OBui/9a2CWa3WtJXU/jukEhEgmzQX9Gxf6SYhKMTrpM=;
        b=XL5nzU0/lagm2y0Cg+y3kw3jZkhFKAozmrNpN0ep0KEpMDufL/OFbDtLCWioxSqeem
         nnCsgfgghmXCCYPpiKSQ9J48pnPNE/N++ztKjRYyIwf2g1E8CYfrFxor1jwbAFcusjX2
         qp4Dj3utI2POQI26TQeeVFDDA22wfjsAk9uhVnTNA1rd2ggkSAWceQpla8XJUZyh0cYw
         HIoL7JvAH0lcB3l43rBR8Kjib3yLsOmkNqGHPxKbzR+2TgP+76c97fiZv8q/uEHwyOZA
         yL5Dy8rn0ETmgAm2peBfaeGnICr8HXdYcru1DQ5tCUElnmG4FhO+3XNHslo4FxAQuHkI
         4CLA==
X-Google-Smtp-Source: APXvYqyb8lHnPKKyifZOVm3QT+J0KCRhQmn2cyfVQLPbutwEhYncdPoxkPCFfBx12/rPhEMByfO6ILpxfoiqWeYD6bE=
X-Received: by 2002:ac2:5212:: with SMTP id a18mr21196110lfl.50.1559946678567;
 Fri, 07 Jun 2019 15:31:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190607113509.15032-1-geert+renesas@glider.be>
In-Reply-To: <20190607113509.15032-1-geert+renesas@glider.be>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 8 Jun 2019 04:06:22 +0530
Message-ID: <CAFqt6zZzqjTb05Tepi-huW7PzV7Mn=FczqaRkAJFZXLjA7sBEQ@mail.gmail.com>
Subject: Re: [PATCH trivial] mm/vmalloc: Spelling s/configuraion/configuration/
To: Geert Uytterhoeven <geert+renesas@glider.be>
Cc: Jiri Kosina <trivial@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 7, 2019 at 5:05 PM Geert Uytterhoeven
<geert+renesas@glider.be> wrote:
>
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Subject line should be s/informaion/information. With that fix,
Acked-by: Souptick Joarder <jrdr.linux@gmail.com>

> ---
>  mm/vmalloc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 7350a124524bb4b2..08b8b5a117576561 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2783,7 +2783,7 @@ static int aligned_vwrite(char *buf, char *addr, unsigned long count)
>   * Note: In usual ops, vread() is never necessary because the caller
>   * should know vmalloc() area is valid and can use memcpy().
>   * This is for routines which have to access vmalloc area without
> - * any informaion, as /dev/kmem.
> + * any information, as /dev/kmem.
>   *
>   * Return: number of bytes for which addr and buf should be increased
>   * (same number as @count) or %0 if [addr...addr+count) doesn't
> @@ -2862,7 +2862,7 @@ long vread(char *buf, char *addr, unsigned long count)
>   * Note: In usual ops, vwrite() is never necessary because the caller
>   * should know vmalloc() area is valid and can use memcpy().
>   * This is for routines which have to access vmalloc area without
> - * any informaion, as /dev/kmem.
> + * any information, as /dev/kmem.
>   *
>   * Return: number of bytes for which addr and buf should be
>   * increased (same number as @count) or %0 if [addr...addr+count)
> --
> 2.17.1
>

