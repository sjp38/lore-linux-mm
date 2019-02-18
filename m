Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA9B2C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:55:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EA77214DA
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:55:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EA77214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 064BF8E0002; Mon, 18 Feb 2019 03:55:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 014578E0001; Mon, 18 Feb 2019 03:55:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E45608E0002; Mon, 18 Feb 2019 03:55:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3F78E0001
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:55:13 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id j5so3201432edt.17
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 00:55:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+txshDmYUeiv4L0SQiNVqM8qxxKe36Du3ox1VYYDCfM=;
        b=bhiffyV57m2ZOEA969MJoMgZ1a0nvkinlE5Xobv5OkNoVh9maziFJ7jFdEMsGWO5U1
         ne+217haeNsL4B/ap1QgD0jRzKYEzIQBtfLPK/RIJXQAHNbzfv8bhm0yfOigadzVyrGe
         SNdWBf7yPrGakuHiJsyC4ohGBLkQyAv4UAx26C9lgDA8A88SoGPON7oXKvkCF8vYU2aU
         2bklU4aBIDsguW3TLqCSsK9PgBGW2WHNdqjLShigvou+e49aDKgv2emBPod4Iv0rx9qH
         Wzlw9iJ6MdqM/TbmospzYX9mfnKgDd+aW0c11xuX+ZMqY2U8dJPaaYkVaBPfIA9dR5M+
         yjMw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZlvdGkgVxF5PQjZ8eNmALeRBW9Ttt+/zt5qb/l/nPfnFlR5LjT
	KWIp1fEjiIWoWdKXsqV2PXowf8XRGbrxXDsDUHP13552LELIIYIepsvzlauG9THbISjpnJICJjc
	KvjosUJ0c/5+bYdenE6myxB5ZTbzCDXcl692qr72hrzGzrrZhUfmAYQlnEsdhJ3s=
X-Received: by 2002:a17:906:580e:: with SMTP id m14mr7519693ejq.57.1550480113081;
        Mon, 18 Feb 2019 00:55:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iahun1rVhIhUUeE4+ixmQ5pWU+2dPbrKekaeN6ojsgSIOfRlsAAxTAA9J5VxHT6u+Cw30fk
X-Received: by 2002:a17:906:580e:: with SMTP id m14mr7519655ejq.57.1550480111974;
        Mon, 18 Feb 2019 00:55:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550480111; cv=none;
        d=google.com; s=arc-20160816;
        b=xRrAnY/cgDmcx7sAGqllJslLu2v4xh9YYh8O4rZe47ugbX9MzpHil81dDYSDjuLZat
         eRp1t32+QsB6K1j20HWGfv4wk+ZgwBPQMqsrwGH2jcY4lprfcBYCP0atEZXCZupCwHsM
         7BEDQwOY34d5vn7yBfROdnbdg6kjFNyhYn5td+pDBII8M2jF7ductsNctA3iCMBcrAvh
         kFXJI+KvTKA7/EILDeTGc+WvBWjUirKNZCtiNUZFHDuKV991r8rLQOxtgMVegVubloU3
         bqbW4sx1m3kG+dsu57lK8XM364nH1xcxuRFW7PrHiU572O4TvXS0a95JiPx91pFUzOzZ
         yUzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+txshDmYUeiv4L0SQiNVqM8qxxKe36Du3ox1VYYDCfM=;
        b=xDqmR27guo+Pc8ow/uG831N4NiJxcRv9kZ4l/P1KvkNU7hz1RqrXRMpIZQKT+tp21U
         nyP4i75ifAHg9Cn0KgAN9+Udgnyq0RVBw0tRJ94p+0D7kIuWvwAP1JGUF+GWZ53V2sZM
         QnQ+W1ydPIQPb2Q3V5sMlXiA7Xm66CIF6Yrlai+4JijYConDkIymp77RJTYair1PwpBo
         QAEeLd0enKHM45v86Z5Fj7xbIp4UIC4zlZ4i9yFK5b7F/mLcf1Yl+nzIfh7NdwhUj5eK
         xamLgwI3dze+rse8fr6vsORss8cIUAWWMbgpXtirPRgFnmtODdjbkKcMFi6csXk4yECx
         bpNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o56si1401689edc.128.2019.02.18.00.55.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 00:55:11 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6F640ACA2;
	Mon, 18 Feb 2019 08:55:11 +0000 (UTC)
Date: Mon, 18 Feb 2019 09:55:10 +0100
From: Michal Hocko <mhocko@kernel.org>
To: kernel test robot <rong.a.chen@intel.com>
Cc: Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-kernel@vger.kernel.org, LKP <lkp@01.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [LKP] efad4e475c [ 40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
Message-ID: <20190218085510.GC7251@dhcp22.suse.cz>
References: <20190218052823.GH29177@shao2-debian>
 <20190218070844.GC4525@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218070844.GC4525@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Sorry for an excessive quoting in the previous email]
