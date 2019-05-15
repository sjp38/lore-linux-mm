Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80436C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 16:01:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DDD62084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 16:01:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda-com.20150623.gappssmtp.com header.i=@toxicpanda-com.20150623.gappssmtp.com header.b="nMdKe4p3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DDD62084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C950A6B0003; Wed, 15 May 2019 12:01:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C46526B0006; Wed, 15 May 2019 12:01:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B34CA6B0007; Wed, 15 May 2019 12:01:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9550B6B0003
	for <linux-mm@kvack.org>; Wed, 15 May 2019 12:01:50 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id h4so279317qtq.3
        for <linux-mm@kvack.org>; Wed, 15 May 2019 09:01:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2C5ZLXS5pnK1SekssJfYLby68kNl/Hg91yqFVlQmDMw=;
        b=MhjHYJ0lSbXLHrcoxRg0lkx517yK1M/Udvird4aRUG/zKO7wujzaXthD7bjqpZQ2qa
         TIa+s6GudR5rPsCvNOw9cEz4wz5vRui2vLXFU9jYF1fDDatWersCdr8F6SL04EOOQMkU
         z2/jcXgyeaMIEfv2lpumWvYx316L1uhOkfNQVZkQGdE7qcNA3jAXwcmQubAUOHj6/KAz
         WPvcEQxkOUwiWZ/Zwxk2nWKcdoVUOgYMCDwHHgoOi5FcqMnbVbYeI7t9WV+cUbCefwwh
         7RXs+vIi432Ss7ManMBWQIRLwxq9p7AHxfJEQb4NDfB/sRhLDJfIDLCogP7q7MLm3tWw
         IaXg==
X-Gm-Message-State: APjAAAUvfPWo3NMKSVefI7rrZff0t1W54mxw074svK6pv3XusrSBzipn
	4bpz2a3lDbVW+6Mtuq/hUteFCYGob5m7/rewgn6AhPRHWKaXKf4cgV2Zu6QDwkhXIuJLIUhHMtg
	f9UcH5e3P6E2HL3i98oH9k1IRyK9tpiTdN6mLRR5BeC/7If4djLYCMBmxNHltYAwtZg==
X-Received: by 2002:a0c:b758:: with SMTP id q24mr33376938qve.69.1557936110339;
        Wed, 15 May 2019 09:01:50 -0700 (PDT)
X-Received: by 2002:a0c:b758:: with SMTP id q24mr33376866qve.69.1557936109661;
        Wed, 15 May 2019 09:01:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557936109; cv=none;
        d=google.com; s=arc-20160816;
        b=YQHfM4xTEPvTmYM/QmFV4puG5vsPKDzAkw7BFT2lz42A4Tlr1/S8IEuYz+Pzs3lw+X
         F7Z0AwdwJ1tFWJ0icmlZQLaPItkgrU8Q4giTbR94rVXHsOcKLm2cO/lPjFjCIubSj5CZ
         ZKMx+ebvWTJiDAikZ9FVMXR2D/BdBTFJTjwJN3G6qpm9zLZqjdhWXKV1i6JbuQoYK/ZK
         qBWVZLEpIfpfPmYGwKVQs4sbRWA/AeERmiaEP6Zx1qqtNoR0UulRQh7OdknEiFIeaEdZ
         YM+xzhZp8q6djt4VEeO58EICDzDC0mf/CyGUwDjj38sgx1hA1XrG764FlwAR2ugWQCzI
         jSMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2C5ZLXS5pnK1SekssJfYLby68kNl/Hg91yqFVlQmDMw=;
        b=UI4YWRC4bzka8cUA0C+47W9nvscHU2Cs8NNpJBkmAoR2xNwswhhcl/NRnzUBiOldpK
         gzCEBVQWb9S1rk5Rzq7TJidP8/TtjbEbQeiD7whEtLzjoxdrX57MCpn26dMBOLP94VyR
         H+IChjxCsFc0Fa34Pr4SJlCcjg71jitgx6tic1wzy9ZA0WI2HepK0P9HYUhC+aLcP5RK
         TlWriZJjjVuSll6Ztf+TReVutp3cmRE0iYZbos7FHTnO1TYu+VKiO7KcCk5PaR8ip22O
         2uGkUB/SRjmWTOcwolrpnZGYYt35W7W3VNP/Ic7Cf40hzUprOgBvVWYbf5H/Uk8wvNEn
         6Kdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=nMdKe4p3;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q5sor2049234qve.45.2019.05.15.09.01.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 09:01:49 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=nMdKe4p3;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda-com.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2C5ZLXS5pnK1SekssJfYLby68kNl/Hg91yqFVlQmDMw=;
        b=nMdKe4p3aF+xVyxfSk0pT8Zlqzg6/bn0U+5PqM0uOEZbamU2dToVvVrtN1ODTZKa0X
         EFkVsBDayJ2NH3cs7kMkrA1sYkJSKH7rRTHYhXvjPOx9CTVgQgCWE7Lj2XmmrwVM9hf+
         T5psHQVnACl/TqF+KUv18k3P/VR2QhgByTB1xwMGgmqa/mnfQD1M4JGZcuwvfOFFtxRz
         CItw9xiMnUyGWj6YFfe0jVyKELSEInBr+SoekmkF7yEPzwjMmBZHiTU7469kTxaRUd5x
         TN6749/HLAk/HJl7jGdpNlnbOhNeM5C7tzfPOwSxCOjB65QuEoEa8VHvIRnQfO/GWGLR
         o5TA==
X-Google-Smtp-Source: APXvYqwV4+KcNeGJbIdrCbzY3gisqJkBjc81DjssqjrPCuGEYTm4AuvHyXhtYW5MdQ4zAHHbU5Ue8w==
X-Received: by 2002:a0c:9ac8:: with SMTP id k8mr34276654qvf.132.1557936109209;
        Wed, 15 May 2019 09:01:49 -0700 (PDT)
Received: from localhost ([2620:10d:c091:480::bca1])
        by smtp.gmail.com with ESMTPSA id z63sm1204403qkb.7.2019.05.15.09.01.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 09:01:48 -0700 (PDT)
Date: Wed, 15 May 2019 12:01:47 -0400
From: Josef Bacik <josef@toxicpanda.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: josef@toxicpanda.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: filemap: correct the comment about VM_FAULT_RETRY
Message-ID: <20190515160146.te5tpydtclguxs6a@macbook-pro-91.dhcp.thefacebook.com>
References: <1556234531-108228-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1556234531-108228-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 26, 2019 at 07:22:11AM +0800, Yang Shi wrote:
> The commit 6b4c9f446981 ("filemap: drop the mmap_sem for all blocking
> operations") changed when mmap_sem is dropped during filemap page fault
> and when returning VM_FAULT_RETRY.
> 
> Correct the comment to reflect the change.
> 
> Cc: Josef Bacik <josef@toxicpanda.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---

Reviewed-by: Josef Bacik <josef@toxicpanda.com>

Thanks,

Josef

