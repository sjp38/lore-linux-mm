Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 627B9C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 20:36:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23AB2206C2
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 20:36:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="rG0dFUj7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23AB2206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B35736B0003; Mon, 12 Aug 2019 16:36:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABF5F6B0005; Mon, 12 Aug 2019 16:36:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9866F6B0006; Mon, 12 Aug 2019 16:36:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0057.hostedemail.com [216.40.44.57])
	by kanga.kvack.org (Postfix) with ESMTP id 7065D6B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:36:19 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 26AC852AE
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 20:36:19 +0000 (UTC)
X-FDA: 75814933278.26.tin96_19fe6e474a355
X-HE-Tag: tin96_19fe6e474a355
X-Filterd-Recvd-Size: 4345
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 20:36:18 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id c81so1272538pfc.11
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:36:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=JmUZr7y0Vz2xdCv3h+uqvQ8rGr3KsFz2eHJHYMvJh/8=;
        b=rG0dFUj7rqFxLYUcS0Cl/+bBlfn0vxQ4HWngVOp21pFxw6lq/KzhhDSznW3J87rEMa
         dFAQl10nuUQwmCt9l6ekbkPPd2bFCzydLmUORfOuDM0+UaVEdaod420qe0IgaHsUqCCv
         ahUb/2XWujO52+WJhX0vBthKQUIYrR48hR12iJzIKEU/d6qXHx/wQZeHYg6+emIT6InX
         VL5suQAGwauW8UJRK5pcroiM1jD0zbTAmtme2prRjcEqMLvwELSZw0Cx5R2FxRDVpTLc
         rAkprfGc1K3fX92MGMI8mhRm9ViL/qJHidlqfIIPGjw1SJrKaZfDWvS+tVLevc9Iybxz
         lpYQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=JmUZr7y0Vz2xdCv3h+uqvQ8rGr3KsFz2eHJHYMvJh/8=;
        b=KYEbDVe9nCee1a4jAH2p7T2ukv0qkIznhukv7Wb1MdILxp9eoa8U/ZQ8QrEUa4Hz8z
         JfP7bCDzOhgEeTeNKu/EavXk052tTGqU+ZmjXhHrwnaseLYs3dC5syaKl7+ruxmj4rvg
         L6VSfHuX44OC0nLZ0JZrfIoYolkJ/JxNQoISRgN9Qw+bRiEnQHbRf6tT80u80DdiQf+L
         F72mhticaHDvm+Ng4eokVb+uebERnQMWmbLf3xlI9JNK9aESAX9qIQxwUm4/CbuGXB1H
         i7mBaCY0FtTpy/Lny4WdTClnWMLjRvKxEaW2byhWaJMw5kHAZYBnQsyUqthmLHnULBO+
         BN0Q==
X-Gm-Message-State: APjAAAXMxcoh5lXR37vZ7Na5LbHeL2Q9jEne1AeHX8j8Eo6PYDdsA1lk
	9hjkJ5C/92iIKFYJCqzSW8gvqg==
X-Google-Smtp-Source: APXvYqyDaod1Q2sAKlRtRSeBrWfVVeu4bsRdV3UDrzaWFpPL3Qya8lka3ODeB7cFVNwLPTX48WepJA==
X-Received: by 2002:aa7:9882:: with SMTP id r2mr5141299pfl.146.1565642176946;
        Mon, 12 Aug 2019 13:36:16 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:f08])
        by smtp.gmail.com with ESMTPSA id m145sm9023428pfd.68.2019.08.12.13.36.15
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 12 Aug 2019 13:36:16 -0700 (PDT)
Date: Mon, 12 Aug 2019 16:36:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org,
	hdanton@sina.com
Subject: Re: [PATCH v10 6/7] mm,thp: add read-only THP support for
 (non-shmem) FS
Message-ID: <20190812203614.GB15498@cmpxchg.org>
References: <20190801184244.3169074-1-songliubraving@fb.com>
 <20190801184244.3169074-7-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801184244.3169074-7-songliubraving@fb.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 11:42:43AM -0700, Song Liu wrote:
> This patch is (hopefully) the first step to enable THP for non-shmem
> filesystems.
> 
> This patch enables an application to put part of its text sections to THP
> via madvise, for example:
> 
>     madvise((void *)0x600000, 0x200000, MADV_HUGEPAGE);
> 
> We tried to reuse the logic for THP on tmpfs.
> 
> Currently, write is not supported for non-shmem THP. khugepaged will only
> process vma with VM_DENYWRITE. sys_mmap() ignores VM_DENYWRITE requests
> (see ksys_mmap_pgoff). The only way to create vma with VM_DENYWRITE is
> execve(). This requirement limits non-shmem THP to text sections.
> 
> The next patch will handle writes, which would only happen when the all
> the vmas with VM_DENYWRITE are unmapped.
> 
> An EXPERIMENTAL config, READ_ONLY_THP_FOR_FS, is added to gate this
> feature.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Rik van Riel <riel@surriel.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

