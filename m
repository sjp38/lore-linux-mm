Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D47FC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 20:38:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03E2C20684
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 20:38:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="02IXqmiP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03E2C20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABEC46B0006; Mon, 12 Aug 2019 16:38:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6FB06B0007; Mon, 12 Aug 2019 16:38:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95DA56B0008; Mon, 12 Aug 2019 16:38:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0151.hostedemail.com [216.40.44.151])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC036B0006
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:38:34 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 1469E3AB6
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 20:38:34 +0000 (UTC)
X-FDA: 75814938948.02.bed76_2d9fcfd08544f
X-HE-Tag: bed76_2d9fcfd08544f
X-Filterd-Recvd-Size: 4128
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com [209.85.214.195])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 20:38:33 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id g4so1843127plo.3
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:38:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=OvGyvW5Iklte0Ea4752AqZSzCvI47sv01KixS4E1a7s=;
        b=02IXqmiPZReQAgyCJd5XNSGkstTKxtHUCQnsagaaTI/Nh5YcPVKftq4hsoImftWUiy
         UNSJu/7l6MF1Uxfqn0NJMq7zLVQWoWjNBYVt6UcKgPMAj4J3vLYX67YbINJzY8O3BvxS
         t59P7WwHqAVA9qyEwtZTq4zBCZwRtvgHdH/2NeLIfUbRhknUrJmreVlGM4iBrRFbGyKa
         FB0S3uNTBf3hEp40WFwr6mnjtWn8CazvUeaTEtQaPHox5O79Zq5gAYLY2pnV99UNu5fX
         Idy85JpYma2zzK/JF1tyDIb57JjheW480EHyTesQUyYt/1+5SNmYiKuQxPLzDnLN41NU
         /AQQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=OvGyvW5Iklte0Ea4752AqZSzCvI47sv01KixS4E1a7s=;
        b=YjYUXWD3lorSTKuEJ/uGbWLibzLqBLhAdaqIN4vOwfjfyIqKOIIAWrrvCiXUv1ztvN
         adjEPga4/0Dslawg1+230EiFXajmgZhYtOQ5+Q/lpw0NMhss+v6AYA89bzKsNQrYs3Q/
         hGWj6JBsCtBDHDQj4ok5nWiOeLKTy6T4/QIFtvlxPGfOTOwam0RgY6zGPNzKYYhcWdcf
         lzdLu7rg/AwLbwcDR4Vj0DSEiD6odCU8zGk2Kcryt6eIyuoNXZ2D5+PtMgB7x33+FucM
         HbomCj9gVQidao0NUDI+NmSK6fMu87LMEfWlBXTLe9E7iJnxoEY5Nk534p573//J6/2H
         +9fw==
X-Gm-Message-State: APjAAAXl/klG9JZ9c23R2ZywcJ25EcWzWYHJqH2eWxFK2eilbjZ/zaxy
	+cioEIPboEY1RPtXzb4XkwHL6A==
X-Google-Smtp-Source: APXvYqx7UX+07QB6rf7tI+JsJp388bL6hSKEDw7jHgHpKKJOqgKh3l4/VtJ/B/CdbYmtlZD9R7SOJg==
X-Received: by 2002:a17:902:74c4:: with SMTP id f4mr33092313plt.13.1565642312071;
        Mon, 12 Aug 2019 13:38:32 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:f08])
        by smtp.gmail.com with ESMTPSA id cx22sm387516pjb.25.2019.08.12.13.38.30
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 12 Aug 2019 13:38:31 -0700 (PDT)
Date: Mon, 12 Aug 2019 16:38:29 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org,
	hdanton@sina.com
Subject: Re: [PATCH v10 7/7] mm,thp: avoid writes to file with THP in
 pagecache
Message-ID: <20190812203829.GC15498@cmpxchg.org>
References: <20190801184244.3169074-1-songliubraving@fb.com>
 <20190801184244.3169074-8-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801184244.3169074-8-songliubraving@fb.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 11:42:44AM -0700, Song Liu wrote:
> In previous patch, an application could put part of its text section in
> THP via madvise(). These THPs will be protected from writes when the
> application is still running (TXTBSY). However, after the application
> exits, the file is available for writes.
> 
> This patch avoids writes to file THP by dropping page cache for the file
> when the file is open for write. A new counter nr_thps is added to struct
> address_space. In do_dentry_open(), if the file is open for write and
> nr_thps is non-zero, we drop page cache for the whole file.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Reported-by: kbuild test robot <lkp@intel.com>
> Acked-by: Rik van Riel <riel@surriel.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

