Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD262C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:08:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B1B520665
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:08:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B1B520665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AE436B0003; Fri,  2 Aug 2019 04:08:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 037AF6B0006; Fri,  2 Aug 2019 04:08:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1BD76B0008; Fri,  2 Aug 2019 04:08:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A89C36B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 04:08:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 145so47719471pfv.18
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 01:08:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version:sender
         :precedence:list-id:archived-at:list-archive:list-post
         :content-transfer-encoding;
        bh=LLcS/wt/JNcH1w5GaAx83RBtvmhyvFW6p1ajQKiIpa4=;
        b=nc1nO7b91CW1O90KWZBY8OGxuw8aRleRg2bvVRC1V5QBisIScFzExSjT3rrL4Z8m/n
         pqzseNgwepdlbOeXEeOYtRAeLiOz1u0wMyZCxBmX9zAgXS4Xwbawc5WmtpWzQa/vQSSP
         t3v8HqZ8qh6nyfqXLEjEC70GH19c9rrYpCE1j1K8/SgSnYRd6kzzojWUpaFTy6f1w9XA
         IuK3bpym9be974qDfeGm2xjDNdlBofdLW88qvJWYxjR90AN4StMGAxK8Co1kHPYGQ2yk
         rvpYCwPU0AJmG5vU1e2V3DzA29Kt03BuVmCNTGyRDGD01TW21YhRmOpQMkLf6WQTEbuA
         FOLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.215 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAWAa7TSxWTB7MC+Av7tVZnYdgU0XGiOK8KOx3RlYrEoDbrozUU6
	UykerYSQiDL7Bz6Pj5InlemOs2J3JCT3bw7sPk7DLtDY7n8WvgwYkPjqWHHnf82lvFhQ3WP7Udt
	qiDLnEH/4BK6XJK9i17YcYHnr5LqEEV+IosdhzYSc5wZHc2DDmjMYwHBWr3gDd6XZrA==
X-Received: by 2002:a63:5823:: with SMTP id m35mr125227948pgb.329.1564733296258;
        Fri, 02 Aug 2019 01:08:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzh4f6CRWYUy/5L5i0mM6BSY8AkifFRlNF5NlTPfeFtGLtaDhYyB7UfQLOSL+mEKPL8e7kj
X-Received: by 2002:a63:5823:: with SMTP id m35mr125227886pgb.329.1564733295271;
        Fri, 02 Aug 2019 01:08:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564733295; cv=none;
        d=google.com; s=arc-20160816;
        b=sNr00vs6scC+fDV2bpaDXOJEXHsvYJ2lHcecOTgSmgFgmG660+7f0PbJ2ZkfOuUYpB
         6faLMedHNT5xr6neaBNTV59CP95woDSBp+HPOTr3PEgllb/BsW5WrYqQop7qR1+L2ssT
         R4X/5CotAKUFnBZODvlne++nTBm6UGjTVfnSIVqqGvQnY/s4PpJXQlH0HhM7ZJ5K6MX9
         LQknm361cPbhThhYlLVOwN8vHJuutQcUFf81NNSwVXeiNIWW+8bDIjmsoFeFaHyI3Pev
         NzIzRe7LRqgw4G7AUNVDevgrC/LNUhXwB8sEghwAF+SD+h342h4SALLIpjDwleGjz3AY
         Hcbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:precedence:sender:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=LLcS/wt/JNcH1w5GaAx83RBtvmhyvFW6p1ajQKiIpa4=;
        b=ydV6BQNjXEgwG6KT3lWkI5J5E9SK7C+KLXIU+l4CIRnCkyRVTzTyGfkOdSVAfQqztD
         T/GBKxJbuVJSUHTKoZxJMeujHLTTFxxpLUDQW2ZbXh67ia9Vr+sk/JleM5LXCuv8pN+U
         d++IedVmY+Zn1CgV242DuOAmCkNBfywa0Kfmqnkdia2EhaCe2HfrWWiB6tr8FmEu7Cko
         UozioAP7PWo1jjbkYdGOTQX91nkVaYEnZaiueqtF+Aso7Wv5omSL550XRl8BtkrvO51W
         k/CZ6Xl4XcaMm3a0qH+iOhSEzNjfMtS9ID9vTp+fSOYazJCCNHbKJclKXizj9JATBSoc
         OD8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.215 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail7-215.sinamail.sina.com.cn (mail7-215.sinamail.sina.com.cn. [202.108.7.215])
        by mx.google.com with SMTP id a24si38086905pfi.205.2019.08.02.01.08.14
        for <linux-mm@kvack.org>;
        Fri, 02 Aug 2019 01:08:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.7.215 as permitted sender) client-ip=202.108.7.215;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.215 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([124.64.0.239])
	by sina.com with ESMTP
	id 5D43EF6B00004C8F; Fri, 2 Aug 2019 16:08:13 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 7038350203724
