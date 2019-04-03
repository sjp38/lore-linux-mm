Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8794C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A79A32084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A79A32084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D7CC6B0269; Wed,  3 Apr 2019 15:33:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45F2A6B026A; Wed,  3 Apr 2019 15:33:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EE2E6B026B; Wed,  3 Apr 2019 15:33:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE11F6B0269
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:33:33 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x18so165639qkf.8
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:33:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Oe+q9l2XDgvlTBk6Utu7p+X1Qwfox15Ft9tXIgf+A00=;
        b=ToSZB4J2bxe/jebxD69TGrkVOROEY+KjFlLtxo1TINkX1xAXwcrSCCoMNut1NUOajg
         IAiEIRIdB5Xw1PfZK4zzgzVRZYuTuJaBWuc3VA9yn9Or6upWRjh0ZQmSwKukDVVIbReq
         W9wrF2Y2DaLSYJ9vly5Q6gahRo9PWL5HUBFKWX6IfthQ4OUy/AvI40ef9G2vYE5cpvD4
         CpuKwRWEyi8EEWbVl62ZV/tddMiP3UOUbaoMwN0nWNyh4pV/vESo4pReq1WlF+RAhjzX
         UDKlk7o+4JobmVzM5iINzFisMc8ctT1JLkXbwPPm4QEoZtfPuvq2HBr4pbAwVRERdQlB
         2ecw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX3HQtn284CFBytI6gQC/SQ0MvTnG2PqppA3zWEyrtFVdm33gU2
	tPsLvtCF2OtxdMAdZMS+YQ8jRZdnnCVy7dQuzihqpvNj1C7bqcsBO9m/z5rW2VLv4KQaQJMau0O
	4SJEqgYCUM7U7O70Bs9tOpq7y5265sPa0wEaniOotblYZJdWCAodcMx3focsMfnBxJQ==
X-Received: by 2002:ac8:2d02:: with SMTP id n2mr1602983qta.229.1554320013770;
        Wed, 03 Apr 2019 12:33:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx42uhQcAKgyOl3g5UahCT2viuQoD9btOq0lyQVdCDw6aWQORANwiBaKw3+MsAxjHr9d25O
X-Received: by 2002:ac8:2d02:: with SMTP id n2mr1602947qta.229.1554320013122;
        Wed, 03 Apr 2019 12:33:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554320013; cv=none;
        d=google.com; s=arc-20160816;
        b=tseK0ZwVIeRXdwiDj+wr9ovZyhwlsHbHt32E0HxlaV6slxM8BEP58WZ7qy7I+jafih
         Up4IWfSKxyk3Mxi3tYhqnadM+xkVeaT7aIq8QGBHot61LJYO5qYgy6r2vzlG8ZTwrBVu
         G1dX/FbOEFpEYzi1XQOag1LRghVMi/QT96S3JPxi85+nU4Ig59q6Eu++oRmqCAoKzfi/
         DO35/2FL0lc7vTim63zltSqRbjJwSBj8Q/ckRpn6KgnzBHd59smsg9fB2UHMM7ZtrH2z
         YpL8Ook9kXMSt29li89K7BGbhB9NyLzh8NkFsDIavfCSuGJVm3RrWnvqqbr9KK9X690g
         VvfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Oe+q9l2XDgvlTBk6Utu7p+X1Qwfox15Ft9tXIgf+A00=;
        b=O9YD318i/3o2lMfAMDR9FzDYZbfNkkekkYGMS4LwM4t3gkoVWNXd2x6mZNte5XI1Xn
         AfQI1J2DJT8UdgCg/A9fKomBoPVMR8jMS3bxu3kCLh9S3XFqMVZHdhbiEYx7UuL7rD1r
         LOxewd7ti9T/sSJxUA1Lz8Mlm5Q6kVLmv5LQYk9Gi4WT2AmyrhQW6un+3mHQGzjtBagU
         9EkZmNDQq2QQs/V1AqbSgc/Mpr0NoiCuO4MJzISM3M2qeq2bgm+GjYQ6l+QDNeQZg4Ne
         Q47LyiaQJF7JqU+whsaYmFC4iVbHljJwOIvf2W5ASw+qeZmsGGP9yJjVifmi5HknYNbt
         fKCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f129si4504474qkb.56.2019.04.03.12.33.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 12:33:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 60F60F961D;
	Wed,  3 Apr 2019 19:33:32 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-125-190.rdu2.redhat.com [10.10.125.190])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 93647605CA;
	Wed,  3 Apr 2019 19:33:31 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v3 03/12] mm/hmm: do not erase snapshot when a range is invalidated
Date: Wed,  3 Apr 2019 15:33:09 -0400
Message-Id: <20190403193318.16478-4-jglisse@redhat.com>
In-Reply-To: <20190403193318.16478-1-jglisse@redhat.com>
References: <20190403193318.16478-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 03 Apr 2019 19:33:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Users of HMM might be using the snapshot information to do
preparatory step like dma mapping pages to a device before
checking for invalidation through hmm_vma_range_done() so
do not erase that information and assume users will do the
right thing.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/hmm.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 919d78fd21c5..84e0577a912a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -174,16 +174,10 @@ static int hmm_invalidate_range(struct hmm *hmm, bool device,
 
 	spin_lock(&hmm->lock);
 	list_for_each_entry(range, &hmm->ranges, list) {
-		unsigned long addr, idx, npages;
-
 		if (update->end < range->start || update->start >= range->end)
 			continue;
 
 		range->valid = false;
-		addr = max(update->start, range->start);
-		idx = (addr - range->start) >> PAGE_SHIFT;
-		npages = (min(range->end, update->end) - addr) >> PAGE_SHIFT;
-		memset(&range->pfns[idx], 0, sizeof(*range->pfns) * npages);
 	}
 	spin_unlock(&hmm->lock);
 
-- 
2.17.2

