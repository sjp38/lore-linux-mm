Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B0DAC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:21:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 304E526312
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:21:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="XiAlvrxQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 304E526312
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D78526B027F; Thu, 30 May 2019 19:21:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D28F66B0280; Thu, 30 May 2019 19:21:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C17056B0281; Thu, 30 May 2019 19:21:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D6556B027F
	for <linux-mm@kvack.org>; Thu, 30 May 2019 19:21:22 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id w6so5918043ybp.19
        for <linux-mm@kvack.org>; Thu, 30 May 2019 16:21:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=QhD5O+DXskHMvk5bCSbNvo+3TeENBCiNBwQHbm3XDKA=;
        b=cJRSFSM62LfdBAPUT3NGHtEhQ8+1FySWdl3SjUesIgU/l0xWI56deapTczUQk/RXau
         OdyP9YKY8kmoM/+SRKuXqkhQ3PZ5YMyk3iXhYPdGZxn+Ku4p43Ub1S5PMGgEVnq5kEZn
         saYrjnOg2XZkDEdTuI9M+yX33IKgMv3/zBF4ksX4uJr4tkAOxw2rEoaYmlfWjNjIit5v
         gvjUSMxFlQ223Cz6+Z+OcpNEIahF130xLcv9pW/u08q0ht06zkAaTPEV4WN31xfvsFRk
         NiiwN8lgxtSzNkvh2xlPs6+SAWGllhsPpAIFQVOcAodLih1i5VBkQ97tkJXjDXwVSCI8
         OFoQ==
X-Gm-Message-State: APjAAAW0lNE2lBOI/u2XgyddBSYlnrJNEwPqWsuWSObTFJXQdR6h5bNX
	jGEvS3cntIJZmwi2nv+WrgYbqmj/3a5WNmEykNrS+uu2JtnOOOyq+WiJluDcXZel6Qgh5C0i9jM
	QKOA1Zzb3KusXKi/+gSsPmnjLuX53/JSXfBADal67ubkL2C/AAFvsMLy/5sdc1LkmKg==
X-Received: by 2002:a81:4709:: with SMTP id u9mr3557445ywa.39.1559258482283;
        Thu, 30 May 2019 16:21:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQlq0E75Y2KSVlVFAvMX4IigdBK4uben26DeG+Pjqxg8InRv9O8I5/1Hbwk1HWRlAcz+iN
X-Received: by 2002:a81:4709:: with SMTP id u9mr3557429ywa.39.1559258481607;
        Thu, 30 May 2019 16:21:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559258481; cv=none;
        d=google.com; s=arc-20160816;
        b=O6+o6+n9aLcwxn9Ebar/YBh4RI/7ltgOalQRNO6eeRDOsId6AjpNIc3yXWSuoGGjaI
         rwuwAtlz5NrWGk67uMglZN2esnSpekbJYJEoFVqbXUPrM/zTuHXM1TRuBUn9JJbbfh1q
         cOV25KHOdifXLRF20ukZv/Plov0F/vQAVrdrrcMlGTT1y4eH4ihYDFiLIOOHUB0mjUgt
         y9//lVwSNj6tcGkRqQKfaEwuHFp+yhpPBbSEzUQw+Baw2tFQUxDyHQrYHJxXlNHbWDjK
         bh10tmnyZxxc3Qlh+v0egLoDcUhOQYbYEVt8GZOZV0nqg84IaXAY2DGcQzpDUGHQlSf3
         L5Zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=QhD5O+DXskHMvk5bCSbNvo+3TeENBCiNBwQHbm3XDKA=;
        b=Ot7gGtv9idKIVjsz8v9q/5H6w524U2vE3nfBQZY4F5o5HuVxVS2PCaoJP2WmE/NTb7
         kk/hkQmmsuvH17P2I2RrlYyvdzThBb8M2EV1ZcTzYZxQyPojOvUC4t7t0R/z0o95PU39
         CmbdcUHzSn/UZ+Pje57eSI54aA3aX7ULiKwGnmRFCUsDJvG4+w0rLx+hzUpzs2mBbtVj
         a3qQAzEcowFelAxz9oof0BLUw9XDAINEGCFqcy5pCHapYl/2Slx27R22loKFJTWaDz+p
         1k59VGBXCRCY9CM8nYPEGHxttRTfn8V4F0tkJvIlSYLzcFlrLCq4Cy9YVwWPd0mpDwpo
         ADlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=XiAlvrxQ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 126si1327357ybq.10.2019.05.30.16.21.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 16:21:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=XiAlvrxQ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf0656f0000>; Thu, 30 May 2019 16:21:19 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 30 May 2019 16:21:20 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 30 May 2019 16:21:20 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 30 May
 2019 23:21:19 +0000
Subject: Re: [PATCH] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
To: Ira Weiny <ira.weiny@intel.com>, Pingfan Liu <kernelfans@gmail.com>
CC: <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mike
 Rapoport <rppt@linux.ibm.com>, Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Aneesh Kumar K.V
	<aneesh.kumar@linux.ibm.com>, Keith Busch <keith.busch@intel.com>,
	<linux-kernel@vger.kernel.org>
References: <1559170444-3304-1-git-send-email-kernelfans@gmail.com>
 <20190530214726.GA14000@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <1497636a-8658-d3ff-f7cd-05230fdead19@nvidia.com>
