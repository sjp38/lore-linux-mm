Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E6C5C43444
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 13:02:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC5F4206B6
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 13:02:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HsTWTntf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC5F4206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 794098E009D; Wed,  9 Jan 2019 08:02:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 742F08E0038; Wed,  9 Jan 2019 08:02:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60BF48E009D; Wed,  9 Jan 2019 08:02:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3853C8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 08:02:54 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id t13so6505345ioi.3
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 05:02:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YBhqaz16hN/CKMu7MZvL4stKncpfQ0HIEKA8wNOI4lo=;
        b=sb2CTwTNH0XStthJuFZg2UpLz4IRu7JkXXhINtkxcfo/DtLOcnBn2HfcwYSmEgRv8E
         8jQj8q4nJU8OpP3cjdnk+b3bD1FVCqUV3gIhJJ9ajkwCWQCrPC46KQqbH3Risa/ZlavX
         NJCWXqkE3rG6+Xk/9XXtcwM0bl+pbDmzGm2b6hv1y2pWUlx0tSUT4ZwpJHMkxV39p+ph
         T5SoY0LI+MFLaQYQCXi/9OAkD11lcc2Vnp1LYyJafJmBuKsz6pvQW4PPDKzvRBRujHHv
         LozOBN1neQsi9z4GZ/WqchnxLedGXEVxWULOHwsQtOAsEs730u+Gy9iUutvUbNnH0HR2
         fMXQ==
X-Gm-Message-State: AJcUukeotD+pb4n+9LoxAkrQHKEOsycBvabDObn4egQGqHvNHQ2oJACJ
	6scxHdFAuYJ0g+YbIW+isOVodixxw7L3oZ5x/ukXpIBC8YxAw+BbCGCaY4xW7eFkY2h2d+O9f5r
	UaKmDqSrUesxQ1aySvia7r7foUX2njZ+sA4v+QJ+UhD9+04l/6MoUDtu+V8hKdxfHK6CpJYuiRj
	ncDN8jfNGRYR5F8lydHECACNhFvE4yklp14yVXa+seQ8iMhk0I0lw3kZisAQJ6KE0AEeJpYP+YK
	tKCnNxj+VRfNYKhfM2gel/kvtU8PsBWtgX9WSYatqsP9PVQoQRlCmcJ17tA2y8PI7E++NOXmAWt
	7D31TY8UudfG9omjzgM9xOy7I7xCWLBKW/WOc6h6y7foFm9qCLY1W5TBFb34DQSgPl5vn9Cyv3S
	b
X-Received: by 2002:a24:fa04:: with SMTP id v4mr3515380ith.175.1547038973927;
        Wed, 09 Jan 2019 05:02:53 -0800 (PST)
X-Received: by 2002:a24:fa04:: with SMTP id v4mr3515337ith.175.1547038972949;
        Wed, 09 Jan 2019 05:02:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547038972; cv=none;
        d=google.com; s=arc-20160816;
        b=PjFtmMIK/OCCeIWJWE3xXc0OO+grWg4MSTQU10o7jrVkrydMv7yYBHVVhDtedr0sbF
         eTF5nneeXaN92l5YPXEVUQpOYdr1Uq8MQysCaJ39d6gKT0CDFBsc6YBCKNGQSV4AB3xQ
         Sto6CWPxNtAb9RhcJvgKaGhkmgK6S3InJzWZYESC/6fhwunCo3ZxXk1tntAepS8szSWV
         VqL43epMuMyHlRyolwmRhiE0CRgXstqoknRHHn5zC5eji6LzoqAmm85+cdD401mEqCEV
         UcNTUd8ExQjwuxkahj2XuW25zG+PzNeGR8LwBj6ADeZoLuvKJ8XYT3WjuhDfruyILtxq
         otpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YBhqaz16hN/CKMu7MZvL4stKncpfQ0HIEKA8wNOI4lo=;
        b=Y3oRdP2tqqlCgkiaLvy4mzBzj6azbrlRveaXbz1GMMAhoe6PKlWfgJWFsRsQXbPpbb
         Iwjl7dqmnmvDtCgEK1QDLVNB/lrKdxWK4AFJDUbutHpD1fG8J162nOucc97AB7oiZMap
         4SEskWSMjjLvSX8Xi8eDYynE/aX6jrgSciGSv0EvePEZvCD1spVOFQeX1enANiK9I0Sn
         LGxeTDZohqceEVVfp0zW9jweEB+GRcCTIeD0J7e86TGx7O+iCi+vGjxchsTEEjl6fHbb
         jR/PqGwlm4Un9beN6pgyKaYV5BB48rPJSwYsp49AFJt+4qgSPKQ3QTvCx8XwSz0d0e5G
         nMfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HsTWTntf;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y98sor23281840ita.20.2019.01.09.05.02.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 05:02:52 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HsTWTntf;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YBhqaz16hN/CKMu7MZvL4stKncpfQ0HIEKA8wNOI4lo=;
        b=HsTWTntfDqIb7e6WmbltjYYI3tqigk7ZkCmfAwpU/KSXjhwt+Vnnz4GUe2IIkiOa46
         KukkG+8r8Pqvw1JluycYzrmtqG94jBKnqtoNbhczFxANqhQb1iVhQ/rv+xeANhCve32Z
         7eNQOoQ3PzvVSMIn2+HqIsVoxuDIp/EGDIjyvOX2+Owi5OanQc8YKqC+7cV6PreRC4Wm
         ma3rTmfJiscjchE7yYD3h1x6ebNIS/lIeiTH4wepAEbhUhdMnp6SELZkudtGypNqi4/e
         M8TmffIs62nbghbTwwzuLvugbLh51VhWvKa4/VAIPiHswuTpTzWKNNtUJB6QU8904pKt
         06Yg==
