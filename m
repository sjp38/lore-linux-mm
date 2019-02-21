Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ADE2C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 01:08:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11DB52084F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 01:08:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="q0w+laaM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11DB52084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 803F88E0052; Wed, 20 Feb 2019 20:08:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DA378E0002; Wed, 20 Feb 2019 20:08:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F1E38E0052; Wed, 20 Feb 2019 20:08:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 414168E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 20:08:56 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 203so4071932qke.7
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:08:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=LgKFH1mGi8c00OC5CaAghfF2/QymbWXD9Kas2gMOlVs=;
        b=tZOps5WFmyP1uaL/wP4/3Iy84eKSZJo99Czb0lDSvH0mIVlVkvlixsm9eP7OzKLa0Y
         bPHEAiB03kVaAcYH3ZLv7SWkGCwROPM4nhNZeE2gRnRRSE2utJmPa0jZJsMwR1XjIkUE
         n4reTSWyNbV2/3H1t+tUkrOzVCyqDWtNio/VPz7iFeBR1WsNkmYYOVAnLA/arWq/79zt
         KZB+QIE4PfJk6OG2Osz4nQQYXCI4nCXoxVnmP7/DASP/Lj42+afqXC44Fru2sRgMw17C
         W5RFtUVLWFzbRIz9GXbHBCodJbq7ndFo2lZ/g35CPGo2JntPNLMXgXRCJsMDQD0+AKEv
         r+uw==
X-Gm-Message-State: AHQUAuaBEENOCv1BuCmh4DKo9sEVi5MQuMpM1D7OKVUqLnGuVg3mY0yJ
	QKZYNPDmnw4HsXK1C/CzBD9c47XFDEcs1J+Kxil4yxVxluj0IzvGove64wESfY0IIOh8kDfBOma
	jyojeRlw5mKBq83R5vzf4Gbo3Y6wZFFc4iOXuvofyHay9Ye+TzfqwvNgXKdJBLzlmjEAfQoY/6H
	xs8l6+MucHmCSvCs3EnAuw3Apl2z2/nu0AFslARL26//0LHhA3bbMGYo5yYVGjssAOOU30Bl57/
	LqYFCSOdpACWNwGgWLFmgpin33Xark5Tq0t1a/tDUhzPCpHrxDW9WgwK+NNkXuCpeYsKqg7O2qq
	pzTRq0vT9Tfo9uFO8MtWhQxhkH85z8E/OOhCImbQfl4IlSrFuznyBCNSoBfpUL9y0PCDVbm4hM7
	C
X-Received: by 2002:ac8:2a7b:: with SMTP id l56mr29820330qtl.270.1550711336009;
        Wed, 20 Feb 2019 17:08:56 -0800 (PST)
X-Received: by 2002:ac8:2a7b:: with SMTP id l56mr29820305qtl.270.1550711335400;
        Wed, 20 Feb 2019 17:08:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550711335; cv=none;
        d=google.com; s=arc-20160816;
        b=gkiaW5w4TMZ4osvavZsXAl4iMiYh4o8n740H4d99K0bFzt5kDU/jA6vDT8q4ydP76F
         hMDko7dSklRRAa3wWpqf4VS3vQjQInPSlXznKkIJ9mmRCCUehcymh25ar1s4jbEzXDFq
         +irVp/gFfLgrXI90wyNqumkswKxROWf++rr0NB1BUOqLWqfcv519SHMQLVScvpxSfuDY
         pJHGF+KSxJxn5Gv4gaAT5KXk2V7l6ceOscpv20uGjoz6hQBmuES/8ym/vUubThpSHGfX
         Odl5n2auxE5sH0JCGfW7WDJGhc2UYnNvKBUY9iYDN2rX/Jh4Pm45iRnBt65Auj93RbeM
         RxIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=LgKFH1mGi8c00OC5CaAghfF2/QymbWXD9Kas2gMOlVs=;
        b=groed3OK2pF9RONUIzl9S85cfhDCvMANvOT5Ne62iaL0lw1eK22xUxEUsQWBgdzgC6
         XtK0/XSj3dwNLRkf8xwCmjuiCNDoFIvuvwyhDdgLzCqIV6+GNGg2Ukn39aWMMpKgAfaU
         xkPF6CEEtlCI5PFBhTz2kl3pJVN16VjoC3ZGBtltQDK8tKCDlwrn4ngwUBBo3PaXB2HN
         zst+kfc03q1QXaY8YRhVLBv6jFdtvSgSnD6Wjyev3yyYTO7U2OhLJ5A+XqREpJUT9B9B
         ZrUb+7/WbY4zBVc4zVPrmtzGdgt6f+AewoN4MhFK64nBtmSWuruJcMdlswGQkYZbQOIZ
         +vTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=q0w+laaM;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h22sor24122921qtc.28.2019.02.20.17.08.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 17:08:55 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=q0w+laaM;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=LgKFH1mGi8c00OC5CaAghfF2/QymbWXD9Kas2gMOlVs=;
        b=q0w+laaMsCEL6A/1PgH9jnG3QJWlLo2ITG/6YD8f0I8tidgiTjb55RhFpOgRi5d4Q/
         eT9p0ByZyVxZfv+gJfoIPxKRY1D3YUzfPd9P0i1XuFuHzN6qL78Y8YB8pTqoJk8sSCFB
         aNJ1VrSsuADQOKM6i0dWqp9tzeIjPUnu4UhZphutYwoL2kCZ5D5Go01kask6o1Qlbm6S
         92c0Np3OLeAvbBn04jFr9TyDxZK0IJ/LoKwIm8IC9Xatgs22GmUb/ZE1Hg2zFESqfxQx
         YjccqC3vaWYYeRe3XaKN2Ix+KtN7e1QU5/sAPaJnh1iUBm1GI/brMx1IMJg9fO1bD+Ry
         ovsw==
