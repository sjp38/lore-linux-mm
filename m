Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D52BC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:58:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2367020820
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:58:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2367020820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9717D6B0005; Mon, 24 Jun 2019 09:58:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9220B8E0003; Mon, 24 Jun 2019 09:58:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8375E8E0002; Mon, 24 Jun 2019 09:58:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8606B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:58:25 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x3so9449657pgp.8
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 06:58:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version:sender
         :precedence:list-id:archived-at:list-archive:list-post
         :content-transfer-encoding;
        bh=gHrfALAmp5FICAUXFQJUtk0BIUdTr9zCt+NIkrBhRgA=;
        b=VQ4wg3v+uTe0ycawJKVMamukvsuOEXXoF/+5nG0R0QLZn0WQ5p/U0V4MnXTwOmK7KA
         sgcx8Xu7nOcrDf+5sHC6gvUo9V5tXq23Mu4itLJPnpD5zcqDiqyMsDYGo7it7SHhii8v
         a4E5oJ08lUjX+p6jas2hbnkjFZ6vyfFl4+hC1nMoNXkWRRV0BP3gu9ZDSO90BpBWIovH
         Nd9X4DskRyYnZFEv1P4TP8mcfAL9lxU1rE0rIFiqdt4Y9lMoaG67pwcuWwB5mqzHYkU1
         fhyt+6oarQ7AsYbYMUNDncTKPRUSAVR+tGO3ArjfADasekNPJfk74jHZILzUNAiJXKeW
         s34w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAW6FNStNg9GYE9Hgo1Ep/2d/ee1Jzw4mwnmXU96GQB9IAfYabzK
	YcFQjjABCZS/9WTPxUGDciR/oZDL2Ec+0YQ/vVf02ichzFA2fJUG0LTjWcVpWq8UNta9QkXmnI5
	VGAL1smrdD67o0GuDUdnAvjX35+BBw0XddGDKVtkMCVApJNcsJb5EXx4KIgf/dP0sfw==
X-Received: by 2002:a17:902:5a4c:: with SMTP id f12mr68789458plm.332.1561384704925;
        Mon, 24 Jun 2019 06:58:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoGwQGI1OmewcrD77SgmXFPN6RuPZUJj1PsG8mNeuo3grKQDooNtFi0zWN02Yr84fATHeM
X-Received: by 2002:a17:902:5a4c:: with SMTP id f12mr68789371plm.332.1561384703913;
        Mon, 24 Jun 2019 06:58:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561384703; cv=none;
        d=google.com; s=arc-20160816;
        b=h1abu1jL0KyM1kEb/alh528BbhiuygUAu98o3qHL3O/jaOcrOUkiuSkBRNW3SBXgCB
         2oEbVfmUiVR8fS6+7SVQjGOryDaaGyz6suSf6ld9iMKnrpbppvleuDnsagLTTx4eE/8E
         lLuvy/xIEfaS3JzqLjJW5SeZHp+inJmpRz23EuICjcZly3nyeozMIok4YWmpdQlkaNQu
         mhixMprUdK2cM58m95eULPsS/tLuRJe6/uTYko5iRvuhYMyy+OBDUvBgYlBI8mYGH4FC
         LYwR6bgGv9rnpvPx6Azyw1i8Rskq3sLTDNs/DawAQOLZscNzbHzTlwfYGtALyD2EPhGZ
         YKfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:precedence:sender:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=gHrfALAmp5FICAUXFQJUtk0BIUdTr9zCt+NIkrBhRgA=;
        b=0I8lgyuSWnHbznfMINFS4cZOL2K4/hBySPOaAncHtUCm4CpNgaRgt7omsuDXrtGSUp
         jEWVGR3yD0FLo39SqSRCERRyBrmpBATQQesrGYXt0LA3nloiNs1sQ9r1Ho0+BxOjOJPd
         uAad5eXV3/4WaQatT5qVJzY5rntga37ZjCm+nV5dO0DIMvYmTgd8JyOLsBNg4bEbq7/v
         dFRHn1DJr64lD4NSYkJSSoKSkZpuJz3bK95aMZ/7JFX1toJMQmJrzAT2X+HUdHlvxpkG
         1M4DbpiNni0/sC+fiaN8Y9e0S2THJXjEzSgdgRBBgosuYbrnohPE/VlIW9XM56RFP3Y1
         +unQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-164.sinamail.sina.com.cn (mail3-164.sinamail.sina.com.cn. [202.108.3.164])
        by mx.google.com with SMTP id k3si10688588pjt.85.2019.06.24.06.58.23
        for <linux-mm@kvack.org>;
        Mon, 24 Jun 2019 06:58:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) client-ip=202.108.3.164;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([114.246.226.133])
	by sina.com with ESMTP
	id 5D10D6FB000007A5; Mon, 24 Jun 2019 21:58:20 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 968200394746
