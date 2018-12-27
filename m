Return-Path: <SRS0=02aR=PE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6708C43387
	for <linux-mm@archiver.kernel.org>; Thu, 27 Dec 2018 19:32:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A31C12148D
	for <linux-mm@archiver.kernel.org>; Thu, 27 Dec 2018 19:32:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="L+nL6fBG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A31C12148D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 459138E0020; Thu, 27 Dec 2018 14:32:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40B438E0001; Thu, 27 Dec 2018 14:32:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 320348E0020; Thu, 27 Dec 2018 14:32:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B2CD8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 14:32:19 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id j5so25133703qtk.11
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 11:32:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=zAjCO3GnuR7K5LykI+2+0VuB0+2IVvgrxN27c6QBKuM=;
        b=BnBB7Ts/+eTMqmDeK8bVfUUo3ZRgsg52XDOi+BH/nBQk3uwgvwJPtdXQffxU7F7N0E
         h7BP5WDvnenNpdq5xudY9Z/nak/fjJW0l/+lVb9pWKdiGFYVwocjOlHxEHUQBJrVaNYW
         7DEstkU66eMPfKW6mi0h5offQHtVFWqbZqaViQIvLI1svNhuNIyaaWB9sUPxy6r471PN
         xnk9Dxt2Y6OHvqOKE289HCqiccTFFHMJjBOj/Dnfg5MQW9NNCnvNovGn9WIBlEbi/Umd
         NnUZ6LEdsKApLnCnIskIJ//BFgRzkLrCuMAgk0qTYg0BDEIUnnX+s85c645ZJsTm73tk
         uykA==
X-Gm-Message-State: AA+aEWa+j1GTmMdSxCxizcvkqscKLUdCXPLq3EI0zk4zlmZFvg7cFnbO
	sIkZOlgjxoSzgfUTeeaeYd23Pg2N4sSwDcDGhC6M6OdGHJYQuZTmufWUBxLzQiVjc0ngBmzfB4k
	cFpQ99KcpqeJzNH6pO+5zMA03+aS7/iUqYHzRT7qiS2UUByUY5NX7LwO65iHDzbT06B3KE5f8zU
	45SNf4WWUuIVqTojXNmcahbUvGQARwcLvlexnQjuETeT5X5N92yQR+D/h/mUsQbGpRmTmiBGNCN
	BK7NzhnFR4wGoa99jmB1CUzZFuqDGPIQterSFChSDK9+ts2nT36kl/49s1YsX2mNPYG7P/MRXjo
	1SrNQ1+MJDMNsjs2toYehJQEo7D++9iRDYj6nQS9lLgx1/kcoHi7ic2fvEvBkn92BfnNEayMNNG
	b
X-Received: by 2002:ac8:3f2d:: with SMTP id c42mr23476451qtk.33.1545939138676;
        Thu, 27 Dec 2018 11:32:18 -0800 (PST)
X-Received: by 2002:ac8:3f2d:: with SMTP id c42mr23476420qtk.33.1545939138125;
        Thu, 27 Dec 2018 11:32:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545939138; cv=none;
        d=google.com; s=arc-20160816;
        b=Bhj3pKG4Sg5qPuImJUi/811QYfwV5XTGbnW7AXO/Mutjmranw1u7apKDqJLDPX39XT
         rA0qlukdGdRezXqtJcHitiHdfPxI8gAwR1hkCtoFQdz2wOFP1MOKJB1yPIaok+hfLHNl
         m/7wkJjforWEi/8inFQk4dh8iz2cQoCI2b3ZhTDHMOKtcfgIs9fA74dfWzUOfcQFZibj
         DaQEJ6foXBm+RBFhe7UOdczrrxKoIpw6nOp6AEclEbLDRqQ73H4oac+EpEPJ+p3PJq6r
         0hrwCZzTQmLkkQ+zeSAbuVkY41jqTLsWSD2JG59Nk/3tsOUQd0VNpoWLP4GotjS8UoCm
         UExg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=zAjCO3GnuR7K5LykI+2+0VuB0+2IVvgrxN27c6QBKuM=;
        b=m0fLJuv/qsYeSH4BshDNcKB9hSOSmNQTUl8IhfgiegzYgIilxCUdrTaXHXA31sT4xC
         w+S1Pknhl5/jHytbLbEpLkF08AF+O6aRtGo7yEAInyz8esHOKE0Qnh5dBZ0qbPLsr/4j
         x8Scu7dfI7Ams8N1ZenPjS119gBzek3WPMi6T4emGsHe8hWjB+/WALaVFSF1tRFXVWLQ
         0drv+vgBlAd3EghRdOf6KCEHBhsDyKjgya6HqictAVa+MXlNYWbDNB9xnppCRZ3DSnfw
         WuK3T4HL3cAWgnC3Y19FnBBkSPW7SthHlW6Gf7CACx8w0L56jaz7Pl/XDVvE2ShbOuiI
         NH4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=L+nL6fBG;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k7sor14979599qkc.144.2018.12.27.11.32.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Dec 2018 11:32:18 -0800 (PST)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=L+nL6fBG;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zAjCO3GnuR7K5LykI+2+0VuB0+2IVvgrxN27c6QBKuM=;
        b=L+nL6fBGB68bgCmWUTBV8p4elnCb/9wH8Hf0dO7WF3Csk8nhG6AF1w/gPOqIZncq68
         udkbk9UmTSxHS0HNnPEUEU9WZ6PaB1ZcQKp0+HacB1TMvdOWRjwVw4RwgGnKcw46QSNn
         Phld/Tv2zx2aAbW4lFVnlQ2w3d2JY4Al+LMzqQZKmUaQQc538rYZ1aGDxRwD2dhZ4/kX
         FhqiRpLRSURikdn5zXL+pI89VvrcO8z+N1zXnfz22WTRcvokvqHj5c8iPY9DIyFDuZMJ
         Bx6EfCrhC7pYka5a5C+fb0c1yY283/FP3K9H9ZzPuMAAbJzOJp6lr2Rgae3j0WQJ0tMT
         39Qw==
