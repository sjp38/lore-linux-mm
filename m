Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC7C3C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:57:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7218F206E0
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:57:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="JL8GBMnD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7218F206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F1016B0006; Mon,  1 Jul 2019 17:57:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A1988E0003; Mon,  1 Jul 2019 17:57:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED2338E0002; Mon,  1 Jul 2019 17:57:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f205.google.com (mail-pg1-f205.google.com [209.85.215.205])
	by kanga.kvack.org (Postfix) with ESMTP id B5EAC6B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 17:57:45 -0400 (EDT)
Received: by mail-pg1-f205.google.com with SMTP id x13so8311009pgk.23
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 14:57:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:from:to
         :cc:subject:date:message-id:in-reply-to:references;
        bh=4J0XDwPxe+pXlEZw06fCMQH6UCnEp0VAm5ojSFh5jUE=;
        b=ZEdgg8TAwkcTy0541k7mo+lnPpHTwF+JMat/2fF0pif9rv+vad63q+MiH+nRgAd2ST
         7dMPcffVotorqwreNHPnAG5IYstb2Gi80SXFqpflccywgBombL8oJfkyKmsAa4wzU2BG
         Fd7U/xxoEoNUMEpXs6GNyAJXPamvbZZsDyeeP7DJ96pOOMUDk7go9+Sf8rWB64EbJsEI
         Ovg5y3wipL663Qls9CtDIcms6xk/z4BEMMxDH/jks7RCctZG2iJdAQHYjsDe07TrOyUA
         7X5E3DE886W6ArZVHuZuQkA2SBMqfn+HG/BVOJ4KntsjO39BPXzOyim4fXblpZxtaKJ+
         NtjQ==
X-Gm-Message-State: APjAAAUXy/2VuQa9FZjNb1N9yz/oz1ov5OBWeCJldkKHsQPD4ly/wZZG
	8xzkMsp37vavw9mF2arrYADkOEWIcCdpuj2VGIRtfN4kDOmxtXaFpmkbam3Wjdmi9vDMq8pH3gu
	Eq/aj2oc5AKgmF7zweUK17SCihW5qTFejKNrp9BaVuAIpHShsf9JcmExNGR00BHn24w==
X-Received: by 2002:a63:4c0b:: with SMTP id z11mr27288462pga.440.1562018265234;
        Mon, 01 Jul 2019 14:57:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwni768YkBFZF0LM5Rdqq0ZptNHKvD4UiQ9HHzro6HSGwOixciXmDTEMtMSlm8VsbxQAn6b
X-Received: by 2002:a63:4c0b:: with SMTP id z11mr27288401pga.440.1562018264438;
        Mon, 01 Jul 2019 14:57:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562018264; cv=none;
        d=google.com; s=arc-20160816;
        b=ImGZozmkGWDsLK4nakd2LDpt8bIUbdveR8MnUXPLAbnEVMQx/YHKHKyVrWNIpU+7T4
         +OdJafITOOnqdkBjMJnPiKk30xFkuX05MTXspz5DE8ODEZysuJ3QqDIhQcPIh9/TZCBB
         5JPbB4HFXaLU06wMwsbWUMg1iTr2kdiBL4nbQOKoxJ4PBHa0C3kl1x8RVbDSjLkEAUkM
         qkCRY6tSAMFV1HXJn5DVouo7bM0fw2PFlwjWWoh55AsRtlqFfBmEWtASRFFeVjqlEb5F
         ID98M64rGS3SvL5W6V/Ex85Xs6yYUlIlcjFjM3uibvbllAH+ErBz26636So4WfAe7p1w
         rUXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :ironport-sdr:ironport-sdr:dkim-signature;
        bh=4J0XDwPxe+pXlEZw06fCMQH6UCnEp0VAm5ojSFh5jUE=;
        b=EcVhCMMFuRjTPNdTUK+ERLitBjlP7WeiEFo1bqxUHi2LDEXTntpMw8Ci67lTfGTARQ
         IgnDbVo0XBfkPHVTK+NCaRIlzcCx1kJp+11KMQtM576woXvBxKanziSoW6GxMECjeFBV
         xJ0pY7gK7JsZV0MMhmIVP74gN3xDRpHDB61EqcXdpNyD70sk9Zyxcde1CDxoXdJSp/ko
         foR+9WtGdQf/ep69791CfpWB7v3kXRK4YJvSoMV5fbejV2jaQAFOufBD5rqEPVMkRR7J
         z4tgWt11qBEJYLA29CX5JJIRG6r+h9t2ggYzqru/N+5NShRKR7v+sQlrrSJ8FSMbZtxa
         ceyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=JL8GBMnD;
       spf=pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.154.42 as permitted sender) smtp.mailfrom="prvs=0789f8ff9=chaitanya.kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa4.hgst.iphmx.com (esa4.hgst.iphmx.com. [216.71.154.42])
        by mx.google.com with ESMTPS id m71si577064pjb.26.2019.07.01.14.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 14:57:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.154.42 as permitted sender) client-ip=216.71.154.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=JL8GBMnD;
       spf=pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.154.42 as permitted sender) smtp.mailfrom="prvs=0789f8ff9=chaitanya.kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1562018264; x=1593554264;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references;
  bh=OqaUD3tyvurJZF4iy8UPTGJAVxI+8vvw75Zn9sBYYZc=;
  b=JL8GBMnD50HsHxgTVbE/yudd7jbD/7ZzaeJ1kmcC2u4H3RKLDFj0uAoH
   FMfGIutJ2q9Sq765r8PJg40eiIySg1OIlYLypuBCBDKKXUu4pyzxI2QgA
   vX/hVCmuz+5SK8d8mHdsT0kQnJtb9sw1zIrWw4zOHs86b662iDiqgUmoT
   z8luDl6zCzrqtxVpoiL6jPwKL8cfvgV1ljVoxA6A57LJ3IxhtAgQCkVcI
   ANQDD9KsExm3ERXg3kOf5GVI0UhsegHo4Dff5XIOaFbqmoKu41PMowi44
   KxFELNp6a29fN7h/r9EMRWk/z7aPwGlL0JAx5u+flxrH/nu95YSvUFZTb
   Q==;
