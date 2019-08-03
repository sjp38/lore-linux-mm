Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68476C433FF
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 02:37:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED6462086A
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 02:37:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED6462086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4960C6B0003; Fri,  2 Aug 2019 22:37:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 447266B0005; Fri,  2 Aug 2019 22:37:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E7086B0006; Fri,  2 Aug 2019 22:37:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 01D906B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 22:37:01 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id h26so42025020otr.21
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 19:37:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=XZazhZ0CmotngoVYbMsiDVatQHN2tXbP8fOcerYOWMg=;
        b=H2rNDwdpSEsvaYV4Dg+NDUf9Bz/gdUaKj8/SnYXIx35kibzSKociKSqsDLMtxqY+6E
         SdOa51t88O0mXHmoKF5sxYLsIf3QXVBDK7dLAP00S8ls2uht5NVsgyGxKQ7kHEpCnE8q
         zRXfELi9zQDXrVmo0PEQ0yWlBf0VHcw2QFopz+7lZ1aRObROewshO3sNf1goTHZAompK
         /N7vvijzBj/6hsYGvboKeNfrllpoaQLeDf4E9p4z/MUuP+Lek3ALFc/j4aov0hWsDKWK
         nPYiCZwPrzOjAuNcNafX0mQCgvhwDeXI242WKPK069bCPnQB+aDYald/FVlBUg7Zwitv
         0g9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAUPBn3ZsFdq+2Y6ukm33brPS6cI0snxQg+P5734RcEkhkrKvmKN
	+nTK+0hzKzyIhhiaCVJRQBDLioHEpoX2IQL3LsLApE22eXzU1Db8etoiaIt3wBu87elu0E+YuxB
	DRC0oRICQWWfPOA3sLw4eIn6aYF9J72KCmkp0OXhZcX5tw96MYD//xZ+VA9HF5+5k6g==
X-Received: by 2002:a05:6808:3:: with SMTP id u3mr4333194oic.141.1564799820600;
        Fri, 02 Aug 2019 19:37:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzd2GJx0nTFIAiJEyQ5LazBbGboofM72mr4R4CMrLxtwX+oTGBYlnoHA/3e44z6GbHoOjVt
X-Received: by 2002:a05:6808:3:: with SMTP id u3mr4333176oic.141.1564799819638;
        Fri, 02 Aug 2019 19:36:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564799819; cv=none;
        d=google.com; s=arc-20160816;
        b=zkZ/njduIY4MJpTMC8XFKaNiARd+dfYDqCvBWz6bU6ggbGYGEc97rCf9qX6vLD0vyl
         rVEaNZFLVCGLZ/jrtKAMnGEu6nJxDRIA3WHtWakc+DZb0+nbikHyeLiykxTYROzKb3MN
         WZ6X+nA18PpzqmkjIBkPzMzsuf8U6mlMyodvJco1Y7Vzlx1ZX2tERrZInHvqvSUzN8Pa
         41n8vQQPS0i4HSYfM3fbe7viDM+82dd+1Bi8y0ZkNNuWNae7dzlpUPK7njP6Zrf6aVCq
         D9IRK6qq8natYfe2sjTRzJd++q1oY60TJqmrzzDkAc/rs6AHT3S/g8aRGzkq3WD1Xj84
         KJhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=XZazhZ0CmotngoVYbMsiDVatQHN2tXbP8fOcerYOWMg=;
        b=OVw36qibcCMfCjtiYxmOrphCjuKE1ohH4MMt+76Mdm3PWVqTY20V1iOFHcwKDBMj2z
         W5WBqo84v8sSF5qVJpckUlAyd7cEFrL+jEWQ20v0rtGWeJkBHefGLBXY6MYcjPUWggxU
         RZ5wlCluMZu3pVc+HgEYfwrhCxbHqY0ZRWH0eyTe3xcFWfFmWM0FhbEtSWhoAVZ3vrvM
         fFTl58PkLyAKc2LouaMbAaDSFXUrSHiJoqIP3t78tz+5OaTqYJ8rRzSb+dI1Q8i7T320
         ehrwMskR/SENWOice/d+T3CEddrDK7tqmu9mRT1Cx5BaFp4WsQk1ReM7Z40fM/EHvOWr
         joaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m84si39571179oib.153.2019.08.02.19.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 19:36:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav401.sakura.ne.jp (fsav401.sakura.ne.jp [133.242.250.100])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x732aiRI033406;
	Sat, 3 Aug 2019 11:36:44 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav401.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav401.sakura.ne.jp);
 Sat, 03 Aug 2019 11:36:44 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav401.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x732aeeh033387
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sat, 3 Aug 2019 11:36:44 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
To: Masoud Sharbiani <msharbiani@apple.com>, Michal Hocko <mhocko@kernel.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, hannes@cmpxchg.org,
        vdavydov.dev@gmail.com, linux-mm@kvack.org, cgroups@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <5659221C-3E9B-44AD-9BBF-F74DE09535CD@apple.com>
 <20190802074047.GQ11627@dhcp22.suse.cz>
 <7E44073F-9390-414A-B636-B1AE916CC21E@apple.com>
 <20190802144110.GL6461@dhcp22.suse.cz>
 <5DE6F4AE-F3F9-4C52-9DFC-E066D9DD5EDC@apple.com>
 <20190802191430.GO6461@dhcp22.suse.cz>
 <A06C5313-B021-4ADA-9897-CE260A9011CC@apple.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <f7733773-35bc-a1f6-652f-bca01ea90078@I-love.SAKURA.ne.jp>
