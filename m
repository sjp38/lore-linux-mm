Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3438DC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 12:50:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD78E206A3
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 12:50:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d3929Rhy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD78E206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A4908E0003; Mon, 18 Feb 2019 07:50:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 779A48E0002; Mon, 18 Feb 2019 07:50:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6920F8E0003; Mon, 18 Feb 2019 07:50:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id F17748E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 07:50:34 -0500 (EST)
Received: by mail-lf1-f70.google.com with SMTP id m10so1873474lfk.6
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 04:50:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=T3mDCcqlTfvGRxpNOHBVgyu2R93YF4O1+jAeLCd5+y8=;
        b=jXAyBPSOENRh8MZISemGK/iCorCWGC/UxkCAslTRBHmOvPI1hmcBXpEFAcBBmZIPxj
         DCY12cMjq9XkLTVzBHb7oYEGTZUyqKMjEEl020Z3ELjYcYy+prQNDjsfu+NEeAqV8uC6
         BPBWkn9Jg9sIFMMosRq0n8eKi4mOfTHEFhN0BPv25iBOOjikmjUtKV/aOopCmb24I/bh
         Xdq7UvB3ziCoEcTtBpv02/RmR4+6rC/22RR76ijuP4nC4hwEl3vvhPULEsecUHMpKBLs
         lr2U2m7XdWeCHqWb2zcA/+gmK1q/9aTOmA7gpvMYtz/rExab+9GdT9VCKOSWrNA5LYXz
         Lrxg==
X-Gm-Message-State: AHQUAua9LyU8s5TcTnXvtTxFGGJj3YabxsA8lAbjwaOVKzHOL+ECQsn/
	1G4s+QsRtxL5+/9bVez2veb62FB29i5YavjftN4Sv3JLoCt+rPCtOuuZkGmuc0tyC3bb6kWaUAZ
	bX2vr309ep6upjOIgcIk27HVR84qALcEwiM5ja+ra8lRLNY6SxQpdkynbB56EsYVf2soCOtoRcF
	0PSIYudf8UUUCYTvz4eO6so5xf+eO++rfK9CuuCFGbQY8RjcooEpVY4sVUsK3L7zfZLGLqRtKCY
	R6prgcVC0VeDjt5I5nS+1V7iRerRkNVAeGptNF33QTPppWSyUEyUEQ/vqKxH7Pczkccq6B+Ie7r
	dosJdGAn09PocHIH+5rGwBHgUD2AftfJCcwoFtcJsy+niEZu2SlPO+kLWWa+vRrllTlev9bTuFF
	j
X-Received: by 2002:a2e:8248:: with SMTP id j8-v6mr1023946ljh.1.1550494234372;
        Mon, 18 Feb 2019 04:50:34 -0800 (PST)
X-Received: by 2002:a2e:8248:: with SMTP id j8-v6mr1023907ljh.1.1550494233405;
        Mon, 18 Feb 2019 04:50:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550494233; cv=none;
        d=google.com; s=arc-20160816;
        b=EIZcbCkcdtlpiDi9NvP1XuqXXs1yCh46noymmTtWsLyBLEX4tDbl4nhlyh9p42WvbF
         CcqD2BDfIgBtCcKp3SNVrH+kz1D0EN0m/oiw66bm7Ws0ZUtWORMXFExyhAHqQ4bICSvq
         i1qOJv5r8YFbabbn6A+29OWFpiMjqCdegbPinZHlM/5PSlhktABecdDVFYz92V8rPJxf
         Ez2YI4XfTXteTMRjKHWbHGOTXL7moBKd368Cq9a0tRtclzcZx2FR+Ab3KSUvNEiX3YU2
         RwT9+HlAipSFov8nMv+3kfATT86UMD1Sgwl5BRJGmfcgQo5xL8NVEshotmWm+1sSQyXk
         8zEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=T3mDCcqlTfvGRxpNOHBVgyu2R93YF4O1+jAeLCd5+y8=;
        b=bpYdz3sYFy1jU2mpC2qoNT3Psr5tEjj0TiZN7OO370NqIRvQ52WiaqfUij2ZL3O4Np
         lR7QDKH9nTOrytQSUZAXze4HB3GPjO6Nc0WvqegfEPqkhp77cavmTMts6jE7rULSNVNU
         XNReBWqg8N/M2G5F7ti9Em1nyyG4GIuQ73A6xN08CGKvLMJfSNqKFx3C1JdlVixRPpf1
         kTPtcK9BqlQsQqMH2j+BGrOR59Mm2NWgyX001mSftgeagE+UdkHpsKbx7QHl+ax8aZ4f
         ojwsJ9ihqMO5Na037o0loWhTUpzrbjbgLK09HQSk+M7Rz23OweQL3GqLxxUckFUh00ca
         AUrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d3929Rhy;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13-v6sor7397583ljj.25.2019.02.18.04.50.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 04:50:33 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d3929Rhy;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=T3mDCcqlTfvGRxpNOHBVgyu2R93YF4O1+jAeLCd5+y8=;
        b=d3929Rhyr7JOx9T5ZNS/6Yvki/jgtKOl1mQuZDiAuzD+uLmHBJA2ImNlzS57u0vjU/
         jNws9qOKr7mOkjYV/Nfm4TJXQmA33N16G6VlmjdgKbs310j7PDoFa0VRVneZTdZPGi0M
         W7HvYdSndWcBXb5ZtA7BY/f7kUN02sa4TH4GuisKrt6rTa5WM9LX6XPz7dnG81E2A270
         AvCoZSdQIfycQQEG4BM+aU/M1/S8c36XS6+kwzPIa9efHzaX/TzViHgV9HoS1C27/vME
         ezEEYRnpVK5/QuJAlIUGlOJjVjPEG/u5gaHDT/EpS2x94vaeTTERXn2sYEbj2LoO3qk9
         0TAg==