From: Hillf Danton <hdanton@sina.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com,
	peterz@infradead.org,
	oleg@redhat.com,
	rostedt@goodmis.org,
	kernel-team@fb.com,
	william.kucharski@oracle.com
Subject: Re: [PATCH v6 6/6] uprobe: collapse THP pmd after removing all uprobes
Date: Mon, 24 Jun 2019 21:58:10 +0800
Message-Id: <20190623054829.4018117-7-songliubraving@fb.com>
In-Reply-To: <20190623054829.4018117-1-songliubraving@fb.com>
References: <20190623054829.4018117-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-23_04:,, signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=728 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000 definitions=main-1906230050
X-FB-Internal: deliver
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/20190623054829.4018117-7-songliubraving@fb.com/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190624135810.1WihIgcH-2N9m6E702XV30ZnDoe2hk7yi-jytf1-aRQ@z>


Hello

On Sat, 22 Jun 2019 22:48:29 -0700 Song Liu wrote:
>After all uprobes are removed from the huge page (with PTE pgtable), it
>is possible to collapse the pmd and benefit from THP again. This patch
>does the collapse by setting AS_COLLAPSE_PMD. khugepage would retrace
>the page table.
>
>A check for vma->anon_vma is removed from retract_page_tables(). The
>check was initially marked as "probably overkill". The code works well
>without the check.
>
>An issue on earlier version was discovered by kbuild test robot.
>
>Reported-by: kbuild test robot <lkp@intel.com>
>Signed-off-by: Song Liu <songliubraving@fb.com>
>---
> kernel/events/uprobes.c | 6 +++++-
> mm/khugepaged.c         | 3 ---
> 2 files changed, 5 insertions(+), 4 deletions(-)
>
>diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
>index a20d7b43a056..418382259f61 100644
>--- a/kernel/events/uprobes.c
>+++ b/kernel/events/uprobes.c
>@@ -474,6 +474,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
> 	struct page *old_page, *new_page;
> 	struct vm_area_struct *vma;
> 	int ret, is_register, ref_ctr_updated = 0;
>+	struct page *orig_page = NULL;
> 
> 	is_register = is_swbp_insn(&opcode);
> 	uprobe = container_of(auprobe, struct uprobe, arch);
>@@ -512,7 +513,6 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
> 	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
> 
> 	if (!is_register) {
>-		struct page *orig_page;
> 		pgoff_t index;
> 
> 		index = vaddr_to_offset(vma, vaddr & PAGE_MASK) >> PAGE_SHIFT;
>@@ -540,6 +540,10 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
> 	if (ret && is_register && ref_ctr_updated)
> 		update_ref_ctr(uprobe, mm, -1);
> 
>+	if (!ret && orig_page && PageTransCompound(orig_page))
>+		set_bit(AS_COLLAPSE_PMD,
>+			&compound_head(orig_page)->mapping->flags);
>+
orig_page may be invalid if it is not identical to new_page for instance.

> 	return ret;
> }
> 
>diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>index 9b980327fd9b..2e277a2d731f 100644
>--- a/mm/khugepaged.c
>+++ b/mm/khugepaged.c
>@@ -1302,9 +1302,6 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff,
> 
> 	i_mmap_lock_write(mapping);
> 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
>-		/* probably overkill */
>-		if (vma->anon_vma)
>-			continue;
> 		addr = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
> 		if (addr & ~HPAGE_PMD_MASK)
> 			continue;
>-- 
>2.17.1
>
>
Hillf

