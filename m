Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65066C76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 09:20:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16CBE21850
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 09:20:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16CBE21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C69F6B0005; Fri, 19 Jul 2019 05:20:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94F396B0008; Fri, 19 Jul 2019 05:20:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C75B8E0001; Fri, 19 Jul 2019 05:20:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 565486B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 05:20:47 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id j81so25691614qke.23
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 02:20:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Dz7pFoV07eaWiuf1Xt5dT9h3rw4q7yHN9PlNVvFfdyI=;
        b=pC5u/yTuOxISJFvM4ykSgrzydZu79AM7XBT/sEVP0PaFC+J/bp3zzkoP5oVmsd5zAI
         QQujjl4LQKkIgI7jtpspW4gVBMKNa4vVcCLGykySqzG6Tk5xvUAQpkCY4+B66DCDXhrn
         iFHLcwKMDAVQynqJpntawJL1AyjbsfVyqtKf5dUBEYCrpjUFEA+whVshdhOgE0Y4tmDV
         G6KellgZiDF2ch6X1uufabCUMpPUF19CXC/DcGsC1WtIkCTzdHRgnkQX5RsHfjSuCQPN
         /G1dpzFhCICjQmRm3CUsd1KXZGvXzwCVf6gKRX+VJTVy5X4GViX2+7m4saVkpDUrR2RT
         YBXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVvkGmzfSioJGeM8oT0N1e6a5YPF74AmX80vMITHk1S2kG4hD33
	34TjmL/A1EtkXPn4lyFPtCGd83FaoEi9uKrL8dp63TKCR4nPbToLttqXIGb9Ro/7dF7+46hlg0x
	SqN6EWsuH5Ct5aspKMFFMiH86/BcOk6IVDBK92dpImnu+suBmN8LLNFUJeerw35VogA==
X-Received: by 2002:ac8:688:: with SMTP id f8mr27608719qth.130.1563528047077;
        Fri, 19 Jul 2019 02:20:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJKWyuj0wKvh0WaIQvRmeY0m2UIYYBsr3ANZJ4R1g/VsFueoaQfOM00rOJRZkbM29EkN9V
X-Received: by 2002:ac8:688:: with SMTP id f8mr27608693qth.130.1563528046467;
        Fri, 19 Jul 2019 02:20:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563528046; cv=none;
        d=google.com; s=arc-20160816;
        b=nFl1lbOUimXs2pJ3fN4fG6wr1vsVbPwlTl8gQND4AkHqtpyCToFXTHeg9cR5v4/w8q
         gzZeU8wyeDTO3zjmp47NIFgRUmX/9F1lMjolS63uxGE6Mj4MPkpJNMu4Pz5s6DDy/VV5
         PIZUI0QGvOoZBGcLAC+AeMhbrL8Z3eqpSPDBk2UuvlflCIF7NXnnmcH4GiDPWp9KD6Lt
         9xWs6DpNs3ElsUMByV61mJ9wQNci8fMmGTDnJF4RkReqTL8ucLpMGJ5JnScwnIWURstQ
         mkCm8kcyrSpGsev/7+ZxtZkHtSba+9LHYMWdHckt9dJftlagL46SvvN/OdJuvrXWkIqJ
         esWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Dz7pFoV07eaWiuf1Xt5dT9h3rw4q7yHN9PlNVvFfdyI=;
        b=a9tUwVGkIP9rXaubCCdL7zlIGy7INBOXqO789QSaZso6ho/a3L9Vu/OIXYf0FTzrg9
         RibeigAiL5U57fdUiJzXTfzWBBD4oSj/oH6bjC/bpWmU2Yei7Xzk4sxO4q9DG+e3fahw
         wuyu/2FWn4dWTjft6epoQ7WqRwG5M5WsQ5wxd/fsXAse1DVQDeFvzG+aPbEkmXLPkc0M
         /JGI/jsysMA9QfLDw5XjapdThWao+M9xzquqH6Kc3FqwdTWzWiMHhATB4nT026/qS07B
         eTtN0ctwD8IbzZAxMpG0TECxQC3w33YcGbosWr0CPEmS4cA8XVaxexUDZWWtOzfKFzyU
         UGJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r18si20330910qtr.225.2019.07.19.02.20.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 02:20:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A6EA330860CF;
	Fri, 19 Jul 2019 09:20:45 +0000 (UTC)
Received: from [10.36.117.221] (ovpn-117-221.ams2.redhat.com [10.36.117.221])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CDB3D5D970;
	Fri, 19 Jul 2019 09:20:43 +0000 (UTC)
