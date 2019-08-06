Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EFBCC0650F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 02:32:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBFA72147A
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 02:32:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBFA72147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49CD46B0003; Mon,  5 Aug 2019 22:32:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44D696B0005; Mon,  5 Aug 2019 22:32:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33CA56B0006; Mon,  5 Aug 2019 22:32:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id F07C16B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 22:32:07 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 21so54825139pfu.9
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 19:32:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=IENhd9oHOmXMmgeMAoF/njM9H/dCoUuEPXf+2wU0+yU=;
        b=hAAV7OSda2uSvYsnk/E+MOk/rlehMs9QxfIWeQ5I4Vxcy5+U/wsYO75nEANLdGie+G
         by9hhauj4j0nfpO3xaeaLMvWt0FkglGsF2rDH66DxU0fjlgmvA7glz0hhPg2Q3CJ/bsC
         ww3GDSwDYC8XKj0V/Z/AEMCQqKEyyhtz2lsea4xzcCyVMMfvmvqZswIvC1ZJwvI5P1K7
         ufp8KvUe6cfkz9GA8Q4n0vyYl8IHuCe1CyCeeRklx2u2BG1QZaLxwBFxcWriZyD4CD1M
         ormqan2sGG7b7YjzP+Xcp9FwhPiz2qEd+/HTWxM67DmvDU09U5WnUCKTWOmtor1QvqED
         hl8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wangkefeng.wang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=wangkefeng.wang@huawei.com
X-Gm-Message-State: APjAAAW8AHmKrqGyrPU8pGq0eS7BwThw4A2tn9ZblF1AvMXIv+EXUftF
	sidz1banCVuioYYxMrEqwfAY4vyYc8iwkcPz2zvzfrn3h8uAAeBwSWDDvOZQ2gR2RVCvMkMzp0J
	RqJeJE33/MBdfBM0h1cCoSwqVDy2S2TIQasGuwOJWTT8zLBvmBwFEzEseXS9AwX3GbA==
X-Received: by 2002:aa7:8dd2:: with SMTP id j18mr1173718pfr.88.1565058727588;
        Mon, 05 Aug 2019 19:32:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCrDfhF2rgyn0YWKKjXb8TzlfXc6ZHvq0NYGT4xRVrGC8nhNdsET76w2mhp/YwfHvmGVM9
X-Received: by 2002:aa7:8dd2:: with SMTP id j18mr1173662pfr.88.1565058726776;
        Mon, 05 Aug 2019 19:32:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565058726; cv=none;
        d=google.com; s=arc-20160816;
        b=ppwkyP0eFncpi1lTZk2t+KGaTX9P1/7ndy/b83x5AhGoaVnH1Nht8XvPJJCdD8HJkQ
         EaqzUvrvrAdOI4IztS08WHkGM8/BnOnTPGLTLKwjXWhfwT7OiFM0UgKzkvJw8aF5L2+6
         XSCmpDonPAytS1LykwsrVt/eaHOtIDmoWkcxrmmJ/TvF95UXXH4cJPCLOZe7el8fn8Sx
         ggUVfv/pPQ0/FhIHPEGZEsS7/QOOHXbxYbnZCunOjZu9+pNqqPNJOMQgDPJXg1k2Bg98
         7x0QMnrlg7Kyh5EB8f4QAYnPpLNu29T1Hbj+nebycCwD/tgWQxawb0+p5lhMsXesY0I+
         HKhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=IENhd9oHOmXMmgeMAoF/njM9H/dCoUuEPXf+2wU0+yU=;
        b=a2M1ZBLAhd3Hg2xM9EQPMj+CaWs2MozzYVeDS44CUuR5iz5Z5WHFYii8BnVvB3Kb9E
         4DXBzKr5XT0LQfyBk6j4ppHlN2v6fN7kUYktrcfrSndCZ5ZCE/qPcoKsDU1qemSB69xf
         6v2Vwo+d3WqWnUHktEfHwoE+xrYnQus7xaTzDX9d0ddwfgQ40kgfjjT37V45IutGlkQ9
         vucT51ZgpDiXrmUEK7/T2hgVU0lYCkv7v8+cfQ6jI7XoXvyqX1NsOwpvCyiI63M4eAWL
         iwYaMFYouuYXafTFSf/PPpOKB5Cf/DUbVK8Esv8ZvBLuu+G0kymu5M6Ouc6AJ2t3xdvA
         0YEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wangkefeng.wang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=wangkefeng.wang@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id 5si43657749plx.200.2019.08.05.19.32.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 19:32:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of wangkefeng.wang@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wangkefeng.wang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=wangkefeng.wang@huawei.com
Received: from DGGEMS411-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 5BC7D11547BD51E5C9F0;
	Tue,  6 Aug 2019 10:32:05 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS411-HUB.china.huawei.com (10.3.19.211) with Microsoft SMTP Server id
 14.3.439.0; Tue, 6 Aug 2019 10:31:58 +0800
From: Kefeng Wang <wangkefeng.wang@huawei.com>
To: Andrew Morton <akpm@linux-foundation.org>, <linux-kernel@vger.kernel.org>
CC: Kefeng Wang <wangkefeng.wang@huawei.com>, Andrea Arcangeli
	<aarcange@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko
	<mhocko@suse.com>, Oscar Salvador <osalvador@suse.de>, Vlastimil Babka
	<vbabka@suse.cz>, <linux-mm@kvack.org>
Subject: [PATCH] mm/mempolicy.c: Remove unnecessary nodemask check in kernel_migrate_pages()
Date: Tue, 6 Aug 2019 10:36:34 +0800
Message-ID: <20190806023634.55356-1-wangkefeng.wang@huawei.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [10.175.113.25]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

1) task_nodes = cpuset_mems_allowed(current);
   -> cpuset_mems_allowed() guaranteed to return some non-empty
      subset of node_states[N_MEMORY].

2) nodes_and(*new, *new, task_nodes);
   -> after nodes_and(), the 'new' should be empty or appropriate
      nodemask(online node and with memory).

After 1) and 2), we could remove unnecessary check whether the 'new'
AND node_states[N_MEMORY] is empty.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org
Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---

[QUESTION]

SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
                const unsigned long __user *, old_nodes,
                const unsigned long __user *, new_nodes)
{
        return kernel_migrate_pages(pid, maxnode, old_nodes, new_nodes);
}

The migrate_pages() takes pid argument, witch is the ID of the process
whose pages are to be moved. should the cpuset_mems_allowed(current) be
cpuset_mems_allowed(task)?

 mm/mempolicy.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f48693f75b37..fceb44066184 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1467,10 +1467,6 @@ static int kernel_migrate_pages(pid_t pid, unsigned long maxnode,
 	if (nodes_empty(*new))
 		goto out_put;
 
-	nodes_and(*new, *new, node_states[N_MEMORY]);
-	if (nodes_empty(*new))
-		goto out_put;
-
 	err = security_task_movememory(task);
 	if (err)
 		goto out_put;
-- 
2.20.1

