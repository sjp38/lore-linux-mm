Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6E7AC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:35:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8069620815
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:35:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8069620815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1634F6B0005; Fri, 24 May 2019 11:35:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1145C6B0006; Fri, 24 May 2019 11:35:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 002D06B000A; Fri, 24 May 2019 11:35:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC52C6B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 11:35:33 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id t1so7201522pfa.10
        for <linux-mm@kvack.org>; Fri, 24 May 2019 08:35:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=4yxQqi6h6TVYUcswGQNLIQ8ZipBRxcwhUG1Z7u4odyg=;
        b=I//z2TRg7eiV6HJ7AH3Bc+8S3MoQTAf4Z1L1R/VCOXtDgCDmSMLWqrUy37RQqH1gP6
         fMqxIvkWsUIMtCYmfykpfSO8gS7dhoIBF9kAMCmH2JggKkW2BCyVfCS9kVVNMi3dXJOi
         dVbwSAzgURDu8YI/FRYvze+WdOmGZgS1BhSG/zgPY3RaEJBpFhmZ11OiZWQH3i42gax8
         mgkjz5srpNBRkRS1AVMRWMIzSnWvS3+fyRZs6IFUBABTShzduJl4t/R9wn/QfMQyyymy
         teJp+kF1T5vSgJjmp8LO+Un9jc/FBmXyx7B/VQ39APUvXdPql83wAHELaGkKhJPEkHiw
         efuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXKHZKTvOR6veb6KIoc2y/xBwg1t8LyqJYrbnA9RRtCLPxVP/0w
	XiihuOztozmJ9LnDC3wTW5BL2fVAtuh7vGxl00FBjWBqDmjNz0q9+HVPICo0wZY5T0328fO1IyT
	oXQvZikUsZ5p7OrdUmAAfPHhGp02c9H0L1OQ5Kh9xdiDqcMMadFQXo6XUZpi/1C9xGQ==
X-Received: by 2002:a17:902:2be7:: with SMTP id l94mr51994111plb.185.1558712133372;
        Fri, 24 May 2019 08:35:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqSDZChtbxN8Z/9umKd+OaZK65L0PlKpdDEeh/05tGdSQ9lReNVOnqCT5WmaXqY6vLf/Kj
X-Received: by 2002:a17:902:2be7:: with SMTP id l94mr51994010plb.185.1558712132713;
        Fri, 24 May 2019 08:35:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558712132; cv=none;
        d=google.com; s=arc-20160816;
        b=T9xEgJDX38pPJ+9e4SvbUIXfzcyaq/t1Xde+CaIc7i0szWfAA4gzNyJISfudyhIqlf
         m/iS61Ee7bOU2Yc0o13HJVzjqvcWj9xFN/+5zLcyHcscqonrX6MWbWswdMJc07laKguF
         yc0m3r1CbEhbb98gpYJvADkMEhzSE8YCeiuNgidoP2lvupQSLEzwapi23FPekphilrfN
         E/8rtMWWkAgBbERRL8XzAF1/7SmijcCT2riPPjOmukKwvx/hgQtgv2+C4ebmtRIWK2Nn
         ujBz9GvqBnOtR1M69a8q38FgyYMSDjwpJsAbPyqzUNwpYnV/ImTOg1yE04gRMBu5GQ1F
         tDrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=4yxQqi6h6TVYUcswGQNLIQ8ZipBRxcwhUG1Z7u4odyg=;
        b=kYY2DgS4ieCoe94SXXHEuj30YEHB3FyP+BIS80GHH8CE2Qar3/HEEpG+XqAkz24lxk
         IDRaefCDL0O3tSP30zJTc+HVwy2RuhFXPCR4PX8dmEIo2unfePXQIGy2KecmuDZ+vUvn
         8W/XjNNj9VC5vT2D82Foby9sKkWuRA+O4Scyjd7i8fW+qFi+gOHhwNLKwxYW9QIONR9m
         n3i1/AmjQ12/2S11B8KQ2otVh49pjUbR/lcJcP+Juw4UcTTGosREzFyLPbcDZRX0Eacw
         AsHjhkLBqzJ1wMywXFN8uZWlxnqS8hJjlymbkfF98mtfCNu2GpmBiiT8Xt0qy595XhAN
         uVCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q43si4642155pjc.3.2019.05.24.08.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 08:35:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 May 2019 08:35:31 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 24 May 2019 08:35:30 -0700
Date: Fri, 24 May 2019 08:36:25 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm/swap: Fix release_pages() when releasing devmap pages
Message-ID: <20190524153625.GA23100@iweiny-DESK2.sc.intel.com>
References: <20190523223746.4982-1-ira.weiny@intel.com>
 <CAPcyv4gYxyoX5U+Fg0LhwqDkMRb-NRvPShOh+nXp-r_HTwhbyA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4gYxyoX5U+Fg0LhwqDkMRb-NRvPShOh+nXp-r_HTwhbyA@mail.gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 08:58:12PM -0700, Dan Williams wrote:
> On Thu, May 23, 2019 at 3:37 PM <ira.weiny@intel.com> wrote:
> >
> > From: Ira Weiny <ira.weiny@intel.com>
> >
> > Device pages can be more than type MEMORY_DEVICE_PUBLIC.
> >
> > Handle all device pages within release_pages()
> >
> > This was found via code inspection while determining if release_pages()
> > and the new put_user_pages() could be interchangeable.
> >
> > Cc: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> > ---
> >  mm/swap.c | 7 +++----
> >  1 file changed, 3 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/swap.c b/mm/swap.c
> > index 3a75722e68a9..d1e8122568d0 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -739,15 +739,14 @@ void release_pages(struct page **pages, int nr)
> >                 if (is_huge_zero_page(page))
> >                         continue;
> >
> > -               /* Device public page can not be huge page */
> > -               if (is_device_public_page(page)) {
> > +               if (is_zone_device_page(page)) {
> >                         if (locked_pgdat) {
> >                                 spin_unlock_irqrestore(&locked_pgdat->lru_lock,
> >                                                        flags);
> >                                 locked_pgdat = NULL;
> >                         }
> > -                       put_devmap_managed_page(page);
> > -                       continue;
> > +                       if (put_devmap_managed_page(page))
> 
> This "shouldn't" fail, and if it does the code that follows might get

I agree it shouldn't based on the check.  However...

> confused by a ZONE_DEVICE page. If anything I would make this a
> WARN_ON_ONCE(!put_devmap_managed_page(page)), but always continue
> unconditionally.

I was trying to follow the pattern from put_page()  Where if fails it indicated
it was not a devmap page and so "regular" processing should continue.

Since I'm unsure I'll just ask what does this check do?

        if (!static_branch_unlikely(&devmap_managed_key))
                return false;

... In put_devmap_managed_page()?

> 
> Other than that you can add:
> 
>     Reviewed-by: Dan Williams <dan.j.williams@intel.com>

Thanks v2 to follow.

Ira

