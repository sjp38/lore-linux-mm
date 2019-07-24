Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E680C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 622FF22387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AJiRp1Us"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 622FF22387
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E4F36B026C; Wed, 24 Jul 2019 00:25:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3725C8E0003; Wed, 24 Jul 2019 00:25:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C3C98E0002; Wed, 24 Jul 2019 00:25:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D81716B026C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:25:39 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 145so27686841pfw.16
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:25:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=I1wDMaqOj/gzGRufAfLYBvs0e80ibIJerHEY6qRx+9Q=;
        b=WYFTG90J0xncfDGyob4AD7ce1Wpia48xh1bezsbuOVkwRIE9EcRtJNp3SyPFRMq7/8
         +pE8FmPnXkj4CUT8QQoZmIc4Bwh9OpvymPGngUICBrL+nGMnrPtKz3gNYLQc4N++IkNa
         eXT+GC9gIJllKhOzYeij8tjs2LUhWO5p2Q3EpZ7PMUhhxDf5qmh36zVqo5A+9GYhXaOu
         SJAzs7BUuS6S5b3i3jcEU7psK+Ib7rHYPtYEufQ+m3U98tw4jYJ/rhdWG5wIORbwN1yp
         +yy+12iISbbGLpc4aK0bURzW5wEhgnhPyYgQemtAsTcrNBc8ycmicigR/xColgq37/ly
         xMeA==
X-Gm-Message-State: APjAAAU2HppbN1u8fzOsHX0XpMDWdSsKTVT4luV8kxUcCWQcpf45xyiu
	95Gv8csE2Dt0VU0mncL4c0x5K5mdk0gwCme7ta3d6QoQ24FhbuL+fsPpkn5pypej5pzIiG7TiXs
	E4gHKDg67V0SH/0nbO9WMXBFRVHOPfC4hN8G1huW5od0ZiHIF34YcWrYk4fznhZkITQ==
X-Received: by 2002:a63:6fcf:: with SMTP id k198mr78633090pgc.276.1563942339443;
        Tue, 23 Jul 2019 21:25:39 -0700 (PDT)
X-Received: by 2002:a63:6fcf:: with SMTP id k198mr78633058pgc.276.1563942338674;
        Tue, 23 Jul 2019 21:25:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563942338; cv=none;
        d=google.com; s=arc-20160816;
        b=fChPYPOlmWlb8n96tp6TwC8x9yjdYJvoqKmQjzYvgcg9Sd5wxF9KCLEJAVPI3isuzn
         HlF2ChScFa0IR4Dm2eUbPdmIlWBhw00w1HrTdfVXxJXMv8pXxtPliLCz1INcwKTTW2UZ
         G5AygQFmQ++b1vT7JjdQShmoO+9oexcmJCgDce+uYjgHvCc2O2v6+5JeyGlp/9v39wg5
         tTKTUUVhEwPmOwL+fRSr8Oik7JoiqZoDQOsZo5IlFjegm2tpt/lr1383yp2t2OV5HBCh
         bEvSV685X4x3DjWlV9KXxlP82lfuNKecWmAmVABjfeE6Ddaff/DLql+gmGfCsO5DCPJK
         Yzmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=I1wDMaqOj/gzGRufAfLYBvs0e80ibIJerHEY6qRx+9Q=;
        b=p3Cn2q84OyWO+9lBoh97T8xRa0K43Ybgx8awB/If1dAMDvS85sZ5WWaxTClU6NXa8f
         q7WalXP4PLIvMoEPAqM2klxdnWFNg5HAprJ1JSiajjCkqmzoQnJsHdlifrIoyJIN649L
         sp1rL/5FGv30GovqflKoYVdUTGwjp5oyh1fzyIlfK9ohY7omaCJF3XJSPrWWLDVLM8QH
         hoU+sO3Ur6nXBDEutsJCPKMb1cexjdkdILvz9M6yYrnnFHBGW207V1mFpDmM12hXyl4m
         5z0YTDNis3CH6QfV6yVXghqyqbIvY0j9Ibii4Xxq9S0dbm4CaF97Tov21aDrp8dEeUr/
         zkNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AJiRp1Us;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i20sor25799437pfa.12.2019.07.23.21.25.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 21:25:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AJiRp1Us;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=I1wDMaqOj/gzGRufAfLYBvs0e80ibIJerHEY6qRx+9Q=;
        b=AJiRp1Uswxxxj2fjLfbqacoLwH06WJ9mszsK/zlNhFuhNoSLtvKRmhFo9KLI7JLl8B
         hxIxG1xThvmkqqGsj4H+PIkZgqzG39WvTfqHCYX31eWH9qZ8HHJptRyRkIYZTdhpSSJA
         nZA7WnB2fukiDrq9dsIiMnZ4oXRSDbx8C0GrWwEoTfJ4nGsrUGvTe9DUv98TbDoHZftU
         2sPJK+pDMsCNPpAzyI5pMUhaliFeOadZMdLhzw1frV4a114QmQGutmlMg9ocT4gPTziz
         ZW1wdryUHfhxRuoKX5pPJ1KukLjcZAbAo24BFz30vzwXdEBQHRvTjXN7uylJkrR8anzL
         2E2g==
X-Google-Smtp-Source: APXvYqwVZxneCPfv2nDeo72FQ4K0Ri4nG9i/Jh52gTbxtuFDM1ER91LNrK6Q0r6xmbSBuioIPNnbSg==
X-Received: by 2002:a62:38c6:: with SMTP id f189mr9250236pfa.157.1563942338440;
        Tue, 23 Jul 2019 21:25:38 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id a15sm34153364pgw.3.2019.07.23.21.25.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 21:25:38 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	"David S . Miller" <davem@davemloft.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jason Wang <jasowang@redhat.com>,
	Jens Axboe <axboe@kernel.dk>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	ceph-devel@vger.kernel.org,
	kvm@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-cifs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org,
	samba-technical@lists.samba.org,
	v9fs-developer@lists.sourceforge.net,
	virtualization@lists.linux-foundation.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 12/12] fs/ceph: fix a build warning: returning a value from void function
Date: Tue, 23 Jul 2019 21:25:18 -0700
Message-Id: <20190724042518.14363-13-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190724042518.14363-1-jhubbard@nvidia.com>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

Trivial build warning fix: don't return a value from a function
whose type is "void".

Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 fs/ceph/debugfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/ceph/debugfs.c b/fs/ceph/debugfs.c
index 2eb88ed22993..fa14c8e8761d 100644
--- a/fs/ceph/debugfs.c
+++ b/fs/ceph/debugfs.c
@@ -294,7 +294,7 @@ void ceph_fs_debugfs_init(struct ceph_fs_client *fsc)
 
 void ceph_fs_debugfs_init(struct ceph_fs_client *fsc)
 {
-	return 0;
+	return;
 }
 
 void ceph_fs_debugfs_cleanup(struct ceph_fs_client *fsc)
-- 
2.22.0

