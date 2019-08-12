Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95CF6C32750
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 20:33:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C8C1206C2
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 20:33:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="Ns5tnFaX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C8C1206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE59E6B0003; Mon, 12 Aug 2019 16:33:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C96D06B0005; Mon, 12 Aug 2019 16:33:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B85156B0006; Mon, 12 Aug 2019 16:33:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0078.hostedemail.com [216.40.44.78])
	by kanga.kvack.org (Postfix) with ESMTP id 977B66B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:33:09 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 36EEF2C0D
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 20:33:09 +0000 (UTC)
X-FDA: 75814925298.18.worm70_8fde2b3c3e73b
X-HE-Tag: worm70_8fde2b3c3e73b
X-Filterd-Recvd-Size: 3674
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 20:33:08 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id z14so12831665pga.5
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:33:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=opuTeOP019YiHjS7zgVGx1N/ZtI2m573pQ8Fm6DPedA=;
        b=Ns5tnFaXWDviA+GNTixFkO7AFl1W+l/Ald/kQO5BWa44a6ukvr1eWIfWjaWVDYUYDj
         hiAQT2HpufQzPthDGeB765CF3V6cCc9ECB9Nb9FumVOdvKyCv603isBx/5MPS6iHlrNj
         YgxsfNStteKFyfoyRgVQ7FztMMbz+A+7H9xCy4FP4N6hIP3FexB/hSxdWfnYZ5e8qxoO
         n8ijIrIRl4bVRGBQMRhePCuyMmbw7FhP1X3hyIp9VFPC+iRXtGEIKjnn3rnFwdAycubP
         1wpdkQhN3+kVMZT8ywoPlKyHLiAEMXVoKcD7/Lr1NHmQ8oLt8qXpYTHauzLeviIHKc2M
         tWfg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=opuTeOP019YiHjS7zgVGx1N/ZtI2m573pQ8Fm6DPedA=;
        b=JZUYI7o9Q8hRvTFe6xAaFycvFFdFz3xpQBJmTdYJbqsXnBw5j9Ym82CLKkKNWO0Koj
         Alc2b9O98r+aJat6p32McS+rnOWXujc4hLfBYkeZvTfXiiQkEZWBuGy1OHl3cS6htTUc
         IK0biIaZDCdaNLnTFTXy0k/7uSRWYihSjPTm5A1O0YOx4kGUKQvBz2KPbiYgE0F6IS7d
         sOVKuC21lmIGoH32Z5EY0vcuDWfvStd7neB30Hrmjr9BaY8jideBHJ3BvPtIOJ+mt/tf
         05HGBT13Iujhz1OqaLyxbVoozNDFNW0nlJwjIfKDhILj14RsAOEtFuYWhSZjYacvP7nu
         zVng==
X-Gm-Message-State: APjAAAVI4OEMFd2evwtQHuJECLKjm1QRQOpHHDowtwjhvywA9C/TSjtE
	hPLu/kO4fTUKibFjV0P5dHT4Lg==
X-Google-Smtp-Source: APXvYqzLso2VXLAcxk2gXZWzzA185FIPfyG4h7hY0rd/zhvtbW+18JphumXy+BZjj65b5PHnBueorA==
X-Received: by 2002:a17:90a:d793:: with SMTP id z19mr1014808pju.36.1565641986978;
        Mon, 12 Aug 2019 13:33:06 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:f08])
        by smtp.gmail.com with ESMTPSA id b6sm93774090pgq.26.2019.08.12.13.33.05
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 12 Aug 2019 13:33:06 -0700 (PDT)
Date: Mon, 12 Aug 2019 16:33:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org,
	hdanton@sina.com
Subject: Re: [PATCH v10 2/7] filemap: check compound_head(page)->mapping in
 pagecache_get_page()
Message-ID: <20190812203304.GA15498@cmpxchg.org>
References: <20190801184244.3169074-1-songliubraving@fb.com>
 <20190801184244.3169074-3-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801184244.3169074-3-songliubraving@fb.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 11:42:39AM -0700, Song Liu wrote:
> Similar to previous patch, pagecache_get_page() avoids race condition
> with truncate by checking page->mapping == mapping. This does not work
> for compound pages. This patch let it check compound_head(page)->mapping
> instead.
> 
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Song Liu <songliubraving@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

