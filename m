Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF16EC28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 17:12:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1E55263F8
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 17:12:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1E55263F8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3775E6B0010; Fri, 31 May 2019 13:12:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 300E46B026F; Fri, 31 May 2019 13:12:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F0A56B0272; Fri, 31 May 2019 13:12:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD0036B0010
	for <linux-mm@kvack.org>; Fri, 31 May 2019 13:12:34 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u1so3357351pgh.3
        for <linux-mm@kvack.org>; Fri, 31 May 2019 10:12:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uYlINBd8hCRLPzdWAhPPuH/x8qnXyTPGNs56Pjt7IJE=;
        b=Kyw6v3cSaCfVF6wO/jx1zvVlXxIm5QxDV8ekNA5jTULx3SFh94hbgqrteFKA1Wf54j
         0WCBJSEmM0GN53BxRJ9K6Wfjvj2Adjg+C79bs7P465JGh2ReXNrULR08ToRqPYalzZVv
         XeRxVzFGnnSoar5W5yVUHiAgDz3lJpa7BbVsJi6QSNr3DnRXEvunoL9ISxnP6n2Ti0ff
         FDB9icozyxZyd8VStbeBYTAx4EjFDb4S1E6bDM0JgsgEWgViFqYDZWy/H6067mv8Njar
         x20Xo2D3ZZvOy2QZyhICw/5XnaJ/r+8Sl9rOIGKLIhjWNKfpnf/NkOpeNZSR/MhMnYt5
         JqiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXBy0atT4QO469jHzE+Vq40hiQcQTOaZttGeEAnZYKZQrURRE43
	eKEYwbB1VYXw0NVrTWnPpVHBQ8tLsc1LSDfRhiE8AMJYtpq09RONuFzveViCJHi9BFBhqdqoJeB
	pjFV2yVAyFHKuNxOr5m9kaWaJ20/R74q2CQknE8syDFw5KW4dp6DVF8yRUaUQ+JTwfQ==
X-Received: by 2002:a63:f703:: with SMTP id x3mr10309651pgh.394.1559322754582;
        Fri, 31 May 2019 10:12:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyiu+qJtwOpKvuVnrKvCyYF2bPYbMXVnw6JyVke19sH0r8LCnp5n44hjZ3PzDFzygeqz3Hg
X-Received: by 2002:a63:f703:: with SMTP id x3mr10309582pgh.394.1559322753818;
        Fri, 31 May 2019 10:12:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559322753; cv=none;
        d=google.com; s=arc-20160816;
        b=eEwzseFoGhchnVeO0NgWyv2Xz5veLNzlQArywu/6Mcmfip+SGcGiGvXZPFvKWtxRh2
         0qM+8DkbNzf/RNoFishlpxQtXf+3pkoH724uqQSXEWBVHyM6TyqJ3wv4bk63JHRFrx5H
         O4nArX0PX7oI3PmOEcu96Du74FlTQcHiQqfLa3FspIWODHZZZyR3foqaKzPcFeOECW5o
         E6XTTsGsznb8eWYymvjIC+k2SgHky+nbstOOILtE+QbiIpnL4Kw+3sVAgClgKSvpxieF
         2VyhGR2+774XsM5n0iBRWNVQ/prjonKEvASDCmDqfCbncGaJGWh3jzCY8u94QVCbmd6p
         JmPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uYlINBd8hCRLPzdWAhPPuH/x8qnXyTPGNs56Pjt7IJE=;
        b=hUEzkEemF7bl2UMbjMlO7b9/NwWfxLSgF+8pfUSaWMK8agAYCF9gmLXDKgCk0pC18/
         NDMJatBvUVut7pxZk8/05mwxLBkGlZ5FbnA/JL/RXmIYTS9Xw/mZ+G+m6ZTQhK0YTe8Z
         sm9E2in4+9UEtzn8oSsmgPMU7EwCf77Arv8DGGp+QehmnX5aC4bkxw1+KX8Q1aayKTjS
         GBVZww7ODysJCcwQVHYHMZgzhatg2WqO2ePcK0780FuQmCTxlWgyOKxgDM8GUlbvzar+
         5Roip++BSMSVl3/dKGPm6Mn9sSw0xZLmjiSUi47Gnu4eRmpMgU5zm3uxigOwKRdPF68y
         b06Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id t4si7227197plb.11.2019.05.31.10.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 10:12:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 31 May 2019 10:12:32 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 31 May 2019 10:12:33 -0700
Date: Fri, 31 May 2019 10:13:37 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: John Hubbard <jhubbard@nvidia.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
Message-ID: <20190531171336.GA30649@iweiny-DESK2.sc.intel.com>
References: <1559170444-3304-1-git-send-email-kernelfans@gmail.com>
 <20190530214726.GA14000@iweiny-DESK2.sc.intel.com>
 <1497636a-8658-d3ff-f7cd-05230fdead19@nvidia.com>
 <CAFgQCTtVcmLUdua_nFwif_TbzeX5wp31GfTpL6CWmXXviYYLyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTtVcmLUdua_nFwif_TbzeX5wp31GfTpL6CWmXXviYYLyw@mail.gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 07:05:27PM +0800, Pingfan Liu wrote:
> On Fri, May 31, 2019 at 7:21 AM John Hubbard <jhubbard@nvidia.com> wrote:
> >
> >
> > Rather lightly tested...I've compile-tested with CONFIG_CMA and !CONFIG_CMA,
> > and boot tested with CONFIG_CMA, but could use a second set of eyes on whether
> > I've added any off-by-one errors, or worse. :)
> >
> Do you mind I send V2 based on your above patch? Anyway, it is a simple bug fix.

FWIW please split out the nr_pinned change to a separate patch.

Thanks,
Ira

