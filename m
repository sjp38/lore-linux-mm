Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0B69C06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:16:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABCE920665
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:16:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KmDmyc9U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABCE920665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47AEA8E0005; Tue,  2 Jul 2019 10:16:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42A978E0001; Tue,  2 Jul 2019 10:16:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31A278E0005; Tue,  2 Jul 2019 10:16:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id F06068E0001
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 10:16:20 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id u4so5993556pgb.20
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 07:16:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WBzXR4TZZHkqkMNv1E0xRf3mfUwoTzVNVZHPzzbj8rI=;
        b=HUUWY+W84TNnOuCv2ChGZTaKhC6Y4BKNlYQrrn98p7r+VqVEWSNeuvpJsQJQwQkMM8
         nWu0rlcN125i9EbSsYkwiKFh2xtGoKoLYWNbtgxab33PVG/h2RaJn4Uy15wXDsHMKkS/
         arURUE/oB60S844Ovr8cTdGiERtJ9+mV8VF2TbfNajDo8rZKJV4LqwekGU4REOWI9+Y7
         4XGOsROV8UkPoqPPNhM3FP8Hyz7fanhogqxO8uvMHGqL0QtWvHPwd49ul3e8ZIipARna
         d/xj/5rofzf/ETokFh8pyT4/WB255mAfsCQvc6DDF3Yuj4NmdrYAS73xD0AxTqTgLjdu
         82Cg==
X-Gm-Message-State: APjAAAXDQ1kQurh/upe7/AZAwOplg1HvJVsOsZ8ipx+AkOSh6XkJPXDw
	eXsNfzY9YhTOriSesxlCUGmba3p+LrWbX+z51UizMGhcW4KovTNgCDinLPgXifoN6XERPdTm+6g
	yJ2S/B6TVFPxhpMpD/T9RXaSPKXFzxmC/QOPxpPY1no84IQNUuVn7WLYghx4/uE4ccg==
X-Received: by 2002:a17:90a:1b4a:: with SMTP id q68mr5888341pjq.61.1562076980688;
        Tue, 02 Jul 2019 07:16:20 -0700 (PDT)
X-Received: by 2002:a17:90a:1b4a:: with SMTP id q68mr5888296pjq.61.1562076980048;
        Tue, 02 Jul 2019 07:16:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562076980; cv=none;
        d=google.com; s=arc-20160816;
        b=rfmKLHjTrgJcu8gHQIscEDoLccB7SYxCd99hp9TZx5Y3UG+i+XRvjpFlvVRp2T7ook
         H3VmoZP8LSrebkz5OOhrSakj09FQDkSFp4wrkCJX93D53t0MCvNZ6iiMJSYVynU4JphJ
         zaftl8w5qb55FdpzMVSkUgmUi4NjfDSCE6vPt7RE9F8K4aAcLBEerNrQk2lrK7jpQrUT
         3+7ZEfapJdCBsx9LDM3ZmK4rwdH1oOzc4M+jRqHKO3yLB2m8SU4W3TRv/ejORQvPrwFK
         qVA2lfICmpCPyzLVCbN1dz7f5jcjNXPgDoj0BfvBXPe/ZuXe+ABNGzuX5Nedjlz14sOc
         hqTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WBzXR4TZZHkqkMNv1E0xRf3mfUwoTzVNVZHPzzbj8rI=;
        b=cQNerA4ZVPa3YsxDzv7g3Ie+muzZ/cgQSyrZmj7tp4ZysfI7IUmqRQqd/cBjUAGsHH
         feGUEAGEaM1DC6BEVVcatbLddmRyxWjvLVonEFADNLaEFofkameQfv4pePrfUlGf7zVM
         iDaSblAr2zAONRsExcc7OAfelpaWVcOZlgPNk01Itafb327d7s+9KJSlR3YneUMuWW2n
         2dFjtELsO81QJAHsVnA+S5vSi7Kksq2oc7OKm1zZ9eb8mlwZ7Pg8xsSNAy2lksmTGlYs
         FSrtcunpuNpTXw5UMu9QN3qfiL/sUFkOjm/J9AW/it75G5QeQ3vCZym9mGNakq3cILLK
         SHxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KmDmyc9U;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f35sor15881020plh.33.2019.07.02.07.16.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 07:16:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KmDmyc9U;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=WBzXR4TZZHkqkMNv1E0xRf3mfUwoTzVNVZHPzzbj8rI=;
        b=KmDmyc9UgitUSKmQSbKjb9DdUtjBdj+AJcQslWKkw6oK98VNaeJDCKYNJj8Xam/2nb
         q9U5fjB5iElBuHff6OX+alidJnQw5RbNmku59aKFEPCB+P/0rZolEcyYCH+1Ert5OfM2
         Xarbe5OEYveIN0ypbc+SAgTrgp9/wO6FCTkr5xOcYmm/gje8u/ya7qWqqX2vkkP1LZPV
         prGXdZQ0qj250aBKWIAPwh8LOBHtsv5H+KaxEO/9MciMvlqE9ZJXBz+4Kd+xVGj0PDm3
         kKVW1Wi0E9CO2PYp7DnGZ9EY2A0l4TeMBvxsHmgBqzWm3wz0Qv/U6RPyHUSVPjADVlY/
         y5/Q==
