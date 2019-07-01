Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C603C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:57:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE917206E0
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:57:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="GJwgOI24"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE917206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70A208E0003; Mon,  1 Jul 2019 17:57:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BB588E0002; Mon,  1 Jul 2019 17:57:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A9E98E0003; Mon,  1 Jul 2019 17:57:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f208.google.com (mail-pf1-f208.google.com [209.85.210.208])
	by kanga.kvack.org (Postfix) with ESMTP id 2249C8E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 17:57:52 -0400 (EDT)
Received: by mail-pf1-f208.google.com with SMTP id x10so9565576pfa.23
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 14:57:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:from:to
         :cc:subject:date:message-id:in-reply-to:references;
        bh=Qfro/XB57m4RkRb3pamnEYt3ZcrE/2bJNg979yXC2es=;
        b=HVXaETbZxnOsrh3D2vuErEBf71rYqtxW5VztqM8ulx5Aa0MkGaYsJnpAqYVpYWDT98
         7A100KDdf3sZQH8ZK7HSdfA4Vk7iZRBOvG9PpgWubTYBvzT2HILv0jhdSi+D3Z33q906
         5KZsebtbgQiRLdLAeEeNCK68CHBWcdgK9fbEo3RCvM0dSs/+RC0rXQ9XxxgxYtRMILRg
         lgXXj4Gl3dL5e836MYsfmznp5hutolXGPt3O5TtBVUddGOciDm2mKqlsGCxfOsbRZGBN
         AKjOaPf4aoE1zee1jJHFJgo1NhMj934d6faMIdfh2h2d9giI5l0ACxejMgcS5s9/cTiv
         rLOg==
X-Gm-Message-State: APjAAAViaxVQmMPcM7HzkNuPeTG3JCFDlAVAwjyT2fpARLRK1Ab9i/oJ
	YQ/9+Xfv2ZDcxfSd1ytUPYNm0xqX/30GsplxPAltsUvg7HVvvLHCqC2Q/nn/zMbL3bTTQtC4xdv
	9ofexDzIiJQ4KSS4hHd5/Qyx/Xq/DbzafuP0dORRqP56Vp7ScN2qjthQ8hGJbL/eMXQ==
X-Received: by 2002:a17:902:1566:: with SMTP id b35mr32273769plh.147.1562018271775;
        Mon, 01 Jul 2019 14:57:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwV+Fs3PmawkEO9Ml9iqhMtq6fmUYtHv+6IwBsz9c5DHRDZBGwVno6E+00phgiBD4etYnbv
X-Received: by 2002:a17:902:1566:: with SMTP id b35mr32273728plh.147.1562018270859;
        Mon, 01 Jul 2019 14:57:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562018270; cv=none;
        d=google.com; s=arc-20160816;
        b=BJimqDMt5GQacJGLZ3JZ8XYIkioT5cg7/ml4JnDyaHHXHVRlPeQ80DwhHZvQRgBpn3
         JyWxWuyLnSxpTg0Et572kdciX84VtXEWVfVHbS9GfZuiXTvyYpt9P4lCp1V+u+jQZZHV
         rfnnRlveF+M/8xBEEF9DcT8bURce1lAQR8HuAY4xqM7LGIGtbb16MzX7NFmv8+325p13
         IL466lqqrdCpDAC4d32G0/0KKf4d3zEFt3ZM+voHA2BRUAcNsx+NFOkeBlwoMy17lYO3
         sPT/6CZ5O8J6Rr5KJh8PoHfMpPIZYshuWSyzx9T1sPZo7j2Zvly5GKKtez9MOD17mzgO
         ZBwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :ironport-sdr:ironport-sdr:dkim-signature;
        bh=Qfro/XB57m4RkRb3pamnEYt3ZcrE/2bJNg979yXC2es=;
        b=aA/dc2Ed4Wn+GDaH7RDRH6ZmXSSScfx6s2VknFXKNnzo+rxCXUwkKc/cjuRBoyofgi
         UmW75OrJRzUQBpKoLxTtQBtLEyKoNn9CYGxWrb+li3Xmn9TP0IiiLgHJBF1FxnofwDgH
         lCIk5JxmtA1tYZHLiz1c10jNmt4+M8nrTBdT0AvSV+NylTD0+SijpyhHxSG/bgdgBm5x
         8J9/rAaZBR8PL/pwYmfq+RtzRO2TEqeQNinVzrZiW4dsVyjl2U2rTnDPykPhG01HGbIf
         Yj/79+M7mUPpQBQ2UgubHSvlKiBqCrYYAwl3UGO6IwtEikZFXNWGUv9hkZ6W8ucc+3nh
         madg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=GJwgOI24;
       spf=pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=0789f8ff9=chaitanya.kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa3.hgst.iphmx.com (esa3.hgst.iphmx.com. [216.71.153.141])
        by mx.google.com with ESMTPS id c11si606364pjq.0.2019.07.01.14.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 14:57:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.153.141 as permitted sender) client-ip=216.71.153.141;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=GJwgOI24;
       spf=pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=0789f8ff9=chaitanya.kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1562018271; x=1593554271;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references;
  bh=9J1OfplonnbynoEAMgNYcUvjFmcuTdb/IR5OisFEtak=;
  b=GJwgOI24cJR3VFJwNiZp95QuWt5AWq2uUdk7q9izC+kN8WZAsIFXBlCH
   9cqWIcp5x9AJM9OthM/z6/Js1aWFEmWtzCHvV7loUwIkI20ykMjhNprGE
   WbnAbzZuPlrzsp+QhG+IWglUA4a3l/5jaLtXf7OJAUFdmMyks1bYCs5lU
   yt2bn3e7W1221gKIfO+XzeTHbsX/utwvS3rmS7ZE7VBL+TmCdN8XNftT9
   L6fXl106XTCUSfYqy9VAv9T/m4P2DlFFU0v2VGkrpKSI78+Ptvkvmrnz4
   qyJ2TWCPwqHMHd4M4BMdagYduO6Yhj1FZsjJEtI6O2TpGvfrWjJC8ATtz
   Q==;
