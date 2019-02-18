Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 953A2C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 12:47:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 332F22173C
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 12:47:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mjcBjbah"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 332F22173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 841DE8E0003; Mon, 18 Feb 2019 07:47:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F3EF8E0002; Mon, 18 Feb 2019 07:47:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E0948E0003; Mon, 18 Feb 2019 07:47:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 007338E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 07:47:14 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id b19so1408389lfi.8
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 04:47:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mhM/mauBJck6aHRYgcqqFsOsl1B7ZjHg4yd8uzUwQDE=;
        b=rTnPonq3NcWfMJxl69vLrYSV8+FcE9fU7E4b272AG6s/OGHPrqdXSBJ0ng9tm+HzpV
         b40OpL9txzYMXjzwIYKAbEt16z14vYDOgj2Q7T7mXcFssevXuLsQ0IJtLY0cFKJ/2UPR
         8OAcW82OmHQ23BAJVyedZ2L4oAKlugCom/3XI1p9ObCbVY0d6bidsLGmiOVH5/utCtRA
         Dr7b+TcU8mmb3lB5i1j+NJlCUyXBSp6ebBKMigOqku01/RU5qku2KQwT/jyTjw5pv+Am
         uh2yuUPVrorszZAMREsLszCMFsCcdHjoii+h9x6WcRTGcFYd2VjOQu5EzZ7tjHkCIRhm
         huaw==
X-Gm-Message-State: AHQUAuaTbDew/ZDKev2uUI9dJjXFaNZzzGJLnM7VQO0W063Tr5IVqLS/
	aF/CJwWvQpWMYOmmYyL93yhu8WnQvdDOGU2jrlNxf0bzgr21ItlwJNlH/gQjtGHH19MUa/gvGCD
	msrih2tnsrqKzDhh0TakgcHjGOoU4VH0Kk34HsM2nDtO0wq0IV4RHRMog3XNKUY/b7W7Uu9Duw2
	2JjUqjiFTLpgFz6R6g22qPjzDL6kvTDspdEnQ41uFTnPF+fOQL4/x4XPvhTS2rZ61Izyc7hcdOa
	48jJYdYN9LgTNcFNkwV+uUuA4CjoU5D1nbz7MP+/OmyJOEqTKiL/Kx69XTSz/7Dh99g9n9agzia
	lKFzMpIbxXj9j3vcTgWfeoil6uVlFeroroTC97CLGUxVFlo/qcPr6Yp96/svFwnoloAdOdJLVp+
	/
X-Received: by 2002:a19:f204:: with SMTP id q4mr14377027lfh.133.1550494033009;
        Mon, 18 Feb 2019 04:47:13 -0800 (PST)
X-Received: by 2002:a19:f204:: with SMTP id q4mr14376987lfh.133.1550494031939;
        Mon, 18 Feb 2019 04:47:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550494031; cv=none;
        d=google.com; s=arc-20160816;
        b=kW83CyzqTyTQ4Olce2mtQTTTMHVgmzFdrrcG75bdztWUdNQ04Ty/GlNx+nAzMEJzRD
         0ofEZQNKnyP07AbbHMPMPnXMJk/aUiHmZUfmbvel1UAfYHETWnR+oRYBb1MU72cDqsxx
         IqlpqsyZbh9QTP4BVIFGNZRX56tC6vgNR21kn0KFpd/7R02QbDE5zbQKlOFU10oRSikL
         kBzQMh6E0EhoP79ma0BjPI9JMkXUnak08npaxn0M+liIokZTLlFd0Lc/INC5+KJFlfUf
         Pf8LUjAuJtHmDJUCtG29Y/P5IO9HrD6/2hxoZk+CAcSamJExPsi1SAJJZaX60ByKS6uF
         a+0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mhM/mauBJck6aHRYgcqqFsOsl1B7ZjHg4yd8uzUwQDE=;
        b=UB3x90UZF3QfDHx2D8vNCtrSvamKWKG30ZMnjpc0chVxW5bd7K+P62o/K49ZXmhBAN
         C3AO5y1qDwanhoaaI80pj0hy4z5ahopLv2b/sJS+wBCfQ/fr8Dkhqh3ANVNY+wixMBDa
         PawpfTthhHURSiemLK8R+fW4aXDnRpv+eEOFiG+6ApAx7RB+YCBL7/iYHUiiEf+xnEhw
         zYrT0kiA8lp/ueHvTmQAg3uLIgf7JmIYlR5oVbfPJYu/aHFINd96ZTDoS4jNvXA+3N/L
         8b1Jqmz8TTC5n1m+cIdOLYn68n9jQ49W8afZlnrYaIGn/GhkqFA9BEm30blXgn+kJ4ho
         LojQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mjcBjbah;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e22sor3321090lfd.25.2019.02.18.04.47.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 04:47:11 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mjcBjbah;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mhM/mauBJck6aHRYgcqqFsOsl1B7ZjHg4yd8uzUwQDE=;
        b=mjcBjbahr86ojcygi/eLoNW179Ryv3mSs0MohtnrQAV6FyL+VV1pgHTqrSBRCfjxDD
         3P6j1Y+gqW+caEQE39wjF5Y8WsUDkaatY7qreO2lfZxw2xY9NceIH2vuB9qC2odbVX4U
         h1XX4saztnNAEoPDc82o6JaiCNHqLV2BlsDqGn7UCeKybvfN0NtqktNs3lRnKCLWD03g
         zLIXkVCt7YBC5z4sh6zI96IvebtIW/FypSqGFPqDqb5iSb6vBN31TKRKalKtaBaPdjV8
         Gv4g4zO6IeDglQk636jbmv73/AGMiHSBcis/aSCO1+g8BvwUZ6ArgCmxGQf4z7pfAf1j
         OXBw==
