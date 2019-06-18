Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1BB7C46477
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:44:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8396120679
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:44:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8396120679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07D808E0005; Tue, 18 Jun 2019 08:44:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02E838E0001; Tue, 18 Jun 2019 08:44:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E87188E0005; Tue, 18 Jun 2019 08:44:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91BF58E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:44:01 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id c190so640581wme.8
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:44:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=IKD/8en+EdSad003MzLsrHFUxGJeE6CL7eT5rxFHS78=;
        b=Bj96k256DMzcb4dVvzIUAyEaVimOD9Cc+hyMvoF3WbEe3MlUUaLn9JOLYw5PotIYYo
         OzLdUgVD6MQkG8Iut/w8jiO0P2pqnc0ElARciZy1Fvxtro2NLX7i+zYamDZvyuLPCj/i
         cLQNAytYdOKVcoJnYwCJHQ/58zYeyuxrAodjSMi78y53hyUE5mihJ94k0aG2NCkDScd4
         br/Teu0rX7b4ELbxD7DE3NimUqaX0wp68go4QPvai2tznkN1AkA81Pr0WkKx9bswopwI
         7zeo8goEhUJZKLnKpwvwlzU9lqj2PCNmE3JrcWPi6C3yZZWQxTdKO5JCidk4VHyQZJDX
         myTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of colin.king@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=colin.king@canonical.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
X-Gm-Message-State: APjAAAV7RLQZSlkNieAcPlq8GdR3wU2VikN4ECMeK6Ngrw4YubjdHC2w
	/zEgJ1KilyCHPq9Cs0D7OZhjhPaKWLaDSPGmrYQCvmwhDmUJdmbTqFgbOfNK0ZQfWEpo70vJy+o
	wkD/t8TLq2LwMcPK5SQMol4WtHvQYH5WauTsv8M+Abj4f//26W67lii8aVPgYc0csug==
X-Received: by 2002:a1c:f314:: with SMTP id q20mr3237661wmq.74.1560861841050;
        Tue, 18 Jun 2019 05:44:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9YfE5CIrO58OFBbIWJgbXQcv7FlfRrR6asAoEHv/OG8Rlx8FCcttEl0MTrIhWUkjJwmSx
X-Received: by 2002:a1c:f314:: with SMTP id q20mr3237589wmq.74.1560861839575;
        Tue, 18 Jun 2019 05:43:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560861839; cv=none;
        d=google.com; s=arc-20160816;
        b=yyRX59GA7o+94QtatLtODITEO3DgngRAPINAi5m2PPKoDhONI0v39ygp4kRSKmS/uf
         g7WIyJxa6Griww61NdOiUvDyW27foJ89HnaXlk4jeb3QzU/0HqY3HUHkuSQbcffSU3Me
         hJhOVoiG/hoQ23LWsC+A+umd7HPaclVLb1vlxHicnSvbJeEV6GzGho6m++aTY2FVZ5N2
         YIW/5UbLi2BGoWROXEmHxec5+JxB8yiW5z4oTr6cDV6ZEqhdcg54jeCQl23aiU5CiQ/U
         TpKGka9UUA90R9ELCu9kds69YckHdf3ZmCYk623xEq9hnbu4tnk1lxkxbvk/6Os9ZWzU
         2V1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=IKD/8en+EdSad003MzLsrHFUxGJeE6CL7eT5rxFHS78=;
        b=LN4RYDCPv65jXCmSv2DqPQdCNKnjVbhkYVTPYYkIpaiA+aTBm2fKSO931Y6ak87jMD
         AyCjTnRqFE9dueqgWOi3nfjTTgALXHUzjh18eLzvfIFP7LqdrT1p+HQeBm5YXyfMv7gT
         +eXJBQ/KMdmFM/h02CRuLdjaqwwkNIxGNeig5BMILGArLIn9indx7SRp5W1vo7+76Ck3
         FIiV8WGdeA40MUTG/8ajNxGtISZWEFrPaEy223A5P+zhSBfgybg/S77v7pCfHEJ1otlK
         7aOTyGLBMbttWM8ILwT2hn6YbD3zYqaVhKl67XAghZUAxgRtE5mlrv15q4tLY874V1n3
         j8Qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of colin.king@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=colin.king@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id z127si1880814wmb.97.2019.06.18.05.43.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Jun 2019 05:43:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of colin.king@canonical.com designates 91.189.89.112 as permitted sender) client-ip=91.189.89.112;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of colin.king@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=colin.king@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from 1.general.cking.uk.vpn ([10.172.193.212] helo=localhost)
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.76)
	(envelope-from <colin.king@canonical.com>)
	id 1hdDSr-000408-4h; Tue, 18 Jun 2019 12:43:53 +0000
