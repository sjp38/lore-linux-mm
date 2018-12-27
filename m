Return-Path: <SRS0=02aR=PE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79C91C43612
	for <linux-mm@archiver.kernel.org>; Thu, 27 Dec 2018 11:44:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2AF9214AE
	for <linux-mm@archiver.kernel.org>; Thu, 27 Dec 2018 11:44:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2AF9214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8540A8E0013; Thu, 27 Dec 2018 06:44:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DA008E0001; Thu, 27 Dec 2018 06:44:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67A718E0013; Thu, 27 Dec 2018 06:44:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11EA58E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 06:44:58 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id y74so11352164wmc.0
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 03:44:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc:from
         :openpgp:autocrypt:subject:message-id:date:user-agent:mime-version
         :content-language:content-transfer-encoding;
        bh=OOUUF9LTXZ1bqSIpvAADD2MTckpcTHuL21wm7uIrrFY=;
        b=TRKT8FiKEoqyBKs3m8bHtJF/Kijq9Lq8VyJKoFt21W0hnsbkEjCqEa3+XIjG0Jn7dv
         eIkqNqGd1FbZb0jqUc5Q0TufCcsNeUBgKqN4DuXI0ntDLDLTro7i9+1nXDsTmlgP3xDo
         Cc6CyNxXM0CxS9UUMVJGue3cCak47+2RePJo0T75MFPhr2qdYfSbYbGxPEsxBF0bOSRH
         UjLMJO0IzNkrCLL7xjfCIGEJXj1l28/gtaAtvXYFI0OyojhG1jf5TP2sAMOFHXWyBAgs
         MbINLAu7+GkR2WIPNrFeTm1zebtFnGFZoWywNh63ioyIioUNEtB0Wx37x6Ph87mwtvkf
         Jltw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of colin.king@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=colin.king@canonical.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
X-Gm-Message-State: AJcUukc+IqB5rOa+3hLeo0GTYQhImm2MbF1DB2gu9R4ryclF9dMYKfY3
	caC4MeiIJDKafSbjmbkyxdwmsFJGQxYrn90aI8TBxma/xgqJMOgB9QEgZUv9IuRmP4NPSIAHGKf
	7FAYr59nPDKBZ2LX53edHaKF1OUnCIh/3pyOHMqsDKsBP8iUoUwALwEtjy8+03c+/YA==
X-Received: by 2002:a5d:63c3:: with SMTP id c3mr9453428wrw.215.1545911097430;
        Thu, 27 Dec 2018 03:44:57 -0800 (PST)
X-Google-Smtp-Source: ALg8bN78zGjWuKPnAC7nRswPkQLoW5d57fXrOgGjhp8xpD0eI1CUHMBotDmIt0UGqN1csQFM0Si6
X-Received: by 2002:a5d:63c3:: with SMTP id c3mr9453386wrw.215.1545911096249;
        Thu, 27 Dec 2018 03:44:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545911096; cv=none;
        d=google.com; s=arc-20160816;
        b=YaDijqvJ45x4ddkYoOfxfkVbdReqUzS+sDkCq9l59pJGMcznsWKw8uAe1sMBLhb2tt
         Iuy90rPVnl+q9arPNjIwBVXVjPHN8pFz2d2WakpqcKsyy9P5YmDX5jyQcY8OqXMoY8Vb
         dKnn+iHgtD8q2nGE7MFxO4lAZ1eB1uoqUQwESaBfv8HvBPhvQwcU/lJYsLrQDyyyVRc4
         J7S/rvC/mGQkqvWRN113LZRnsbm+kN/AJNXmm76mZ6zZRMhdIfv6w5p0P71NeKIzwavZ
         XXn4krrcHCbA1hqIqtaTMFpdxnKZ8Fa4V66E2DC7kbPhgw0d2TrnKqlOJIVKwAx5N9pi
         iGeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:subject:autocrypt:openpgp:from:cc:to;
        bh=OOUUF9LTXZ1bqSIpvAADD2MTckpcTHuL21wm7uIrrFY=;
        b=IAUDumJZsSe9CzJwDFhZ3O3+DXNyGKo0bth79F7Ye1mPfF8ERKRueN4eLjcjr0PVXX
         fhSGSbz0Og2E9XvufUWBd6HvnQrWO4Kgtns99OcmInvf1bHxZ7nYu3xFJab10GgTv2qm
         gItFoGzEiz0OZICiFMRwzAZc8dcGQsXREFGxKmSKcYiLopI9357Cm1YgR7HlAC5B9L+f
         TcYeO97KqP1oePxDS8+NsjKvaRR997ey2Kx99iLk+y1zK7n1dKK+yh4SzrVxadw/Uw4v
         YjTi1FC975CmDPpFf7bstLIML4QfK0szTVZM1esJx0Pv5sk2MWAe8/qA20ZcdpYhN08M
         mXMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of colin.king@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=colin.king@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id h25si17199614wmb.160.2018.12.27.03.44.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Dec 2018 03:44:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of colin.king@canonical.com designates 91.189.89.112 as permitted sender) client-ip=91.189.89.112;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of colin.king@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=colin.king@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from 1.general.cking.uk.vpn ([10.172.193.212])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <colin.king@canonical.com>)
	id 1gcU5u-0004Ch-E5; Thu, 27 Dec 2018 11:44:54 +0000
To: Mike Kravetz <mike.kravetz@oracle.com>,
 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Stephen Rothwell <sfr@canb.auug.org.au>, stable@vger.kernel.org,
 linux-mm@kvack.org,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
From: Colin Ian King <colin.king@canonical.com>
Openpgp: preference=signencrypt
Autocrypt: addr=colin.king@canonical.com; prefer-encrypt=mutual; keydata=
 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
Subject: bug report: hugetlbfs: use i_mmap_rwsem for more pmd sharing,
 synchronization
Message-ID: <5c8be807-03cd-991d-c79b-3c10a4d6d67b@canonical.com>
Date: Thu, 27 Dec 2018 11:44:53 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181227114453.8BKMnVf5yZ2XN6NylRtABHxRebAUWOkKGjSjlamL7Cw@z>

Hi,

Static analysis with CoverityScan on linux-next detected a potential
null pointer dereference with the following commit:

From d8a1051ed4ba55679ef24e838a1942c9c40f0a14 Mon Sep 17 00:00:00 2001
From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Sat, 22 Dec 2018 10:55:57 +1100
Subject: [PATCH] hugetlbfs: use i_mmap_rwsem for more pmd sharing

The earlier check implies that "mapping" may be a null pointer:

var_compare_op: Comparing mapping to null implies that mapping might be
null.

1008        if (!(flags & MF_MUST_KILL) && !PageDirty(hpage) && mapping &&
1009            mapping_cap_writeback_dirty(mapping)) {

..however later "mapper" is dereferenced when it may be potentially null:

1034                /*
1035                 * For hugetlb pages, try_to_unmap could potentially
call
1036                 * huge_pmd_unshare.  Because of this, take semaphore in
1037                 * write mode here and set TTU_RMAP_LOCKED to
indicate we
1038                 * have taken the lock at this higer level.
1039                 */
    CID 1476097 (#1 of 1): Dereference after null check (FORWARD_NULL)

var_deref_model: Passing null pointer mapping to
i_mmap_lock_write, which dereferences it.

1040                i_mmap_lock_write(mapping);
1041                unmap_success = try_to_unmap(hpage,
ttu|TTU_RMAP_LOCKED);
1042                i_mmap_unlock_write(mapping);


Colin

