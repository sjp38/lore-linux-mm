Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9EE0C74A35
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 17:52:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 942BE20844
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 17:52:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="Xpz1OWs0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 942BE20844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35BB68E0081; Wed, 10 Jul 2019 13:52:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30CD08E0032; Wed, 10 Jul 2019 13:52:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 223788E0081; Wed, 10 Jul 2019 13:52:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E03628E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 13:52:49 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n1so1676430plk.11
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 10:52:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7bt3uTjdvwOxCSrbgXPGxceLQgj9AhCnSmWTiQF3lg0=;
        b=L7UHhQxT8pk5j2VleFYUgWRmUlmaqU0BP8mwvejs2Ao586Z9mH71dyo1TEfOaLYcCE
         hOfpFoDZWYijVPwRDYbC/IGp3aKLmIYZARFqFocJEOLfOGdrraCZi9/1exGqko8v9wor
         +u/A8ZjZA+4Rg++fB9/fcyapEVdt9BpPCqxl+ptepR4afVPPIAW6zpgHfFDlbZ5OwBhU
         jZUJA06QFFTniZjWbiPeWLNCRDcH8wA6csqvZeQcO4GE4AIxomxyGncGO3Od/HeBhE7J
         /hM/QoFfVqj3/7dXDauNHDQxiGnHNDM3RiZOErUYHezhy+M9vZV5MHURYzlzsjiIkF+V
         YORA==
X-Gm-Message-State: APjAAAXX9zIyXERP1Wt5dGXbpFyC6Y+xW0eUs5GI8PL+Y6xD9jKPkCdJ
	5c30eYvoY7Ar/Rc5GPCtCmhdn114/bo8UqkG40OgFgDTOfcIKgPXzKUmsVOiplgiJK0yESFAMvg
	I+QhBbkMHWi0Tsx4LCSbaXyzkyXxfwUb2Ux3XmqLNZqI+6NkL4mmtQfD4qEXamb9clA==
X-Received: by 2002:a63:221c:: with SMTP id i28mr38909243pgi.114.1562781169391;
        Wed, 10 Jul 2019 10:52:49 -0700 (PDT)
X-Received: by 2002:a63:221c:: with SMTP id i28mr38909193pgi.114.1562781168645;
        Wed, 10 Jul 2019 10:52:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562781168; cv=none;
        d=google.com; s=arc-20160816;
        b=BQpKCC4TqgiYs/AOPYHCqJ/ZNpNEF57CuYprSEGW6uVuKkba8BgEnaQ5nANR3iJiQ2
         9iF6DWeGFOQm1gBpj29WIIifi6A9UgbVPFDXhaUL8Tsl16QLcNQ6LSE4eWjfNHF+UGd/
         GAXRxLtw/bXy+CwXraxdS/gZw4mv/LvNCzVTKQfQpYUJMSf/DyNIhmxysi0uAYHiMp+P
         bbK9pTN62ukvjq1s0h05AEFbEU7uGY0viMi6FT9SkIoWVXnCPg4d45wY5jDc88BCw1R2
         eldYSJupo++3Ik57vnGvw9RFiGX3/eHkxNjvph5LidJuWoiPqsu9cb4sBz2YHhr+ceWp
         9ZeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7bt3uTjdvwOxCSrbgXPGxceLQgj9AhCnSmWTiQF3lg0=;
        b=ZJ0eASz30JgV6EEDE9Zm/qBCe+e8MtVl+V0YxA+iCoxXvSPZnkUMi6Sp0MUyq5PVPO
         +9gxJoMTN4KSa3W4g8qJY39RL2ShRN37AD0WC3qw3HhLEYvv9BU8x6aAyS9FbC1bfm51
         jPPCJz0kDrwy0bStl90JbsYg3kyJASqKG1NHqWVZoltkaP6wV0d6lduWvNTj5JmiuiKh
         9hzMXDp6us4ahqTNpcMdTpZLAU0Qv1K/sIElx+QvuQcYugQkHAIvIQAXgLtSOxgLPe8a
         +Hfg/lwo2DiovYPn0dF2RJu3onIL20GfgXwzlMWSNbtMFGgL/SGwMUI6sm/LsyCSFCNK
         e3Uw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=Xpz1OWs0;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32sor3549841pla.39.2019.07.10.10.52.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 10:52:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=Xpz1OWs0;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7bt3uTjdvwOxCSrbgXPGxceLQgj9AhCnSmWTiQF3lg0=;
        b=Xpz1OWs0EPOn58mLkWBhZPj0ilFyo38+TfIG0u4B64TO0IAg54S4ECVhLPLqe5gbPe
         1s93oq/MKLVtxFowoz2+aHvKEm2fHJ8Tigl0xgfhA3FDHMqFZg/s9JnhG+wQLAR2Vx+6
         fcohSx5C7M09X1g6P6Twd8Cy4kZkCcCKt2IU/24708FAyvj3PfD0Ub/5a4A/wbuKyToK
         QBnxwi9ZmcZfjz+WHd7qCq72ElHe8xjDGZ1c4HbYZm19EGIi3B7SaEoanabZ2iECkcAq
         TXKx8JaVZzClM9BTtaLtgNRUzbC15I+jMzBYKKFjQdwLBYieC0O552wi/1Aste4d+RiJ
         tJUw==
X-Google-Smtp-Source: APXvYqyO2e4PUxtRgJBhe0wMewV1eQoMpbGPj6EP6YgjdiLHi9SLRVufDFsyJ/LenfbVToiBoJT2yQ==
X-Received: by 2002:a17:902:24c:: with SMTP id 70mr40140076plc.2.1562781168363;
        Wed, 10 Jul 2019 10:52:48 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:5b9d])
        by smtp.gmail.com with ESMTPSA id b3sm6722337pfp.65.2019.07.10.10.52.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 10:52:47 -0700 (PDT)
Date: Wed, 10 Jul 2019 13:52:45 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org,
	hdanton@sina.com
Subject: Re: [PATCH v9 2/6] filemap: update offset check in filemap_fault()
Message-ID: <20190710175245.GC11197@cmpxchg.org>
References: <20190625001246.685563-1-songliubraving@fb.com>
 <20190625001246.685563-3-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625001246.685563-3-songliubraving@fb.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 05:12:42PM -0700, Song Liu wrote:
> With THP, current check of offset:
> 
>     VM_BUG_ON_PAGE(page->index != offset, page);
> 
> is no longer accurate. Update it to:
> 
>     VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);
> 
> Acked-by: Rik van Riel <riel@surriel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

