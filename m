Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D12EC74A5B
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0325A21880
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NDRrGTHq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0325A21880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E029F6B0276; Tue,  6 Aug 2019 21:34:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE9B46B0277; Tue,  6 Aug 2019 21:34:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC7836B0278; Tue,  6 Aug 2019 21:34:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7596B6B0276
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:23 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d6so49356311pls.17
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6GC3vp7Kgk6wrS2t1aIFSliRmKpmpPmHRVTf1Sq+2hE=;
        b=EpIko//YehgpiZZeBjcDQJa4tUhHjGoo4vufUq0PpHL/An0zFybNFcjGP24M5oL/N5
         OJFykGrvD/rVOJ34N2OJ4xOre0rvIJEJX3gAyBVv3lM143cCvHEMH7EROBPbG1EqUqOY
         AmKhf1DAnfl+FkWz7K2rmwFyegLMiB1i10NmcGlVRWr4G/3UWozCTsKT5o0i5D7b4CHq
         CS0Uu7BQfFlEVvT/LrFbNK+kEgN+kT9exLs+fLoVth4ZCrZYjTlLDjhFovRa6I231VHY
         O9UuoOHA+k2AraWQphyzoMfzZHu9LwcQy2sk5UiA7C6JlTCLtuqwfY7kQ362eM/vdSLC
         vvXQ==
X-Gm-Message-State: APjAAAWGpiFg8ym0MBDQNut9fxwq8EFIX8HyATqPeyzPwyCbeH0r8u5X
	+I/S+ydMhwynoZ0v48TZtlM6GO5zqA8UQ0bCFBw0uoa8Z0QV6xqgYjfWUViyzk/D5744++dLF0e
	cf71EGN5gotESmgkQEFBvY2xF9nkIATPbUzpOrP+n8bM2SpH5bHC7X5GMzJvmy9I+Qg==
X-Received: by 2002:a62:e315:: with SMTP id g21mr6893700pfh.225.1565141663171;
        Tue, 06 Aug 2019 18:34:23 -0700 (PDT)
X-Received: by 2002:a62:e315:: with SMTP id g21mr6893638pfh.225.1565141662377;
        Tue, 06 Aug 2019 18:34:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141662; cv=none;
        d=google.com; s=arc-20160816;
        b=pWl3VtwgGEqU/TNh2ifBSK8rcdzat/KIUJgR66B0M40A0Ggu2F+76SxHefOmEkUsuO
         bgZ2W+YkvCZNjU12IsaOpePn86Q0uBl4nW78BOI+CRHuBsK4SB6LSlDQv0zkn3y39uHX
         591fGUCU5qcMdHp/acrYvInKs44wHlgJ+SvucPgsd9H79qi1QcWVf0Vf/MiOsZfSF+90
         EmUhUID1382s00QYkeMXBidBuCl3fQXlDPwplV/3u0IWgkJn3QNTxMkErEsFcxyMFKwE
         9wrfgCbCttw9PqDgk9WaEOiM5FSiio/U92rDvjqGWQQveUjQIBxhSOtRtpMBVOyJZskX
         M1Bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=6GC3vp7Kgk6wrS2t1aIFSliRmKpmpPmHRVTf1Sq+2hE=;
        b=GKkF6Y38QRFeGe3H6JjAUEDg/z8viRzZt8Md+pMYWX5j0xvZUDthhPGOqaEJPaDBYC
         4m9iq527Khm4BKwooUT30ChJYWHioxfPQTqYavgCbSXCuejKMuT3BB8YFIlKd5+tmZIV
         1ewOAnELLS8MNX4lrKcKNUBYwUUp7rhpv/NjOgZcb6hAFBozGy8YND5563zthSHpJsna
         7GYeo6gL3qhg4b7A3KV6p/MtOdv+Ira9UR2wdsiak90yCo5p3zDWiH1SJu2gvENZqWUL
         lKQIXQXIlAQVy47wmC/2AtlWBF/McBr+SYWsDdeMyyKgq0b+1prhIQDO1MWjbo77muLa
         aTRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NDRrGTHq;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r140sor53590718pgr.22.2019.08.06.18.34.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NDRrGTHq;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=6GC3vp7Kgk6wrS2t1aIFSliRmKpmpPmHRVTf1Sq+2hE=;
        b=NDRrGTHqLYH0GVc6uMIRr4mVyV40WfAqYn7w+X7B2+KxadDpBkUoDH1692sptrKq4y
         C2b84L9+UrVSHeZfQfv6N2zieXkMMjWSuutP0ntWCNqq+OA3nS79IQYMOR/Bean1Ukkm
         w7u/RLKab4ibriFSyZKOgsWuNa5tCFv8C2bD6EQGHf8xo4i0ZMfxDnYEz3SYXrEQ1CAQ
         ph6xeZb31fEX0ILajRxBkvT5tnY8c7uU4gyqYPRAJWZF0hsMvVjXdHAtEuwcqejfTPc4
         Etr29q0fUGsdTj13fryfrujh6CCSRKTL9s9VWAxoxYETeOz9px/+oFZuuGBV9dnVGiqV
         vySQ==
X-Google-Smtp-Source: APXvYqwBJlH3d0L/1BSxFnL+vLT8aQU3g2pJmlFcXlcqO/GjIhh0NRs5+pZNe4h8FrEWDwW4ivgjRA==
X-Received: by 2002:a63:124a:: with SMTP id 10mr5554258pgs.254.1565141661706;
        Tue, 06 Aug 2019 18:34:21 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.20
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:21 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>
Subject: [PATCH v3 23/41] fs/exec.c: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:22 -0700
Message-Id: <20190807013340.9706-24-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 fs/exec.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/exec.c b/fs/exec.c
index f7f6a140856a..ee442151582f 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -227,7 +227,7 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 
 static void put_arg_page(struct page *page)
 {
-	put_page(page);
+	put_user_page(page);
 }
 
 static void free_arg_pages(struct linux_binprm *bprm)
-- 
2.22.0

