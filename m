Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1C26C32757
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AFA821743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TH7xsIR8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AFA821743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91C536B02A2; Tue,  6 Aug 2019 21:34:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A4F26B02A4; Tue,  6 Aug 2019 21:34:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DAA36B02A5; Tue,  6 Aug 2019 21:34:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5156B02A2
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:45 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id z1so57132896pfb.7
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=S+0IdzDd5LiY8AHwrYdqvSEMzcb9gWZ2lznukLTa4fI=;
        b=nbYobVNT0PxpWY7w9lZJgIsDjshLg4++WMgig2gjtYSRYobRKWdAaKAJdvyU/hK4kA
         xEOVUEeI6X0gpN158r4/WssbvRa3pV5TVZIQc8q7dYNO7nRkGufoVgSx/wtqpx7ztpVf
         iC2SuIrwl07CHoIMKcNNrNymduSYWofX45tU8kBNxDM9mjctCgwpPh8joqseGFyxny+h
         pwzL4elOSOTqNWePXKWtqwmbjumP/Ya7/ARECpIGznCq9XwyMOc6qII51PBgkln0fiVn
         M5uyuRXawNBdkRxC8puMI+qpC2P/6QBA2cUVD0OXNx9sqd2yseJ+GAdHfEl096Lu2Sox
         vj8A==
X-Gm-Message-State: APjAAAXnvBehAld7NKD3nJIcPEHboCyQiNwuJIynoonaHoP2Bm090vmK
	q/Xi0nAenaKemJ2xZ7wu1UZexhL8yOWv+vdeLYgNDqw5LTcXgLql9LXCfk6ceWBdcvD3aj2ojM2
	774k8uvPzYJXT9ICDahaJZxGKePEUu6JjAQhOIypGW8+W1nVFF/2lYvUKGWcQiDZKGw==
X-Received: by 2002:a17:902:8a8a:: with SMTP id p10mr6004735plo.88.1565141684873;
        Tue, 06 Aug 2019 18:34:44 -0700 (PDT)
X-Received: by 2002:a17:902:8a8a:: with SMTP id p10mr6004682plo.88.1565141684041;
        Tue, 06 Aug 2019 18:34:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141684; cv=none;
        d=google.com; s=arc-20160816;
        b=lHTMrYw62K5xX6xuqrJdjt4LkhIM6DIgLuiAbzMEyQOOl1+IlkTTovd/YowXfwNgsX
         UJPoareCcDNYgdbMbBlSqp3gZs3GCba+Ii4U1OcFuqoQuKoQ5Y50qdeufTehe0jl/e9i
         C4sHXjKfVEUi9MKM455wyS6dX9+q6QoDjPWJbprSHhUHuS+P9QBZxqiyec/vNGnHDmOr
         erxBw7bCtbrrTVP5elj9SleRcsqlyf46V/pvkkWsYRy4hbu+mAfCypGBUn7niH4ASI7O
         OC28/UDXwGD+rhZSktI5Of8IaI6OKSsNM2ZI6IbA3vl5AWj8VCum7gwAhqML9GDWCURd
         i0gQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=S+0IdzDd5LiY8AHwrYdqvSEMzcb9gWZ2lznukLTa4fI=;
        b=BcB5+fv4ma6P+OyrZYYKsw/Q7t0iImSXgufEQ3BQM7g9bY/VZCfeC6baBLQMfuN6RN
         aSQKS0iWe5nQInPt9qAAxeiiaWCYx69io0HtAOZU1EUNspcZlnqJ7YAtiFbA4m4mB3o8
         OCZkLiBTILuw4lBKcPQYHa0mPJilgn5vXt+TJb3OH9s8AdBquwEojKpVdYPm5wYKvnU1
         qxHPXlEVbiNjbdRT1wuQ8uSdoE5wqeN/e0aRx7GjJ4NruTOFA6E/+E+Y5vqSSuvglEtJ
         UP7utrBsQFCgkwCj1CBb6f+31BIZM8qdPDVimPWjOG06dSPKXD+W40F1VJ7pAufl5XSN
         KlUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TH7xsIR8;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x15sor104115102pln.50.2019.08.06.18.34.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TH7xsIR8;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=S+0IdzDd5LiY8AHwrYdqvSEMzcb9gWZ2lznukLTa4fI=;
        b=TH7xsIR8mdN6BLY7JG8/eF6RsdDCkk2cRD3dBopErpIToembDlJ6DvjPGThWxgNDHN
         izZnY8v+rrCTqbMQXBbwMmFJJ4/nvmF6zRWW4Xs6qUrfZ8o0czAW/fGIDrwD7Q1ygI7M
         9Zf8Re7QredxsFLkJT7ZLJf014g9dC9bvOiPKF2NgNaHSnsjvFjfZ4bBzwffrRrGp9/v
         vlT+JVAmAuL0sqc4zONRKIioMJS5mLcrWMkUTsb2T5dvyeXECRBNXvR++1qedsjna65N
         Bpeio/uU7dJ/a25yv6b3onr0A5BIr5z5tUmsUB0sHub+eppjPv5sJ1ZexYmVLUXkgvRa
         bJaw==
X-Google-Smtp-Source: APXvYqwBIISXTWf4C+eZPMoIO/o34tgUz/S5eMQixOLDQAsdZlLcpYV/uzVG2wEPWDAc94LDsKhJ9w==
X-Received: by 2002:a17:902:9a49:: with SMTP id x9mr5953327plv.282.1565141683818;
        Tue, 06 Aug 2019 18:34:43 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.42
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:43 -0700 (PDT)
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
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	linux-security-module@vger.kernel.org
Subject: [PATCH v3 37/41] security/tomoyo: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:36 -0700
Message-Id: <20190807013340.9706-38-jhubbard@nvidia.com>
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

Acked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Cc: Kentaro Takeda <takedakn@nttdata.co.jp>
Cc: linux-security-module@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 security/tomoyo/domain.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/security/tomoyo/domain.c b/security/tomoyo/domain.c
index 8526a0a74023..6887beecfb6e 100644
--- a/security/tomoyo/domain.c
+++ b/security/tomoyo/domain.c
@@ -931,7 +931,7 @@ bool tomoyo_dump_page(struct linux_binprm *bprm, unsigned long pos,
 	}
 	/* Same with put_arg_page(page) in fs/exec.c */
 #ifdef CONFIG_MMU
-	put_page(page);
+	put_user_page(page);
 #endif
 	return true;
 }
-- 
2.22.0

