Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C1B6C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:01:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41ADD2082C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:01:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41ADD2082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC6A46B0273; Tue,  2 Apr 2019 16:01:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C76986B0274; Tue,  2 Apr 2019 16:01:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8B756B0275; Tue,  2 Apr 2019 16:01:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDCF6B0273
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 16:01:57 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id c64so7595336pfb.6
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 13:01:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=D51T58mIQA7PGpMmrkD5jv4bew+qqilD3LL2ilwXehI=;
        b=LH8ORDcVQcQSjBURzLTiKU9N2z9BsGNbZ4M23llPc6MShtLlsoTvJgiSyYDJR1sx0O
         Okvc1orMAT+CB6uIXY6YGlXYlLnf+pa3a0krwRdiLwLewcwVXOf55U11gNva47fdEwhH
         j5Wbc9HIk3gyuKJGmSIDl7737f7qftTYeG0RnExhZ7fh9HJkSrbccELdzd0duA5oGD+r
         WgUcuC9ifPUbQRZIpK8XErsHLnEqEvO26aWf0p/czTeS0n/lkSMUzaB6gH0BRv1xQeeA
         gBJtKRjVkX9NO+9Gmw225/4EOaIFgHZMbrMK3rxyC2jvtZfer/EXi86NYd98cfcSpPyO
         zxzw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAU6gvpej33ozh1FZOkMTOGYdijE3ahgzD49hDNb/9cR89xEvsXE
	3tIxioi4/OPVSpqViDZIK5mJaRVrQOB0FSPU9L/mltSnDOYkWjn9IZjTINnfCWN2z0ZbKOP8jVY
	inGEhlt9cajhKOTNW/+pFTpUWxFtunlfO+PhtMTTvdPZj+gwwwXA6mTKi/jcRZwwn+g==
X-Received: by 2002:a63:4144:: with SMTP id o65mr68331659pga.241.1554235317072;
        Tue, 02 Apr 2019 13:01:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAaZRu538HezNR7Yz0gDXOZNNr9/mEnmW9SCGOjBmjZPwC5GwE8b3LQwOmNf4IFqjrZXRz
X-Received: by 2002:a63:4144:: with SMTP id o65mr68331599pga.241.1554235316375;
        Tue, 02 Apr 2019 13:01:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554235316; cv=none;
        d=google.com; s=arc-20160816;
        b=KacAEx6yefKBbQYP7b27fG0f+glDNVcK65F5wiNKXLStC9Ut1qvGAB2j6BKJYrg6hH
         cg4RvW1ngFUmKdB6wfdE2hJPoiU45aeOsQuMvRRYbfJXDBu6+zzTbg+u41TuRPV0l9Kl
         zWRnjfuhjYkLs9ciqL7M5b/BE6nuP+W6DgrTTvyPB0tgJTGkamH5vQGLqMixGDCvBMFT
         cfxvzZiHoN8sQWt4ESEL+iLLbiHPa7CUdqsT8svt6K52yes6WfxaRqX+DbXhuvruPn0I
         txlx06qhyOeLOTQxgG2A1MeGKH9AGteOLMRzs+xdaeuT/5kZ253+VWvUsLDAYp+UQOfo
         tsjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=D51T58mIQA7PGpMmrkD5jv4bew+qqilD3LL2ilwXehI=;
        b=BA/p3KcsR6l/Tr2NdJgAngCFOTXGtt4r3VYeKyAjpIuSf17xDiPUmDedKlyzyqzXrY
         28am9n2Ptueg3wMhcJCDJrV+Xi60xgizr1L7cir8kPNiJdxcUOWxldpJKEcSZ4GhJQNp
         ifwFwNSWUe7hTucovgKXazxQGdQVatp3n3RMuhd8yDoQgJot8sZxH2QVnBpiwQxxWeu6
         wA7xWyGCE6GfdqN1E0sZKDegTsBajcs1X4hOg67tK8U+yZ6XMf1S0gGcPH5CTr1XOgdb
         gqWgqzCSFRJ7Ga/UnTLoBEXpsjjVvD8ytPtj/BN44biUkMFI3mPlBPmaY2wzKbfb5haW
         5smw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p13si12519144pll.324.2019.04.02.13.01.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 13:01:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id DC995EA8;
	Tue,  2 Apr 2019 20:01:55 +0000 (UTC)
Date: Tue, 2 Apr 2019 13:01:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hugetlb: Get rid of NODEMASK_ALLOC
Message-Id: <20190402130153.338e59c6cfda1ed3ec882517@linux-foundation.org>
In-Reply-To: <20190402133415.21983-1-osalvador@suse.de>
References: <20190402133415.21983-1-osalvador@suse.de>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  2 Apr 2019 15:34:15 +0200 Oscar Salvador <osalvador@suse.de> wrote:

> NODEMASK_ALLOC is used to allocate a nodemask bitmap, ant it does it by
> first determining whether it should be allocated in the stack or dinamically
> depending on NODES_SHIFT.
> Right now, it goes the dynamic path whenever the nodemask_t is above 32
> bytes.
> 
> Although we could bump it to a reasonable value, the largest a nodemask_t
> can get is 128 bytes, so since __nr_hugepages_store_common is called from
> a rather shore stack we can just get rid of the NODEMASK_ALLOC call here.
> 
> This reduces some code churn and complexity.

It took a bit of sleuthing to figure out that this patch applies to
Mike's "hugetlbfs: fix potential over/underflow setting node specific
nr_hugepages".  Should they be folded together?  I'm thinking not.

(Also, should "hugetlbfs: fix potential over/underflow setting node
specific nr_hugepages" have been -stableified?  I also think not, but I
bet it happens anyway).

