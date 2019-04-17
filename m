Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71E6EC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 12:04:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B981206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 12:04:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B981206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D00B06B0003; Wed, 17 Apr 2019 08:04:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAF116B0006; Wed, 17 Apr 2019 08:04:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC5E96B0007; Wed, 17 Apr 2019 08:04:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 85E0B6B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 08:04:08 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z29so9756518edb.4
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 05:04:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=JgTFmCFcOUMdDDKUPS35b9aRva/sOrdMAVuXoP/qXbw=;
        b=Kub6132XIS4JRUGS8ZEglpiRXgQIZAoI5gn+oljnWGjRauUyOwkBY7+gI719HKDYd9
         Lwgic7nuqJvSZ3atfLW0ZRj8eeJ1/ANRagZqdveHR8MHAA5QgW00x1Ykh4MVzhIMsw93
         W+dfj1rDenWILIOJKW1fgW8f3behy8D3qN8EHNOQUYLzwuVDj9SdsF4MCHiD/Q0menlZ
         il/vu9Lgul2hzWyk5c+VFP+zX0Ghbn2pFc5ojIxMKKq/KfUAaim/LlzGCq+Y/0K9qVcb
         Ot9hoOhl4j87dGVt1t4pEYKy+nAwFox9JtAhRbOEdM/SR1NyAMV86icTsSMVZ9tzijeM
         kTNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAVDNTU8X016UjUlUeUouZy65Rvj8AurEJqp96Z/1g12G53lSmJY
	jf5pFWtDbSg/nRXFyt61QZQA9CED+NYufVXMpJAtWDaysyKVFgb4PgmO4PpPdq00OlfbyU8aL9h
	55vXSICK6QPVtKmbedwbXChNMEBDLqu4p0I2PaLTeDjQd0l9Mr28dwUTBpyWMufiN8w==
X-Received: by 2002:a17:906:4ac1:: with SMTP id u1mr46596172ejt.179.1555502647968;
        Wed, 17 Apr 2019 05:04:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqWopKq2yv+SP3kf17HagIYMAn9jfd12diCmdCoSs7T+AobD3GZgLBRVU+vcOfnRb/yVQO
X-Received: by 2002:a17:906:4ac1:: with SMTP id u1mr46596117ejt.179.1555502646950;
        Wed, 17 Apr 2019 05:04:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555502646; cv=none;
        d=google.com; s=arc-20160816;
        b=xVLnh2A8yfMYbD0d+fW5PlO1vp4SafkT1ZVkoWS6qw7u7k5ynJrDzW9oJOObZO74QR
         LdQ+8q5bK7U6KkKZ2F5EIjGN6AaLlr3G8NSZ6W/shKTUJDFJkVF1VH9cM2nT1j19U3pp
         4RXLm7YWtIKzs4aIBQRfkdgPz7N6j8uQDfHkTX+FGGy14A1jypdNW+zd7jrRvCyCwRWF
         FWw716iZK/9xoDgMmMCAGFokrNkuLJkv939xhNWkLellYKxtTAVRc1Owz12KpRBin7mT
         86j8UfXB7IMhcucTXhRSM02L1k4ipMaJL7++KTxhiM9Awq/seFtQ03dHKcA0FF8gW2rL
         LF0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=JgTFmCFcOUMdDDKUPS35b9aRva/sOrdMAVuXoP/qXbw=;
        b=Dxm9UNH66XFyLWsoinYkyf3Vhgta1NQNNTo8GDCLpE362gqZ2fUs79uyoUM8zp6XT6
         zMsnEAe6urg+gCBDvnvy83BjoCm/HPpZ8KcDiL7dYBgXW7jXwExg84lyrobhNE4/zP5i
         8jhfK0yuFhC+udUw3FmPZ55KlfFyz/2spEEeL+yLBp6ALcYrwO/gRq9UxNTsOc9inHen
         3uxj7H5q64OYppx5s8WmoIHWYAyS5pNUKTmBi1mjka/tTZ/2XQ8rMRJ/k9NBQKgUebkR
         sjdeV432bjrYIRXbpKYjhR1VLrluZr2X0MRWTbQPb1z240Je9cpruFc9xY4jY03J3isq
         pSgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b54si457161edc.183.2019.04.17.05.04.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 05:04:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6C816AF8D;
	Wed, 17 Apr 2019 12:04:06 +0000 (UTC)
From: =?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Mateusz Guzik <mguzik@redhat.com>,
	Michal Hocko <mhocko@suse.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Geert Uytterhoeven <geert+renesas@glider.be>,
	Arun KS <arunks@codeaurora.org>,
	Bartosz Golaszewski <brgl@bgdev.pl>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: get_cmdline use arg_lock instead of mmap_sem
Date: Wed, 17 Apr 2019 14:03:47 +0200
Message-Id: <20190417120347.15397-1-mkoutny@suse.com>
X-Mailer: git-send-email 2.16.4
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit a3b609ef9f8b ("proc read mm's {arg,env}_{start,end} with mmap
semaphore taken.") added synchronization of reading argument/environment
boundaries under mmap_sem. Later commit 88aa7cc688d4 ("mm: introduce
arg_lock to protect arg_start|end and env_start|end in mm_struct")
avoided the coarse use of mmap_sem in similar situations.

get_cmdline can also use arg_lock instead of mmap_sem when it reads the
boundaries.

Signed-off-by: Michal Koutný <mkoutny@suse.com>
---
 mm/util.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/util.c b/mm/util.c
index d559bde497a9..568575cceefc 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -758,12 +758,12 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 	if (!mm->arg_end)
 		goto out_mm;	/* Shh! No looking before we're done */
 
-	down_read(&mm->mmap_sem);
+	spin_lock(&mm->arg_lock);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	spin_unlock(&mm->arg_lock);
 
 	len = arg_end - arg_start;
 
-- 
2.16.4