X-Google-Smtp-Source: AHgI3IYy3raoHx+Iskr/hYqAnmynUTEF231M3/+3RbDjlKaPoI058zx9Wua90jyIaG1/0a69PKV0dQ==
X-Received: by 2002:ac8:35f8:: with SMTP id l53mr30259475qtb.15.1550711335043;
        Wed, 20 Feb 2019 17:08:55 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id q184sm10504681qkb.23.2019.02.20.17.08.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 17:08:54 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: dave@stgolabs.net,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] mm/debug: use lx% for atomic64_read() on ppc64le
Date: Wed, 20 Feb 2019 20:08:19 -0500
Message-Id: <20190221010819.92039-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

atomic64_read() on ppc64le returns "long int" while "long long" seems on
all other arches, so deal the special case for ppc64le.

In file included from ./include/linux/printk.h:7,
                 from ./include/linux/kernel.h:15,
                 from mm/debug.c:9:
mm/debug.c: In function 'dump_mm':
./include/linux/kern_levels.h:5:18: warning: format '%llx' expects
argument of type 'long long unsigned int', but argument 19 has type
'long int' [-Wformat=]
 #define KERN_SOH "\001"  /* ASCII Start Of Header */
                  ^~~~~~
./include/linux/kern_levels.h:8:20: note: in expansion of macro
'KERN_SOH'
 #define KERN_EMERG KERN_SOH "0" /* system is unusable */
                    ^~~~~~~~
./include/linux/printk.h:297:9: note: in expansion of macro 'KERN_EMERG'
  printk(KERN_EMERG pr_fmt(fmt), ##__VA_ARGS__)
         ^~~~~~~~~~
mm/debug.c:133:2: note: in expansion of macro 'pr_emerg'
  pr_emerg("mm %px mmap %px seqnum %llu task_size %lu\n"
  ^~~~~~~~
mm/debug.c:140:17: note: format string is defined here
   "pinned_vm %llx data_vm %lx exec_vm %lx stack_vm %lx\n"
              ~~~^
              %lx

Fixes: 70f8a3ca68d3 ("mm: make mm->pinned_vm an atomic64 counter")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/debug.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/debug.c b/mm/debug.c
index c0b31b6c3877..e4ec3d68833e 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -137,7 +137,12 @@ void dump_mm(const struct mm_struct *mm)
 		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
 		"pgd %px mm_users %d mm_count %d pgtables_bytes %lu map_count %d\n"
 		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
-		"pinned_vm %llx data_vm %lx exec_vm %lx stack_vm %lx\n"
+#ifdef __powerpc64__
+		"pinned_vm %lx "
+#else
+		"pinned_vm %llx "
+#endif
+		"data_vm %lx exec_vm %lx stack_vm %lx\n"
 		"start_code %lx end_code %lx start_data %lx end_data %lx\n"
 		"start_brk %lx brk %lx start_stack %lx\n"
 		"arg_start %lx arg_end %lx env_start %lx env_end %lx\n"
-- 
2.17.2 (Apple Git-113)