From: Colin King <colin.king@canonical.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: idle-page: fix oops because end_pfn is larger than max_pfn
Date: Tue, 18 Jun 2019 13:43:52 +0100
Message-Id: <20190618124352.28307-1-colin.king@canonical.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Colin Ian King <colin.king@canonical.com>

Currently the calcuation of end_pfn can round up the pfn number to
more than the actual maximum number of pfns, causing an Oops. Fix
this by ensuring end_pfn is never more than max_pfn.

This can be easily triggered when on systems where the end_pfn gets
rounded up to more than max_pfn using the idle-page stress-ng
stress test:

sudo stress-ng --idle-page 0

[ 3812.222790] BUG: unable to handle kernel paging request at 00000000000020d8
[ 3812.224341] #PF error: [normal kernel read fault]
[ 3812.225144] PGD 0 P4D 0
[ 3812.225626] Oops: 0000 [#1] SMP PTI
[ 3812.226264] CPU: 1 PID: 11039 Comm: stress-ng-idle- Not tainted 5.0.0-5-generic #6-Ubuntu
[ 3812.227643] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1ubuntu1 04/01/2014
[ 3812.229286] RIP: 0010:page_idle_get_page+0xc8/0x1a0
[ 3812.230173] Code: 0f b1 0a 75 7d 48 8b 03 48 89 c2 48 c1 e8 33 83 e0 07 48 c1 ea 36 48 8d 0c 40 4c 8d 24 88 49 c1 e4 07 4c 03 24 d5 00 89 c3 be <49> 8b 44 24 58 48 8d b8 80 a1 02 00 e8 07 d5 77 00 48 8b 53 08 48
[ 3812.234641] RSP: 0018:ffffafd7c672fde8 EFLAGS: 00010202
[ 3812.235792] RAX: 0000000000000005 RBX: ffffe36341fff700 RCX: 000000000000000f
[ 3812.237739] RDX: 0000000000000284 RSI: 0000000000000275 RDI: 0000000001fff700
[ 3812.239225] RBP: ffffafd7c672fe00 R08: ffffa0bc34056410 R09: 0000000000000276
[ 3812.241027] R10: ffffa0bc754e9b40 R11: ffffa0bc330f6400 R12: 0000000000002080
[ 3812.242555] R13: ffffe36341fff700 R14: 0000000000080000 R15: ffffa0bc330f6400
[ 3812.244073] FS: 00007f0ec1ea5740(0000) GS:ffffa0bc7db00000(0000) knlGS:0000000000000000
[ 3812.245968] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3812.247162] CR2: 00000000000020d8 CR3: 0000000077d68000 CR4: 00000000000006e0
[ 3812.249045] Call Trace:
[ 3812.249625] page_idle_bitmap_write+0x8c/0x140
[ 3812.250567] sysfs_kf_bin_write+0x5c/0x70
[ 3812.251406] kernfs_fop_write+0x12e/0x1b0
[ 3812.252282] __vfs_write+0x1b/0x40
[ 3812.253002] vfs_write+0xab/0x1b0
[ 3812.253941] ksys_write+0x55/0xc0
[ 3812.254660] __x64_sys_write+0x1a/0x20
[ 3812.255446] do_syscall_64+0x5a/0x110
[ 3812.256254] entry_SYSCALL_64_after_hwframe+0x44/0xa9

Fixes: 33c3fc71c8cf ("mm: introduce idle page tracking")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 mm/page_idle.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_idle.c b/mm/page_idle.c
index 0b39ec0c945c..295512465065 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -136,7 +136,7 @@ static ssize_t page_idle_bitmap_read(struct file *file, struct kobject *kobj,
 
 	end_pfn = pfn + count * BITS_PER_BYTE;
 	if (end_pfn > max_pfn)
-		end_pfn = ALIGN(max_pfn, BITMAP_CHUNK_BITS);
+		end_pfn = max_pfn;
 
 	for (; pfn < end_pfn; pfn++) {
 		bit = pfn % BITMAP_CHUNK_BITS;
@@ -181,7 +181,7 @@ static ssize_t page_idle_bitmap_write(struct file *file, struct kobject *kobj,
 
 	end_pfn = pfn + count * BITS_PER_BYTE;
 	if (end_pfn > max_pfn)
-		end_pfn = ALIGN(max_pfn, BITMAP_CHUNK_BITS);
+		end_pfn = max_pfn;
 
 	for (; pfn < end_pfn; pfn++) {
 		bit = pfn % BITMAP_CHUNK_BITS;
-- 
2.20.1

