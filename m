Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BD0DC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AD41208CB
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AD41208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CDDE6B02B9; Thu,  6 Jun 2019 16:15:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 231456B02BD; Thu,  6 Jun 2019 16:15:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D37B6B02BE; Thu,  6 Jun 2019 16:15:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C22BE6B02B9
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:42 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d7so2596039pfq.15
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=03A9LmtVlu2jdr4RND01DjQZ3G+si2RYtelfS6jbPdM=;
        b=Ua1I0mrUgKCEhpKiaiFxwEAsLa4b0cSEk7evwDy1LATeOT9nr4sgSe8FSLe5SOkjrl
         9z4MwurCUpyqMBcK2gPJwpk+/E6CMRjij/wgEIiXE3aIUVX/03jyqO6dHs+nwn/xq+Da
         1w62q3iQk2tZR8LFDel/Tip3dBTND8TVSXlkwTOvMfMEOwe+i9ZDOI/P01ulWMuJ7fHN
         YmEDIKbIAFERYYLrRY9pfnjE99J7mVr0bzaTuEvHrz2LXE4hZlgvgCO8IBq8+MStUvCI
         +LVJVHnR0728GJ1/0wmsANdzoRIU9WuKnvg8TrYIMnpxuSPaWlPhHzebMwV4AJSB5TJ8
         wD8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVKztJzc/iljJH32TgKaHYMtIQqGe1M7y8LdcpR6Wat6DRPi6sx
	bqxsuxinjxZSiQW0vrUtRofkcgj9nn/gklQTWzvwOMNv0z4a6vHjmpqhIptF9+ZZniVzAdf3nat
	3dnlM3Z+J6ygwAyjIBYvR3UTELxN8owiHn4zLvYeWx2hmu1bTZ5nPCH7hqah0xVo7gQ==
X-Received: by 2002:a17:90a:ba81:: with SMTP id t1mr1600472pjr.139.1559852142440;
        Thu, 06 Jun 2019 13:15:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwv+Ewhzd+hSGQMrnisB2CGLu9sb2IEzC2RWa3suaipKIs1Z1yj12Vr++Cbu8Jh+MkvFl7
X-Received: by 2002:a17:90a:ba81:: with SMTP id t1mr1600417pjr.139.1559852141740;
        Thu, 06 Jun 2019 13:15:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852141; cv=none;
        d=google.com; s=arc-20160816;
        b=hY9CdFPXwt0AsnYfD5cCwdukaR1PuF9in14UAr/qDBGJUM/LJpUrN2zfLEgV8tF7pr
         HFyerYrmB3rCO21P8kxsT2xQ6Q0/BFnsPNmYErdT+53j486YYZ2SZL3FVd3o5u5JAH16
         PQm25YIYnMpt8LD43LwYUr23sotgzjYSPyFwz4H6gg3fOAsbZ2B266sWu2YSIoJ+iX2a
         c2s3SilRwp9NaaIrE47Sz0KdR0dPpen9NXdB2lE0MrBVN/yg5GF2UyLFp49wUa4IFTd2
         2cQxKOrvzhYG13xAKAGOKgEKL69e0I1xrCN4lxRGc6qQ4BWJzh6Vjv1j1qjTNVpUl7sH
         gv2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=03A9LmtVlu2jdr4RND01DjQZ3G+si2RYtelfS6jbPdM=;
        b=oo9IpXnfZmoWwVa+47QVB+z6QyZwI71aZPOJTP8YD1esp2NCTC9X6Sytq9EsIxz/GO
         CDtx1SaTChH0GvP3Z8aES6O54xjglzQgdqIeb45BqXmVu77M6w3OW332J/bpSo0Z0B24
         KkBOB7eLNjzj+VDcE2YNzcOBxOuroOAIMuw4Jrqicaz0BUVfEAIbQf//x00UVa3YWvak
         od3LVdcCiF30Tu1BDi1vzX7XNkLd6tnKSVMz+V0+w05v8b2I03Hfo2QqbT2sZnEQOlWY
         fyo7EUOsyDV7ksUJ34OuOhnhk5DtpNvVm1ziEGS1lUE7SHSwsRiwIFPqn8PIh7X9uSS0
         /93w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:41 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:40 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v7 25/27] mm/mmap: Add Shadow stack pages to memory accounting
Date: Thu,  6 Jun 2019 13:06:44 -0700
Message-Id: <20190606200646.3951-26-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add shadow stack pages to memory accounting.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 mm/mmap.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index b1a921c0de63..3b643ace2c49 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1703,6 +1703,9 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 	if (file && is_file_hugepages(file))
 		return 0;
 
+	if (arch_copy_pte_mapping(vm_flags))
+		return 1;
+
 	return (vm_flags & (VM_NORESERVE | VM_SHARED | VM_WRITE)) == VM_WRITE;
 }
 
@@ -3319,6 +3322,8 @@ void vm_stat_account(struct mm_struct *mm, vm_flags_t flags, long npages)
 		mm->stack_vm += npages;
 	else if (is_data_mapping(flags))
 		mm->data_vm += npages;
+	else if (arch_copy_pte_mapping(flags))
+		mm->data_vm += npages;
 }
 
 static vm_fault_t special_mapping_fault(struct vm_fault *vmf);
-- 
2.17.1

