Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12EB6C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 19:55:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4B4D2086D
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 19:55:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LbcNP/Np"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4B4D2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C74D6B0003; Fri, 28 Jun 2019 15:55:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69F1D8E0003; Fri, 28 Jun 2019 15:55:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B4CD8E0002; Fri, 28 Jun 2019 15:55:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f80.google.com (mail-io1-f80.google.com [209.85.166.80])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7006B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 15:55:33 -0400 (EDT)
Received: by mail-io1-f80.google.com with SMTP id y5so7783560ioj.10
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 12:55:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=f2yLYBZUi8BM/4wZmIBqHDnSCICFDY3sNbGxuLsfM0k=;
        b=EIhyDlNcSPQ7q8qLXmR2GO46kI8/rLWU95tI6wEcrrcdfeQGa1LdR8jhWNhfcrhVdQ
         GiPoP2OtRN0DHoGRN7U8a+ulvKuHOG82bxgnMhekcw9DCuvN5V/1ysd1WvJt5t6iVh7a
         K1J7rUO6GgCJLVsEh7lSK6h5uErQHXExzu9AIaUp3Ewl9c4w347RP4bpvaDddCvIPcaU
         1T5YtY34LQKME5qW1WMM+mgBFtk7hadmA06Mh4U7Bqpaq12Q7csjZ713R42ZfK6tF5BK
         IrTLArzg2lQyvP+1b8aF0Kzve2zT6mZ+8V7v+1LOtr/4wyLjW/AWuw0bS7ZfJLA5+TnZ
         zoyw==
X-Gm-Message-State: APjAAAXCYcXaHbpCg38Ss+cLs808ryEuGEl8mGs91UU6FhZLGa8LvD6a
	QJLP40EE9+hcsG8sw5JV5bkifUqf3qaZ5bGh3PrCdtnnO2mT36YZYT5+j9ARpGykjKvTFuEsBIl
	wKWU17Zdb2ilIz7zGPZUx2riO0p1eKrBbwFGnV4ZwC/izZAm9jYCIm0YuwqG9kJuRFg==
X-Received: by 2002:a05:6638:3e4:: with SMTP id s4mr13698676jaq.141.1561751732986;
        Fri, 28 Jun 2019 12:55:32 -0700 (PDT)
X-Received: by 2002:a05:6638:3e4:: with SMTP id s4mr13698626jaq.141.1561751732420;
        Fri, 28 Jun 2019 12:55:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561751732; cv=none;
        d=google.com; s=arc-20160816;
        b=gd+W0+r2KWH0Erwl25iVgvQm6l0W13aWjRYsLylwEaOR3dC7qYqE5eelYeANisWX59
         myEQc2KbXY7zcBvgQYBujdEtMMfzGX5c5LMZLc440P3CakDQi8FmirPCMbKpi+tpoPud
         XEPnAwvvsol2J7qz1ZAhUwtMPAwAI5wFBRUFV39DQaZJ5hUh/WIxqpzRY0i3o8rtfULE
         n1aawoXq1Q88Lbi/uRVZvqO8tSwuTTGsD2AKlX44iQJefXF253Bu6LowJwwGSKy5toHD
         LlZSlzVWDr6dQ997xG3/N/1++atEXxS2vNm9mVWxZzPcHVCfUVGdIvSFE0t5wdBbFlzU
         dRhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=f2yLYBZUi8BM/4wZmIBqHDnSCICFDY3sNbGxuLsfM0k=;
        b=mbg3+XwKT57lvJApC929UFkkdzrn5tQwEOybFIh6oEOnG4q8wSuQo42mw6nwC1cLRl
         QtHSQZglz5iZYKfniEKGiw79nAs+CRClZc90N+RCyily5+PEK+sPAUE1nkXUVtSjNUEA
         sO9ReYt0RBz5lkO2ci2XTKB0joJo8UJjyI3jYEJIysae8dnYfzP2wYxN8Q97LSaEya+S
         LIcTS0MgO2jVy1879mtztiTMSntvM6VwumMs6x5vkwu8OPhnIW8+uklTUoQABzrwXDxB
         PJhA70IVEuJHiq860BhfZo/7f2o+un52W/gkyCGWT/1NbzfqXXq+TaHCfc5JJSUdry5U
         DFww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="LbcNP/Np";
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7sor2725871iok.7.2019.06.28.12.55.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 12:55:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="LbcNP/Np";
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=f2yLYBZUi8BM/4wZmIBqHDnSCICFDY3sNbGxuLsfM0k=;
        b=LbcNP/NpYTiLzuG8hu83xxWym0DcCioXNOxYN4/h+QJ/lY70UIce05xClprRUb3M5H
         Kb5diR2YwHMOhaQmb74WhvzthU3Ow8ao+LLv5dKAFH25WUoGyzO0yrr3bbV1JHSTcY3z
         +FpAlFco+H2c4S/AawTfTaqbKTbcoYMb1q7P3gbGfcKTJ8gXRwkOUm2mwRr7YaHluPni
         IObuKWcBf9XhDGZmUlYG+8ULHLTZ4T3ZEgBBaiviHizyEuu+CqlKYnBwR4serz04dKZp
         kMVH8L1/zuf9P0GaHpJ6mTm0s7InpNwiF8ZbulhJdvBKZAoCC30bCwPrtEz1ptajyizj
         mLRQ==
X-Google-Smtp-Source: APXvYqy6jPwUSYsREJwQF0076GQ3zmexyIsNehD14G3SWw4LW7DT42vQGbWcnDIisCJFt4I207HSbpWwNYm7IFe9tZA=
X-Received: by 2002:a5d:9dc7:: with SMTP id 7mr13024297ioo.237.1561751732065;
 Fri, 28 Jun 2019 12:55:32 -0700 (PDT)
MIME-Version: 1.0
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <20190619223309.1231.16506.stgit@localhost.localdomain> <68ed3507-16dd-2ea3-4a12-09d04a8dd028@intel.com>
In-Reply-To: <68ed3507-16dd-2ea3-4a12-09d04a8dd028@intel.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 28 Jun 2019 12:55:21 -0700
Message-ID: <CAKgT0UcpbU2=RZxam1n84L3XnTqzuBO=S+bkg9R1PQeYUxFYcw@mail.gmail.com>
Subject: Re: [PATCH v1 2/6] mm: Move set/get_pcppage_migratetype to mmzone.h
To: Dave Hansen <dave.hansen@intel.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com, 
	Rik van Riel <riel@surriel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 11:28 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 6/19/19 3:33 PM, Alexander Duyck wrote:
> > In order to support page aeration it will be necessary to store and
> > retrieve the migratetype of a page. To enable that I am moving the set and
> > get operations for pcppage_migratetype into the mmzone header so that they
> > can be used when adding or removing pages from the free lists.
> ...
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 4c07af2cfc2f..6f8fd5c1a286 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
>
> Not mm/internal.h?

Yeah, I can probably move those to there. I just need to pull the call
to set_pcpage_migratetype out of set_page_aerated and place it in
aerator_add_to_boundary.