Date: Sat, 3 Aug 2019 11:36:36 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <A06C5313-B021-4ADA-9897-CE260A9011CC@apple.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Well, while mem_cgroup_oom() is actually called, due to hitting

        /*
         * The OOM killer does not compensate for IO-less reclaim.
         * pagefault_out_of_memory lost its gfp context so we have to
         * make sure exclude 0 mask - all other users should have at least
         * ___GFP_DIRECT_RECLAIM to get here.
         */
        if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
                return true;

path inside out_of_memory(), OOM_SUCCESS is returned and retrying without
making forward progress...

----------------------------------------
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2447,6 +2447,8 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
         */
        oom_status = mem_cgroup_oom(mem_over_limit, gfp_mask,
                       get_order(nr_pages * PAGE_SIZE));
+       printk("mem_cgroup_oom(%pGg)=%u\n", &gfp_mask, oom_status);
+       dump_stack();
        switch (oom_status) {
        case OOM_SUCCESS:
                nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
----------------------------------------

----------------------------------------
[   55.208578][ T2798] mem_cgroup_oom(GFP_NOFS)=0
[   55.210424][ T2798] CPU: 3 PID: 2798 Comm: leaker Not tainted 5.3.0-rc2+ #637
[   55.212985][ T2798] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
[   55.217260][ T2798] Call Trace:
[   55.218597][ T2798]  dump_stack+0x67/0x95
[   55.220200][ T2798]  try_charge+0x4ca/0x6d0
[   55.221843][ T2798]  ? get_mem_cgroup_from_mm+0x1ff/0x2c0
[   55.223855][ T2798]  mem_cgroup_try_charge+0x88/0x2d0
[   55.225723][ T2798]  __add_to_page_cache_locked+0x27e/0x4c0
[   55.227784][ T2798]  ? scan_shadow_nodes+0x30/0x30
[   55.229577][ T2798]  add_to_page_cache_lru+0x72/0x180
[   55.231467][ T2798]  iomap_readpages_actor+0xeb/0x1e0
[   55.233376][ T2798]  ? iomap_migrate_page+0x120/0x120
[   55.235382][ T2798]  iomap_apply+0xaf/0x150
[   55.237049][ T2798]  iomap_readpages+0x9f/0x160
[   55.239061][ T2798]  ? iomap_migrate_page+0x120/0x120
[   55.241013][ T2798]  xfs_vm_readpages+0x54/0x130 [xfs]
[   55.242960][ T2798]  read_pages+0x63/0x160
[   55.244613][ T2798]  __do_page_cache_readahead+0x1cd/0x200
[   55.246699][ T2798]  ondemand_readahead+0x201/0x4d0
[   55.248562][ T2798]  page_cache_async_readahead+0x16e/0x2e0
[   55.250740][ T2798]  ? page_cache_async_readahead+0xa5/0x2e0
[   55.252881][ T2798]  filemap_fault+0x3f3/0xc20
[   55.254813][ T2798]  ? xfs_ilock+0x1de/0x2c0 [xfs]
[   55.256858][ T2798]  ? __xfs_filemap_fault+0x7f/0x270 [xfs]
[   55.259118][ T2798]  ? down_read_nested+0x98/0x170
[   55.261123][ T2798]  ? xfs_ilock+0x1de/0x2c0 [xfs]
[   55.263146][ T2798]  __xfs_filemap_fault+0x92/0x270 [xfs]
[   55.265210][ T2798]  xfs_filemap_fault+0x27/0x30 [xfs]
[   55.267164][ T2798]  __do_fault+0x33/0xd0
[   55.268784][ T2798]  do_fault+0x3be/0x5c0
[   55.270390][ T2798]  __handle_mm_fault+0x462/0xc00
[   55.272251][ T2798]  handle_mm_fault+0x17c/0x380
[   55.274055][ T2798]  ? handle_mm_fault+0x46/0x380
[   55.275877][ T2798]  __do_page_fault+0x24a/0x4c0
[   55.277676][ T2798]  do_page_fault+0x27/0x1b0
[   55.279399][ T2798]  page_fault+0x34/0x40
[   55.281053][ T2798] RIP: 0033:0x4009f0
[   55.282564][ T2798] Code: 03 00 00 00 e8 71 fd ff ff 48 83 f8 ff 49 89 c6 74 74 48 89 c6 bf c0 0c 40 00 31 c0 e8 69 fd ff ff 45 85 ff 7e 21 31 c9 66 90 <41> 0f be 14 0e 01 d3 f7 c1 ff 0f 00 00 75 05 41 c6 04 0e 2a 48 83
[   55.289631][ T2798] RSP: 002b:00007fff1804ec00 EFLAGS: 00010206
[   55.291835][ T2798] RAX: 000000000000001b RBX: 0000000000000000 RCX: 0000000001a1a000
[   55.294745][ T2798] RDX: 0000000000000000 RSI: 000000007fffffe5 RDI: 0000000000000000
[   55.297500][ T2798] RBP: 000000000000000c R08: 0000000000000000 R09: 00007f4e7392320d
[   55.300225][ T2798] R10: 0000000000000002 R11: 0000000000000246 R12: 00000000000186a0
[   55.303047][ T2798] R13: 0000000000000003 R14: 00007f4e530d6000 R15: 0000000002800000
----------------------------------------


