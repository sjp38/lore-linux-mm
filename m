Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7C4DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:02:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD26F20830
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:02:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD26F20830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50C276B0007; Tue, 26 Mar 2019 05:02:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 493F66B0008; Tue, 26 Mar 2019 05:02:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30F216B000A; Tue, 26 Mar 2019 05:02:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1421D6B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:02:40 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x18so10980733qkf.8
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:02:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Rfq/KbollvLqK27V6rSdLsQNZwc1B0hDiuqQQN782C0=;
        b=h6s4BQNiHEHAO4ecTbDPRocZ0WVYv3BwXLCjosbbWCoVnPU4XdNTIht7Kvyf3V7xmG
         XaPFpn84z8929oXDGooYzqUpf+4ZmvOSck4pe7GSr/kEXlw3ed3QGQyLQVbdW+m7H4ka
         zFUSzKc4zfw5m0NlKLrPy5kK3MUEcu9P0o/uoYIy9uE+jWU6ay/Qo+qhIxF9rlmITH3e
         bY+iuSyJS0kd6nsAgDt9bofR179V5cnZUJtoHMKyEoS7cx2rGQmQgE4Uy2wib2c+Kk2U
         Uy+OZ1fBtQnKwQsv6V0QqUBbsru/YivgDaQPi+hJckL/mzzCXAXWxnzUJT4WgivdQn3J
         ZCqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWE4pH0YWqpGpVT0n/O9X3liR0NpaNGIxvGKnq9oNdCLRwJZlIY
	kM3RrpMB3FVVWLi6t69sUwc/AufU7Tf+egeCdwqUdq8HYU+TV+b9k+Oi2NZpWMDtUcJHVm/EVuL
	jzWP/jylWWcx8FcUxpiIxSS+3XlrBdIMLLNaxiMrX/YF4MAM66raWLdKaeFjI6kGmeQ==
X-Received: by 2002:aed:2497:: with SMTP id t23mr24005593qtc.359.1553590959858;
        Tue, 26 Mar 2019 02:02:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztpDwPzS70socAOVAlkQOWCKY59qNBn/etmf82LVeiixjZd0IwPA+ghTk2w3loV6DvYueO
X-Received: by 2002:aed:2497:: with SMTP id t23mr24005561qtc.359.1553590959237;
        Tue, 26 Mar 2019 02:02:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553590959; cv=none;
        d=google.com; s=arc-20160816;
        b=C9A1ai8nJq8p+rWs0Ns1niq1yA7umxXAjjY6zBmxUbTML11PRfWmavSw5tMpCvQjrm
         6py4yRYFTllK7NYMwGYKS4hci6406xDTbHfznOU4qDbaW0jSzUKXrtq8hH55b1z4LXu1
         PSycB/TvFwPe21WL2YT03LQI8xF93+AENz7EEiVB6DmRkhWm2xSGAz94ANjA3P+JufxQ
         wMEkrnHkd05NbHVO8QEaabiVfZhmZcd8OzqWrp97/KaeQNDVIiDSOdGGE6cKi9MSL78p
         AizrUQ5xmEo3s559KSa7dxMUAFDqO94W3Z9O1+oiaagi1y/71cOUTr7HkrFZ3WNxBt7S
         jlGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Rfq/KbollvLqK27V6rSdLsQNZwc1B0hDiuqQQN782C0=;
        b=oMLNuZUKlSCiO8GWSc0IguUiHpvtohcgMCinHN11cVtYChKIn+9pr9RibhCB3zL7xa
         VTyO1QOG6GLwbVKUy3oU+4YMWfBXVxz94tqVF/Q6t3jsublm2xQu4tGEa+Ld2WDdnobP
         CAou5O1Z0VxPc3XAdjtwZUtc2I9HfyG7WsVv34UIpXpb9IEhxqUbeJ9j5vatrnJBo/fS
         /ktWxsKz55E9PlNHBsXvYhodd6/pvOx8UViwATGxsjZoGnBRCRNC1aPIThJf1/vQo2e9
         AEtVs/yNX3MxcYqeuZBjHmlsU8tSCDKt39EDJOuiuXpUx/64PUz7CfAJXusaugdn7AGL
         Ehag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h3si3139738qth.218.2019.03.26.02.02.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:02:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5D80230C1C07;
	Tue, 26 Mar 2019 09:02:38 +0000 (UTC)
Received: from MiWiFi-R3L-srv.redhat.com (ovpn-12-21.pek2.redhat.com [10.72.12.21])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 42B0C8387B;
	Tue, 26 Mar 2019 09:02:34 +0000 (UTC)
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	rppt@linux.ibm.com,
	osalvador@suse.de,
	willy@infradead.org,
	william.kucharski@oracle.com,
	Baoquan He <bhe@redhat.com>
Subject: [PATCH v2 1/4] mm/sparse: Clean up the obsolete code comment
Date: Tue, 26 Mar 2019 17:02:24 +0800
Message-Id: <20190326090227.3059-2-bhe@redhat.com>
In-Reply-To: <20190326090227.3059-1-bhe@redhat.com>
References: <20190326090227.3059-1-bhe@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 26 Mar 2019 09:02:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The code comment above sparse_add_one_section() is obsolete and
incorrect, clean it up and write new one.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
v1-v2:
  Add comments to explain what the returned value means for
  each error code.

 mm/sparse.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 69904aa6165b..b2111f996aa6 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -685,9 +685,18 @@ static void free_map_bootmem(struct page *memmap)
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
 /*
- * returns the number of sections whose mem_maps were properly
- * set.  If this is <=0, then that means that the passed-in
- * map was not consumed and must be freed.
+ * sparse_add_one_section - add a memory section
+ * @nid: The node to add section on
+ * @start_pfn: start pfn of the memory range
+ * @altmap: device page map
+ *
+ * This is only intended for hotplug.
+ *
+ * Returns:
+ *   0 on success.
+ *   Other error code on failure:
+ *     - -EEXIST - section has been present.
+ *     - -ENOMEM - out of memory.
  */
 int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 				     struct vmem_altmap *altmap)
-- 
2.17.2

