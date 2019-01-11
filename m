Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE714C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 02:38:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 953162084C
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 02:38:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uLNnYiWB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 953162084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 143C48E0005; Thu, 10 Jan 2019 21:38:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F6348E0001; Thu, 10 Jan 2019 21:38:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F263E8E0005; Thu, 10 Jan 2019 21:38:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA4318E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:38:01 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id i12so144098ita.3
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:38:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ChVVd5G4oRILHPTf1tyaQyCJSFIBPNwRM4QhHAYVNtk=;
        b=BufLe2WC+Jdoi16pBpGhI0YXatE8AfCPhcvJGNOqy2pLX1TRwceHi8vRyG2u5tIk/a
         xNqhcxl3u1JICZNKtnrIsmpDnoiXCtigf8boouoS8bwtWDkmR2rM9HaLtxqSH5D2gLVV
         K/l+LkMhPHwJzz1SD62HEHuX6LTYaRDS1b7bhltmTh+woOEcCSN38qAVUS3r0oCcp+HW
         NX/QfFbEyNPERbIe8tmDIbpZnblqTCFYPrw8aeqoIDjEioTAnh7cAiRGw9xcKalySDUV
         KLnpi2kn+3DDTwu3kn0WXksnGQzUyf9TV1e/8ocUgRPhnxrerbcODOE3xtlMOOxYyFLU
         Ieog==
X-Gm-Message-State: AJcUukeLtx2XvY63S5Xeu91ixWx+ttT/2iwGH8QdV34UypZbSvj9zpCq
	1ZaPS03malGCblmv0434zPAO0JWwBjU+CgvXGVcUfzBGJhiZY111CuVvJGJxsCKWcA12dlu+rtr
	TLTAFLpestkxDCN4mIYx4sd8+hMRs43S0y68/2pLV5bW6Gd44BBuJSEK1FnNzP6iHorQpJR0r+X
	NDqTcbJuIOQFgUILVH/VyeTzBsjWNhIjiWKQzw4A1X9UWBVSx//OOkCGVskjJIAijCcuTyZ5ndk
	o4GZJ+1H5vvEiTDuF+en+CL5X7NUYctPcBL//OsBHZWLcl2p1qZ1POvbUwkVRaHW/Tobh4//sgt
	3JRFq14CRl7b2NOxEA/Ra71DrlVASNZ62nMAeaFRoGV6HhtD8epSyhvbB0Kn5bwZkY3qaqwwfvJ
	1
X-Received: by 2002:a6b:f814:: with SMTP id o20mr8478638ioh.129.1547174281537;
        Thu, 10 Jan 2019 18:38:01 -0800 (PST)
