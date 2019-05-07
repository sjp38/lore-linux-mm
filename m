Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA3CAC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 13:16:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6925B205C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 13:16:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Cm6wvAFw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6925B205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0206F6B0005; Tue,  7 May 2019 09:16:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F13BC6B0006; Tue,  7 May 2019 09:16:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E28A56B0007; Tue,  7 May 2019 09:16:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D3F06B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 09:16:09 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id d13so2590799lfi.22
        for <linux-mm@kvack.org>; Tue, 07 May 2019 06:16:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MHPIqM7JCox7474Ql+xv/9Bn+cArjwrigJpmZBOlFYc=;
        b=jErkPMlT/Spby54AB+/9EgwBv28scNBKR2MPCza6zZfYSlAzC3PXaTuV2GUB7UVAlk
         aIz7DIkT+i0wPceCVZ2iCjitbH8U8lSEwSMAwKtpcpJ4JHVkymrS1QvGfF7ZlaW+kVlU
         CBjCgi7XpW8cnkN6twmy5B1SDgPy/5lGzZsjFXifb8/Gx7374l5vS0eT31SK5r0TFPw1
         7z9ZBsepAwoCSygClDUc4JQP+1FTwjyYWF3gaRg3gZA8AKCd/oXAq4fXer16WwA6nmRQ
         eKUxTsUYKtx7uck7DjzfH3eMwIYMzx8HqITQVHDUECaevLJr6F/I/Nyh1lJdxQO4lz+9
         dyvQ==
X-Gm-Message-State: APjAAAVU4KeHO5PVsyM7tPt+UzRzjZDlxooNmhVGw8F8Je9y3/PCjFJM
	b1SrQ/Cmp1pEkvjTi9grSFe9Wmj3dv9ufTZmi4m0uLuwe7ijuQDrohPOSODS1IlFnUDmpHOGpEp
	cYuPPaTK0CG+tSn2Q50gcGLcwkMQbhIs4SRoAQ5LXwlzzHJacghu642gqbKZmey7Nwg==
X-Received: by 2002:a2e:1508:: with SMTP id s8mr16894291ljd.87.1557234968541;
        Tue, 07 May 2019 06:16:08 -0700 (PDT)
X-Received: by 2002:a2e:1508:: with SMTP id s8mr16894230ljd.87.1557234967216;
        Tue, 07 May 2019 06:16:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557234967; cv=none;
        d=google.com; s=arc-20160816;
        b=TvGMr37mMlpL53fuHP5vipzM9+4K1kbDja6RQlAT56TGnun1uHGuK3vJpuiDa1Y882
         eVlRZ6bQJEQdUxDm8br7O5mgbSoZciuw4CORCpgjvtpezYrT0gFOiV/dtFAFN8O1KIwB
         TWq8WhI9JpMkl+JqchMxN2qKXtkOprTW0kJrx5FaEeVKw8cuvEMjKgP/fuChX96dfIf5
         XRaH8MBSnJQpqwUXhUiYXx0ymQkgmbL7mJGfBCVwaAv75fHN3Awx0Be/nqBZ8Sv3bFfn
         6xQVO9M5gs3NfA9RY9+uD2rZiuLc8rnXwU5I1D+dtDmZqQNs2JCQoDj42Tz6W38raFAc
         z/WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MHPIqM7JCox7474Ql+xv/9Bn+cArjwrigJpmZBOlFYc=;
        b=YjoBKjHgWjjCHjlJRUZVVg7/R6GJh80AhEeKIiKpfOu1iRJZfugmKpUWy2mF0ytcOz
         OTt4iN2RARYWP5/tDfZXGav7PG6fMTrg9i+Fs3ePOuNlrz2VheMWRRGskR6QSOOXPmEk
         PaSJBggLumOCX1fxisGNDH/ApWoj+OWG3GXM0mOfEwjkHWkDLuMLQGrpSvaxe1KzPluG
         wUGerffjt8O8MOplPBQRG0AmtI3zFKd3FC7cFGz096cMTxzS2WDMTbAWM43cBelxiU46
         zHQ2U6az/Yo2MB7tIWZbI7JEHkls/R92bGWcgAdgZ5QoTApQ0rSDo9p3NBbtPlH3prCl
         KUvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Cm6wvAFw;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x23sor2008571lfe.51.2019.05.07.06.16.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 06:16:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Cm6wvAFw;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MHPIqM7JCox7474Ql+xv/9Bn+cArjwrigJpmZBOlFYc=;
        b=Cm6wvAFwgAxp/8D3CkSsBcbPu7kiNDKTuOPOjj7VgZexU4R3MuQVhAtBWxto2J3mkD
         R5ilpzaX5NiHw5RM65X5ZS2DkJuQA7x+/Hp5Bj/Y3EJ5iS12D5vswADthPKpU8JlQtX/
         +evJAeTS11J4tIUcoXBhWnOD404ANf2KNSE50/ynuFzUReJkCdsj0p72urrf5GyApTod
         1p2j+DBuZtLzo0G3wpB9Dkn+us74hciQr/9q9l5MhPPR2rrRwHq9GwCHiN/OIhTB42lF
         ekO9nOGnT2bD3xS7Fw5XfrJwzz1km3w0uXrPLjHG4I5LqG9YqonzZlEzFrqkL70EWiIs
         Jacw==
