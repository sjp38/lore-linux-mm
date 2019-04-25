Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCA3BC43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:14:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB154206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:14:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB154206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DF236B0003; Thu, 25 Apr 2019 15:14:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 264196B0005; Thu, 25 Apr 2019 15:14:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 154FE6B000A; Thu, 25 Apr 2019 15:14:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD9356B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 15:14:34 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g92so350063plb.9
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 12:14:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=XZhVAAQkKmYxObYzy/bsb0LrHZn9z/1JxRLykLpv10s=;
        b=Pb9BfAE7zK6nCNwkQI/wWji+mQ19UMJKSuJhfrRZrod7d/enMzCZpncN1rXgDCcBFt
         sNWEzxrggj9JhGVasTfdnnwiHvYQIddL8GRSa++gAS42Z+sJL7zQxj9Hmu2guU6qlNK4
         WugGxk/wvIBi1qUry+g1Sj4tl3qjFmyc9XoZT14FwvwsKYD0ac6a8tVzRAPMk67wDacK
         EKeByvIe6R06wfbuqIKPhFcNBO9HSOuLdAyg1m7Bgzw+tjV+5x5GuK4PrAix5GmX/WA4
         c4r2Wh7ldSjyh/AxTuWxxUa1OY/RCfD6ZKY+IRUBbubOQVX8QeLlu0twa2NquJT4eE6Y
         N+rg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAWEabrVSH7dbIBGx3L1MplhfUmcw5+5xTLsOMnmDSOV2BW7dN9h
	fVejSF0hErQZK4NqxrjUwlt9knZjTj5XRWbI0IkBmnTiWoTwCnC5VhD2l8qcYu3zU7sATyind9A
	a5Id08UbF40XqDAd7qFV4zoGannw2LHh8dkOJ8yjVfCECNIHOdTJCKuH89dsMJvixng==
X-Received: by 2002:a63:ef46:: with SMTP id c6mr22831943pgk.392.1556219674488;
        Thu, 25 Apr 2019 12:14:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0qP6lTObayRNSPOUW2AtgtjxFlI0ChAuy804uWTx2XizFVvIW8YCdBEFdaIQBzOvaYSjf
X-Received: by 2002:a63:ef46:: with SMTP id c6mr22831863pgk.392.1556219673403;
        Thu, 25 Apr 2019 12:14:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556219673; cv=none;
        d=google.com; s=arc-20160816;
        b=0AhAEY2jyPDC9s2h1yOyZ/Re824W1dQXx2yKsMMa51IfeYcWnmhahXR0vp2waSgIm0
         1U6Inu/bOCCZzdKFbiTtXRMhlRImRCzGm6LYNkMmX26GcxZgoOPU+ruqYP2U/rGlYefb
         PldZF1VrZDutPaZNn09x471enXAEwLV7jg1764S+oKBwQR3yBWri3sMIZhBCd56qBIr3
         BMIVsd+Sc1HpXzBE9MQoBSrgpwo+OC+vKZr6/+6uN/hXkcAaVKPfsmgF+ea1TMmVRiW6
         ZTMnAGlwWo0Xj0AEbZ3avkT9oqzknJ2xkqg3djR2YL4c9ArrDUdy3OSXdVJk1uECz73s
         nQ3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=XZhVAAQkKmYxObYzy/bsb0LrHZn9z/1JxRLykLpv10s=;
        b=RJs6PRpWoqzBCNiXzKX72zcj+CE/fn1rQyhfOpNmg1zkSTnrFgA0gSTAs8U3TA0j6o
         WtgfnaRC1Vb+7lmhRlkgVqMNEwkddOAZslnx/yrZwSs5KsVSv98C7I1fYM9H1BOaFLew
         l0UzUJFcR/ygLbtGRvAiaT0PK7b5nlWctIyM+OCm/71rmVEKtriKEkd5Mag1P6arWDL1
         1gBTLufJc+mMWWRk1w1eq3H1qjVcK3ssh5rLV/yErM69nCEmqJfjxVE0SIv8KRvWAL3Z
         gDND1SSNwOkQpYClyqnxAV2R17ESpONeCVgZnjIiZTEAIUzKwjMn+VVmly1KTPIFi5r3
         hu4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id a85si23305392pfj.12.2019.04.25.12.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 12:14:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Thu, 25 Apr 2019 12:14:31 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 57107411D6;
	Thu, 25 Apr 2019 12:14:32 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Michael S. Tsirkin"
	<mst@redhat.com>
CC: Arnd Bergmann <arnd@arndb.de>, Julien Freche <jfreche@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, Jason Wang <jasowang@redhat.com>,
	<linux-kernel@vger.kernel.org>, <virtualization@lists.linux-foundation.org>,
	<linux-mm@kvack.org>, Nadav Amit <namit@vmware.com>
Subject: [PATCH v4 0/4] vmw_balloon: Compaction and shrinker support
Date: Thu, 25 Apr 2019 04:54:41 -0700
Message-ID: <20190425115445.20815-1-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

VMware balloon enhancements: adding support for memory compaction,
memory shrinker (to prevent OOM) and splitting of refused pages to
prevent recurring inflations.

Patches 1-2: Support for compaction
Patch 3: Support for memory shrinker - disabled by default
Patch 4: Split refused pages to improve performance

v3->v4:
* "get around to" comment [Michael]
* Put list_add under page lock [Michael]

v2->v3:
* Fixing wrong argument type (int->size_t) [Michael]
* Fixing a comment (it) [Michael]
* Reinstating the BUG_ON() when page is locked [Michael] 

v1->v2:
* Return number of pages in list enqueue/dequeue interfaces [Michael]
* Removed first two patches which were already merged

Nadav Amit (4):
  mm/balloon_compaction: List interfaces
  vmw_balloon: Compaction support
  vmw_balloon: Add memory shrinker
  vmw_balloon: Split refused pages

 drivers/misc/Kconfig               |   1 +
 drivers/misc/vmw_balloon.c         | 489 ++++++++++++++++++++++++++---
 include/linux/balloon_compaction.h |   4 +
 mm/balloon_compaction.c            | 144 ++++++---
 4 files changed, 553 insertions(+), 85 deletions(-)

-- 
2.19.1

