Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A862C606B2
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 12:52:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E84D92064A
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 12:52:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E84D92064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66DA88E0013; Mon,  8 Jul 2019 08:52:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F7C58E0002; Mon,  8 Jul 2019 08:52:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 497088E0013; Mon,  8 Jul 2019 08:52:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEA818E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 08:52:22 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id s18so8162301wru.16
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 05:52:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=77Vp1juDzlRrpvVnwfZYS6xDqW19KpmeFqUsetecy2o=;
        b=PLI4LzbrjaUEP9+aHKdpSTDSprg25vg4aQkgHsqWcgfwxBpoiP/LGcEY1LDtGmCWKl
         Rdm5A50valyX1B6KW/q+VQr988v1lBjYeQvyN1FmArcuvEd5LpVXwyfrmG1w52ifwC8V
         lbIO486sg8J10uG4Lll14M4iN874xtFeSnJES/cDv7DPri7Sctjhn1AU6ve+tTJasgiz
         JiVJ3qwb4VhvM04x9x7ilO4KUpsdupRCtbdy2qoxXJkFqEXuzVV4nGIASRU70q6lZYey
         /7on/vI01U6S5PS3807LivhQ+1G47H8D7YH0DCejkWhgUvT6fZl3xlROI1gOBJ/LxH3D
         mnvA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 212.227.126.187 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
X-Gm-Message-State: APjAAAUbe6pR/Ir/EoAoM5EYKmW1oDmeWiGIt6yJRLy8WzjwF+5jEiJf
	oAcHDkNg6tBwCyOMgMZnOT9RBKOKwNiVoFrj6lB664yG/GYw0sE/IcgAH08sBw8zorvZBTomf2F
	a7u3kjuon3FoTanZMFooy3XACHJbW3rAX6kZOqezvFzGOnJrBqXbsULyFUJjx77o=
X-Received: by 2002:a7b:c632:: with SMTP id p18mr12801369wmk.114.1562590342566;
        Mon, 08 Jul 2019 05:52:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy438arRxcrlddLk7j3QKwhlxsEvuHanJTh/M4v3ydpeb07kvCUX8nOS62VfrgJe80guDny
X-Received: by 2002:a7b:c632:: with SMTP id p18mr12801334wmk.114.1562590341776;
        Mon, 08 Jul 2019 05:52:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562590341; cv=none;
        d=google.com; s=arc-20160816;
        b=ZZGHKy0YDE5H/LFDt50YpGuKCIYcxDuyqI1F9b4Zpnai49QzU3bGYI3j6oZx5KiJ1k
         Sn5iMajlWC6DdfqqkF5z6XN85GefuJVdWfSEW2zGewz1tH63iMm01VqcPuVZBRHPQX8i
         fnfMjwJ2yCZa4Kiv4JbWLhBKrIP0MufopYbTTsrYdJIKH+ol+VZE6pgOJf1wCNu/dX4x
         ccq/SVXXYpshA9YGrol2FozczUGK//xKP9/WtV+b1TAQWZbxQFeiDR8NDIoajet/nXws
         DnDSmCYGKpjxAMD2MK7Lv1z5GkJf+euwpcvdpqriTgKmoQW3dBB+CUPiugDAZ0k4bNYM
         kavw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=77Vp1juDzlRrpvVnwfZYS6xDqW19KpmeFqUsetecy2o=;
        b=dErV2FVZKMEk/1nSbpS31p2RKXXOlnWMGlqL8M8P80gMMJPdTvoW+ER2hoHhjvNSVM
         z0a7liGPM6mgrS0zw6ccxuh4s3pNRX7Lvc7zL0/f0qFx3SDPASVkxatyNGZMkGgRd8fm
         uekNqNTJM/c6zHVs1rIFTrLZMH5UgIkAC0dNWsInbSDOC7Jg+ydh2hIJSePQySO+mt8c
         698slO0USYifUV7l8FTFhHPJqWqh0AFiovnvQTXphD/NavKRxPYDN4fEx8RRyLAsIUD/
         Vq97tPI7PzsvFLk8hnXVu00bbZP0mJasy9T4Ulw73ru4WpjzPX4on5j0BA9851qtOY7f
         DtJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 212.227.126.187 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id p1si6045028wrn.142.2019.07.08.05.52.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 05:52:21 -0700 (PDT)