X-Received: by 2002:a6b:f814:: with SMTP id o20mr8478624ioh.129.1547174280797;
        Thu, 10 Jan 2019 18:38:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547174280; cv=none;
        d=google.com; s=arc-20160816;
        b=CpbKa+2kCawEpmaaeEAKHk35DE5dxsWPYcfgM/Eu0Q68r6UVowLp2/iriEeeIwqADJ
         y5bslbnrOin3OBCIx/Cwxt7tr9T6d/GZSiEuE4FSZ1t9sVITg9vv4SH+pPOvanbrsToe
         Oqe/3okGOySP9jBYvv9ssGJaqRtVM6pCwuCtJAwfpToVilJdz4NeVhYrVUi8cJ1UEU6z
         X0/8LcwZZFgCvMxEc4czkH2WdQj0LNIgGlyMFIYxo09Kb6BimH0QRZrzAUGGgY8gnjD4
         FfUYSxA3ycQ2ah+5F5a/hH31jYioToQ6GRQNREnEJ19vSNWKwOflhKPVwdoC0fMjs6am
         L7Dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ChVVd5G4oRILHPTf1tyaQyCJSFIBPNwRM4QhHAYVNtk=;
        b=IjS8rm2ZwDjhnEzXh3OA2C9EaRJDPdOR2jWIuWzkpJ6A0UHuymInb39m8wjt0oEaDX
         O6YRB8kyQZfPagJURlObeK28EZjmTftqchaKAeNvyQI+c2HqbsHOeCV7iv7cP4T+99WC
         q7pvuwpyOZK/MuRkpgKvVC9Q4/ZD02wj0Eo26VvpEyx5MomKkOH3v937kn+oJyVVbVpZ
         a+toSyhol62p4BGiE89Y8OQcomXWkbeCUHP2/YlFZIRToW2zIqidA1K7Xsv1ZhIZ9sX7
         QbFk7xMmBuixDkRYCy3ZTaILhBD90dLKPxcLNY2QoL44PpYrsnk690LoYUKA1awchT6J
         dYKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uLNnYiWB;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 23sor241556jal.5.2019.01.10.18.38.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 18:38:00 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uLNnYiWB;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ChVVd5G4oRILHPTf1tyaQyCJSFIBPNwRM4QhHAYVNtk=;
        b=uLNnYiWB8I17TwcJpP71jhsWQB4meFDYlrAGHOkxy7wq6xDTSnZzk3eWhJkW7DO9IZ
         WT1NBZ/YpqQu9ax/bSfID5CQoaoRKkc2Jdiov5yigZE7oKp0cV25oN/sxiVmTc9WFs2B
         Kcj3lfnsb0uj3K+lKkrQEVssWYmy2yqje0zjmy/39oStMT6inoAVKqM6MbNCEKb+z+5r
         5pPSC7htXM5SH6nHDIlHeCd+plBE7Dr57eSYIMqkGyCVCZTmZO/oyE7uiJfCrIfFj70R
         mzOyG1SbRsD/l0uYpwQU3NXJOeIKCtcPe939oi+7lyC5Egz/c/tdaXln7vj1ERbjmyhY
         KZ8g==
X-Google-Smtp-Source: ALg8bN6aUllHXnFFLmH1NDESj5/2uRqt/6kCtMryq2v6x3xBiLqUIkUuC+kyE6HiOYq/eufCp7x3rS4MvHeYhQVunVw=
X-Received: by 2002:a02:8244:: with SMTP id q4mr9163965jag.43.1547174280468;
 Thu, 10 Jan 2019 18:38:00 -0800 (PST)
MIME-Version: 1.0
References: <1546848299-23628-1-git-send-email-kernelfans@gmail.com>
 <20190108080538.GB4396@rapoport-lnx> <20190108090138.GB18718@MiWiFi-R3L-srv>
 <20190108154852.GC14063@rapoport-lnx> <CAFgQCTtVjwJ_Rfp8DcmzPx6uYPnOx7E_x=YjC+MQ=mx7W38HEw@mail.gmail.com>
 <20190110075652.GB32036@rapoport-lnx>
In-Reply-To: <20190110075652.GB32036@rapoport-lnx>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 11 Jan 2019 10:37:49 +0800
Message-ID:
 <CAFgQCTtXp3gOhfzfQPnBP7wU7ABCJcyTTki689iqkVEr_A21AQ@mail.gmail.com>
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
Message-ID: <20190111023749.kPvVCE__eYWDoMOs4jIyc34cQC1SnkcFPYXx7q93B_0@z>

