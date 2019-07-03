Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55DE3C5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 05:54:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17A0321871
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 05:54:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AHbczLFR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17A0321871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A50356B0003; Wed,  3 Jul 2019 01:54:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DA248E0003; Wed,  3 Jul 2019 01:54:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A3148E0001; Wed,  3 Jul 2019 01:54:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2218C6B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 01:54:33 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id f24so101596lfk.6
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 22:54:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fodI9RBCNqef8mpe31lNAJ/C8aPx3qCPQdaIULFPQEE=;
        b=ofahv3TUc9tV+UFPBK4RcbZLps5MUaJzNIVmkHd7ufX6CvmxyRQ7X+tn22n6j7i2z1
         x1NN68Th2A/aj0fD7Pq8YeBwCu/JMuOGbhkhpj4f/3JyhQLMPvmFOlfHnckOW+oYTbng
         pS+q9l06agUdyLM+HlBjy5ZioR4CMib6Rn6csZ1LF1XuSnALrqWRyvaqcXPiYocOxmah
         OOvkwaIE0j9u1jrcMH9vmgilyYD4ecGLNJUJLebqmopyo2QJcJlGQ5UOLKi8K5mPFGDi
         OTR0ibfJIymlooZMbKhNFbjbXEMiopPz0h7ca1fpI2IVFDMeZ9j1Jbxsqs4RKSmzwL9U
         kk1g==
X-Gm-Message-State: APjAAAW9JK+1UxMW6A3bNPv1Yvrubt7yH+NPxgWSQqZ5Ke1BHzGw4lDL
	tkKQqw+XoUJuDFqdhc3lEZFT4vW8pfQmBpdG0MZQLKKkYVZrAEken+rO6nsPZg/RmAEyRoqHjYl
	ltsbj37lAeyOTHw+K2Sak32PkHOJx9UxXat1eS2881c8icnZFVCK08PZBw5+c1RX7Eg==
X-Received: by 2002:a2e:8944:: with SMTP id b4mr19134490ljk.154.1562133272227;
        Tue, 02 Jul 2019 22:54:32 -0700 (PDT)
X-Received: by 2002:a2e:8944:: with SMTP id b4mr19134421ljk.154.1562133271127;
        Tue, 02 Jul 2019 22:54:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562133271; cv=none;
        d=google.com; s=arc-20160816;
        b=pi82Izdy+LHwaL/+bXzzB19sKrPIbD9eTvOCJteNTy7gb5zWrw4iHyxbF6Ejr70NHF
         c28+vqfIUp+cyZv/5KqevYqlikZ6LlJfn8rCfduQleVZ7eJoesHGPZD7GDfrTPz78xBE
         HKUp2CVDmEOZHyzrYnduzlwjD0Z3kDq50V25FDmDtN8hX5gJFQG0Agtt4ApaOm8P9RzJ
         4XMxE7lM8G/7+NrGmrlHoivkxItCrTLrRjeWLXXnDUkp6da+NQJxwq9CKLtjsqoLUeHW
         B2zfIx+KkQXhWEm8QzkzK2dg1b0tyWBNAyxAMEQIgKHh3Mj2Oz4LoIP3z72G6O9SZl2+
         TYaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fodI9RBCNqef8mpe31lNAJ/C8aPx3qCPQdaIULFPQEE=;
        b=nPYy/RKGAeY9vJGkgBsjBUhoGG9zyDRfIte1vyeTjCCJPSvu/8uBdmHaRTTxwHz9Un
         snVwYCXb8qdto3dgix2qEbEtJcXSe8DjzZxFgSmLeJJ/nWtjKyKhaPiBJnTRivg9q5gE
         enSOGWhAiYswit16EG2F9BLZ/92eyWucPtKuLOK/r9lFEjs6XRYOXYJi8EZwQoxjz6WD
         QD2nmmmpOeHpapS16PlcUiBJb/FesK0pLqhmPByb98ZVBxYrZMiGH5or91u/V+lL9SxO
         A8cZiIm2reMoYGvQDB7eC8v4B89g+tXB976dM9WqnCGgrYBlP0yd3JALBUNUdIJqx45r
         IiDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AHbczLFR;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r23sor493343lja.30.2019.07.02.22.54.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 22:54:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AHbczLFR;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fodI9RBCNqef8mpe31lNAJ/C8aPx3qCPQdaIULFPQEE=;
        b=AHbczLFRfqjuasmjmf30Hp49qfV0kAllz4rzpXWdPTIk4/ZlCNK3n/2EkaNRwYdgbz
         X+cN1RcUD9z36Tgkn2j1xJtIDZYR8Fht7jHZ/tMm4ZcIxsyU60SOhe/boS6RwAnsXUJo
         X5J8ToDtvEIH/qsrWau/X0ci+4WSMh89blfdBk66hBhOxobWrJ2qD8o9ZcEQGbqHbRBp
         x98npKojErQCAkBd65rFWVqeJfetB9Eo8/8KJ8O3sa4sy2+ZAFvp8qNadLIbuyNccfhf
         cp+k5AgU1VUR+Tk6JLRN/QSawNvIrPCeZdT/pV2Yk23NdGrbnxVXdeUMAsgH+KKqWd8L
         5NUQ==
