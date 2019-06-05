Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61C80C28CC6
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:21:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B11220866
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:21:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uI2GOFin"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B11220866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9917D6B0266; Wed,  5 Jun 2019 17:21:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 942896B0269; Wed,  5 Jun 2019 17:21:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 857346B026A; Wed,  5 Jun 2019 17:21:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 37DE56B0266
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 17:21:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p14so355232edc.4
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 14:21:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DbESKGjaSdEzS+8K4ZZpYJHwCVMJbIIgpVyCBcGmoDA=;
        b=TdNIj7+CzjhLks6IQcnYL0NAZ2Fk1vnh2xjM4yxoll+xEYZ+4aNvqifClpOUpZL6Ik
         cp6pLSHhIWe9mQWNIPQjl6QbDH99A3+qIw1d/XLjzoOIYjMIiAjBhpXVA0Z1Fev96SDg
         WOgMNuHFqyymRHp1oOHmm/h8zn2T4h+wCzDY8oUlC+N+lnoMKiEAhaeAz5BOKZGK1WGo
         X5p0YE/cOTVbF9m0Jofk66lqPy3kG/QeKqfFnU26Xn3Fy7ErAegRiJwaH3mAfV29gCFj
         OYjvRnvmeKI9euowZl4SDd04iTxuBKs3Wma7hhuep45HBfkpKfg85we1lx04RV/Qfvdv
         cgCA==
X-Gm-Message-State: APjAAAVhPFwNXLfwpSU25yPf8OdGSAPZJr4+0B01JL5SszlQdwB5p1US
	FXnQFFSsQ5yEfSmUL8jJVRSApfcleT4HP7miIauVuBvMS74TEbS5BbV2RVneQwnk0GtfABJrPQY
	jMUbASXqq5s2EX0g4RLPYzHcGQUFQbLxFEUxPzDheySntptxKzGD2d7fi6RGbtrpBxQ==
X-Received: by 2002:a50:86b9:: with SMTP id r54mr19101699eda.162.1559769669690;
        Wed, 05 Jun 2019 14:21:09 -0700 (PDT)
X-Received: by 2002:a50:86b9:: with SMTP id r54mr19101662eda.162.1559769668928;
        Wed, 05 Jun 2019 14:21:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559769668; cv=none;
        d=google.com; s=arc-20160816;
        b=wYIjUEWLtp3ADVwN85EOBYTBMtGLKkMPUslQ0UPSHDEWzCahu7jnplL+k9K46n5owi
         JyGordf78UHHIJVPZrA52f/mcZCRdxScc8EzylS2ARz/xonu9RJMJULb8m49e0accHZb
         6J+zvBAwSbhV+A4DQlO9DWlVvqgWxAZIjaCmxuDK0jJiuNbZdZTdjmfoLmDG4vNAgg8n
         4Fbx9AGaH7r40xOsC7wf74VRrzyGli5rDizJ9DPASznW2rFUKFPcw3zK5cSTtRVYI3AQ
         6lpWBETAN27Sthc8Hrx7pULp8sYi3xUpcNepd7nDFYdjBLfMc/S5eAcWXnSPgjh57UCs
         JRZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=DbESKGjaSdEzS+8K4ZZpYJHwCVMJbIIgpVyCBcGmoDA=;
        b=pgDJrFV+KS4XP70V03YgdNLt3usnx5E+/nGM5RhmsSTWX1WEn9HYN+OIGfuOZ6FwQl
         l9VGs0eTAManJQ+bG19I12EKB55OIf4gUE6Z6lKp6MrytCEU1SfisFf/O1TAk5RQ7W+S
         Ifb+QmdeAV9IDed/vJPbu5muve1dDJjxYGsRZoQfq+j+dgWVMI2cimqErkLGrz+l3hrc
         rkQWTFfJsYaBiK92g8aSyqtQSKaHVwT2ZCzo+riiByAiTZq06639IXCvIIKx8HIVOP6V
         C/AIgzud2VMwQt4EfTqnj58unmkoSF72Lf7uMlMZyjTTJmKhQ4oW9cUae4byT1W7qphj
         kXXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uI2GOFin;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b2sor1444697edd.17.2019.06.05.14.21.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 14:21:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uI2GOFin;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DbESKGjaSdEzS+8K4ZZpYJHwCVMJbIIgpVyCBcGmoDA=;
        b=uI2GOFinAV8sZvL+69rPUYkiOvfq/P6RaIvMP/TCLE7Eigu+OsAMxrlQ7M56dpfeaB
         KXnPuGlaLKfjVW4OK022oY9x2O84uuKCnTuTJ2Hy/rU4g60rDzrdLH9+Tx5dD+CSiY7P
         MZd6Gt4WuEMmALvkc+6OxkvqFlyqE8pj0B+RKWqsERmaO6rCiyUFNdAQJaK+bn+j6ZDo
         3+Ozb7/fHxX66bj8rSxIxrArPzuRzb+SpAu32sfxsWnMui2GD+nbp3sZ5ByAMfIb0inB
         TyCDQNWvPlw0yG17KhNWZpYS35pRM3rqQaLlQ7Rzw4ggssD4+ZfqKxNNHceKsI3nMqCT
         +Ubw==