X-Google-Smtp-Source: AHgI3Ia7IZsHQNFgpIiE0j0w/ytCYnL63rFO9AwxTQ8Wplej5TLVOxyA2h10iRJ1ZNJWTRv7b5EcitX5kmjrKENMz4g=
X-Received: by 2002:a2e:3807:: with SMTP id f7mr12365910lja.9.1550494232904;
 Mon, 18 Feb 2019 04:50:32 -0800 (PST)
MIME-Version: 1.0
References: <1550159977-8949-5-git-send-email-rppt@linux.ibm.com>
 <mhng-e6dedfc5-937e-42e5-90d6-4ce400cbc6fb@palmer-si-x1c4> <CAFqt6zYL8q16a0dKvNb_1MpJCuz4VrkT1pKe=eqpywxA-hnL0Q@mail.gmail.com>
In-Reply-To: <CAFqt6zYL8q16a0dKvNb_1MpJCuz4VrkT1pKe=eqpywxA-hnL0Q@mail.gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 18 Feb 2019 18:20:20 +0530
Message-ID: <CAFqt6zZZaFU_i+srxk9rd_+5V9FTd767MH-rCocvJPfFcXJsCQ@mail.gmail.com>
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

On Mon, Feb 18, 2019 at 6:16 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Hi Mike,
>
> On Fri, Feb 15, 2019 at 2:19 AM Palmer Dabbelt <palmer@sifive.com> wrote:
> >
> > On Thu, 14 Feb 2019 07:59:37 PST (-0800), rppt@linux.ibm.com wrote:
> > > The riscv version of free_initmem() differs from the generic one only in
> > > that it sets the freed memory to zero.
> > >
> > > Make ricsv use the generic version and poison the freed memory.
> > >
> > > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
>
> Just for clarity, does same change applicable in below places -
>
> arch/openrisc/mm/init.c#L231
> arch/alpha/mm/init.c#L290
> arch/arc/mm/init.c#L213
> arch/m68k/mm/init.c#L109
> arch/nds32/mm/init.c#L247
> arch/nios2/mm/init.c#L92
> arch/openrisc/mm/init.c#L231

Please ignore this query. just saw the other patches.
Sorry for the noise.
>
>
> > > ---
> > >  arch/riscv/mm/init.c | 5 -----
> > >  1 file changed, 5 deletions(-)
> > >
> > > diff --git a/arch/riscv/mm/init.c b/arch/riscv/mm/init.c
> > > index 658ebf6..2af0010 100644
> > > --- a/arch/riscv/mm/init.c
> > > +++ b/arch/riscv/mm/init.c
> > > @@ -60,11 +60,6 @@ void __init mem_init(void)
> > >       mem_init_print_info(NULL);
> > >  }
> > >
> > > -void free_initmem(void)
> > > -{
> > > -     free_initmem_default(0);
> > > -}
> > > -
> > >  #ifdef CONFIG_BLK_DEV_INITRD
> > >  void free_initrd_mem(unsigned long start, unsigned long end)
> > >  {
> >
> > Reviewed-by: Palmer Dabbelt <palmer@sifive.com>
> >
> > I'm going to assume this goes in with the rest of the patch set, thanks!
> >

