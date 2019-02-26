Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00149C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 09:13:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97EA92173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 09:13:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97EA92173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0B0C8E0003; Tue, 26 Feb 2019 04:13:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D93B28E0001; Tue, 26 Feb 2019 04:13:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C34518E0003; Tue, 26 Feb 2019 04:13:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 67E8A8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:13:40 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i20so5132505edv.21
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:13:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=40aXNnKPO2K5rE4XgLrrm/LGc41r4UtUEgcE62scM/U=;
        b=QRrC0W3z4IeyS9fEXL5fyCQZXtNOr0gUrj+KOq6VojYY0bAcmyGCwLtcMYQ4dMn3gW
         kyB7+sPgn+b9DlB3Nz3fx5US4/tpa7e4DquKyYuZqv6xmxd3lGxG/aMAlS5KMVuwRKB7
         sfchegCT6aVuAc5E794p8kX9ZZGEUVEI0//cq0WNrudOJcSo22P9TbbEJHCDI5EVsW91
         HJaqcFo77Bsj0BGuP9PnwkN6Ga4F9GtOlxJlhW6PVvt7flSHglfuGweyvCm/8DAgkXrU
         8jgHF1lpiowYiNVmEbIc10R4yW+CWXB5HaTiSvKHIiwfCRHJGuT/N0wA/FLo/c0auUIC
         tpsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuasdIj4MP6i36vnr8alO87yAFJTUJWEuACZPP0q9pk0ICOKZU44
	N2xEQ1rWSS+WNud6Cd5hwx0dzuRvKSQWt2cg3YVUu6L/XZ+F7Vc+sLkDLep1pSVtdCM6NT9mtyo
	ogstTIkOETxFY7Bm80eByedtIeFcTqi3oVLklwOizZetzxx5J2kgVeBgWbasKWPNoZw==
X-Received: by 2002:a50:b3ad:: with SMTP id s42mr235039edd.142.1551172419840;
        Tue, 26 Feb 2019 01:13:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZV09ZS4FRP9L2deeEVZfgg/fwyKSKV5wlvaUlMhdh7luCfLP/aHB6Xjyc6jH2awLhmfO2z
X-Received: by 2002:a50:b3ad:: with SMTP id s42mr234979edd.142.1551172418551;
        Tue, 26 Feb 2019 01:13:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551172418; cv=none;
        d=google.com; s=arc-20160816;
        b=r7Twah8w3rHGOG5wErQ2cdoLZezvIVSbN0u+Ttqsa/uuw28urWaj1WNgcOzl4Lje+B
         PxOgPyeBZvzhrXIyIoDOMmjesRxyTV0gFlAWhOYmNU6FmlCRRmlGKRRYPglU8FZdqzeM
         J+jw1/9qywcHrGveMeOUacjMrqwof/jpODjfjS76lKKcNp83EptzWikA7jnQKlsj+JMh
         qseSmM/ERzyMIzKL8CUuMtYzyIGcx03EinJYWRmWRYO9TLqt77CIjolocCY8RTgjSVOt
         W8Upw+34OIc38mV9bO2eam8m8pptfMge9V60VhXLDJvEnyzvzEy2SPN2OCHyX/eRp5Ps
         wNoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=40aXNnKPO2K5rE4XgLrrm/LGc41r4UtUEgcE62scM/U=;
        b=kQW1+kts/jZe0hU0K2ByVgf6CAakTnEo/vwW3Q3eJdn3SqD5Uwir3CXiQtG0+Dc60o
         unFK3CMUGn54MwAytJivdnYGwUNBFLDuHbMG5L1W0EaTcvUW21cv5f6GijLwHXiAIIl2
         /Z2FdWSrlJ8NwLHFRRjmunjFSMnmZlbf8qatqoMPHdXEbkH3WCZdBXrauzpAdzYn1sQS
         pe/13gEZqXfLqDKZgRYx05Jih+FD5lSjXK12Wo56C3pTAFZSUb/u/FAu21uv8WdFXmNw
         iPjCRrb3wfpgCuzsZinHqgl6vD6E/g0PO2eZBSpFMRUb3EfTBuR7tm6jDxhL7j3+ICGI
         65Wg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id g25si137272edy.215.2019.02.26.01.13.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 01:13:38 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 26 Feb 2019 10:13:37 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Tue, 26 Feb 2019 09:13:28 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org,
	hughd@google.com,
	kirill@shutemov.name,
	vbabka@suse.cz,
	joel@joelfernandes.org,
	jglisse@redhat.com,
	yang.shi@linux.alibaba.com,
	mgorman@techsingularity.net,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH] mm,mremap: Bail out earlier in mremap_to under map pressure
Date: Tue, 26 Feb 2019 10:13:14 +0100
Message-Id: <20190226091314.18446-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When using mremap() syscall in addition to MREMAP_FIXED flag,
mremap() calls mremap_to() which does the following:

1) unmaps the destination region where we are going to move the map
2) If the new region is going to be smaller, we unmap the last part
   of the old region

Then, we will eventually call move_vma() to do the actual move.

move_vma() checks whether we are at least 4 maps below max_map_count
before going further, otherwise it bails out with -ENOMEM.
The problem is that we might have already unmapped the vma's in steps
1) and 2), so it is not possible for userspace to figure out the state
of the vma's after it gets -ENOMEM, and it gets tricky for userspace
to clean up properly on error path.

While it is true that we can return -ENOMEM for more reasons
(e.g: see may_expand_vm() or move_page_tables()), I think that we can
avoid this scenario in concret if we check early in mremap_to() if the
operation has high chances to succeed map-wise.

Should not be that the case, we can bail out before we even try to unmap
anything, so we make sure the vma's are left untouched in case we are likely
to be short of maps.

The thumb-rule now is to rely on the worst-scenario case we can have.
That is when both vma's (old region and new region) are going to be split
in 3, so we get two more maps to the ones we already hold (one per each).
If current map count + 2 maps still leads us to 4 maps below the threshold,
we are going to pass the check in move_vma().

Of course, this is not free, as it might generate false positives when it is
true that we are tight map-wise, but the unmap operation can release several
vma's leading us to a good state.

Another approach was also investigated [1], but it may be too much hassle
for what it brings.

[1] https://lore.kernel.org/lkml/20190219155320.tkfkwvqk53tfdojt@d104.suse.de/

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mremap.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/mm/mremap.c b/mm/mremap.c
index 3320616ed93f..e3edef6b7a12 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -516,6 +516,23 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (addr + old_len > new_addr && new_addr + new_len > addr)
 		goto out;
 
+	/*
+	 * move_vma() need us to stay 4 maps below the threshold, otherwise
+	 * it will bail out at the very beginning.
+	 * That is a problem if we have already unmaped the regions here
+	 * (new_addr, and old_addr), because userspace will not know the
+	 * state of the vma's after it gets -ENOMEM.
+	 * So, to avoid such scenario we can pre-compute if the whole
+	 * operation has high chances to success map-wise.
+	 * Worst-scenario case is when both vma's (new_addr and old_addr) get
+	 * split in 3 before unmaping it.
+	 * That means 2 more maps (1 for each) to the ones we already hold.
+	 * Check whether current map count plus 2 still leads us to 4 maps below
+	 * the threshold, otherwise return -ENOMEM here to be more safe.
+	 */
+	if ((mm->map_count + 2) >= sysctl_max_map_count - 3)
+		return -ENOMEM;
+
 	ret = do_munmap(mm, new_addr, new_len, uf_unmap_early);
 	if (ret)
 		goto out;
-- 
2.13.7

