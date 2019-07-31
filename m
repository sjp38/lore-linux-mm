Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89140C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 19:32:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BE1C208E4
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 19:32:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BE1C208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE2228E0003; Wed, 31 Jul 2019 15:32:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E924C8E0001; Wed, 31 Jul 2019 15:32:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D81DC8E0003; Wed, 31 Jul 2019 15:32:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id B68A28E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 15:32:48 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id j140so29770614vke.10
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 12:32:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=akSqbXG8PrAr17ckjUsK2m0YgRALGESaXqNJ8c0Dnqo=;
        b=ZY3/2uPNA5bFyxEaCMNce1iysvvE3OspVeLhxPLmIZldM9s+ESmcq/Uwmd5legUOZR
         ntAChwYAGj2oWBbP27S5oUFJXClvBwnNr7SlpWNeyC57PVQJk6s4bhHph81NFSin8V/o
         VhURELNY/P7vNMZuIPdytDQIpsS0UPVRY0rhh9OG5cgKRQWluI2eCk0yskmveJ2zguoM
         g/6IYtaaOQvMunID2jHcq+UGFuh63quosKnrGUUyyHWVHiGgEHm7XcdnUNdIeqHu5ljJ
         p8jAJ42FSu8DvK1D22Wuyj965+YFUWy3Z8bmOHpp6g2coYd5z06MST/jyxnH+blzlHX9
         M+3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUYfhB9Dfgw9W498J4rzmNDtr2h/2vcesI1+pd3o4Ag0UaqVL85
	YJ9g9MEZFxdLE20KZC1SM/QMnQOsiBp89DXjfoqPTIM2YY+2d54Dh77+/3QBfdOxnplqd2qNJpL
	NkxlaPavTp7EzuotDCpQjhikLgfdd8mI1rDY+YMEWsHNyx199U3u6F14h2R06hDwi+w==
X-Received: by 2002:ab0:7618:: with SMTP id o24mr26097343uap.39.1564601568502;
        Wed, 31 Jul 2019 12:32:48 -0700 (PDT)
X-Received: by 2002:ab0:7618:: with SMTP id o24mr26097210uap.39.1564601567249;
        Wed, 31 Jul 2019 12:32:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564601567; cv=none;
        d=google.com; s=arc-20160816;
        b=heYFCCEv7LlCY39TercAjvP1S9VZM0FoyvtCdL5N41oZ2VOWecPXR6SmSB3BCknQwK
         nuJRNF7NgqibNMh/gf/wE+T4oBT3LCwUdMw0r4VBQvC3SW7FyKpK2iWeTNp4uYiJaX4W
         WWP7/rwqUDZwxuq2Yz9o5O0r8SwhuzR+WjWDR9/dOMW9cgSWPAF5RtfVaDa7dEqgJi1G
         +XcR9tcWJQM/iaSVKsH2jyKLjWP0UkafVoruLWtkZmTsBeQCRNX9WAEmguDWUPFJkztX
         sSyKKsV/EOSf9sA4kOf6o3nSTMr1GAWVUIVKkFx/Y2AlenUMjGQ4EU6pDVD2+QM0hmSU
         aN/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=akSqbXG8PrAr17ckjUsK2m0YgRALGESaXqNJ8c0Dnqo=;
        b=WtrnNa9iVrqQUZ/OGCypqklSqpCCM/oqu8tmad1zzVmQF6Cx5Jy6OBelOGyvPZm+rW
         AkrkySxqPrhnHpAxkmehxct48fDe00CFsXU/4KTFxPLEvic+NokjShHVQ8Eld78aBucs
         sSI6syYPup0aLckp4MxFkl+AsRn43tJjaOx8G7lgJczAeEC3YU4AqylIiBGmYbymIwng
         /9fKCPMwDUBi0ofDS+DxRWw7hjvpg8y9Vpw/RDFkKCzNGghmcwi4tFsIMBLAQIfUFXZV
         t9nQY+UrkpgbB25a4v1h0wt+b7Rv1oX6Ptyq+qNdiUBwaHAS3xKqlJzlWkUkjmvin2G8
         x+UA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 2sor34041229uaa.63.2019.07.31.12.32.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 12:32:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqw3uXWgwtwcCw3O9oGG6PWeaJhRIa795B4+dILrq2ZVp25tJCrw7/2+zGbYN3p2a5I+o+Ve+g==
X-Received: by 2002:ab0:4a6:: with SMTP id 35mr12378084uaw.123.1564601566815;
        Wed, 31 Jul 2019 12:32:46 -0700 (PDT)