X-IronPort-AV: E=Sophos;i="5.63,440,1557158400"; 
   d="scan'208";a="111992767"
Received: from uls-op-cesaip01.wdc.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 02 Jul 2019 05:57:44 +0800
IronPort-SDR: 6tuCbBgfRDKnMjDdNUKivRlmIP0d4+OSfMQyfizQeqjHYczFsSDX1D3kZPxTfq3LBftHAvTmT6
 Itn/NRh1OmTQb7I3YGoOhaXSrBu7tVtNU08ryY8TebPXx6PndINtgMvVySf9XNmR4/gr4VCEWt
 OsqLh8o9bcw6c+qbGrY668K3VwCJ6WsoSn34wF5giwzdggS33KVWer8OxIDSOhhwLYY75prB+l
 9RQ9NCm/YBJvNUuKBpLq0YNn7f70JaZZ7KZ+Q+ZISv8aAfYMGfnsRwobim2wXScxp3XpIFV9I9
 1FWLHpqTLCpgdC2sYOcrvc0V
Received: from uls-op-cesaip02.wdc.com ([10.248.3.37])
  by uls-op-cesaep01.wdc.com with ESMTP; 01 Jul 2019 14:56:44 -0700
IronPort-SDR: wxv1jtI14V0dynykEUh694Gd+y7cQjWb6GNJY2Fh1io9Yv2yWDaMNS0U/JIdWHAae8H+x4yL1W
 N8sJUPfXtNew4R3FGvi5vtEkUUuC+o/5h7G8ONNS4DBhdnjyj/KMZDZp04wpV/yvF7Z8u/99sA
 uBVwShEzK5Us0emedzyRYuwUbykkGHGjaXjaDb5eWT8VBIRhR7ziI9lLDS6iqG/8fpLe8oLFHM
 NE+ShJ7xGWHPzrWAT26BbsgntAdjRye8w3WoQUUyGZwqC1uRL8WOE9kirSgjy8CNKNo5LagRUC
 I1I=
Received: from cvenusqemu.hgst.com ([10.202.66.73])
  by uls-op-cesaip02.wdc.com with ESMTP; 01 Jul 2019 14:57:44 -0700
From: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
To: linux-mm@kvack.org,
	linux-block@vger.kernel.org
Cc: bvanassche@acm.org,
	axboe@kernel.dk,
	Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
Subject: [PATCH 1/5] block: update error message for bio_check_ro()
Date: Mon,  1 Jul 2019 14:57:22 -0700
Message-Id: <20190701215726.27601-2-chaitanya.kulkarni@wdc.com>
X-Mailer: git-send-email 2.17.0
In-Reply-To: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
References: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The existing code in the bio_check_ro() relies on the op_is_write().
op_is_write() checks for the last bit in the bio_op(). Now that we have
multiple REQ_OP_XXX with last bit set to 1 such as, (from blk_types.h):

	/* write sectors to the device */
	REQ_OP_WRITE		= 1,
	/* flush the volatile write cache */
	REQ_OP_DISCARD		= 3,
	/* securely erase sectors */
	REQ_OP_SECURE_ERASE	= 5,
	/* write the same sector many times */
	REQ_OP_WRITE_SAME	= 7,
	/* write the zero filled sector many times */
	REQ_OP_WRITE_ZEROES	= 9,

it is hard to understand which bio op failed in the bio_check_ro().

Modify the error message in bio_check_ro() to print correct REQ_OP_XXX
with the help of blk_op_str().

Signed-off-by: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
---
 block/blk-core.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 5d1fc8e17dd1..47c8b9c48a57 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -786,9 +786,9 @@ static inline bool bio_check_ro(struct bio *bio, struct hd_struct *part)
 			return false;
 
 		WARN_ONCE(1,
-		       "generic_make_request: Trying to write "
-			"to read-only block-device %s (partno %d)\n",
-			bio_devname(bio, b), part->partno);
+			"generic_make_request: Trying op %s on the "
+			"read-only block-device %s (partno %d)\n",
+			blk_op_str(op), bio_devname(bio, b), part->partno);
 		/* Older lvm-tools actually trigger this */
 		return false;
 	}
-- 
2.21.0