On Thu, Jan 10, 2019 at 3:57 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> Hi Pingfan,
>
> On Wed, Jan 09, 2019 at 09:02:41PM +0800, Pingfan Liu wrote:
> > On Tue, Jan 8, 2019 at 11:49 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> > >
> > > On Tue, Jan 08, 2019 at 05:01:38PM +0800, Baoquan He wrote:
> > > > Hi Mike,
> > > >
> > > > On 01/08/19 at 10:05am, Mike Rapoport wrote:
> > > > > I'm not thrilled by duplicating this code (yet again).
> > > > > I liked the v3 of this patch [1] more, assuming we allow bottom-up mode to
> > > > > allocate [0, kernel_start) unconditionally.
> > > > > I'd just replace you first patch in v3 [2] with something like:
> > > >
> > > > In initmem_init(), we will restore the top-down allocation style anyway.
> > > > While reserve_crashkernel() is called after initmem_init(), it's not
> > > > appropriate to adjust memblock_find_in_range_node(), and we really want
> > > > to find region bottom up for crashkernel reservation, no matter where
> > > > kernel is loaded, better call __memblock_find_range_bottom_up().
> > > >
> > > > Create a wrapper to do the necessary handling, then call
> > > > __memblock_find_range_bottom_up() directly, looks better.
> > >
> > > What bothers me is 'the necessary handling' which is already done in
> > > several places in memblock in a similar, but yet slightly different way.
> > >
> > > memblock_find_in_range() and memblock_phys_alloc_nid() retry with different
> > > MEMBLOCK_MIRROR, but memblock_phys_alloc_try_nid() does that only when
> > > allocating from the specified node and does not retry when it falls back to
> > > any node. And memblock_alloc_internal() has yet another set of fallbacks.
> > >
> > > So what should be the necessary handling in the wrapper for
> > > __memblock_find_range_bottom_up() ?
> > >
> > Well, it is a hard choice.
> > > BTW, even without any memblock modifications, retrying allocation in
> > > reserve_crashkerenel() for different ranges, like the proposal at [1] would
> > > also work, wouldn't it?
> > >
> > Yes, it can work. Then is it worth to expose the bottom-up allocation
> > style beside for hotmovable purpose?
>
> Some architectures use bottom-up as a "compatability" mode with bootmem.
> And, I believe, powerpc and s390 use bottom-up to make some of the
> allocations close to the kernel.
>
Ok, got it. Thanks.

Best regards,
Pingfan

> > Thanks,
> > Pingfan
> > > [1] http://lists.infradead.org/pipermail/kexec/2017-October/019571.html
> > >
> > > > Thanks
> > > > Baoquan
> > > >
> > > > >
> > > > > diff --git a/mm/memblock.c b/mm/memblock.c
> > > > > index 7df468c..d1b30b9 100644
> > > > > --- a/mm/memblock.c
> > > > > +++ b/mm/memblock.c
> > > > > @@ -274,24 +274,14 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
> > > > >      * try bottom-up allocation only when bottom-up mode
> > > > >      * is set and @end is above the kernel image.
> > > > >      */
> > > > > -   if (memblock_bottom_up() && end > kernel_end) {
> > > > > -           phys_addr_t bottom_up_start;
> > > > > -
> > > > > -           /* make sure we will allocate above the kernel */
> > > > > -           bottom_up_start = max(start, kernel_end);
> > > > > -
> > > > > +   if (memblock_bottom_up()) {
> > > > >             /* ok, try bottom-up allocation first */
> > > > > -           ret = __memblock_find_range_bottom_up(bottom_up_start, end,
> > > > > +           ret = __memblock_find_range_bottom_up(start, end,
> > > > >                                                   size, align, nid, flags);
> > > > >             if (ret)
> > > > >                     return ret;
> > > > >
> > > > >             /*
> > > > > -            * we always limit bottom-up allocation above the kernel,
> > > > > -            * but top-down allocation doesn't have the limit, so
> > > > > -            * retrying top-down allocation may succeed when bottom-up
> > > > > -            * allocation failed.
> > > > > -            *
> > > > >              * bottom-up allocation is expected to be fail very rarely,
> > > > >              * so we use WARN_ONCE() here to see the stack trace if
> > > > >              * fail happens.
> > > > >
> > > > > [1] https://lore.kernel.org/lkml/1545966002-3075-3-git-send-email-kernelfans@gmail.com/
> > > > > [2] https://lore.kernel.org/lkml/1545966002-3075-2-git-send-email-kernelfans@gmail.com/
> > > > >
> > > > > > +
> > > > > > + return ret;
> > > > > > +}
> > > > > > +
> > > > > >  /**
> > > > > >   * __memblock_find_range_top_down - find free area utility, in top-down
> > > > > >   * @start: start of candidate range
> > > > > > --
> > > > > > 2.7.4
> > > > > >
> > > > >
> > > > > --
> > > > > Sincerely yours,
> > > > > Mike.
> > > > >
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

