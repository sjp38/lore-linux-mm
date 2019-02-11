Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB217C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:00:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D2EB218A1
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:00:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JFKeaZqs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D2EB218A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 184358E0170; Mon, 11 Feb 2019 17:00:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 132D38E0165; Mon, 11 Feb 2019 17:00:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04A2C8E0170; Mon, 11 Feb 2019 17:00:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id A32548E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:00:00 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id v24so150235wrd.23
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:00:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=9j6arYV5oPSo1evTW/g+5CNWYkpQXSJzF8KLWrEz4EM=;
        b=UTxhwhgYEFgAcsrcVEIR5t3OsLaKdu+fPIqXmaPFP77x3ogz2SFjODvWEFK8RiuZk5
         AMrv5tvJBlIatxt5bYR8dMGBlFDrE8T8PXaxm0zg5Kbf4yTi+hTLK7K+zeIThyW/Ll7X
         HQ3Y1gTGy5+0WkUEPufMQHtp1BGPxWrkWAgMCVzVGa7grEBnSYyicFeXkSiAlomOKzM/
         hC6rMNf8uHlXvs/uRkQvxBlm4BnmKesoWLO2W6Oi21CIzDYkokGZAmxYB0kin428iU5Z
         qIOOmTMVzjj4LgAY4dI1JKBzN/iaRaOcEbQxxcbSROip+V2V2FjldRWw35qJxj8rDqB6
         OuJQ==
X-Gm-Message-State: AHQUAuYci3k2LMqiCGOdbwcoeezgBC3EKprJfCvo/kSzKeN1b+YuXSEG
	VEv9LTf8sgrhNk1A5r2P871fsSijOk6JzcL9vJ9CRexLtvUisSIWm+Z9u3kZ4qZSUEsBPGRsCHf
	X8CNjwPHQdYP6q5a5unCw5riplWkhCT9uDrqA4ElYty7D1HvcYq2kCbsAXRrqFtRNkB9gNp66Wv
	lQNlXIM8K24u9ZngHO/u4La1vpwpvIy6bFs4LbEzPV6hsarBnDxP3XUZlnwAoZ0GME1Ne3FuVHA
	KguvHG+nXVf7Lxxjijp7VYEiX3/RrnpEVTdbkBDqPzfcx9nfuwCt9panobGA14nsvRh5wNpwo8t
	9jPOTnwOy3QhOid4OGU923AmCxF6pNoO28Jtw6uyO7H8fgFuneJyp0F3RprkPQMQAOo2Va8r5+w
	D
X-Received: by 2002:a1c:2348:: with SMTP id j69mr272050wmj.100.1549922400162;
        Mon, 11 Feb 2019 14:00:00 -0800 (PST)
X-Received: by 2002:a1c:2348:: with SMTP id j69mr272001wmj.100.1549922399240;
        Mon, 11 Feb 2019 13:59:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549922399; cv=none;
        d=google.com; s=arc-20160816;
        b=V/+c9DgkQkRGSKyicBxb8sWkNfAquJAA35c4AfxacvZOKurzWD+xubLIDLp2E0JT3V
         ek8+t2vNDnzqnzq7nf/Ga9/nr7niNDvzd/4jAMdmTpM+HcXfYvJ85U2Rd9h43kwxDEtG
         +fjySMXSvzlC3K5zXNZSlnbsdUMTmVE8dDrA5zDnOYrVZGgQ+hBzTwAZi40ouc2p7BVM
         aUZr6FDv+ODj6V9bwe5JjlLi6yXo8TdQuMkPvRLBu2Ie/f7Sl5koWiFUr9uJH7UNq7Ys
         XgQGWXeDiFibLJda04YqncxZcZ6jSmIvZp64VDY4tZozbWUB43QvktqhvxPMO0lfeK+R
         44FQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=9j6arYV5oPSo1evTW/g+5CNWYkpQXSJzF8KLWrEz4EM=;
        b=KVEQkpqtd9VRTAzBzHstaHcBjpSCafnu0Z2bKWuCyZBvgyNkNiAKfH8rRi/F0/GC3b
         Mk0xNndZ9LCZfrOY8asBA8K57TUxK/PaCZG93caDEfwim2+A7owKlYk4yYNGN+6T1TRK
         0LtbEjoDjWn0W2Uq/urZ0MTcXuernlVWDHwJ16yaZuZtMx4R037gnW+jGMtK/SZcW1J8
         tngorIi4CJi3RBaCIVNftuzV8YH5tqwKoxUNQ85Lb3H9WDzbm2HgaGI3OLnVhbo2CwAa
         L7VexD2YtZ+bjRI35Cr987aSYjlZGdMJ2inNLqwzTF1k5/ic9g0k33AZVHMmcwtU4VMT
         1Ahg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JFKeaZqs;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 67sor6852287wrm.46.2019.02.11.13.59.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 13:59:59 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JFKeaZqs;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=9j6arYV5oPSo1evTW/g+5CNWYkpQXSJzF8KLWrEz4EM=;
        b=JFKeaZqsMP57hGgCzSjlriqO35PCARns0ukYHF1y5+qHvNLziRjGrLCrCwec01pHNW
         Dzdqsf0x4PEEUKcVnlTMCn7cV3pkYgummcAFb5GfsPOAN1Heowb+dH4ORiY4e+JJs3w7
         lvLJtgGHHfYTSumoIvdcrXeT4sjVB3y9ORC2mVOJTEu5L0C7NzMUUJu5K/BZ6pRbOvmb
         SP7AcUJnm0bDvRyulxNZdYwDcOUu+CeX0rI9rvf+0dRCBOf9e8rbQHD30nTmdjOWqhNu
         Nhs8zlXsbvi7bMSq4wzk/hg5HJcDqKTdlguoHFLPbCXdN8mjrCUVxzpbx6wopB3Aguzl
         8jaw==
X-Google-Smtp-Source: AHgI3Ib0EaVpTVNKKkwVXXzcVygK8gOvWKEzBVqt3UqLkErRFV5ycOKGB6j6GwVyXsxz1AhNvWfs7Q==
X-Received: by 2002:adf:e548:: with SMTP id z8mr315108wrm.52.1549922398596;
        Mon, 11 Feb 2019 13:59:58 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id c186sm762685wmf.34.2019.02.11.13.59.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 13:59:57 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 0/5] kasan: more tag based mode fixes
Date: Mon, 11 Feb 2019 22:59:49 +0100
Message-Id: <cover.1549921721.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrey Konovalov (5):
  kasan: fix assigning tags twice
  kasan, kmemleak: pass tagged pointers to kmemleak
  kmemleak: account for tagged pointers when calculating pointer range
  kasan, slub: move kasan_poison_slab hook before page_address
  kasan, slub: fix conflicts with CONFIG_SLAB_FREELIST_HARDENED

 mm/kasan/common.c | 29 +++++++++++++++++------------
 mm/kmemleak.c     | 10 +++++++---
 mm/slab.h         |  6 ++----
 mm/slab_common.c  |  2 +-
 mm/slub.c         | 32 +++++++++++++++-----------------
 5 files changed, 42 insertions(+), 37 deletions(-)

-- 
2.20.1.791.gb4d0f1c61a-goog