[Cc Pavel - the full report is http://lkml.kernel.org/r/20190218052823.GH29177@shao2-debian[]

On Mon 18-02-19 08:08:44, Michal Hocko wrote:
> On Mon 18-02-19 13:28:23, kernel test robot wrote:
[...]
> > [   40.305212] PGD 0 P4D 0 
> > [   40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
> > [   40.313055] CPU: 1 PID: 239 Comm: udevd Not tainted 5.0.0-rc4-00149-gefad4e4 #1
> > [   40.321348] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> > [   40.330813] RIP: 0010:page_mapping+0x12/0x80
> > [   40.335709] Code: 5d c3 48 89 df e8 0e ad 02 00 85 c0 75 da 89 e8 5b 5d c3 0f 1f 44 00 00 53 48 89 fb 48 8b 43 08 48 8d 50 ff a8 01 48 0f 45 da <48> 8b 53 08 48 8d 42 ff 83 e2 01 48 0f 44 c3 48 83 38 ff 74 2f 48
> > [   40.356704] RSP: 0018:ffff88801fa87cd8 EFLAGS: 00010202
> > [   40.362714] RAX: ffffffffffffffff RBX: fffffffffffffffe RCX: 000000000000000a
> > [   40.370798] RDX: fffffffffffffffe RSI: ffffffff820b9a20 RDI: ffff88801e5c0000
> > [   40.378830] RBP: 6db6db6db6db6db7 R08: ffff88801e8bb000 R09: 0000000001b64d13
> > [   40.386902] R10: ffff88801fa87cf8 R11: 0000000000000001 R12: ffff88801e640000
> > [   40.395033] R13: ffffffff820b9a20 R14: ffff88801f145258 R15: 0000000000000001
> > [   40.403138] FS:  00007fb2079817c0(0000) GS:ffff88801dd00000(0000) knlGS:0000000000000000
> > [   40.412243] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [   40.418846] CR2: 0000000000000006 CR3: 000000001fa82000 CR4: 00000000000006a0
> > [   40.426951] Call Trace:
> > [   40.429843]  __dump_page+0x14/0x2c0
> > [   40.433947]  is_mem_section_removable+0x24c/0x2c0
> 
> This looks like we are stumbling over an unitialized struct page again.
> Something this patch should prevent from. Could you try to apply [1]
> which will make __dump_page more robust so that we do not blow up there
> and give some more details in return.
> 
> Btw. is this reproducible all the time?

And forgot to ask whether this is reproducible with pending mmotm
patches in linux-next.

> I will have a look at the memory layout later today.

[    0.059335] No NUMA configuration found
[    0.059345] Faking a node at [mem 0x0000000000000000-0x000000001ffdffff]
[    0.059399] NODE_DATA(0) allocated [mem 0x1e8c3000-0x1e8c5fff]
[    0.073143] Zone ranges:
[    0.073175]   DMA32    [mem 0x0000000000001000-0x000000001ffdffff]
[    0.073204]   Normal   empty
[    0.073212] Movable zone start for each node
[    0.073240] Early memory node ranges
[    0.073247]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.073275]   node   0: [mem 0x0000000000100000-0x000000001ffdffff]
[    0.073309] Zeroed struct page in unavailable ranges: 98 pages
[    0.073312] Initmem setup node 0 [mem 0x0000000000001000-0x000000001ffdffff]
[    0.073343] On node 0 totalpages: 130942
[    0.073373]   DMA32 zone: 1792 pages used for memmap
[    0.073400]   DMA32 zone: 21 pages reserved
[    0.073408]   DMA32 zone: 130942 pages, LIFO batch:31

We have only a single NUMA node with a single ZONE_DMA32. But there is a
hole in the zone and the first range before the hole is not section
aligned. We do zero some unavailable ranges but from the number it is no
clear which range it is and 98. [0x60fff, 0xfffff) is 96 pages. The
patch below should tell us whether we are covering all we need. If yes
then the hole shouldn't make any difference and the problem must be
somewhere else.

---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 35fdde041f5c..c60642505e04 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6706,10 +6706,13 @@ void __init zero_resv_unavail(void)
 	pgcnt = 0;
 	for_each_mem_range(i, &memblock.memory, NULL,
 			NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end, NULL) {
-		if (next < start)
+		if (next < start) {
+			pr_info("zeroying %llx-%llx\n", PFN_DOWN(next), PFN_UP(start));
 			pgcnt += zero_pfn_range(PFN_DOWN(next), PFN_UP(start));
+		}
 		next = end;
 	}
+	pr_info("zeroying %llx-%lx\n", PFN_DOWN(next), max_pfn);
 	pgcnt += zero_pfn_range(PFN_DOWN(next), max_pfn);
 
 	/*
-- 
Michal Hocko
SUSE Labs

