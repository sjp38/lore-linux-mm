Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51AB3C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:00:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 171502070C
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:00:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TLB7WEzM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 171502070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E7706B0003; Tue,  6 Aug 2019 04:00:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 999586B0005; Tue,  6 Aug 2019 04:00:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8869A6B0006; Tue,  6 Aug 2019 04:00:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2F26B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:00:36 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h5so54451521pgq.23
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:00:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=aV69onuQcwDqEYz62/w3oHFd2R0PARV3h+ba+PwsLJU=;
        b=TimuRRJUKA2h99Qd6s73LRsUSkrbs9oka9Pw0YQWStVRQM9xDzfYsOKgfV3dPNbezu
         3ITUaw6m1gUldo7LnNL+W4pRFmSLQzM2w0fCjo0bN7m32Zi7ELIFBxC4hfU0pDHPdk+u
         XdQr/VodK94sYcVRQ0gKK6DxWL3hw3cYTbuenZ2WnTG+lPoZwf4SY78OxsaVmuhLXMao
         +Ee7kEedQRUmij6F68mgor10RI7cgz94/ESyClWL+NMdLYzxbv6tHA0yoDYnigqVrrxD
         AfgnWXThCpDQr1dFLx+KLWJbItstP3+1tpgNpfznCHbsahzRZrb3d8qxQy1W+FyT5XhQ
         C7lQ==
X-Gm-Message-State: APjAAAVY+JrJKzcwqaMP6NI7OdqLNUe/GSbW32xImgndkx61AkM6cKq8
	nWt4Czf9m2ajdRujeAQN0lCM17RJTmN6Zx6KRPPImqf1rc8NmY8/rmr4getYSl2cmMbJDa+a4wo
	TTpXsJ7fRiF9LD6nAerB7DHpGon9D+iu1Z4LANN4dJaIj6aWUfuPjNe7D0sZmqjgbww==
X-Received: by 2002:a62:1c93:: with SMTP id c141mr2402487pfc.9.1565078435946;
        Tue, 06 Aug 2019 01:00:35 -0700 (PDT)
X-Received: by 2002:a62:1c93:: with SMTP id c141mr2402324pfc.9.1565078434272;
        Tue, 06 Aug 2019 01:00:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565078434; cv=none;
        d=google.com; s=arc-20160816;
        b=hWTwiGZO5f0s3rK8dy2YYFoXbXOOfpT55naYhmgz//Xfhsnl5nmF/lar4+mSpN9/3W
         /FFLHDsubvYd0GE33A04/tnUsTH23uyCUB1PVEvXvClqV0OqlQbOCS0AuvR7XuCFc1l0
         0iEj+fTEuTQJNRJ/YtJpJ4To+BacNiohsMfmw6lohLgrXalA6TlaTFTFutEoWFrlDxI4
         br9kaqEaS9brb6h9n/a8SGfJUIb8wQQSOCphwsgJJumiMrDeB/yOUy8AdGs3Z8UV0Qx+
         ttr00gwIK0yuODrQeyhV3kKoDrA3aQ8AWMtHpEvFRF2rETFgPsBbKfcOweWb9soaCdSg
         Ru7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=aV69onuQcwDqEYz62/w3oHFd2R0PARV3h+ba+PwsLJU=;
        b=VR9VaUDBsk4m4T0bhS2U0e3p/SQjFTXqPG8XBG1OXl+hbaRww+LR3VABkT8jaeXFfb
         i1aEprzahtDDsqZFxOWLrySGK10VXCxMxv4ad4OneU49ZNIKoKLFCK8+sBfz/h2gUOkj
         7a1+WKObxjS3oulKgPs9z09zn49QP8DxIYUTrolkQdltWdBYpCFdZ/Bej3VRL4y/4JYn
         U/jJBs+xSX1yuhR5B/MCB46vdI+WiJgnDkajTprpWlpanSQrxq6AF+29SWeg4Cri7nKA
         zE6lOVsIR9JU6dbvF3ZplUiTFvu/ueRrUHqeLb4yd0xUlRt622a0G53xgwadfDanXZxh
         cUbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TLB7WEzM;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a1sor41470990pfc.63.2019.08.06.01.00.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 01:00:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TLB7WEzM;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=aV69onuQcwDqEYz62/w3oHFd2R0PARV3h+ba+PwsLJU=;
        b=TLB7WEzMV1FG9qsC+tFG0uVO2zJplwy4NMtcXZmIe83n8bPedvYIg0kRV+0BKaC2/W
         qA1bhXaKHBsjod4hTqmfQwF/lUsR277uCh8BUc5BQAE/w4nKQrmd9u5fBIRR3tWkijJN
         P5PrCFxtrlEUtjIManUEPXxHYB6fAs1VwWq1OkSVqmhXQKqSYhkRRd1j5LGp6QOrTvkB
         sGzDPsINgXkaDyPTnVx/qVsPefVhLgtJSuNlRD6IbkGv6hdmE3xmprXG4kWR5dvjsvc6
         Zcxp+1RmUOKxSrb97ji+pRTFedoopdRumI6BPcbOWQ/ZBZwy1O8iwqkQ+sCrr5SwppNd
         dRDA==
X-Google-Smtp-Source: APXvYqzcRDSMRahvNSlA2NE7YehHcCK+DdqZfd9iDDVrttQjMFGM+2BAVpZ47/jY+R7q00gXTs3ESQ==
X-Received: by 2002:a62:be04:: with SMTP id l4mr2260030pff.77.1565078433810;
        Tue, 06 Aug 2019 01:00:33 -0700 (PDT)
Received: from mylaptop.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id p7sm96840679pfp.131.2019.08.06.01.00.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 01:00:33 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Jan Kara <jack@suse.cz>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/3] mm/migrate: clean up useless code in migrate_vma_collect_pmd()
Date: Tue,  6 Aug 2019 16:00:09 +0800
Message-Id: <1565078411-27082-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/migrate.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 8992741..c2ec614 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2230,7 +2230,6 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		if (pte_none(pte)) {
 			mpfn = MIGRATE_PFN_MIGRATE;
 			migrate->cpages++;
-			pfn = 0;
 			goto next;
 		}
 
@@ -2255,7 +2254,6 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			if (is_zero_pfn(pfn)) {
 				mpfn = MIGRATE_PFN_MIGRATE;
 				migrate->cpages++;
-				pfn = 0;
 				goto next;
 			}
 			page = vm_normal_page(migrate->vma, addr, pte);
@@ -2265,10 +2263,9 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 
 		/* FIXME support THP */
 		if (!page || !page->mapping || PageTransCompound(page)) {
-			mpfn = pfn = 0;
+			mpfn = 0;
 			goto next;
 		}
-		pfn = page_to_pfn(page);
 
 		/*
 		 * By getting a reference on the page we pin it and that blocks
-- 
2.7.5