From: Hillf Danton <hdanton@sina.com>
To: Masoud Sharbiani <msharbiani@apple.com>
Cc: mhocko@kernel.org,
	hannes@cmpxchg.org,
	vdavydov.dev@gmail.com,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Date: Fri,  2 Aug 2019 16:08:01 +0800
Message-Id: <7EE30F16-A90B-47DC-A065-3C21881CD1CC@apple.com>
In-Reply-To: <20190801181952.GA8425@kroah.com>
References: <5659221C-3E9B-44AD-9BBF-F74DE09535CD@apple.com> <20190801181952.GA8425@kroah.com>
MIME-Version: 1.0
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/7EE30F16-A90B-47DC-A065-3C21881CD1CC@apple.com/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190802080801.FgipbUiUIRs2pZQem8TIVsBBsNLNyssPt3Um-NmRPB4@z>


On Thu, 01 Aug 2019 18:08:42 -0700 Masoud Sharbiani wrote:
> 
> Allow me to issue a correction:
> Running this test on linux master 
> <629f8205a6cc63d2e8e30956bad958a3507d018f> correctly terminates the 
> leaker app with OOM.
> However, running it a second time (after removing the memory cgroup, and 
> allowing the test script to run it again), causes this:
> 
>  kernel:watchdog: BUG: soft lockup - CPU#7 stuck for 22s! [leaker1:7193]
> 
> 
> [  202.511024] CPU: 7 PID: 7193 Comm: leaker1 Not tainted 5.3.0-rc2+ #8
> [  202.517378] Hardware name: <redacted>
> [  202.525554] RIP: 0010:lruvec_lru_size+0x49/0xf0
> [  202.530085] Code: 41 89 ed b8 ff ff ff ff 45 31 f6 49 c1 e5 03 eb 19 
> 48 63 d0 4c 89 e9 48 8b 14 d5 20 b7 11 b5 48 03 8b 88 00 00 00 4c 03 34 
> 11 <48> c7 c6 80 c5 40 b5 89 c7 e8 29 a7 6f 00 3b 05 57 9d 24 01 72 d1
> [  202.548831] RSP: 0018:ffffa7c5480df620 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff13
> [  202.556398] RAX: 0000000000000000 RBX: ffff8f5b7a1af800 RCX: 00003859bfa03bc0
> [  202.563528] RDX: ffff8f5b7f800000 RSI: 0000000000000018 RDI: ffffffffb540c580
> [  202.570662] RBP: 0000000000000001 R08: 0000000000000000 R09: 0000000000000004
> [  202.577795] R10: ffff8f5b62548000 R11: 0000000000000000 R12: 0000000000000004
> [  202.584928] R13: 0000000000000008 R14: 0000000000000000 R15: 0000000000000000
> [  202.592063] FS:  00007ff73d835740(0000) GS:ffff8f6b7f840000(0000) knlGS:0000000000000000
> [  202.600149] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  202.605895] CR2: 00007f1b1c00e428 CR3: 0000001021d56006 CR4: 00000000001606e0
> [  202.613026] Call Trace:
> [  202.615475]  shrink_node_memcg+0xdb/0x7a0
> [  202.619488]  ? shrink_slab+0x266/0x2a0
> [  202.623242]  ? mem_cgroup_iter+0x10a/0x2c0
> [  202.627337]  shrink_node+0xdd/0x4c0
> [  202.630831]  do_try_to_free_pages+0xea/0x3c0
> [  202.635104]  try_to_free_mem_cgroup_pages+0xf5/0x1e0
> [  202.640068]  try_charge+0x279/0x7a0
> [  202.643565]  mem_cgroup_try_charge+0x51/0x1a0
> [  202.647925]  __add_to_page_cache_locked+0x19f/0x330
> [  202.652800]  ? __mod_lruvec_state+0x40/0xe0
> [  202.656987]  ? scan_shadow_nodes+0x30/0x30
> [  202.661086]  add_to_page_cache_lru+0x49/0xd0
> [  202.665361]  iomap_readpages_actor+0xea/0x230
> [  202.669718]  ? iomap_migrate_page+0xe0/0xe0
> [  202.673906]  iomap_apply+0xb8/0x150
> [  202.677398]  iomap_readpages+0xa7/0x1a0
> [  202.681237]  ? iomap_migrate_page+0xe0/0xe0
> [  202.685424]  read_pages+0x68/0x190
> [  202.688829]  __do_page_cache_readahead+0x19c/0x1b0
> [  202.693622]  ondemand_readahead+0x168/0x2a0
> [  202.697808]  filemap_fault+0x32d/0x830
> [  202.701562]  ? __mod_lruvec_state+0x40/0xe0
> [  202.705747]  ? page_remove_rmap+0xcf/0x150
> [  202.709846]  ? alloc_set_pte+0x240/0x2c0
> [  202.713775]  __xfs_filemap_fault+0x71/0x1c0
> [  202.717963]  __do_fault+0x38/0xb0
> [  202.721280]  __handle_mm_fault+0x73f/0x1080
> [  202.725467]  ? __switch_to_asm+0x34/0x70
> [  202.729390]  ? __switch_to_asm+0x40/0x70
> [  202.733318]  handle_mm_fault+0xce/0x1f0
> [  202.737158]  __do_page_fault+0x231/0x480
> [  202.741083]  page_fault+0x2f/0x40
> [  202.744404] RIP: 0033:0x400c20
> [  202.747461] Code: 45 c8 48 89 c6 bf 32 0e 40 00 b8 00 00 00 00 e8 76 
> fb ff ff c7 45 ec 00 00 00 00 eb 36 8b 45 ec 48 63 d0 48 8b 45 c8 48 01 
> d0 <0f> b6 00 0f be c0 01 45 e4 8b 45 ec 25 ff 0f 00 00 85 c0 75 10 8b
> [  202.766208] RSP: 002b:00007ffde95ae460 EFLAGS: 00010206
> [  202.771432] RAX: 00007ff71e855000 RBX: 0000000000000000 RCX: 000000000000001a
> [  202.778558] RDX: 0000000001dfd000 RSI: 000000007fffffe5 RDI: 0000000000000000
> [  202.785692] RBP: 00007ffde95af4b0 R08: 0000000000000000 R09: 00007ff73d2a520d
> [  202.792823] R10: 0000000000000002 R11: 0000000000000246 R12: 0000000000400850
> [  202.799949] R13: 00007ffde95af590 R14: 0000000000000000 R15: 0000000000000000
> 
> 
> Further tests show that this also happens if one waits long enough on  
> 5.3-rc1 as well.
> So I dont think we have a fix in tree yet.

--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2547,8 +2547,12 @@ retry:
 	nr_reclaimed = try_to_free_mem_cgroup_pages(mem_over_limit, nr_pages,
 						    gfp_mask, may_swap);
 
-	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
-		goto retry;
+	if (mem_cgroup_margin(mem_over_limit) >= nr_pages) {
+		if (nr_retries--)
+			goto retry;
+		/* give up charging memhog */
+		return -ENOMEM;
+	}
 
 	if (!drained) {
 		drain_all_stock(mem_over_limit);
--

