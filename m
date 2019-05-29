Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D32AAC28CC1
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 09:16:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C98120665
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 09:16:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C98120665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E89E6B0010; Wed, 29 May 2019 05:16:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 498676B0266; Wed, 29 May 2019 05:16:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 361776B026A; Wed, 29 May 2019 05:16:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E03B16B0010
	for <linux-mm@kvack.org>; Wed, 29 May 2019 05:16:36 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z5so2484319edz.3
        for <linux-mm@kvack.org>; Wed, 29 May 2019 02:16:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Uhvy+OSflg2PNCXiYNPvnH6BRNLk2GvqTjsi+E6Ajyo=;
        b=Zbj4CgDz0M7llSc8/FMvNbwPPoZ34CIbeZoKeuMgVK1jIGcwqjW2PYNSNZUGFdQyUo
         WqVflovgPVSn0WXNtrBDobZfDyd02/Ffw5El/euwwAZYNIIxi/dgo0tU7xkNZ/G6kfFE
         KPyp5A22dhrYXICcG9v2r2ItrxUMxxDg1Jf3+n+S3IBCcVkxDH/m6Yi5EbchlQtSJOiO
         HK/3jMKOAXARzA0xtpEEBZlUefo/+7M5YlJqBV64jK9B6r5R9A1btefCCIcDQi237UNn
         gjm72vSODGE+OlUQRSJ7LuWZI0DrT7dlC7/M9mUWRLiV3VovI9OFHxl2rKOhRvPTXWtu
         WoDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUnM7R9PQeZimj4S5VATjhYdZ6fGJv0+HcaEfIE0xzkk+LLiWw6
	Df+hUCBD+yV/9NgG87WYjDtMz5BhwLxVYOTKklAHf0G8ikOuD8p2UWzitabTgthyAJbvJHCy7pS
	5QfPAAxWBOPrMD2wdtby1YwwzpYkIiym36z/UgYQBpKER1qRpfokZzAguxIsafCf4jg==
X-Received: by 2002:a17:906:c82e:: with SMTP id dd14mr45411305ejb.133.1559121396342;
        Wed, 29 May 2019 02:16:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBneP1pFXEFq0ar7Wb4lM8EGjaYQcx6ZwNfkvvOmfpbRF2ehQjq8IYxinUErfmYCTc+Mct
X-Received: by 2002:a17:906:c82e:: with SMTP id dd14mr45411253ejb.133.1559121395503;
        Wed, 29 May 2019 02:16:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559121395; cv=none;
        d=google.com; s=arc-20160816;
        b=FRmA7UJLVgwAapFWtEa/VE2xjXqBZXVLmyxqSaAFMSnSjLqtIuMT8nVP1+WSallvQa
         EZ3vQrn8x0EWOp+z6qqYYUjXvFtkoJmcAAw7Ol6f/IJk7MSb5oZ6jr11Qv39VJb78lr3
         TaVvHKbVGyD24OSLEiB0C8rs8yzJtF2VrluLTkAdb/HwQorGIpxbPok8g119IuMRT/MP
         di0e5xGzbnbt67+ET/Bd+5y90RiWnq40mdtYGMkx0UHRGrYHz/wng6eCYUTxqb60IB52
         LS/BbNEWu5HuPL23AacX5FHS7eG8bn1Sw9vaG5+n6vUzORt8RbgXvcSIilVbTCiDJYob
         /HXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Uhvy+OSflg2PNCXiYNPvnH6BRNLk2GvqTjsi+E6Ajyo=;
        b=Od08jQhYDAi/zCgjxYGE6HX3ob51mIusdvGsXV+CcekXXWk84x20YjRXZctqqsqCMo
         nRkBm/+088WsUpisDVuja0x5MqUOH/hT/x9Jc7YMdwB4fy2lV6sUiEx+6iXFXehvK1kH
         VEak9nsuVcmo3nvWKWSW9Tlwspbe64QQkstcHDoSkrx3Ykw9UuVYAzFVltGIf6hU2hPs
         FY+vXQ2WZGfLrtrFGaPbgGzNy+ikD9ACwD8JqObeDPmtZFP9d4dobt1E7XoF2cSWrgQ4
         hk0aI/24rABQ38KuX+15yq3H6BM/xW5R1AlRrdEqLwMUqVgNvmLrQbolVGoo41wU801t
         XTnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w1si5880693eji.251.2019.05.29.02.16.35
        for <linux-mm@kvack.org>;
        Wed, 29 May 2019 02:16:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6E45D15AD;
	Wed, 29 May 2019 02:16:34 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.41.181])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 2E2683F5AF;
	Wed, 29 May 2019 02:16:28 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	catalin.marinas@arm.com,
	will.deacon@arm.com
Cc: mark.rutland@arm.com,
	mhocko@suse.com,
	ira.weiny@intel.com,
	david@redhat.com,
	cai@lca.pw,
	logang@deltatee.com,
	james.morse@arm.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	mgorman@techsingularity.net,
	osalvador@suse.de,
	ard.biesheuvel@arm.com
Subject: [PATCH V5 2/3] arm64/mm: Hold memory hotplug lock while walking for kernel page table dump
Date: Wed, 29 May 2019 14:46:26 +0530
Message-Id: <1559121387-674-3-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
References: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The arm64 page table dump code can race with concurrent modification of the
kernel page tables. When a leaf entries are modified concurrently, the dump
code may log stale or inconsistent information for a VA range, but this is
otherwise not harmful.

When intermediate levels of table are freed, the dump code will continue to
use memory which has been freed and potentially reallocated for another
purpose. In such cases, the dump code may dereference bogus addresses,
leading to a number of potential problems.

Intermediate levels of table may by freed during memory hot-remove,
which will be enabled by a subsequent patch. To avoid racing with
this, take the memory hotplug lock when walking the kernel page table.

Acked-by: David Hildenbrand <david@redhat.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/mm/ptdump_debugfs.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm64/mm/ptdump_debugfs.c b/arch/arm64/mm/ptdump_debugfs.c
index 064163f..80171d1 100644
--- a/arch/arm64/mm/ptdump_debugfs.c
+++ b/arch/arm64/mm/ptdump_debugfs.c
@@ -7,7 +7,10 @@
 static int ptdump_show(struct seq_file *m, void *v)
 {
 	struct ptdump_info *info = m->private;
+
+	get_online_mems();
 	ptdump_walk_pgd(m, info);
+	put_online_mems();
 	return 0;
 }
 DEFINE_SHOW_ATTRIBUTE(ptdump);
-- 
2.7.4

