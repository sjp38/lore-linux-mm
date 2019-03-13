Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDA49C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:10:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95ED5206DF
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:10:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95ED5206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 330218E0006; Wed, 13 Mar 2019 12:10:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DE428E0001; Wed, 13 Mar 2019 12:10:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F5478E0006; Wed, 13 Mar 2019 12:10:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB2E78E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:10:11 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f19so2599121pfd.17
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 09:10:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+j1wPCLCDnUM46ZuR3wFLEpN0hSCFMKGL88MTApWywc=;
        b=T4xaH7XxhWw5PgdVlRH1pi/S0PZm+Wzg+jOQxYWQFA5gnAnaCTRaQjzZmK0nKHOfc3
         jgecmNipE3QXkwukfDji/7YZuSyZhb9IUqw5KQUcGM/+Od5vwG4DmnJBc+IsHEFYbo/7
         BNx10UyBVkBCuSgmPkbZHfaoBfB0pYif+ARzv/N7wNkIGVlCg3Ox6G99E2JeaYAt3NoT
         XuUrz+mcPRAQEbzUQ+CJ4WjKHScGnL74xl4F5by8qJXo0t3TVRtefBojByo8olE34KL7
         eOfBxJMvAcAA264yhSi4fIOBC7yQlhdkaTR+oi6ez32mz7lzMNMQVVCZt+MmkkrKozRS
         /8LQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAURCnNQ1ZJjDnv4w4uOMsvm91qO2BkagnfHzZHldiOcokuig3dD
	Os5NLt+NbMpR7D9ph+/kHEqT7JKWXuK+elp4+py0zLDLBi3UIIAiWmvw7A2pAJPwz5BPLydNdIW
	PnZG1dkEM5Q+CnbEv77Jdq2uUjsE+1pglKPkpdKTv5AnxU1+RYg/4IAKUjqNOXTRrRg==
X-Received: by 2002:a62:ed06:: with SMTP id u6mr43831285pfh.132.1552493411538;
        Wed, 13 Mar 2019 09:10:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybT2GXVeyuhTZFFd18NhGkpJJktUesThxM34EVztxdArzITpmmj2w/CDNN7gBS/0auZWaq
X-Received: by 2002:a62:ed06:: with SMTP id u6mr43831090pfh.132.1552493408816;
        Wed, 13 Mar 2019 09:10:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552493408; cv=none;
        d=google.com; s=arc-20160816;
        b=hoD5id/N63Ik9TUJpL97TVdwi89MXLFECq2OGoCANPQ+SWijkR+YZpSh6/OXk0aDFm
         C1xo6O9SrBRJa+ahHV5xP3oFHPZSSLaYPhijpEgVRFTYlVzpob3whBRwPjlhoHsmNBR1
         dnqsTCAa7XRoZmrvS0dpSORCyhSl4ybSGsvcOMG+yeZxHHw8IwqvlZY5/8VJS6YdkHT4
         Xl8KjrODxvwKPhRUejvlqub7Gg13bMvbi8cfgVt5SVw+9hJB598+KZJs2yagOEQ8uGmb
         z55+iDgvAZBOlpzegWfrdphRA6eVeHFoIQRPqbS39GJ1lU0BDyywOfQPFqZxcFlHPuyx
         bUOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=+j1wPCLCDnUM46ZuR3wFLEpN0hSCFMKGL88MTApWywc=;
        b=YfA/aKOW8klBVOkxt8Y4aNQ2+qLqxkaHVTlsr3XaCDy5yd4iCUevl3S6SRPxtTdnrD
         dmSolvEb1Mv46yvPxGzOlrwSLgTl3PT7Q8F77liQ3xT0zlkTpbS8jBwhNjRhToKvnJRt
         sdUx1LcgCwtlxFB8s8FiJDLzpMSJZ1Iv/3QFhX8FazQhBTMHvda+SN5B1YJPfKwjnV99
         hjccetNOcqYE1vVqnr99mSI48RiSr3bqospLHliO5DKzM3jRGixcJfa7v2lwgTt4dptb
         UEPsvyaL8M3j3EiBLJNFBeL8KW2+Uxc3Ek5ay0+LdECuB/T0JMxMyh+N83UDQ3asqOqt
         Mk6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y12si7670738plp.86.2019.03.13.09.10.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 09:10:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 1C1D6CC8;
	Wed, 13 Mar 2019 16:10:08 +0000 (UTC)
Date: Wed, 13 Mar 2019 09:10:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Felix Kuehling
 <Felix.Kuehling@amd.com>, Christian =?ISO-8859-1?Q?K=F6nig?=
 <christian.koenig@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John
 Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@mellanox.com>, Dan
 Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Message-Id: <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
In-Reply-To: <20190313012706.GB3402@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
	<20190313012706.GB3402@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Mar 2019 21:27:06 -0400 Jerome Glisse <jglisse@redhat.com> wrote:

> Andrew you will not be pushing this patchset in 5.1 ?

I'd like to.  It sounds like we're converging on a plan.

It would be good to hear more from the driver developers who will be
consuming these new features - links to patchsets, review feedback,
etc.  Which individuals should we be asking?  Felix, Christian and
Jason, perhaps?