X-Google-Smtp-Source: APXvYqwQEFSscdGA01+RoCapFWC3y9tcFL0+T1GOAo2m1WR3EkamuBGmQ24dndljkFKzDHi1wqKgkanBahuRl8HlrgY=
X-Received: by 2002:a2e:80c8:: with SMTP id r8mr5330522ljg.168.1562133270780;
 Tue, 02 Jul 2019 22:54:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190702005122.41036-1-henryburns@google.com> <CALvZod5Fb+2mR_KjKq06AHeRYyykZatA4woNt_K5QZNETvw4nw@mail.gmail.com>
 <CAGQXPTjU0xAWCLTWej8DdZ5TbH91m8GzeiCh5pMJLQajtUGu_g@mail.gmail.com>
 <20190702141930.e31bf1c07a77514d976ef6e2@linux-foundation.org>
 <CAGQXPTiONoPARFTep-kzECtggS+zo2pCivbvPEakRF+qqq9SWA@mail.gmail.com> <20190702152409.21c6c3787d125d61fb47840a@linux-foundation.org>
In-Reply-To: <20190702152409.21c6c3787d125d61fb47840a@linux-foundation.org>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Wed, 3 Jul 2019 07:53:32 +0200
Message-ID: <CAMJBoFOhXP36L6pZEA-7p24mJweDGe9iYb2fo1nNCxadYHcPzQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/z3fold.c: Lock z3fold page before __SetPageMovable()
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Henry Burns <henryburns@google.com>, Shakeel Butt <shakeelb@google.com>, 
	Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Xidong Wang <wangxidong_97@163.com>, Jonathan Adams <jwadams@google.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 3, 2019 at 12:24 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Tue, 2 Jul 2019 15:17:47 -0700 Henry Burns <henryburns@google.com> wrote:
>
> > > > > > +       if (can_sleep) {
> > > > > > +               lock_page(page);
> > > > > > +               __SetPageMovable(page, pool->inode->i_mapping);
> > > > > > +               unlock_page(page);
> > > > > > +       } else {
> > > > > > +               if (!WARN_ON(!trylock_page(page))) {
> > > > > > +                       __SetPageMovable(page, pool->inode->i_mapping);
> > > > > > +                       unlock_page(page);
> > > > > > +               } else {
> > > > > > +                       pr_err("Newly allocated z3fold page is locked\n");
> > > > > > +                       WARN_ON(1);
>
> The WARN_ON will have already warned in this case.
>
> But the whole idea of warning in this case may be undesirable.  We KNOW
> that the warning will sometimes trigger (yes?).  So what's the point in
> scaring users?

Well, normally a newly allocated page that we own should not be locked
by someone else so this is worth a warning IMO. With that said, the
else branch here appears to be redundant.

~Vitaly