X-Google-Smtp-Source: APXvYqwWEAKTT6dyFXv7dzOsiRMsExc4YRB82MDVaOFpGFRbH99CZs+/cOLzM+zyEfvt2oTwz2Gisg==
X-Received: by 2002:a17:902:f204:: with SMTP id gn4mr35901637plb.3.1562076979826;
        Tue, 02 Jul 2019 07:16:19 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:648:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id a5sm744617pjv.21.2019.07.02.07.16.10
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 02 Jul 2019 07:16:19 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org,
	peterz@infradead.org,
	urezki@gmail.com
Cc: rpenyaev@suse.de,
	mhocko@suse.com,
	guro@fb.com,
	aryabinin@virtuozzo.com,
	rppt@linux.ibm.com,
	mingo@kernel.org,
	rick.p.edgecombe@intel.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v2 2/5] mm/vmalloc.c: Introduce a wrapper function of insert_vmap_area_augment()
Date: Tue,  2 Jul 2019 22:15:38 +0800
Message-Id: <20190702141541.12635-3-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190702141541.12635-1-lpf.vector@gmail.com>
References: <20190702141541.12635-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The red-black tree whose root is free_vmap_area_root is called the
*FREE* tree. Like the previous commit, add wrapper functions
insert_va_to_free_tree and rename insert_vmap_area_augment to
__insert_vmap_area_augment.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/vmalloc.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0a46be76c63b..a5065fcb74d3 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -658,7 +658,7 @@ insert_va_to_busy_tree(struct vmap_area *va)
 }
 
 static void
-insert_vmap_area_augment(struct vmap_area *va,
+__insert_vmap_area_augment(struct vmap_area *va,
 	struct rb_node *from, struct rb_root *root,
 	struct list_head *head)
 {
@@ -674,6 +674,13 @@ insert_vmap_area_augment(struct vmap_area *va,
 	augment_tree_propagate_from(va);
 }
 
+static __always_inline void
+insert_va_to_free_tree(struct vmap_area *va, struct rb_node *from)
+{
+	__insert_vmap_area_augment(va, from, &free_vmap_area_root,
+				&free_vmap_area_list);
+}
+
 /*
  * Merge de-allocated chunk of VA memory with previous
  * and next free blocks. If coalesce is not done a new
@@ -979,8 +986,7 @@ adjust_va_to_fit_type(struct vmap_area *va,
 		augment_tree_propagate_from(va);
 
 		if (lva)	/* type == NE_FIT_TYPE */
-			insert_vmap_area_augment(lva, &va->rb_node,
-				&free_vmap_area_root, &free_vmap_area_list);
+			insert_va_to_free_tree(lva, &va->rb_node);
 	}
 
 	return 0;
@@ -1822,9 +1828,7 @@ static void vmap_init_free_space(void)
 				free->va_start = vmap_start;
 				free->va_end = busy->va_start;
 
-				insert_vmap_area_augment(free, NULL,
-					&free_vmap_area_root,
-						&free_vmap_area_list);
+				insert_va_to_free_tree(free, NULL);
 			}
 		}
 
@@ -1837,9 +1841,7 @@ static void vmap_init_free_space(void)
 			free->va_start = vmap_start;
 			free->va_end = vmap_end;
 
-			insert_vmap_area_augment(free, NULL,
-				&free_vmap_area_root,
-					&free_vmap_area_list);
+			insert_va_to_free_tree(free, NULL);
 		}
 	}
 }
-- 
2.21.0