Subject: Re: [PATCH v1] drivers/base/node.c: Simplify
 unregister_memory_block_under_nodes()
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Oscar Salvador <osalvador@suse.de>
References: <20190718142239.7205-1-david@redhat.com>
 <20190719084239.GO30461@dhcp22.suse.cz>
 <eff19965-f280-6124-8fc5-56e3101f67cb@redhat.com>
 <20190719091313.GR30461@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <48ea1d5d-ce40-aaad-b9fe-006488ed71dc@redhat.com>
Date: Fri, 19 Jul 2019 11:20:43 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190719091313.GR30461@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Fri, 19 Jul 2019 09:20:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19.07.19 11:13, Michal Hocko wrote:
> On Fri 19-07-19 11:05:51, David Hildenbrand wrote:
>> On 19.07.19 10:42, Michal Hocko wrote:
>>> On Thu 18-07-19 16:22:39, David Hildenbrand wrote:
>>>> We don't allow to offline memory block devices that belong to multiple
>>>> numa nodes. Therefore, such devices can never get removed. It is
>>>> sufficient to process a single node when removing the memory block.
>>>>
>>>> Remember for each memory block if it belongs to no, a single, or mixed
>>>> nodes, so we can use that information to skip unregistering or print a
>>>> warning (essentially a safety net to catch BUGs).
>>>
>>> I do not really like NUMA_NO_NODE - 1 thing. This is yet another invalid
>>> node that is magic. Why should we even care? In other words why is this
>>> patch an improvement?
>>
>> Oh, and to answer that part of the question:
>>
>> We no longer have to iterate over each pfn of a memory block to be removed.
> 
> Is it possible that we are overzealous when unregistering syfs files and
> we should simply skip the pfn walk even without this change?
> 

I assume you mean something like v1 without the warning/"NUMA_NO_NODE -1"?

See what I have right now below.


From 27e9b02146e5fbe8edac49767693fa18c9b204dd Mon Sep 17 00:00:00 2001
From: David Hildenbrand <david@redhat.com>
Date: Thu, 18 Jul 2019 15:48:41 +0200
Subject: [PATCH v2] drivers/base/node.c: Simplify
 unregister_memory_block_under_nodes()

We don't allow to offline memory block devices that belong to multiple
numa nodes. Therefore, such devices can never get removed. It is
sufficient to process a single node when removing the memory block.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c |  1 +
 drivers/base/node.c   | 39 +++++++++++++++------------------------
 2 files changed, 16 insertions(+), 24 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 20c39d1bcef8..154d5d4a0779 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -674,6 +674,7 @@ static int init_memory_block(struct memory_block **memory,
 	mem->state = state;
 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
 	mem->phys_device = arch_get_memory_phys_device(start_pfn);
+	mem->nid = NUMA_NO_NODE;
 
 	ret = register_memory(mem);
 
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 75b7e6f6535b..840c95baa1d8 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -759,8 +759,6 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
 	int ret, nid = *(int *)arg;
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
 
-	mem_blk->nid = nid;
-
 	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
 	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
 	sect_end_pfn += PAGES_PER_SECTION - 1;
@@ -789,6 +787,13 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
 			if (page_nid != nid)
 				continue;
 		}
+
+		/*
+		 * If this memory block spans multiple nodes, we only indicate
+		 * the last processed node.
+		 */
+		mem_blk->nid = nid;
+
 		ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
 					&mem_blk->dev.kobj,
 					kobject_name(&mem_blk->dev.kobj));
@@ -804,32 +809,18 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
 }
 
 /*
- * Unregister memory block device under all nodes that it spans.
- * Has to be called with mem_sysfs_mutex held (due to unlinked_nodes).
+ * Unregister a memory block device under the node it spans. Memory blocks
+ * with multiple nodes cannot be offlined and therefore also never be removed.
  */
 void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 {
-	unsigned long pfn, sect_start_pfn, sect_end_pfn;
-	static nodemask_t unlinked_nodes;
-
-	nodes_clear(unlinked_nodes);
-	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
-	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
-	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
-		int nid;
+	if (mem_blk->nid == NUMA_NO_NODE)
+		return;
 
-		nid = get_nid_for_pfn(pfn);
-		if (nid < 0)
-			continue;
-		if (!node_online(nid))
-			continue;
-		if (node_test_and_set(nid, unlinked_nodes))
-			continue;
-		sysfs_remove_link(&node_devices[nid]->dev.kobj,
-			 kobject_name(&mem_blk->dev.kobj));
-		sysfs_remove_link(&mem_blk->dev.kobj,
-			 kobject_name(&node_devices[nid]->dev.kobj));
-	}
+	sysfs_remove_link(&node_devices[mem_blk->nid]->dev.kobj,
+			  kobject_name(&mem_blk->dev.kobj));
+	sysfs_remove_link(&mem_blk->dev.kobj,
+			  kobject_name(&node_devices[mem_blk->nid]->dev.kobj));
 }
 
 int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn)
-- 
2.21.0


-- 

Thanks,

David / dhildenb

