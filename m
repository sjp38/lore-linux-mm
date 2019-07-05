Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57744C46499
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 04:16:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11B6A21852
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 04:16:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="irbfu9qA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11B6A21852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 975C56B0003; Fri,  5 Jul 2019 00:16:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 924748E0003; Fri,  5 Jul 2019 00:16:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EC4B8E0001; Fri,  5 Jul 2019 00:16:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0056B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 00:16:30 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d6so1020249pls.17
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 21:16:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=DIVzl05bCmHqAQSTOF3kZ/Ym5AufpX9dq9JbDFqM6xA=;
        b=PEtiGeTw/WJHsg07xxMXgt+GhyW9IEtFa37FnCVh7WpGrPsCvtDZDlGBxcaWrPVkb+
         V6fWshGJmnM6wLpuMxJo99EfrN0wYbg6WJrU5Exx8BPiiNxlhOYLhRs7NirJYWlrhMzT
         P4dhhYNj1OmQxbmaUBhJiDuYm1JZmaoslEPWNhP9H8kwkLMJimXwpqNhtnUtX8pcKHE1
         oy2fUF7GFZw6ji8IU8WhXyTI9m/CAc/hv2QK1wR1+uEscGDnUziOzGn+YSHKyH6yMhcc
         VSJBUTL/d+PC90olmVZtzAR69jNkGwxs4JFtbo5rqU6Vt8tNvPguvrmooJK46UD1KG/z
         CgXg==
X-Gm-Message-State: APjAAAXsMCnTxImhXwia5APdETl+sI9LcKAFLjVh11ZlKu+gXOz7kuk6
	w/TDPsuq1NiOz8wHL8G7O3wJYff4GUS/7Fwr5qr1mXx7APMZcgvkri7E2P1SRJwhpVt8K+2BGkX
	9Z39YKfoUPCkp6d0nT7IaXkQ0bOPDzghc+EY3FVCmI6FrHFdFBOqXIryPch8i3WU2yw==
X-Received: by 2002:a63:3ec7:: with SMTP id l190mr2392195pga.334.1562300189753;
        Thu, 04 Jul 2019 21:16:29 -0700 (PDT)
X-Received: by 2002:a63:3ec7:: with SMTP id l190mr2392137pga.334.1562300188726;
        Thu, 04 Jul 2019 21:16:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562300188; cv=none;
        d=google.com; s=arc-20160816;
        b=PeBMi1Zc0Y6fVNRWInEsCAGmNfqA7v+ikY6rJ9nlWn/VEC61QT6KPK0duWrYgBcOZt
         1QZC31NrxSYjSgCo0ECPRMfcdwbYK1bX/QHuir+DgfhdlCL3TlcfPwPxsy8Iubjm1F+F
         i5SKPJurxoJQw1Xfu87NntCVsBhHwt2q7ZajvV6jvLFX1tazsxSaneHqIP9jj36Nri/b
         upla5PlTWHovd3c6kgqgDSoc6kCJOiWPuDcqfa2TnQ0+2D81syNN6qY8cSiTVR+Nf/0Y
         s68HiTlpmD9ko4KiakcNrvvs2kjXmsEs3ex6rNzlKVKLQPbx2JIXk3OepYTQVSSFMeU+
         D+lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=DIVzl05bCmHqAQSTOF3kZ/Ym5AufpX9dq9JbDFqM6xA=;
        b=R4mm/InJbe04rebRN8UDL2YL+91hZMBPR7KY9tQVl/cWknAcA5lPcu6UfLLO+CV4CI
         1SByHZDaOKNnhxg7mHhXqNL4ZVWiqPi7z1ZHdVMWOOE/TnrRh7Is82lzzOQ838Xn+Xht
         qWcz1tNGGcxSF+T9JJLml1Osj+TOR6BZbjZNdRN3bHmWuoXzznTnItkLElEvZVmEIiPG
         0a3lv+qaEqNZr/zL0JUI7SAyn1mrAj64b4FxAOiLrFD9CCe99X463lMNCwJ2/TtU+8/p
         IyNB5J+mrATB0IMiNE3V2gvh3iQadIx03wWRLDxhXHKS8ilRI/pSm39nSIuSWyJN560d
         F/YA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=irbfu9qA;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor8977611plg.68.2019.07.04.21.16.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Jul 2019 21:16:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=irbfu9qA;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=DIVzl05bCmHqAQSTOF3kZ/Ym5AufpX9dq9JbDFqM6xA=;
        b=irbfu9qArbablvA6nbNLTjhMKotjU5R09Zqx9DqYYzjYZz6fd5+MPt/5WZbfkukptH
         ModvZovWGiIEr+b3EIj5ZiICW7ImUrh3nRwJTahq1LWKcCom1ky/dNd/YJtqmVepFxZ8
         7AsjoiTxjhRx2Aj53GHp3t5fLh2hoojsAcpKPqb0LR381CH/haWPEyvmmHBz2cAivW99
         WVXDORQ9Wr97G+nOp9RqBFcimlQK4ne9s+s2+ZgyW2brfU8QICXkVIuoj+gkRZdHXC3l
         ZmGrtQLaXCzMowk6ehabqxUsVefUs7+VLbWuol4DwWq9rU1zsWApq87yWvwdSTmkzzeM
         C6nw==
X-Google-Smtp-Source: APXvYqzI9ZcBsR33Wj69OYxhz8Fl3uU52XOagYXuFn3y1+rHU7l+0to8zenOnZia6VzGeJ1Wmt9bLQ==
X-Received: by 2002:a17:902:f204:: with SMTP id gn4mr2206522plb.3.1562300188420;
        Thu, 04 Jul 2019 21:16:28 -0700 (PDT)
Received: from mylaptop.redhat.com ([2408:8207:7821:9e80:eaf2:5f81:4c66:c3d0])
        by smtp.gmail.com with ESMTPSA id l68sm16328638pjb.8.2019.07.04.21.16.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 21:16:27 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: x86@kernel.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Tony Luck <tony.luck@intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Qian Cai <cai@lca.pw>,
	Barret Rhoden <brho@google.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	David Rientjes <rientjes@google.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/2] x86/numa: carve node online semantics out of alloc_node_data()
Date: Fri,  5 Jul 2019 12:15:42 +0800
Message-Id: <1562300143-11671-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Node online means either memory online or cpu online. But there is
requirement to instance a pglist_data, which has neither cpu nor memory
online (refer to [2/2]).

So carve out the online semantics, and call node_set_online() where either
memory or cpu is online.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Qian Cai <cai@lca.pw>
Cc: Barret Rhoden <brho@google.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 arch/x86/mm/numa.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index e6dad60..b48d507 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -213,8 +213,6 @@ static void __init alloc_node_data(int nid)
 
 	node_data[nid] = nd;
 	memset(NODE_DATA(nid), 0, sizeof(pg_data_t));
-
-	node_set_online(nid);
 }
 
 /**
@@ -589,6 +587,7 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 			continue;
 
 		alloc_node_data(nid);
+		node_set_online(nid);
 	}
 
 	/* Dump memblock with node info and return. */
@@ -760,8 +759,10 @@ void __init init_cpu_to_node(void)
 		if (node == NUMA_NO_NODE)
 			continue;
 
-		if (!node_online(node))
+		if (!node_online(node)) {
 			init_memory_less_node(node);
+			node_set_online(nid);
+		}
 
 		numa_set_node(cpu, node);
 	}
-- 
2.7.5

