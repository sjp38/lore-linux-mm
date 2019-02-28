Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47B6DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:57:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 050A92183F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:57:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dMhcgLXP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 050A92183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C84D8E0003; Thu, 28 Feb 2019 06:57:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 877318E0001; Thu, 28 Feb 2019 06:57:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B3568E0003; Thu, 28 Feb 2019 06:57:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 130EC8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:57:01 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id z15so3316416ljz.7
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:57:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=L8fcmR+rQmEReDcuYpUYxW0tKYPUtWoev1VscFLxHis=;
        b=ZoEL9xDxQ9C4/IbcxogIuUDbndZ4cifqljQkX88Fskw1mw1xEfz/2uK8oNCeTzHY1a
         +yDVMrIkmb5t3f8kr3pmH58CemTcUTWcdeLKq5nYZXZT9ciid5Opa0A/1SPTnZv9neNe
         NhrGv31X7eME895jz8vxKhmZEVryXQcMQ/xaxmtLcpurJ+W8fwVz5jbnr250Z6SInCwx
         1SLzUzfC0t8i2ekQCp0m8kw2v7Zo/bY8FDmf6MgbK66BvNPgaALihgJa9ihcSGrOesuX
         XaePy1x+iiCnF7Fjcgq2IpNYgW5ccKGO5xPRGmftQAiBa5Tox83HHroKjB5aOVSRbbum
         U1eg==
X-Gm-Message-State: AHQUAua74P3vJffyRdUG/HpJu/2uV6U1IXlqz8EWmv57TNgbteaJUV2T
	LcG/VB8YaOmPmffJDcGjqieWoGsmDI6l0gLq4vid5rcpYQWCriJ85YxZqL+K4CUdLqe+Cdcl0/7
	bcXKvJ8JkQBkDHSgOkpBA+px5pIuHwKByMij0HZf0CbOTb351H3p98HHruPn2qlkiKLd+5jU0Tg
	QHFqQcrscqB1nR8P37SsElm8DSIAIj+Q83FA51qc/phcxJ1CTs05jG3nlUJk36WQ7JQsWu9+H5p
	J5eloaWey/A6WTQ22mkapSEtqRElKV/mnJqhGl2zxDnl9EYkumyCKekTaQ16nME8Qt79mW2Ehce
	u7rtTXfuQ+8UJqnjSwGa9HHq++tUJJMnxOsghhZ1T2x7XX+iLZMEZtLcHT6I7zCqjepy6pp6Eoq
	m
X-Received: by 2002:a19:2d44:: with SMTP id t4mr3876277lft.90.1551355020238;
        Thu, 28 Feb 2019 03:57:00 -0800 (PST)
X-Received: by 2002:a19:2d44:: with SMTP id t4mr3876236lft.90.1551355019301;
        Thu, 28 Feb 2019 03:56:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551355019; cv=none;
        d=google.com; s=arc-20160816;
        b=XzivHR74UedwQzgLVp1RweR7ESFwGlgJ8ytOkl3u4c6ca3DilMXnCQIZrTEo9Aab+4
         SWP5cLizI+PHxe6iW3nIoqM/OCNEwZC3aIWiHVz1FOihGlFPKRi9E7TIhAF+6xO2qkeY
         LR8yBu6PnmQqPhFretYyA47L72bWA8lOcRNnZe4rPsGKbtez0fMzf824dMxsELSUWzx/
         HPcVTzxbO3egjlFQNEWhG+ecTAiU3mu3RTEFYqVrOEki3vV4Ic+yoS7yPOc955HvAyTv
         Hu3T3nXow8PjEBtufy/FdBtO8qmx8Rsgl6S9ELx8S9eZxnqXZkz5HHhc9tz6+flpBUxY
         W7GQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=L8fcmR+rQmEReDcuYpUYxW0tKYPUtWoev1VscFLxHis=;
        b=YumdZGHX/6ybk7zF+ADn16df/jiyaLaGNuOLOjQQNmhFe21GtoNBSrwLdXMqDe2sA1
         ueun8p2or1eThrlBovfZqgUpKDgASEXGXbSbY3oRVcpkIwoUvmZNdHZ9URKsj2/aRsEF
         1HZl8D14xVvDMCgW7V+jMEqcloWGV69fodTuwBpEFKkVZvd6HbYfWCupLKrqAiP5b7kr
         U2lInGXPuL94tLFBIAaPCbJMuZFjUS9PNvzPzxUr4M3VD6YPJWFBP6LRZ73hN2IMZbeO
         /vr2GLYQN1XFPtmzwKmyPgFfGqA6cw/7zxp2ZxQiAkHBaVmozQ3ACJWd6DS0VojQ+Qvb
         wtQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dMhcgLXP;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e27sor3729899lfc.52.2019.02.28.03.56.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 03:56:59 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dMhcgLXP;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=L8fcmR+rQmEReDcuYpUYxW0tKYPUtWoev1VscFLxHis=;
        b=dMhcgLXPtaIJ8dCC63OVyx+y559roriUbGChDiEyK76D9mm2mvpV+Mr47Uzk5F5zBs
         V79QA6AXgTBm3/Ww/X0wjRbY6VmTWxxftRvCDpAk7zBPU2BXSGgkwd1hYK04SUoFKST6
         M/Qt5bDlNhN07ksiqepq8iSHE2zJGTK+IagegRaVbteW3txRORTNC9u1GFiBBE/iM0Hb
         QcCzKZKLj1dHRkjUh4tRAu5Qmu/tmLb6SGUAKqrxPOX5rOltee5eSX0J5u/tHAGLby/z
         VGgC7v+aZIqB4j0LdHlVwBw0IRklfOgpgW5TxMI9bdSRjYfdjwUaIAS89bu9kHfh+rDh
         PRRw==
X-Google-Smtp-Source: AHgI3IZo8k///89/y1o5lt4Dv2UZF+8R6z+ujfCV+8pMmu7ktTjftmdf3Qt0yw7jC+Wn+++nskhpoD55vdAj2sX3Luk=
X-Received: by 2002:a19:ab19:: with SMTP id u25mr3993927lfe.64.1551355018788;
 Thu, 28 Feb 2019 03:56:58 -0800 (PST)
MIME-Version: 1.0
References: <20190227205242.77355-1-cai@lca.pw>
In-Reply-To: <20190227205242.77355-1-cai@lca.pw>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 28 Feb 2019 17:26:47 +0530
Message-ID: <CAFqt6za55vjCHvmk3smZYQ2cGLTsTyAcs6B1SLwCoYcm+XSiSA@mail.gmail.com>
Subject: Re: [PATCH] memcg: fix a bad line
To: Qian Cai <cai@lca.pw>
Cc: hannes@cmpxchg.org, Michal Hocko <mhocko@kernel.org>, vdavydov.dev@gmail.com, 
	cgroups@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 2:22 AM Qian Cai <cai@lca.pw> wrote:
>
> Miss a star.
>
> Signed-off-by: Qian Cai <cai@lca.pw>

I think, the change log is too short and could be little more. Otherwise,
Acked-by: Souptick Joarder <jrdr.linux@gmail.com>

> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index af7f18b32389..d4b96dc4bd8a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5747,7 +5747,7 @@ struct cgroup_subsys memory_cgrp_subsys = {
>   *
>   *             | memory.current, if memory.current < memory.low
>   * low_usage = |
> -              | 0, otherwise.
> + *            | 0, otherwise.
>   *
>   *
>   * Such definition of the effective memory.low provides the expected
> --
> 2.17.2 (Apple Git-113)
>