X-Google-Smtp-Source: ALg8bN6jZVtBQkoIL+gc2foVzNueQuCtYtBjioYQw3sdpf4SaFMhD/UMFv8bOLJKob2dcgytuCGinhA7fnSzqjJ8LhQ=
X-Received: by 2002:a24:3282:: with SMTP id j124mr3974539ita.173.1547038972554;
 Wed, 09 Jan 2019 05:02:52 -0800 (PST)
MIME-Version: 1.0
References: <1546848299-23628-1-git-send-email-kernelfans@gmail.com>
 <20190108080538.GB4396@rapoport-lnx> <20190108090138.GB18718@MiWiFi-R3L-srv> <20190108154852.GC14063@rapoport-lnx>
In-Reply-To: <20190108154852.GC14063@rapoport-lnx>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Wed, 9 Jan 2019 21:02:41 +0800
Message-ID:
 <CAFgQCTtVjwJ_Rfp8DcmzPx6uYPnOx7E_x=YjC+MQ=mx7W38HEw@mail.gmail.com>
Subject: Re: [PATCHv5] x86/kdump: bugfix, make the behavior of crashkernel=X
 consistent with kaslr
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, kexec@lists.infradead.org, 
	Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, 
	Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, 
	Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, 
	Dave Young <dyoung@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109130241.UVbRwCguo2E8Dw-M04bSgNGjY6cdt5NQwbD1AzgQ598@z>

On Tue, Jan 8, 2019 at 11:49 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Tue, Jan 08, 2019 at 05:01:38PM +0800, Baoquan He wrote:
> > Hi Mike,
> >
> > On 01/08/19 at 10:05am, Mike Rapoport wrote:
> > > I'm not thrilled by duplicating this code (yet again).
> > > I liked the v3 of this patch [1] more, assuming we allow bottom-up mode to
> > > allocate [0, kernel_start) unconditionally.
> > > I'd just replace you first patch in v3 [2] with something like:
> >
> > In initmem_init(), we will restore the top-down allocation style anyway.
> > While reserve_crashkernel() is called after initmem_init(), it's not
> > appropriate to adjust memblock_find_in_range_node(), and we really want
> > to find region bottom up for crashkernel reservation, no matter where
> > kernel is loaded, better call __memblock_find_range_bottom_up().
> >
> > Create a wrapper to do the necessary handling, then call
> > __memblock_find_range_bottom_up() directly, looks better.
>
> What bothers me is 'the necessary handling' which is already done in
> several places in memblock in a similar, but yet slightly different way.
>
> memblock_find_in_range() and memblock_phys_alloc_nid() retry with different
> MEMBLOCK_MIRROR, but memblock_phys_alloc_try_nid() does that only when
> allocating from the specified node and does not retry when it falls back to
> any node. And memblock_alloc_internal() has yet another set of fallbacks.
>
> So what should be the necessary handling in the wrapper for
> __memblock_find_range_bottom_up() ?
>
Well, it is a hard choice.
> BTW, even without any memblock modifications, retrying allocation in
> reserve_crashkerenel() for different ranges, like the proposal at [1] would
> also work, wouldn't it?
>
Yes, it can work. Then is it worth to expose the bottom-up allocation
style beside for hotmovable purpose?

Thanks,
Pingfan
> [1] http://lists.infradead.org/pipermail/kexec/2017-October/019571.html
>
> > Thanks
> > Baoquan
> >
> > >
> > > diff --git a/mm/memblock.c b/mm/memblock.c
> > > index 7df468c..d1b30b9 100644
> > > --- a/mm/memblock.c
> > > +++ b/mm/memblock.c
> > > @@ -274,24 +274,14 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
> > >      * try bottom-up allocation only when bottom-up mode
> > >      * is set and @end is above the kernel image.
> > >      */
> > > -   if (memblock_bottom_up() && end > kernel_end) {
> > > -           phys_addr_t bottom_up_start;
> > > -
> > > -           /* make sure we will allocate above the kernel */
> > > -           bottom_up_start = max(start, kernel_end);
> > > -
> > > +   if (memblock_bottom_up()) {
> > >             /* ok, try bottom-up allocation first */
> > > -           ret = __memblock_find_range_bottom_up(bottom_up_start, end,
> > > +           ret = __memblock_find_range_bottom_up(start, end,
> > >                                                   size, align, nid, flags);
> > >             if (ret)
> > >                     return ret;
> > >
> > >             /*
> > > -            * we always limit bottom-up allocation above the kernel,
> > > -            * but top-down allocation doesn't have the limit, so
> > > -            * retrying top-down allocation may succeed when bottom-up
> > > -            * allocation failed.
> > > -            *
> > >              * bottom-up allocation is expected to be fail very rarely,
> > >              * so we use WARN_ONCE() here to see the stack trace if
> > >              * fail happens.
> > >
> > > [1] https://lore.kernel.org/lkml/1545966002-3075-3-git-send-email-kernelfans@gmail.com/
> > > [2] https://lore.kernel.org/lkml/1545966002-3075-2-git-send-email-kernelfans@gmail.com/
> > >
> > > > +
> > > > + return ret;
> > > > +}
> > > > +
> > > >  /**
> > > >   * __memblock_find_range_top_down - find free area utility, in top-down
> > > >   * @start: start of candidate range
> > > > --
> > > > 2.7.4
> > > >
> > >
> > > --
> > > Sincerely yours,
> > > Mike.
> > >
> >
>
> --
> Sincerely yours,
> Mike.
>

