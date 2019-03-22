Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8844BC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:47:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CF332183E
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:47:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CF332183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7C8C6B0006; Fri, 22 Mar 2019 11:47:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2A236B0007; Fri, 22 Mar 2019 11:47:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D40766B0008; Fri, 22 Mar 2019 11:47:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8280B6B0006
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:47:20 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id t190so707621wmt.8
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 08:47:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IhDNwIOxYiNuMhOLPEts3SuSbShNhJqvzKkXI4ciqCQ=;
        b=iC6KAdOdh6OK05j33eI8/DNcp286XgiSZqzOpI4p1Xa+J5WI/xfzeHqFfnCuWTVd1S
         W4CPPiVAKR2pIUiMRO0hO1cidL9pay/WOO9H7IbKYgWUE/ZxHoS4FeiBFx/LBAVjZWh5
         mT6KF/EjSLhhlmgtabDe9FoTRv9N/vTDd8XxuwKn5GDyFO76wKltLr5sgJvtetg05eqU
         jbmfiOJyzrk8mAPwpNDnxwDEe9pNLeCHz2QTiud64sNVVFvMHvjRNV5YT5X5TMJbFUOt
         bMFHrAIDayxS6N86U9/HWZqWMt2Dyh4Ktixt4WtmseWduf5ErJJJ1dJhjeHB7Hk+CHbk
         UrlA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
X-Gm-Message-State: APjAAAXpAoDDgsrgmdnHZWkg5Uj8Ihy1QRhYYsJzezxTRekzrGc7skai
	nP2wVBIv1AyxEoCrIFeB/8bCXZEZSnLrFWQ7mFZ3wuKdBNvVgo3t5cTJLswVAk7sUskGSaWCFOs
	G9YBUqSAA6wPeyMReUBFJRwOr0rhM1t5rTwWdXFXJjH4RjbUgNyH/R+vkhuC/aJw=
X-Received: by 2002:a5d:4081:: with SMTP id o1mr6711810wrp.241.1553269640021;
        Fri, 22 Mar 2019 08:47:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwo9c7lFHBf5g0MuBpfZIbC2NBGvYCdZPP/NY0vaDoNk6q8UfgUIJimIPzUy/7DL1eDizYT
X-Received: by 2002:a5d:4081:: with SMTP id o1mr6711746wrp.241.1553269638956;
        Fri, 22 Mar 2019 08:47:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553269638; cv=none;
        d=google.com; s=arc-20160816;
        b=mrJCeMaFrvbFGL1K5rtHpJHMGBdOJLnjipihOCzJcMKqRZEz6bO6lQe6haqjUednCw
         J74VcOPF/rm6cJw89guk7VD3TGoxCC00OVSm4dQ8b61qlX9KwhMBxxktaIArDTtXMLDK
         81cg2slaEzpwrL838wbyd/UrmUPelfMc+WiLMDE6S2+UqdGh1OrhzzEF7w4y7QvJu87b
         36EFcm0PIxNEy2ndOnAMxR7aPQpSH6bYJj2h+7NViUHiDjAlE4WaesBpCDksDbjjskEw
         PhdOrujq2xeHXziFsTgSpxHmr7Chw5JJDQZgibFEiXl58EHu7LjKzNIRnvYMWkhVPXYK
         bz2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=IhDNwIOxYiNuMhOLPEts3SuSbShNhJqvzKkXI4ciqCQ=;
        b=Ipg3jSz/s3Y4Vyq0CKChCT41NmAkH9aNwd4eu16Lt6qosDCSXBWLRiIo4X5+7QVpU6
         tnoICQfl0AtcQS09tcPZAWxt9SMY8bdhwuEOIfywF3JUVC0+jC0inr6Krep84aqRpAvk
         RVARSRt7paUW2VbPcHKTt36Abpyi3H74d+WrRpoFlTfR9ApzkqT0XoQXdrSZiambGN9n
         yeezU5IsKs+Qi3u4N9iJ7G8POvdo+Dy0sHzOlsvBcS/C9Fv+VfXWYRFq8shu2PYat5G0
         NkKxJtXsvw0uFJYbGa8t+S07NiqcLhipNrzJap3hYAcYI1sZWcVsXMqDQk0GmuWp30Q1
         pFbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.13])
        by mx.google.com with ESMTPS id t8si5313360wmb.173.2019.03.22.08.47.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 08:47:18 -0700 (PDT)