X-Google-Smtp-Source: ALg8bN7cFEH0nAFiavDtrruWYIkUr4bNP4bbMHbm0mHq2lQX9nStpzzZ24Gosp7aYu/35ejoJO5uu3Ki8y5W6l7TT8g=
X-Received: by 2002:a37:9281:: with SMTP id u123mr23363934qkd.0.1545939137848;
 Thu, 27 Dec 2018 11:32:17 -0800 (PST)
MIME-Version: 1.0
References: <20181226131446.330864849@intel.com> <20181226133351.106676005@intel.com>
 <20181227034141.GD20878@bombadil.infradead.org> <20181227041132.xxdnwtdajtm7ny4q@wfg-t540p.sh.intel.com>
 <CAPcyv4hBBvcHiUSU4ER6WV7Po_GEwDjFcJy2aE3VW5Nwiu+Qyw@mail.gmail.com>
In-Reply-To: <CAPcyv4hBBvcHiUSU4ER6WV7Po_GEwDjFcJy2aE3VW5Nwiu+Qyw@mail.gmail.com>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 27 Dec 2018 11:32:06 -0800
Message-ID:
 <CAHbLzkqR2z+wcVXkKRoHysXtjtn12P33emr15h_HB=jMaByV5w@mail.gmail.com>
Subject: Re: [RFC][PATCH v2 01/21] e820: cheat PMEM as DRAM
To: Dan Williams <dan.j.williams@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Matthew Wilcox <willy@infradead.org>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, KVM list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, 
	Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, 
	Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, 
	Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181227193206.eINsnooRU6RM8OlkDkhq4BXx9-rGqhsB6VPSQIxCjPQ@z>

On Wed, Dec 26, 2018 at 9:13 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Wed, Dec 26, 2018 at 8:11 PM Fengguang Wu <fengguang.wu@intel.com> wrote:
> >
> > On Wed, Dec 26, 2018 at 07:41:41PM -0800, Matthew Wilcox wrote:
> > >On Wed, Dec 26, 2018 at 09:14:47PM +0800, Fengguang Wu wrote:
> > >> From: Fan Du <fan.du@intel.com>
> > >>
> > >> This is a hack to enumerate PMEM as NUMA nodes.
> > >> It's necessary for current BIOS that don't yet fill ACPI HMAT table.
> > >>
> > >> WARNING: take care to backup. It is mutual exclusive with libnvdimm
> > >> subsystem and can destroy ndctl managed namespaces.
> > >
> > >Why depend on firmware to present this "correctly"?  It seems to me like
> > >less effort all around to have ndctl label some namespaces as being for
> > >this kind of use.
> >
> > Dave Hansen may be more suitable to answer your question. He posted
> > patches to make PMEM NUMA node coexist with libnvdimm and ndctl:
> >
> > [PATCH 0/9] Allow persistent memory to be used like normal RAM
> > https://lkml.org/lkml/2018/10/23/9
> >
> > That depends on future BIOS. So we did this quick hack to test out
> > PMEM NUMA node for the existing BIOS.
>
> No, it does not depend on a future BIOS.

It is correct. We already have Dave's patches + Dan's patch (added
target_node field) work on our machine which has SRAT.

Thanks,
Yang

>
> Willy, have a look here [1], here [2], and here [3] for the
> work-in-progress ndctl takeover approach (actually 'daxctl' in this
> case).
>
> [1]: https://lkml.org/lkml/2018/10/23/9
> [2]: https://lkml.org/lkml/2018/10/31/243
> [3]: https://lists.01.org/pipermail/linux-nvdimm/2018-November/018677.html
>

