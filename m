Return-Path: <SRS0=ZOUz=TM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC6CFC04AB3
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 15:08:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8572320873
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 15:08:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8572320873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16F926B0005; Sun, 12 May 2019 11:08:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 146D26B0006; Sun, 12 May 2019 11:08:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 035C96B0007; Sun, 12 May 2019 11:08:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D6AE16B0005
	for <linux-mm@kvack.org>; Sun, 12 May 2019 11:08:37 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s46so11934231qtj.4
        for <linux-mm@kvack.org>; Sun, 12 May 2019 08:08:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=yWrg+Xsje4ueBQKHhQxHSzuOnHkhQGVzpQI6865q3ek=;
        b=XWRYZ8fjc06DeSDcWhRLAVax6A9hrXntiJaPp/QBAAgZoDJ+8tZVBHjpdC3M7th9ch
         ATwEOrHkxUUQTnxSgC29m8TxsyQtKMVAd5uN7bL1VBpXqPPQ2cQwes43w8neWi5g4dKU
         32YR2ZK3YoMnl3tGUNH0Fh014Qsxr5LbOQWeo3nLNV+Jm0xvl4LQiOLf+g4iKee6kRB4
         5cby76/SA/kd5gFMEg828O1ys5wcdPFcuqHnVymH0fzDV9SPQaFfTQRvgRfL+n7Z1eTw
         2sCk93cbJEqLuQDuMK3iROa3w7Kzofe5gMZQiVLO6N4U22ssZpVzqKA+F/lVGRLoojyQ
         4Qmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUBWsVGDh8VpCbD2wAb0oe1wTwftpVrpgwc8yMqKSgq9TF1Ecqz
	t/ZfeLtRkhiu65xJVKLVqoTqKFMiydl0AG/totmSWGRFINSJW5K8Ar3Dcct+Z1L1cbyXdfC7e+Q
	QiZg6vBg0ASDhVXcp8pJ1UVKKRFaHF8BiVYaHRwRKOko0ajZnKI5g6l45CT/liT8x6w==
X-Received: by 2002:a37:7a84:: with SMTP id v126mr18472523qkc.335.1557673717592;
        Sun, 12 May 2019 08:08:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWgKITNt6TKgLR2NjcOxDguRotyFqJT6GpdXA1VaIujLAbzl7zpPdP0AQpiZkxrHFBG44l
X-Received: by 2002:a37:7a84:: with SMTP id v126mr18472473qkc.335.1557673717003;
        Sun, 12 May 2019 08:08:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557673717; cv=none;
        d=google.com; s=arc-20160816;
        b=j667V9oCSwN+AhDBkNpaxW9m4jN28DtC/HWFzTno/aUfPJqti+MRc7T0ydzfW78f6y
         taXw1YUWc4ZolAhAkZg4rO74QRAnB/cRmtu7UkRbOVNAbCruAiaZi+ampOrber25CoAV
         tDQBSo52Yy9jjwnubNgKxx/EqV5C+7vKOIyZMaPVRdomRlaGtqBzQ3Xg4BTLpudyQU1R
         Bf5vLYo7nqMbwHJEgywq2gGUtKGvWunLRdRuVIJzzhzoP3QjNngQlrjdsbNw4nPqZJcI
         lKA/wCYQ5xk55PIs0nG6s9uVDJAukHGaP1s/p7YMQqSLqNmhlM54nWSeXq0LUpb9tT1w
         Xc4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=yWrg+Xsje4ueBQKHhQxHSzuOnHkhQGVzpQI6865q3ek=;
        b=APTRznebItef6dGjBD8v6eQk3ci7Pv7nrddUV4R3LSuZyuCn5fR6TS1gkY63zFglKP
         dtQftFE7tvOG9jooQtrIrwx7kJuG2XFt39DZmWBoRdOGn6zKAiBTrxK7dk7mxrgQkJYx
         tQsZZ93SDRGaQ4F+DX/guohzH5u6/ujoekWuBzHxVMgHzard+UaAyZiJGCj0bmfjczhT
         lY9s3+dAvssRAX7oWRhvtNI8G5WQxPAjEeeqT5k9l7lIMrBBFjw8+0RFpYlbi07uRFgr
         9QTdFHZj826lEINyWTKZ3BkomxWB5MFbxEV3WseIv8pVtUIk8uD6qcoVwN3eQdW/6Hsg
         F/dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b22si542502qvh.145.2019.05.12.08.08.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 May 2019 08:08:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 193658667B;
	Sun, 12 May 2019 15:08:36 +0000 (UTC)
Received: from redhat.com (ovpn-120-196.rdu2.redhat.com [10.10.120.196])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 82E1E1001E7D;
	Sun, 12 May 2019 15:08:34 +0000 (UTC)
Date: Sun, 12 May 2019 11:08:32 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: rcampbell@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] mm/hmm: HMM documentation updates and code fixes
Message-ID: <20190512150832.GB4238@redhat.com>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190506232942.12623-1-rcampbell@nvidia.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Sun, 12 May 2019 15:08:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 04:29:37PM -0700, rcampbell@nvidia.com wrote:
> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> I hit a use after free bug in hmm_free() with KASAN and then couldn't
> stop myself from cleaning up a bunch of documentation and coding style
> changes. So the first two patches are clean ups, the last three are
> the fixes.
> 
> Ralph Campbell (5):
>   mm/hmm: Update HMM documentation
>   mm/hmm: Clean up some coding style and comments
>   mm/hmm: Use mm_get_hmm() in hmm_range_register()
>   mm/hmm: hmm_vma_fault() doesn't always call hmm_range_unregister()
>   mm/hmm: Fix mm stale reference use in hmm_free()

This patchset does not seems to be on top of
https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-5.2-v3

So here we are out of sync, on documentation and code. If you
have any fix for https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-5.2-v3
then please submit something on top of that.

Cheers,
Jérôme

> 
>  Documentation/vm/hmm.rst | 139 ++++++++++++++++++-----------------
>  include/linux/hmm.h      |  84 ++++++++++------------
>  mm/hmm.c                 | 151 ++++++++++++++++-----------------------
>  3 files changed, 174 insertions(+), 200 deletions(-)
> 
> -- 
> 2.20.1
> 