X-Google-Smtp-Source: AHgI3IZuUyk0D28Ou67GADmhMyds23jk34C0/RBSJfPoSe4kiB+TgSQa5Tjz5Ptmy8SfkVo0CA5Gf1sx8Kh8TroF6hk=
X-Received: by 2002:a19:ab19:: with SMTP id u25mr13349710lfe.64.1550494031281;
 Mon, 18 Feb 2019 04:47:11 -0800 (PST)
MIME-Version: 1.0
References: <1550159977-8949-5-git-send-email-rppt@linux.ibm.com> <mhng-e6dedfc5-937e-42e5-90d6-4ce400cbc6fb@palmer-si-x1c4>
In-Reply-To: <mhng-e6dedfc5-937e-42e5-90d6-4ce400cbc6fb@palmer-si-x1c4>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 18 Feb 2019 18:16:58 +0530
Message-ID: <CAFqt6zYL8q16a0dKvNb_1MpJCuz4VrkT1pKe=eqpywxA-hnL0Q@mail.gmail.com>
Subject: Re: [PATCH 4/4] riscv: switch over to generic free_initmem()
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Palmer Dabbelt <palmer@sifive.com>, 
	Christoph Hellwig <hch@lst.de>, rkuo@codeaurora.org, linux-arch@vger.kernel.org, 
	linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, linux-riscv@lists.infradead.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mike,

On Fri, Feb 15, 2019 at 2:19 AM Palmer Dabbelt <palmer@sifive.com> wrote:
>
> On Thu, 14 Feb 2019 07:59:37 PST (-0800), rppt@linux.ibm.com wrote:
> > The riscv version of free_initmem() differs from the generic one only in
> > that it sets the freed memory to zero.
> >
> > Make ricsv use the generic version and poison the freed memory.
> >
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Just for clarity, does same change applicable in below places -

arch/openrisc/mm/init.c#L231
arch/alpha/mm/init.c#L290
arch/arc/mm/init.c#L213
arch/m68k/mm/init.c#L109
arch/nds32/mm/init.c#L247
arch/nios2/mm/init.c#L92
arch/openrisc/mm/init.c#L231


> > ---
> >  arch/riscv/mm/init.c | 5 -----
> >  1 file changed, 5 deletions(-)
> >
> > diff --git a/arch/riscv/mm/init.c b/arch/riscv/mm/init.c
> > index 658ebf6..2af0010 100644
> > --- a/arch/riscv/mm/init.c
> > +++ b/arch/riscv/mm/init.c
> > @@ -60,11 +60,6 @@ void __init mem_init(void)
> >       mem_init_print_info(NULL);
> >  }
> >
> > -void free_initmem(void)
> > -{
> > -     free_initmem_default(0);
> > -}
> > -
> >  #ifdef CONFIG_BLK_DEV_INITRD
> >  void free_initrd_mem(unsigned long start, unsigned long end)
> >  {
>
> Reviewed-by: Palmer Dabbelt <palmer@sifive.com>
>
> I'm going to assume this goes in with the rest of the patch set, thanks!
>