X-Google-Smtp-Source: APXvYqyuNRjvHNzTb2gEE1mIj1supSxm4qc3GPA7ju0Tg73FF069vkjl4Ke6VX7sPJnRrK6BAE1EDw==
X-Received: by 2002:a50:b523:: with SMTP id y32mr38680719edd.209.1559769668613;
        Wed, 05 Jun 2019 14:21:08 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id x19sm3180078edq.9.2019.06.05.14.21.07
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Jun 2019 14:21:07 -0700 (PDT)
Date: Wed, 5 Jun 2019 21:21:06 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Oscar Salvador <osalvador@suse.de>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: Re: [PATCH v3 10/11] mm/memory_hotplug: Make
 unregister_memory_block_under_nodes() never fail
Message-ID: <20190605212106.6folqx2zawbvzzmm@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-11-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-11-david@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 01:11:51PM +0200, David Hildenbrand wrote:
>We really don't want anything during memory hotunplug to fail.
>We always pass a valid memory block device, that check can go. Avoid
>allocating memory and eventually failing. As we are always called under
>lock, we can use a static piece of memory. This avoids having to put
>the structure onto the stack, having to guess about the stack size
>of callers.
>
>Patch inspired by a patch from Oscar Salvador.
>
>In the future, there might be no need to iterate over nodes at all.
>mem->nid should tell us exactly what to remove. Memory block devices
>with mixed nodes (added during boot) should properly fenced off and never
>removed.
>
>Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>Cc: Alex Deucher <alexander.deucher@amd.com>
>Cc: "David S. Miller" <davem@davemloft.net>
>Cc: Mark Brown <broonie@kernel.org>
>Cc: Chris Wilson <chris@chris-wilson.co.uk>
>Cc: David Hildenbrand <david@redhat.com>
>Cc: Oscar Salvador <osalvador@suse.de>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
>Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>

>---
> drivers/base/node.c  | 18 +++++-------------
> include/linux/node.h |  5 ++---
> 2 files changed, 7 insertions(+), 16 deletions(-)
>
>diff --git a/drivers/base/node.c b/drivers/base/node.c
>index 04fdfa99b8bc..9be88fd05147 100644
>--- a/drivers/base/node.c
>+++ b/drivers/base/node.c
>@@ -803,20 +803,14 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
> 
> /*
>  * Unregister memory block device under all nodes that it spans.
>+ * Has to be called with mem_sysfs_mutex held (due to unlinked_nodes).
>  */
>-int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
>+void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
> {
>-	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
> 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
>+	static nodemask_t unlinked_nodes;
> 
>-	if (!mem_blk) {
>-		NODEMASK_FREE(unlinked_nodes);
>-		return -EFAULT;
>-	}
>-	if (!unlinked_nodes)
>-		return -ENOMEM;
>-	nodes_clear(*unlinked_nodes);
>-
>+	nodes_clear(unlinked_nodes);
> 	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
> 	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
> 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
>@@ -827,15 +821,13 @@ int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
> 			continue;
> 		if (!node_online(nid))
> 			continue;
>-		if (node_test_and_set(nid, *unlinked_nodes))
>+		if (node_test_and_set(nid, unlinked_nodes))
> 			continue;
> 		sysfs_remove_link(&node_devices[nid]->dev.kobj,
> 			 kobject_name(&mem_blk->dev.kobj));
> 		sysfs_remove_link(&mem_blk->dev.kobj,
> 			 kobject_name(&node_devices[nid]->dev.kobj));
> 	}
>-	NODEMASK_FREE(unlinked_nodes);
>-	return 0;
> }
> 
> int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn)
>diff --git a/include/linux/node.h b/include/linux/node.h
>index 02a29e71b175..548c226966a2 100644
>--- a/include/linux/node.h
>+++ b/include/linux/node.h
>@@ -139,7 +139,7 @@ extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
> extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
> extern int register_mem_sect_under_node(struct memory_block *mem_blk,
> 						void *arg);
>-extern int unregister_memory_block_under_nodes(struct memory_block *mem_blk);
>+extern void unregister_memory_block_under_nodes(struct memory_block *mem_blk);
> 
> extern int register_memory_node_under_compute_node(unsigned int mem_nid,
> 						   unsigned int cpu_nid,
>@@ -175,9 +175,8 @@ static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
> {
> 	return 0;
> }
>-static inline int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
>+static inline void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
> {
>-	return 0;
> }
> 
> static inline void register_hugetlbfs_with_node(node_registration_func_t reg,
>-- 
>2.20.1

-- 
Wei Yang
Help you, Help me