X-IronPort-AV: E=Sophos;i="5.63,440,1557158400"; 
   d="scan'208";a="116844010"
Received: from h199-255-45-14.hgst.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 02 Jul 2019 05:57:51 +0800
IronPort-SDR: 6xzCaxW29mLPFV6IJr/NiJP+8796x9RLBm3SrvMJuS/mgh4LeyFIMNnGLOICtDlKh3yJGQS/5P
 Ym9osdSqWfkDal7V9ALdKh3klhusPgNpqUBXD/virkbgXvUwvmovkrBOJYwFBI+gnDNehkaH0Z
 iPp4wS4cY4ZSz+7ulz3TamyTRmusBfwqqyFR2zj4FOnCpso8ZprvOiE0gNTXcbh7eIJ2ka1tOi
 gWfW1+w0HPSEzgIkXAN9Y9QkQBkiHSvXWmQYVQqP0kWw8SM//xO+VMidt5PRvjve9TvkAdTBge
 +1uAHswdNGw/vP+RR0yaCA5s
Received: from uls-op-cesaip02.wdc.com ([10.248.3.37])
  by uls-op-cesaep01.wdc.com with ESMTP; 01 Jul 2019 14:56:50 -0700
IronPort-SDR: RUT0zDud5mdeTiDe1oPpuNFjDkJ3uuMy6naMhD7jlFJOo5Lx94cNdS/Nkt7n9zdRsqDaX8I6aS
 kpaO5xs/asgCHLZQqRzj68/bAQY1ftPJ1LuuI+Mm0adufqE1zU2V1QalNgVa5v+cw+tQbBCrsx
 z5HtwnIeWwhelc9wuGhNRmFmJqPGDwu9W68q3GBRjOdrZ8nIYKVL2ZoE53gzE6nYvBvV79r5Oi
 iHsMW4+fL3q2Caum4SGUrUHvk/O18aCQYKP5YevyAbm4yOdXJpq0lIPCo89V0C6rqMGJesnYkn
 MW0=
Received: from cvenusqemu.hgst.com ([10.202.66.73])
  by uls-op-cesaip02.wdc.com with ESMTP; 01 Jul 2019 14:57:50 -0700
From: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
To: linux-mm@kvack.org,
	linux-block@vger.kernel.org
Cc: bvanassche@acm.org,
	axboe@kernel.dk,
	Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
Subject: [PATCH 2/5] block: update error message in submit_bio()
Date: Mon,  1 Jul 2019 14:57:23 -0700
Message-Id: <20190701215726.27601-3-chaitanya.kulkarni@wdc.com>
X-Mailer: git-send-email 2.17.0
In-Reply-To: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
References: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The existing code in the submit_bio() relies on the op_is_write().
op_is_write() checks for the last bit in the bio_op() and we only
print WRITE or READ as a bio_op().

It is hard to understand which bio op based on READ/WRITE in
submit_bio() with addition of newly discussed REQ_OP_XXX. [1]

Modify the error message in submit_bio() to print correct REQ_OP_XXX
with the help of blk_op_str().

[1] https://www.spinics.net/lists/linux-block/msg41884.html. 

Signed-off-by: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
---
 block/blk-core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 47c8b9c48a57..5143a8e19b63 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1150,7 +1150,7 @@ blk_qc_t submit_bio(struct bio *bio)
 			char b[BDEVNAME_SIZE];
 			printk(KERN_DEBUG "%s(%d): %s block %Lu on %s (%u sectors)\n",
 			current->comm, task_pid_nr(current),
-				op_is_write(bio_op(bio)) ? "WRITE" : "READ",
+				blk_op_str(bio_op(bio)),
 				(unsigned long long)bio->bi_iter.bi_sector,
 				bio_devname(bio, b), count);
 		}
-- 
2.21.0

