Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00F8BC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:21:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9D282173C
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:21:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="e4+/tJPy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9D282173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E9456B0005; Wed, 17 Apr 2019 14:21:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26EBA6B0006; Wed, 17 Apr 2019 14:21:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 111426B0007; Wed, 17 Apr 2019 14:21:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C53946B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:21:21 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x2so15096519pge.16
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:21:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=vOuimekE8NbfgdHPy5nv6BcziXj9tFjoRdCDEhswAWM=;
        b=CC3wxfbxeFCDNnRTzJd9X+6McUUeAKXUMge8MrZoqjYI6SXq9Xf/YgmLrTnOYFJLKp
         i3hvKgWAzXrt31wpZwByzJJtY7Lwts5gzY/Q4pX6PR4y5IdCr9RSj/2y0gNqedvCV3JD
         WNCCm+nRNJjk31uMdWC2f86RlsLu6S/LZh0badrMFxcIKfqN989qZGbhac0iaNmgURsl
         oeBVnYKQ5/+MVYfBX7uHQICMEueFgnEINGS4J0sqfuVsGHj1JbU9xksSGBD2zJZECOJA
         bDYi/Y5AJ9ORFMnoTHwqnBH6COH8RhTgnkD+6m1VgrZecdWvhIlnwQXJhglPBLiSPFjZ
         Pqfw==
X-Gm-Message-State: APjAAAXDOtSp5pkkTJ1k6TBNlWwuvEvhlPLW3wcG8rSrtFlcuKp1xE0G
	nREKN2cu1u28/NS1LAqdDlnZ9G/KDbIZRoW8k9Cu6uQPH2Ibg+3aphRrVLV8ejd+NeSpmh4o8SM
	HbGvLwSqjBNxhCElobeH+JUVaZ4O/2qoJJGXvZyHyNs6oC9tvLFUBH8yBNNP05Xo=
X-Received: by 2002:a17:902:9b83:: with SMTP id y3mr87812882plp.165.1555525281115;
        Wed, 17 Apr 2019 11:21:21 -0700 (PDT)
X-Received: by 2002:a17:902:9b83:: with SMTP id y3mr87812805plp.165.1555525280248;
        Wed, 17 Apr 2019 11:21:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555525280; cv=none;
        d=google.com; s=arc-20160816;
        b=SIInZA0CyAnzJ3jntzdpoLy+6OeX1fkghWViu6aofUggAQ+B/La8UW74UBWfv2hheB
         5ZSHs8dvKajV0xZiewoGEAzWHlWcZn2I+fdJoChMUzreN92hBiH+BsaVpXQd39hJzL5J
         JWSlxvMqwy2FIgvF3h6QrmEeUMtwqIZu4jnfvSLTW3WOQ3EY3+9cb/0/av4agOrIGaGu
         ahe6movrm7uWOgn7Til81GYsvWgE6dcH4/qtXLR9scKexJEEiFr/03bVhpZIyM+fdprk
         gDY2Q1IpxMIjfJmFZcBJLNCGBeLRQ9bIR+qQ7CZr5npfdMhJ3EeciG9o/beOeLH3V7FB
         +0Mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=vOuimekE8NbfgdHPy5nv6BcziXj9tFjoRdCDEhswAWM=;
        b=o3sRvrzaKbctCMbEhOFu17EKIYqJGfegzrCjovOEmA9pLUZVX9xRtEV+JwmzskXdGq
         guu26lpcClhKnzDGqPWLsIsjK9+4qF8EsXEekIfc67E6MNi3i78ilZaeGkojMWokftH4
         yzVppJpfigwi9sxZwKPmowETOFtJO2m1EusMa6P9FhtStSzuwLAVZelaGSh8zfI9kVhc
         jD9czlwbCw0PhdqMRAxolvtIQ61P/5ix0VkNX5oAgfeA5odFSMFQUhpoAwGpKm1CoGKP
         Mdsz/khqHM7cvp6hKDdTcU0V4ktfNMWtYntu79lZwfPAgr4S8rcUDn8KYVdzRF3NKnuP
         GBew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="e4+/tJPy";
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18sor52383769pgm.1.2019.04.17.11.21.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 11:21:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="e4+/tJPy";
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=vOuimekE8NbfgdHPy5nv6BcziXj9tFjoRdCDEhswAWM=;
        b=e4+/tJPy9lZwMFKr1lYS3q3eI9IoHyKSQhAgMxR+bPSmv8loX5z6dYO2v2AaBiWwQr
         5bA094hod0B34csbEBBjE+gvUycjTRfBKflPToNuCtG0YlEM3qcLynIEErSW66mo6Cxp
         DsrAuc1OiGEexuBiL4J8KkETdasvfZu/Eo4k/e0ZRexFY+rqeqzIPE2N1maA3jsmXA2U
         gXLKNobxJyPtVlRcRxvmT0qJVH1SshV04HIwMuJ2p6mGGux8W9PHSV2zVfA7t0TC9SOu
         Oo1FO5EMMrcYnb7qjkjw3BGHLk4ZRFL5urqhBUsnaPjF5uOlB9w2NII2U35LBv938aFB
         8CPw==
X-Google-Smtp-Source: APXvYqzx0ob/O2sv9bLyl1/8sl4QBaI1CzJIblQrJnVdq12BlB+M+ece4h5MiJ3ybKRGa8WdqTk8QQ==
X-Received: by 2002:a63:7153:: with SMTP id b19mr81205327pgn.289.1555525279839;
        Wed, 17 Apr 2019 11:21:19 -0700 (PDT)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id e21sm75010222pfd.177.2019.04.17.11.21.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 11:21:19 -0700 (PDT)
Date: Wed, 17 Apr 2019 11:21:18 -0700
From: Guenter Roeck <linux@roeck-us.net>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Leon Romanovsky <leonro@mellanox.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH] mm/hmm: kconfig split HMM address space mirroring from
 device memory
Message-ID: <20190417182118.GA1477@roeck-us.net>
References: <20190411180326.18958-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190411180326.18958-1-jglisse@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 02:03:26PM -0400, jglisse@redhat.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> To allow building device driver that only care about address space
> mirroring (like RDMA ODP) on platform that do not have all the pre-
> requisite for HMM device memory (like ZONE_DEVICE on ARM) split the
> HMM_MIRROR option dependency from the HMM_DEVICE dependency.
> 
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Cc: Leon Romanovsky <leonro@mellanox.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Tested-by: Leon Romanovsky <leonro@mellanox.com>

In case it hasn't been reported already:

mm/hmm.c: In function 'hmm_vma_handle_pmd':
mm/hmm.c:537:8: error: implicit declaration of function 'pmd_pfn'; did you mean 'pte_pfn'?

and similar errors when building alpha:allmodconfig (and maybe others).

Guenter