X-Google-Smtp-Source: APXvYqz8d9kZlmnP7W0YjChLPfOjnpt8Wn0ENZFruzEv4tpK/oiDqKaN1ndX881yL1autUWNqhijNjQCghEYOAXZjxQ=
X-Received: by 2002:ac2:5495:: with SMTP id t21mr16592698lfk.3.1557234966713;
 Tue, 07 May 2019 06:16:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190506232942.12623-1-rcampbell@nvidia.com> <20190506232942.12623-5-rcampbell@nvidia.com>
In-Reply-To: <20190506232942.12623-5-rcampbell@nvidia.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 7 May 2019 18:45:54 +0530
Message-ID: <CAFqt6zbhLQuw2N5-=Nma-vHz1BkWjviOttRsPXmde8U1Oocz0Q@mail.gmail.com>
Subject: Re: [PATCH 4/5] mm/hmm: hmm_vma_fault() doesn't always call hmm_range_unregister()
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, 
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, 
	Balbir Singh <bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>, 
	Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 5:00 AM <rcampbell@nvidia.com> wrote:
>
> From: Ralph Campbell <rcampbell@nvidia.com>
>
> The helper function hmm_vma_fault() calls hmm_range_register() but is
> missing a call to hmm_range_unregister() in one of the error paths.
> This leads to a reference count leak and ultimately a memory leak on
> struct hmm.
>
> Always call hmm_range_unregister() if hmm_range_register() succeeded.

How about * Call hmm_range_unregister() in error path if
hmm_range_register() succeeded* ?

>
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/hmm.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 35a429621e1e..fa0671d67269 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -559,6 +559,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
>                 return (int)ret;
>
>         if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
> +               hmm_range_unregister(range);
>                 /*
>                  * The mmap_sem was taken by driver we release it here and
>                  * returns -EAGAIN which correspond to mmap_sem have been
> @@ -570,13 +571,13 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
>
>         ret = hmm_range_fault(range, block);
>         if (ret <= 0) {
> +               hmm_range_unregister(range);

what is the reason to moved it up ?

>                 if (ret == -EBUSY || !ret) {
>                         /* Same as above, drop mmap_sem to match old API. */
>                         up_read(&range->vma->vm_mm->mmap_sem);
>                         ret = -EBUSY;
>                 } else if (ret == -EAGAIN)
>                         ret = -EBUSY;
> -               hmm_range_unregister(range);
>                 return ret;
>         }
>         return 0;
> --
> 2.20.1
>