Received-SPF: neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) client-ip=212.227.17.13;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from wuerfel.lan ([149.172.19.189]) by mrelayeu.kundenserver.de
 (mreue108 [212.227.15.145]) with ESMTPA (Nemesis) id
 1MPosX-1hKuvq2lZj-00Mtqj; Fri, 22 Mar 2019 16:47:13 +0100
From: Arnd Bergmann <arnd@arndb.de>
To: stable@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Vasily Averin <vvs@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [BACKPORT 4.4.y 12/25] mm/rmap: replace BUG_ON(anon_vma->degree) with VM_WARN_ON
Date: Fri, 22 Mar 2019 16:44:03 +0100
Message-Id: <20190322154425.3852517-13-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
In-Reply-To: <20190322154425.3852517-1-arnd@arndb.de>
References: <20190322154425.3852517-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:x9JLVby8r9r7TUxGTqLadFU79q0Pp1coCzkDeRV4r6c3+Dj8drW
 w3wZyzmVLkCOYTZj7d1rl88zJZduSJcyDx7T15j+BD/3ifn1JSCjet7XYnM20CaSy6N1FqD
 7oLYAODBmF5j39idn1uZOpAtb5Pka75NOa5OilzhmcKHyWFj6CykM7EbL/824ma//x/PSon
 oX+qL1Ko/GgJFwkbg64yQ==
X-UI-Out-Filterresults: notjunk:1;V03:K0:Tc+wj3NMZgw=:RU5Wsg8S3mds99gc6a+cXf
 24zk4q6XyhTdtuLlc4ogImJLY4QiG24v/yy09Tl/6LHmXdSKfSSz0YHGE29MfuqrdWegfJOkP
 HARXOKftZgpOMl+c9zVYH0PEzaM8Tif2m3cTj4zkvf1Y2f8q2ma3eHQ+po2nSuoicrIhb9EJS
 lp2Pe4Ws18R1OVojCdmuEoK4o8x/lOCAkOF4stpcg4PpCzti1AzmQ0ZB5dEcPdRAAhN19JqBv
 2qmULxrOYCuIWVcX5tLf5DMlamm5q1llRTPHC2dZkj1fL42dCF8D+NegqIH4gMhOZdqy3dW1l
 KfFLyp6JOnY9vbztmz3bqyshvyqyogXFd8yivOCzuTmQkItbHHziDVXUR72l0yepI5FAHT4wE
 clQHva8klOUopNyxz6rK45XmcYuZXe3BgbEfyVqT8H0F1z+0upYceQcNDsgGo/Pnk0L88JPj/
 Q2M3FiuLkzN2pXg9ZshcAprVQytMU19AeN8vxAbJ0rbeESp42ZovYrdku5j+ozGN2tMGaGUXY
 FOdw5kl+ItdZaAy1Bn1RgeiSc0nKsNTkaxQaYJyyOFfjJnJDqun+X2FYIxzQBKspWyKBjRYZn
 qLA9ma6JXewR4OR+icxH2Dbq/A78inl8+s0rTxu7gP20oapeMz6R5ZkijTrjybWV8mDLCjzUL
 EBDekinZo6eUHBS6RGHjAtXh0h5mDJ6BaWPIBuiDTr2iAAMkUf3mcAXwwLWLggKUf5zWJzuFQ
 BEzDhhnnoHNiCvGc7jkiDMBXH3aSJW+lLtm8aA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

This check effectively catches anon vma hierarchy inconsistence and some
vma corruptions.  It was effective for catching corner cases in anon vma
reusing logic.  For now this code seems stable so check could be hidden
under CONFIG_DEBUG_VM and replaced with WARN because it's not so fatal.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Suggested-by: Vasily Averin <vvs@virtuozzo.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
(cherry picked from commit e4c5800a3991f0c6a766983535dfc10d51802cf6)
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/rmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 488dda209431..cf733fab230f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -408,7 +408,7 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
 	list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma) {
 		struct anon_vma *anon_vma = avc->anon_vma;
 
-		BUG_ON(anon_vma->degree);
+		VM_WARN_ON(anon_vma->degree);
 		put_anon_vma(anon_vma);
 
 		list_del(&avc->same_vma);
-- 
2.20.0

