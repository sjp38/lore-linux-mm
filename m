Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16782C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 09:38:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D24FE2175B
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 09:38:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Tb7K9MML"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D24FE2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04E9A6B0266; Mon, 27 May 2019 05:38:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1C856B026B; Mon, 27 May 2019 05:38:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6E0A6B026C; Mon, 27 May 2019 05:38:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7120C6B0266
	for <linux-mm@kvack.org>; Mon, 27 May 2019 05:38:54 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id 205so3082429ljj.4
        for <linux-mm@kvack.org>; Mon, 27 May 2019 02:38:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=fnFIhfm6w+x6vlcZglDCubHYA2sqJDEBTXH+zDoT54E=;
        b=n8K597XhN2znFW2cdkp1KRLkeESuDMMZ2saC3vgEGvJ3vKbq/gfhjpV7g9+bIxGYMy
         MhzqeD99gIPA1cRBcYGGmIj7VQTMl0jk3VNOxDLLy71dMnm3KhnGnGv4gh8+EyQs5QJe
         iMjOU3dOXQfu34+spBB9EMgEpEPBMZ6KseHolcRRARsXWKA0jjxpsoyGbWSSr11Vg0M0
         2qjooF0DtqhWEU8PW1vcBEt3U2B/r4adh5QOFhE5ViqeXyek0UHSJ6SnGZpYqc0ZxVOL
         Vrts8T34qelNGxwMbP6CzkFfTbNr6+ttZ1mxdAM5LohjrpL8ToQ8HXpw4nDGnigQ20Zr
         umNw==
X-Gm-Message-State: APjAAAXcheU8pgi7qiBfeQx0wATcdRiDAMNKj6uBkB6vDDqJODaqj7G8
	3T176EAYBuJ63kWPX2/q2jPBTv1Y00XSh7SXXyRGFUqNyYQRn47/Q7imY77zvqh3iWUghAP98Du
	8T9SkD1awVtniw3pjnUBFfytDPn6dYzr/oyBXO88uCNQWXJC7dEJqnJAOKLJzDk7/lw==
X-Received: by 2002:a2e:864e:: with SMTP id i14mr28798430ljj.141.1558949933928;
        Mon, 27 May 2019 02:38:53 -0700 (PDT)
X-Received: by 2002:a2e:864e:: with SMTP id i14mr28798383ljj.141.1558949932983;
        Mon, 27 May 2019 02:38:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558949932; cv=none;
        d=google.com; s=arc-20160816;
        b=tDK7EWRhp+CKOuBfheO3tVtE9151wsdksjFtnWB3U7vFQeRw+SWXJi2k94oym1Fs/f
         l8jZpSIk9pLv5Yfg/dnr00UzUoIAohYTosuA8T+fmGmaImwx1cs3QylQRJJ/W4UNKzBz
         neIbeK79v/21t/W6PQ93QNhF37JbZrgyX24ydXPZ2twj9+rgrKDvbmXVIw1O362AthrP
         CIAp3O8fTZKAxILETQuxzosccQDGh3PAkX4g179tVpvXMJYRbq9+Sshm5rvPHqLtB66q
         Xeb8vk4MFK1vqeYvidG8EaKf8BsymLVY99GUb0EHYt3djuJNwclwCNoaDnpkts+9YDTg
         7v8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=fnFIhfm6w+x6vlcZglDCubHYA2sqJDEBTXH+zDoT54E=;
        b=LRWvnccZD9LssBc7jBN6PjXO7erHWBVqnaalhau6Jdrc0QX2ePMcg33JRdnqGfy7pW
         cbVy/3vy9+RJl3bo2brCMv3R5XnYquCGxt0o2sBcZ5F8+WOnobGG2ToA5/87RTP+rGQ2
         eRCSQbVCKXnIpWn/U6/Hu/N3LsSiI3JCH1njW/WnbBl3HRRwsJ01F53PVnpX7D4DDqeb
         bTy79QWfAKd1hv+rxmtl4ekh3zQYcBCrgCcxPv5UKhUVBDq1DNbDN0cB1s8XmRbBEF3V
         yd94zTUTfxyW2Zp/HCSGjLcLORXSE9tnDp4uLMHjlT4cUlHoonakrnt43cLQKXs9YezZ
         yMxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Tb7K9MML;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c11sor4974656lja.9.2019.05.27.02.38.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 02:38:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Tb7K9MML;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=fnFIhfm6w+x6vlcZglDCubHYA2sqJDEBTXH+zDoT54E=;
        b=Tb7K9MMLxMfT8Ruf4WhPnYDIGjoQlIJuk2rE0mwfrdgOa/ztIWbsgQRI00S7Iejm44
         hO7Bn46pPdR249Rmcc1jZDG2trMR8cqjlK4Kv2xTAQqcJQQ82aP1b10pZZFz+CDc9qLj
         cfkr89AF+OJ6LHZd+GGhpFaEUIWiZVM4F3jXQlnztnDKPVcwLVyKw/7LYsO7FrOhnC1Y
         qYGeXOx6TkhbMI3bbxrw337HiydFA0nJ/+KrDcd6M7/w1gfyW0hw1SrPBC5bz5k9BJXx
         XRyhT06BSCeU8Jp0OAn+AU1ZNGNNX7c2oxxAz3E7mtf8G7P+cYWz44gNM+/OOh5Tw/u3
         Hf9A==
X-Google-Smtp-Source: APXvYqxqDucO+QSLHcUPvlIGziovBalve+hsDNrpg9l8JvuiiZP9nKTlMH0Z+oGIvB6vfIb/4Pv8Aw==
X-Received: by 2002:a2e:8850:: with SMTP id z16mr16840496ljj.69.1558949932592;
        Mon, 27 May 2019 02:38:52 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id z26sm2176293lfg.31.2019.05.27.02.38.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 02:38:51 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH v3 1/4] mm/vmap: remove "node" argument
Date: Mon, 27 May 2019 11:38:39 +0200
Message-Id: <20190527093842.10701-2-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190527093842.10701-1-urezki@gmail.com>
References: <20190527093842.10701-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Remove unused argument from the __alloc_vmap_area() function.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index c42872ed82ac..ea1b65fac599 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -985,7 +985,7 @@ adjust_va_to_fit_type(struct vmap_area *va,
  */
 static __always_inline unsigned long
 __alloc_vmap_area(unsigned long size, unsigned long align,
-	unsigned long vstart, unsigned long vend, int node)
+	unsigned long vstart, unsigned long vend)
 {
 	unsigned long nva_start_addr;
 	struct vmap_area *va;
@@ -1062,7 +1062,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	 * If an allocation fails, the "vend" address is
 	 * returned. Therefore trigger the overflow path.
 	 */
-	addr = __alloc_vmap_area(size, align, vstart, vend, node);
+	addr = __alloc_vmap_area(size, align, vstart, vend);
 	if (unlikely(addr == vend))
 		goto overflow;
 
-- 
2.11.0