Received: from labbott-redhat.redhat.com (pool-96-235-39-235.pitbpa.fios.verizon.net. [96.235.39.235])
        by smtp.gmail.com with ESMTPSA id e125sm19292798vsc.28.2019.07.31.12.32.45
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 12:32:46 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
To: Alexander Potapenko <glider@google.com>
Cc: Laura Abbott <labbott@redhat.com>,
	kernel test robot <rong.a.chen@intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Christoph Lameter <cl@linux.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Marco Elver <elver@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	LKP <lkp@01.org>,
	linux-mm@kvack.org
Subject: [PATCH] mm: slub: Fix slab walking for init_on_free
Date: Wed, 31 Jul 2019 15:32:40 -0400
Message-Id: <20190731193240.29477-1-labbott@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <CAG_fn=VBGE=YvkZX0C45qu29zqfvLMP10w_owj4vfFxPcK5iow@mail.gmail.com>
References: 
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To properly clear the slab on free with slab_want_init_on_free,
we walk the list of free objects using get_freepointer/set_freepointer.
The value we get from get_freepointer may not be valid. This
isn't an issue since an actual value will get written later
but this means there's a chance of triggering a bug if we use
this value with set_freepointer:

[    4.478342] kernel BUG at mm/slub.c:306!
[    4.482437] invalid opcode: 0000 [#1] PREEMPT PTI
[    4.485750] CPU: 0 PID: 0 Comm: swapper Not tainted 5.2.0-05754-g6471384a #4
[    4.490635] RIP: 0010:kfree+0x58a/0x5c0
[    4.493679] Code: 48 83 05 78 37 51 02 01 0f 0b 48 83 05 7e 37 51 02 01 48 83 05 7e 37 51 02 01 48 83 05 7e 37 51 02 01 48 83 05 d6 37 51 02 01 <0f> 0b 48 83 05 d4 37 51 02 01 48 83 05 d4 37 51 02 01 48 83 05 d4
[    4.506827] RSP: 0000:ffffffff82603d90 EFLAGS: 00010002
[    4.510475] RAX: ffff8c3976c04320 RBX: ffff8c3976c04300 RCX: 0000000000000000
[    4.515420] RDX: ffff8c3976c04300 RSI: 0000000000000000 RDI: ffff8c3976c04320
[    4.520331] RBP: ffffffff82603db8 R08: 0000000000000000 R09: 0000000000000000
[    4.525288] R10: ffff8c3976c04320 R11: ffffffff8289e1e0 R12: ffffd52cc8db0100
[    4.530180] R13: ffff8c3976c01a00 R14: ffffffff810f10d4 R15: ffff8c3976c04300
[    4.535079] FS:  0000000000000000(0000) GS:ffffffff8266b000(0000) knlGS:0000000000000000
[    4.540628] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    4.544593] CR2: ffff8c397ffff000 CR3: 0000000125020000 CR4: 00000000000406b0
[    4.549558] Call Trace:
[    4.551266]  apply_wqattrs_prepare+0x154/0x280
[    4.554357]  apply_workqueue_attrs_locked+0x4e/0xe0
[    4.557728]  apply_workqueue_attrs+0x36/0x60
[    4.560654]  alloc_workqueue+0x25a/0x6d0
[    4.563381]  ? kmem_cache_alloc_trace+0x1e3/0x500
[    4.566628]  ? __mutex_unlock_slowpath+0x44/0x3f0
[    4.569875]  workqueue_init_early+0x246/0x348
[    4.573025]  start_kernel+0x3c7/0x7ec
[    4.575558]  x86_64_start_reservations+0x40/0x49
[    4.578738]  x86_64_start_kernel+0xda/0xe4
[    4.581600]  secondary_startup_64+0xb6/0xc0
[    4.584473] Modules linked in:
[    4.586620] ---[ end trace f67eb9af4d8d492b ]---

Fix this by ensuring the value we set with set_freepointer is either NULL
or another value in the chain.

Reported-by: kernel test robot <rong.a.chen@intel.com>
Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 mm/slub.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index e6c030e47364..8834563cdb4b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1432,7 +1432,9 @@ static inline bool slab_free_freelist_hook(struct kmem_cache *s,
 	void *old_tail = *tail ? *tail : *head;
 	int rsize;
 
-	if (slab_want_init_on_free(s))
+	if (slab_want_init_on_free(s)) {
+		void *p = NULL;
+
 		do {
 			object = next;
 			next = get_freepointer(s, object);
@@ -1445,8 +1447,10 @@ static inline bool slab_free_freelist_hook(struct kmem_cache *s,
 							   : 0;
 			memset((char *)object + s->inuse, 0,
 			       s->size - s->inuse - rsize);
-			set_freepointer(s, object, next);
+			set_freepointer(s, object, p);
+			p = object;
 		} while (object != old_tail);
+	}
 
 /*
  * Compiler cannot detect this function can be removed if slab_free_hook()
-- 
2.21.0

