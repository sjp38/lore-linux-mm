Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7DF3C04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 09:42:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6760E2082E
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 09:42:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6760E2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A0486B0008; Thu, 16 May 2019 05:42:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18E166B000A; Thu, 16 May 2019 05:42:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02E026B000C; Thu, 16 May 2019 05:42:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id A977D6B0008
	for <linux-mm@kvack.org>; Thu, 16 May 2019 05:42:43 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id w9so571478wmc.5
        for <linux-mm@kvack.org>; Thu, 16 May 2019 02:42:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QVnbcHKCSN58gborHO3ol7EK02u5KFHxun0EUOWl0vk=;
        b=Bz/BLjN0xQ9WFK7e5cH0tUG/xJBdFdiZgWWgWGOY/nv57ZC7XiLAi1vjpW08l3vTYj
         4kt3o72Z1vlpphjRcAmiIBJhIzdhzysXSxoUc0tQ6W4h6qOKnN0HNpdSbInxl1b7rlVZ
         BLVbVVD80rfrmcN1Z8F/gtybSGD9vIoUxArR+43JH0nB9LYHre9jy4CGc8E6n5eKu2D7
         GdTLrTGm02AotxKERfzQBqAkfedkkDEOn+Vn4XtIQrgOAg6CheTTgokGvAdvCr6oqihB
         Z1pZmue53DwwpezBCll+pc/0o9RxnYJucnHZyoI4x5bn5O5porZTAJ/hxJ53eZpwJN1k
         /rCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWi33PMSrjXCe+lpvq8pndpGB6RlTTqls308SvXyRhvQLHvBetL
	W1c7MjbBIkDIIY61v0gSey4qIPrKBnIkUl3XvvXgQzJnbnpVbkuzvqAvqyq2r+Udr+q8F4kLqNV
	0XB77HUz97Y8oNrrlR8e7ZF7IApV2/0VAIvfUkLN5J1jpDdkUnuPBeLaN4T51hqEsFA==
X-Received: by 2002:a1c:6586:: with SMTP id z128mr11441203wmb.67.1557999763221;
        Thu, 16 May 2019 02:42:43 -0700 (PDT)
X-Received: by 2002:a1c:6586:: with SMTP id z128mr11441136wmb.67.1557999762047;
        Thu, 16 May 2019 02:42:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557999762; cv=none;
        d=google.com; s=arc-20160816;
        b=MW05nh/00nuPcYLDsou7bjzvgojnEjkrcwARubgX641ynjYo7X4jl3Fc5c/97eqOyW
         BClABGFvn9oKpix4j4Iv/ixK7uxN1WbqSCUJxkuf5L1ttdcJ4L0HsjGTk4zRxIvEaSGG
         S6XQuMWigBw/IND/pGyimueeBs6EKNxQrresgH+TPIyQoLpeQcNA8cdue/MYRapI6LsM
         jl2cSwAgZHf82/amkpF94MkllJDq04QDBajVUqHH9lrYjp5r8HdEPd03MAYaBMGQWtYY
         LhTd5KqQWSOeewckSd9yZ4YSOzVoMhNNBkRU4E8RGBKuoEUsPDCn8SD7FJDTejD8y9no
         pKpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=QVnbcHKCSN58gborHO3ol7EK02u5KFHxun0EUOWl0vk=;
        b=UvnnCLyJfUsGdrbyZCnqbDYsXpioJBskBIFu2S5nYPj7iZ2dNFbROo0B9qrKo/fEau
         Whc9I6I5qUhQdlEPUogtmLf41UHcWEFZKTmvfcnX7RsM9ZoN5tyNeIEqL78FcMRzXk3l
         kZC5ZWAXjBefJUQhAdpqY1aRfsffFnGMv9viIQN05JPmnRzcif7uDkV7m/HU3Vd9RrLa
         zyrchkSNaoHlbHESpmO7BkLdfTNvlivDXqdcp+fjsIJnDdChpBMySpZyfNN0jPELE3V9
         +OCxbF/bpgyE7lfPgf0R52T5Txnh6v4NbLiPBK6Hf3sWs+ANZ1WZ5zWr9TGn4AZ99wRl
         N3jw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x9sor3862542wrw.47.2019.05.16.02.42.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 02:42:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwl58jVVB/evRftpSSgIkEdQu3pDWBXBnUiYvoeLvTMFHBb+KM6NeJY7cXdaHqSSVbMh3vTNg==
X-Received: by 2002:a5d:6982:: with SMTP id g2mr13708219wru.223.1557999761707;
        Thu, 16 May 2019 02:42:41 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id n63sm4614805wmn.38.2019.05.16.02.42.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 02:42:40 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Hugh Dickins <hughd@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Greg KH <greg@kroah.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: [PATCH RFC 3/5] mm/ksm: introduce ksm_madvise_unmerge() helper
Date: Thu, 16 May 2019 11:42:32 +0200
Message-Id: <20190516094234.9116-4-oleksandr@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190516094234.9116-1-oleksandr@redhat.com>
References: <20190516094234.9116-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Move MADV_UNMERGEABLE part of ksm_madvise() into a dedicated helper
since it will be further used for unmerging VMAs forcibly.

This does not bring any functional changes.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 include/linux/ksm.h |  2 ++
 mm/ksm.c            | 32 ++++++++++++++++++++++----------
 2 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index e824b3141677..a91a7cfc87a1 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -21,6 +21,8 @@ struct mem_cgroup;
 #ifdef CONFIG_KSM
 int ksm_madvise_merge(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long *vm_flags);
+int ksm_madvise_unmerge(struct vm_area_struct *vma, unsigned long start,
+		unsigned long end, unsigned long *vm_flags);
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags);
 int __ksm_enter(struct mm_struct *mm);
diff --git a/mm/ksm.c b/mm/ksm.c
index 1fdcf2fbd58d..e0357e25e09f 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2478,6 +2478,25 @@ int ksm_madvise_merge(struct mm_struct *mm, struct vm_area_struct *vma,
 	return 0;
 }
 
+int ksm_madvise_unmerge(struct vm_area_struct *vma, unsigned long start,
+		unsigned long end, unsigned long *vm_flags)
+{
+	int err;
+
+	if (!(*vm_flags & VM_MERGEABLE))
+		return 0;		/* just ignore the advice */
+
+	if (vma->anon_vma) {
+		err = unmerge_ksm_pages(vma, start, end);
+		if (err)
+			return err;
+	}
+
+	*vm_flags &= ~VM_MERGEABLE;
+
+	return 0;
+}
+
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags)
 {
@@ -2492,16 +2511,9 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		break;
 
 	case MADV_UNMERGEABLE:
-		if (!(*vm_flags & VM_MERGEABLE))
-			return 0;		/* just ignore the advice */
-
-		if (vma->anon_vma) {
-			err = unmerge_ksm_pages(vma, start, end);
-			if (err)
-				return err;
-		}
-
-		*vm_flags &= ~VM_MERGEABLE;
+		err = ksm_madvise_unmerge(vma, start, end, vm_flags);
+		if (err)
+			return err;
 		break;
 	}
 
-- 
2.21.0

