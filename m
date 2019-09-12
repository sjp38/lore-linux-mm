Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACFA6C49ED9
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 09:40:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D19E208E4
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 09:40:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="VxIrmrgB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D19E208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0000E6B0003; Thu, 12 Sep 2019 05:40:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF2DC6B0005; Thu, 12 Sep 2019 05:40:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE0C56B0006; Thu, 12 Sep 2019 05:40:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0149.hostedemail.com [216.40.44.149])
	by kanga.kvack.org (Postfix) with ESMTP id BCA746B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 05:40:37 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 61535824376C
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 09:40:37 +0000 (UTC)
X-FDA: 75925773714.12.brake22_2277330fce70e
X-HE-Tag: brake22_2277330fce70e
X-Filterd-Recvd-Size: 4093
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 09:40:36 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id u6so23341769edq.6
        for <linux-mm@kvack.org>; Thu, 12 Sep 2019 02:40:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=y6RE2XQhRzZWupLEteqsLYHDuJ01Xgu0HTXHplF3Lm0=;
        b=VxIrmrgBlvUhodILVlykpcbHTyK0rkk/gKxD4Mo/n2XpRy5Bjdyb/Xeaod3knVMBGj
         C4fP5pHsIO/ZyVSuLjMubCrm63a5mEpQ5Fa98A7/Hl8BYWR4DTEjP0l6JdqU4SFNRYlT
         uylQmJNDf032FIgFfKyBx9w+ITKf7yL4DTfq389idXvIisvG19NNalIX/JHPOKbinmTL
         +16kfCy8/2XBltprgKXqcs92CdMEg8R5q4JLCUyFBP4jIGtSSm56QyBEMVMpx2Na+yMA
         GZLdExB3U1JCUSrteUIMaqnvo1XYH6w0rmTyD3IDn2Fn+YljNIncJqaWYrJIPqlGC+zH
         JR5A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=y6RE2XQhRzZWupLEteqsLYHDuJ01Xgu0HTXHplF3Lm0=;
        b=F/aZYFm0+AvawKx5c9PzOBgZw1FyzIGJQjLhW/wjkHMppqRefEIeYzVOqyy1/KpSA4
         TipZPLGna18ydgYcCPFvmaBygE3l9o7BHNeEL8+P8fN9ZRdJCRyrTY6jxrVSPMc47H4K
         dVcHRbe07zJW4X1tuv+fmtGwx+sF9K0bOSVBsO4PucVf61jxJOSy6tERWtaeG+kY2aoj
         3OiV97GuHiO8HxnG1hrYiwTuVhkNNcvuvlHgHMBgL+T2PGGFQPnT61NGer1gEC02PxYo
         GhX8YptAgLb/4INgxM/+viiyAPr5bxUp8zMAtQ/Bvs8sac7dEMz46B6lE+pORHTrVqkj
         aNKQ==
X-Gm-Message-State: APjAAAWhCNV+WmEpYRyzR8TC6CZJcjjcc8s+mNu9oaNgFPfuXiBYadLq
	f590CGkYmFGMqFSUXmmp4ymkHA==
X-Google-Smtp-Source: APXvYqwEIAM5TzJzwqPjVyP0/PDYdmqyk2EIzasslST9N6YDcosm0gquqF+rkSnHKuztcfUwgiD+Vg==
X-Received: by 2002:a50:ed0f:: with SMTP id j15mr33181121eds.127.1568281235525;
        Thu, 12 Sep 2019 02:40:35 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id rh20sm2765695ejb.39.2019.09.12.02.40.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Sep 2019 02:40:34 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id BBBE7100B4A; Thu, 12 Sep 2019 12:40:35 +0300 (+03)
Date: Thu, 12 Sep 2019 12:40:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yu Zhao <yuzhao@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 1/4] mm: correct mask size for slub page->objects
Message-ID: <20190912094035.vkqnj24bwh33yvia@box>
References: <20190912004401.jdemtajrspetk3fh@box>
 <20190912023111.219636-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190912023111.219636-1-yuzhao@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 08:31:08PM -0600, Yu Zhao wrote:
> Mask of slub objects per page shouldn't be larger than what
> page->objects can hold.
> 
> It requires more than 2^15 objects to hit the problem, and I don't
> think anybody would. It'd be nice to have the mask fixed, but not
> really worth cc'ing the stable.
> 
> Fixes: 50d5c41cd151 ("slub: Do not use frozen page flag but a bit in the page counters")
> Signed-off-by: Yu Zhao <yuzhao@google.com>

I don't think the patch fixes anything.

Yes, we have one spare bit between order and number of object that is not
used and always zero. So what?

I can imagine for some microarchitecures accessing higher 16 bits of int
is cheaper than shifting by 15.

-- 
 Kirill A. Shutemov

