Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72D8EC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:53:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D0022070C
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:53:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D0022070C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4D0D6B0003; Tue,  6 Aug 2019 03:53:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFC946B0005; Tue,  6 Aug 2019 03:53:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C3426B0006; Tue,  6 Aug 2019 03:53:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 50CBC6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 03:53:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so53228087edc.17
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 00:53:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=dUQpSTRSkme2qCFPs7T/GiUjxsKsRdExsttZXy7UD+Y=;
        b=jbuEDhkv/p+/Dy/MsARuMWRvnQP9JV4nKqP1YhlHNBJL0k7GQzwIU6s/KLMQVp5zvf
         Nu+wND7c5Zx8H/Q0vjtaxBBBPfQFPrAxXAjtKFG2W4ALtL4ho2ghM6MXqnDfuYQYBT19
         rggfDro8LLIcB04zHcPilolmRFZa1oMEdSzJ6nSudJjgs9Zy4D7H8TreXe95cw3w4MGu
         ZwMO6VHlzXqOHnUW0bMPg1Ofn0HHP97+67m/hkkVJ65WqM099lmfH33DtBD8MnGg65/5
         RKgMfDFTkpCHetGpf7wb+Eagtd8K+yVNALSEo1MlWXI9CrC3pExiHU3l8p/DcMhm/kKU
         9dng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUl3LmsiN2b9/KFpndNARNdFy4N6Avz17OjyzP/Kyt5B9YrSDDP
	Tgeo/IpNMyb3I/2VVUmy+yNIUoD/sg+S/HyzR8cl6xGDiD/O8AC2kaFr0b7c0Zp5ZP48EKcHG/q
	0jp9Cz2yHZtTyS1ZfKFIM6UCaMu1bbt1oTrO1o/y6b49LtYbbvFGcm1GaqpJ3LodGQQ==
X-Received: by 2002:aa7:d4cf:: with SMTP id t15mr2384448edr.215.1565078028898;
        Tue, 06 Aug 2019 00:53:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKf/DBggv0oLmTW2F9W1Fb/5r188gAM09Ii+ncn6f44SVmHyBc3thS4QSleARZBgKKtmwe
X-Received: by 2002:aa7:d4cf:: with SMTP id t15mr2384420edr.215.1565078028238;
        Tue, 06 Aug 2019 00:53:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565078028; cv=none;
        d=google.com; s=arc-20160816;
        b=sKxFXwIgXq4Ef70r+QQtmrn6hEcRISYSI3w5qf20Az02xP3Utr6TX1iNepbtYqXE/j
         Lcoe3H+pIon93tpMYjdrixmfOOYnKbfC3Q1irAQvTSwkvs+/ZRvpk3BWKoWqo/Xdf7z4
         fXsnjN3mp3dtA+HYmQEEgYGgNlMibVaRuNBaVItZ6+vNdJhX+yXwUILXfnhnCYs02WBQ
         oDwE/arP1mTfgTxhkNPmEEFTfKYJlGAn28nDn/Wv0cYW8+lK/KRZ7rIumA3iFT/39Swg
         BAyLT8PM2gwS6OFQAU48V1y7VRXOgeshdA8rLAG6xwG4Er3xq/uH/WVm9pPGsDNxIiZ0
         iOzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=dUQpSTRSkme2qCFPs7T/GiUjxsKsRdExsttZXy7UD+Y=;
        b=oWVhUB/Rrm6IBBJjCVX5U3U8u5o27d391NBa+6bv3NPXGjGhUOq/XDR0L/8rZluiEs
         tMxJ0Zydh2piOM94CnDeDnJjw8gWeJCoc7lJqPmli0Kn8mmK60Qzd6NQx3qHy3Kbwg4n
         Quka3HtaAAJSvfclA3AUbCTdulNUrn7XoBXIrUTqihwXSeYgWKjt1iXbFQkll/4fKP77
         CKWqGOw8bZG1Wj6vnPCT7dwCd5f5nG56QXwweViOkXVWqHE8OJ7gL0BW3F66KU/sepDP
         dbhpAYZzV/plqmr5dVGbzG1aLBN0xkv3b+wIXXLTfhseM+LsLa5KCsc4jrzs0v5TESir
         jLRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m44si31340650edc.110.2019.08.06.00.53.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 00:53:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 84A25AD29;
	Tue,  6 Aug 2019 07:53:47 +0000 (UTC)
Subject: Re: [PATCH V2] fork: Improve error message for corrupted page tables
To: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: dave.hansen@intel.com, Ingo Molnar <mingo@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Anshuman Khandual <anshuman.khandual@arm.com>
References: <3ef8a340deb1c87b725d44edb163073e2b6eca5a.1565059496.git.sai.praneeth.prakhya@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5ba88460-cf01-3d53-6d13-45e650b4eacd@suse.cz>
Date: Tue, 6 Aug 2019 09:53:46 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <3ef8a340deb1c87b725d44edb163073e2b6eca5a.1565059496.git.sai.praneeth.prakhya@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/6/19 5:05 AM, Sai Praneeth Prakhya wrote:
> When a user process exits, the kernel cleans up the mm_struct of the user
> process and during cleanup, check_mm() checks the page tables of the user
> process for corruption (E.g: unexpected page flags set/cleared). For
> corrupted page tables, the error message printed by check_mm() isn't very
> clear as it prints the loop index instead of page table type (E.g: Resident
> file mapping pages vs Resident shared memory pages). The loop index in
> check_mm() is used to index rss_stat[] which represents individual memory
> type stats. Hence, instead of printing index, print memory type, thereby
> improving error message.
> 
> Without patch:
> --------------
> [  204.836425] mm/pgtable-generic.c:29: bad p4d 0000000089eb4e92(800000025f941467)
> [  204.836544] BUG: Bad rss-counter state mm:00000000f75895ea idx:0 val:2
> [  204.836615] BUG: Bad rss-counter state mm:00000000f75895ea idx:1 val:5
> [  204.836685] BUG: non-zero pgtables_bytes on freeing mm: 20480
> 
> With patch:
> -----------
> [   69.815453] mm/pgtable-generic.c:29: bad p4d 0000000084653642(800000025ca37467)
> [   69.815872] BUG: Bad rss-counter state mm:00000000014a6c03 type:MM_FILEPAGES val:2
> [   69.815962] BUG: Bad rss-counter state mm:00000000014a6c03 type:MM_ANONPAGES val:5
> [   69.816050] BUG: non-zero pgtables_bytes on freeing mm: 20480
> 
> Also, change print function (from printk(KERN_ALERT, ..) to pr_alert()) so
> that it matches the other print statement.
> 
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
> Acked-by: Dave Hansen <dave.hansen@intel.com>
> Suggested-by: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

I would also add something like this to reduce risk of breaking it in the
future:

----8<----
diff --git a/include/linux/mm_types_task.h b/include/linux/mm_types_task.h
index d7016dcb245e..a6f83cbe4603 100644
--- a/include/linux/mm_types_task.h
+++ b/include/linux/mm_types_task.h
@@ -36,6 +36,9 @@ struct vmacache {
 	struct vm_area_struct *vmas[VMACACHE_SIZE];
 };
 
+/*
+ * When touching this, update also resident_page_types in kernel/fork.c
+ */
 enum {
 	MM_FILEPAGES,	/* Resident file mapping pages */
 	MM_ANONPAGES,	/* Resident anonymous pages */

