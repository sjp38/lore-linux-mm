Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CA58C282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 21:22:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32D1220863
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 21:22:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UBdTX9+e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32D1220863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 203686B000E; Sun, 26 May 2019 17:22:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18BB16B0010; Sun, 26 May 2019 17:22:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFA546B0266; Sun, 26 May 2019 17:22:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8B06B000E
	for <linux-mm@kvack.org>; Sun, 26 May 2019 17:22:25 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id y11so2795314ljc.20
        for <linux-mm@kvack.org>; Sun, 26 May 2019 14:22:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=fnFIhfm6w+x6vlcZglDCubHYA2sqJDEBTXH+zDoT54E=;
        b=uARKyR8Ci0MO+NMqzO80D4+9ueGXy0kR629YBnExQG586nbKCT1llvml/ICuravWsZ
         AcoXODg+BEJr2uhz7km89p4Gpd7Ibjj8c8ibTi2CAM7KkAwbVDCpOK49RZ+5FMNhYKKl
         yV7UFJQuBbjJAzc6nR4JRpV92jQykDm5MXzD4ChyUbUpcdKTkJjpYrLYAjKJVJEBxIuF
         bImEEn5V3pHABffdrHQ5WWmjBK7RdYjxvU4pYTp4HjZG7CXRinp7Cw/mkRXaO7VEzBGs
         aNMac0sz2CPl1SKw69ij+3FJYxfOTMmo1M0TCSRyd6/PynC3+sEdyPCxdf90QCZA4K7x
         oRBA==
X-Gm-Message-State: APjAAAXms2GplKK/ikUkIPAjbhOHho8KgL/lL1FB3s5CKN/EaVy8Gnp7
	xUcWmXwqz5iJV2fhndAmCaND7mYIzMpZcOjSXOQwhF7FIaOAXVohG1Tx+cQc80lFwghkfUJ4nuZ
	V4GdBSjo0BzSubk6yd/VYx4bg+F5hNJOpwk1AF/+Ebzmenx+gN3uVpXCNgHOTdOMoug==
X-Received: by 2002:ac2:4312:: with SMTP id l18mr44295218lfh.139.1558905744877;
        Sun, 26 May 2019 14:22:24 -0700 (PDT)
X-Received: by 2002:ac2:4312:: with SMTP id l18mr44295196lfh.139.1558905743892;
        Sun, 26 May 2019 14:22:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558905743; cv=none;
        d=google.com; s=arc-20160816;
        b=kK0YeGRv62JuX6en62LcT3TLfPIzzxJzsdrZDtSzb4D0V3CLKHDg9antwaOt2ZQzoD
         kN7ob6MWxNxEfRs2AZ8mDAHhH49NuPSK7B/afsHrqeILarJDC3D3pT/DsscUq3lA2m+i
         vTC/3BAarjkhh0wd5Ss6dlZkZzN56Ux0mmmpGgsW+cOb3LCgb7JWEP9qOqXH4znclbn9
         5eYRIY8EHiT1u/pQDlOslBKY8UWJMsVh0gFxAK/i9nvaNsJC/dVbElBsM5O+8L0bDPvC
         /A49x+WsPzdjgltbjf6pWDgGpg42YQ1lw3RnE5jxCl+8WcDGjrobzj9jIFEdW5u9rQot
         a0Lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=fnFIhfm6w+x6vlcZglDCubHYA2sqJDEBTXH+zDoT54E=;
        b=btPRty1J47eic7W/Rj/121XMX//zpTfzgU1H4eTJfzU3eWueMbAmMzZ9wfQiCTNMHW
         yuLwaiJZ2uaNgfIj4YMr7heAKzLhLplZpkLXKmJLx/iM0WzHeHqW06zDqJoGRJ7oaqsy
         hgmYWF3KTsY51H6MvF9FxRBcI2+2ojdUa5FEI9hCoXE8qXMoQXlVRRqJOQbSc9Hcgo0v
         hOInEdtNB33CcNi2o/ypnUiC/i+DE0EQt8z9R/7W/B7n44bHDLtLLSU7e2OsCfXaMpjU
         QX+KnVwzj8YwKHy1X2iqz6RvyjgWdFBqHGAmz4QN2fan7FOYpwRutF59/ONv2f43bYaj
         d9zw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UBdTX9+e;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c15sor4168204lji.24.2019.05.26.14.22.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 May 2019 14:22:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UBdTX9+e;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=fnFIhfm6w+x6vlcZglDCubHYA2sqJDEBTXH+zDoT54E=;
        b=UBdTX9+e4FvlHF4JFOYIDGquBW1PRTf6/hoP7Ew9uurKyudFzrNtQsPK+PpY2kJbcz
         RrbaPQyrg87qkICEVv2tBAVhjYD+SMpSdxNurR6cJfHLCn1BtGBQfSdPP9AkBjsdJAfg
         aLzuFtmSM/Yp6QTaZ94jvl3W56Eqf8+1cBNozcS581wGb4CnsbDB+ce8MuQkYEWOHghV
         2WNVzQwZavCHCwYE9pLaKNRczb/qIwTAeNH1O3VcpMY3WFa+yJHRgnyaecSjfbSODT0E
         gmJH9eFilpIPj/xNffX9FYFqVn5/b4fsxxF6OCytbaResF1Q+VfdYOqoeb1a+V4haXP8
         IGOw==
X-Google-Smtp-Source: APXvYqxKcunfWrPxCigO2o6ZR9K3hxrEk96bNlekmsQEeZIMZuGoXyAQXyF5tttat3bj0KboCwbv8g==
X-Received: by 2002:a2e:249:: with SMTP id 70mr56398543ljc.178.1558905743514;
        Sun, 26 May 2019 14:22:23 -0700 (PDT)
Received: from pc636.lan (h5ef52e31.seluork.dyn.perspektivbredband.net. [94.245.46.49])
        by smtp.gmail.com with ESMTPSA id y4sm1885105lje.24.2019.05.26.14.22.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 14:22:22 -0700 (PDT)
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
Subject: [PATCH v2 1/4] mm/vmap: remove "node" argument
Date: Sun, 26 May 2019 23:22:10 +0200
Message-Id: <20190526212213.5944-2-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190526212213.5944-1-urezki@gmail.com>
References: <20190526212213.5944-1-urezki@gmail.com>
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