Date: Thu, 30 May 2019 16:21:19 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190530214726.GA14000@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559258480; bh=QhD5O+DXskHMvk5bCSbNvo+3TeENBCiNBwQHbm3XDKA=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=XiAlvrxQMbOM4ctL1paRuyrwrfNDjIvPv7YOz+g2l5YnbUB9x0KNsYyTY1HfvYFSF
	 yBtV6cth8iJifwd7zlMXe73i9be+V9eO3nWlEA9iMgbXkbKvlgFrkidWZ9cJeGaN7r
	 I9wbcXt0uaPJGuZ2NEwS678W1Vrlpi1pCFOZzOjSrkMtXA7dlsm4RN18QJaFV1Ia2F
	 VNhrXiCP9q4b/gl89V17PN3FXaSJgSZjrvBkvzMjK3wnEUyOzzrnYmtb/qNpczYywl
	 CWbiigFdnV9y0tsKvBKbqikIcppyd4EdwDOzMj800aJadNysiw9FJayKfJwHmOqlMK
	 irQf8rDCTzQwQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/30/19 2:47 PM, Ira Weiny wrote:
> On Thu, May 30, 2019 at 06:54:04AM +0800, Pingfan Liu wrote:
[...]
>> +				for (j = i; j < nr; j++)
>> +					put_page(pages[j]);
> 
> Should be put_user_page() now.  For now that just calls put_page() but it is
> slated to change soon.
> 
> I also wonder if this would be more efficient as a check as we are walking the
> page tables and bail early.
> 
> Perhaps the code complexity is not worth it?

Good point, it might be worth it. Because now we've got two loops that
we run, after the interrupts-off page walk, and it's starting to look like
a potential performance concern. 

> 
>> +				nr = i;
> 
> Why not just break from the loop here?
> 
> Or better yet just use 'i' in the inner loop...
> 

...but if you do end up putting in the after-the-fact check, then we can
go one or two steps further in cleaning it up, by:

    * hiding the visible #ifdef that was slicing up gup_fast,

    * using put_user_pages() instead of either put_page or put_user_page,
      thus getting rid of j entirely, and

    * renaming an ancient minor confusion: nr --> nr_pinned), 

we could have this, which is looks cleaner and still does the same thing:

diff --git a/mm/gup.c b/mm/gup.c
index f173fcbaf1b2..0c1f36be1863 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1486,6 +1486,33 @@ static __always_inline long __gup_longterm_locked(struct task_struct *tsk,
 }
 #endif /* CONFIG_FS_DAX || CONFIG_CMA */
 
+#ifdef CONFIG_CMA
+/*
+ * Returns the number of pages that were *not* rejected. This makes it
+ * exactly compatible with its callers.
+ */
+static int reject_cma_pages(int nr_pinned, unsigned gup_flags,
+			    struct page **pages)
+{
+	int i = 0;
+	if (unlikely(gup_flags & FOLL_LONGTERM)) {
+
+		for (i = 0; i < nr_pinned; i++)
+			if (is_migrate_cma_page(pages[i])) {
+				put_user_pages(&pages[i], nr_pinned - i);
+				break;
+			}
+	}
+	return i;
+}
+#else
+static int reject_cma_pages(int nr_pinned, unsigned gup_flags,
+			    struct page **pages)
+{
+	return nr_pinned;
+}
+#endif
+
 /*
  * This is the same as get_user_pages_remote(), just with a
  * less-flexible calling convention where we assume that the task
@@ -2216,7 +2243,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 			unsigned int gup_flags, struct page **pages)
 {
 	unsigned long addr, len, end;
-	int nr = 0, ret = 0;
+	int nr_pinned = 0, ret = 0;
 
 	start &= PAGE_MASK;
 	addr = start;
@@ -2231,25 +2258,27 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 
 	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_disable();
-		gup_pgd_range(addr, end, gup_flags, pages, &nr);
+		gup_pgd_range(addr, end, gup_flags, pages, &nr_pinned);
 		local_irq_enable();
-		ret = nr;
+		ret = nr_pinned;
 	}
 
-	if (nr < nr_pages) {
+	nr_pinned = reject_cma_pages(nr_pinned, gup_flags, pages);
+
+	if (nr_pinned < nr_pages) {
 		/* Try to get the remaining pages with get_user_pages */
-		start += nr << PAGE_SHIFT;
-		pages += nr;
+		start += nr_pinned << PAGE_SHIFT;
+		pages += nr_pinned;
 
-		ret = __gup_longterm_unlocked(start, nr_pages - nr,
+		ret = __gup_longterm_unlocked(start, nr_pages - nr_pinned,
 					      gup_flags, pages);
 
 		/* Have to be a bit careful with return values */
-		if (nr > 0) {
+		if (nr_pinned > 0) {
 			if (ret < 0)
-				ret = nr;
+				ret = nr_pinned;
 			else
-				ret += nr;
+				ret += nr_pinned;
 		}
 	}
 

Rather lightly tested...I've compile-tested with CONFIG_CMA and !CONFIG_CMA, 
and boot tested with CONFIG_CMA, but could use a second set of eyes on whether
I've added any off-by-one errors, or worse. :)

thanks,
-- 
John Hubbard
NVIDIA