Received-SPF: neutral (google.com: 212.227.126.187 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) client-ip=212.227.126.187;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 212.227.126.187 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from threadripper.lan ([149.172.19.189]) by mrelayeu.kundenserver.de
 (mreue012 [212.227.15.129]) with ESMTPA (Nemesis) id
 1MALql-1hd0Lw2Uqh-00Bs63; Mon, 08 Jul 2019 14:52:19 +0200
From: Arnd Bergmann <arnd@arndb.de>
To: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Kefeng Wang <wangkefeng.wang@huawei.com>,
	Peng Fan <peng.fan@nxp.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Dennis Zhou (Facebook)" <dennisszhou@gmail.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] percpu: fix pcpu_page_first_chunk return code handling
Date: Mon,  8 Jul 2019 14:52:09 +0200
Message-Id: <20190708125217.3757973-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:cJtj1haBkBbWRm+C+Iua7rdvkbZLbR4MZWZ6z3vSC1X/PXqtkAs
 R+qNUxDsVrk6zgmmdUs6UXIxDw//8IMdKBSJyl1ZUQl9wsyHhvL31/QV8xXn9D8roifT7PY
 GZ1A9E8jTpmXrMwd7rc7egfuxl6cmhOPGYiLqpJKpDSL/DxvxmrJsuTXEe081AhSnUqL2GX
 Ub4oC7dZySA4sOigUqskA==
X-UI-Out-Filterresults: notjunk:1;V03:K0:ITl96BottfQ=:qqxhzos/aOanf3aqBADACV
 JwgD/BUjtgaC1QokhGuyrwx9DsbxnL44mYL17o/rvkq300Dt+Iyleg1ZQwXxaUQ3vnRZAvEF5
 xOEvUpaESSPGruqL33FOixV+UbWXKGDJn6tNBqOxunBZbQ2QQZT64w9L7ANwxAZwXsjrmmmT5
 Rl1TvI0bxyEg8Bzub6PXaQL89ZLZsCW9JVrV/ShakwTiJcIusHUcNTuBSXuuNd+QlKHB+3pb7
 PtwTXRrNEGANSh0UAi8Gw6HXax3DSOaqZcLy3nweZ2himUOJELhpVMQMPNcTypax5bEKG8TvD
 PL4QykHTINpFOQo7eu3Oj1CTPXEVazMUBTRjsuOGTR6pbjDRXvBZdxgl2XJRYpyYprEEnVl0t
 Ub1w5K4+yQG8XlHNCNPKUrtXz3TulnB9Wb7OSU/u4GAWRL7OEvsHHncCBgxyyta4+X3I/aPrn
 oTa8fnO+i8VLlgUYGmkZ32uv9tMjbNn1rao1HPmzu8QJ86UUbsNgdEg8UDh1iaGf2qNUOkarZ
 +hmD7nZH/2Y3jNzeO1gdirDawiVUBRztfjcloIbt++CucLtIuZmv3WBOK04ERzeawGNyRWyom
 HfeJn13r1mqX56Vg8d5IdgOiUSo+0XnvSOo37Iz3A7YZWP4uTCUPhV3nIESaeQd6Ukjf8U2fP
 Wb4ngytBXr4k5s64ogPVtk/CGed73Ns0xrh0/X2f+PCEQD0HvVVgmKCkD5A2vtFzhTfWSPrkN
 4R0t/U9YTMtk/TpTC68ZfJTIJDUhFNxssqnwRA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

gcc complains that pcpu_page_first_chunk() might return an uninitialized
error code when the loop is never entered:

mm/percpu.c: In function 'pcpu_page_first_chunk':
mm/percpu.c:2929:9: error: 'rc' may be used uninitialized in this function [-Werror=maybe-uninitialized]

Make it return zero like before the cleanup.

Fixes: a13e0ad81216 ("percpu: Make pcpu_setup_first_chunk() void function")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/percpu.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/percpu.c b/mm/percpu.c
index 5a918a4b1da0..5b65f753c575 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -2917,6 +2917,7 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 		ai->reserved_size, ai->dyn_size);
 
 	pcpu_setup_first_chunk(ai, vm.addr);
+	rc = 0;
 	goto out_free_ar;
 
 enomem:
-- 
2.20.0

