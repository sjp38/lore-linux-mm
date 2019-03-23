Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24F9BC43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 03:39:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90C50218A2
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 03:39:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YhO4cPeZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90C50218A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C91896B0005; Fri, 22 Mar 2019 23:39:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C430A6B0006; Fri, 22 Mar 2019 23:39:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE2A06B0007; Fri, 22 Mar 2019 23:39:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6AAF96B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 23:39:02 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d15so3876324pgt.14
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 20:39:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Zx0aOprpnR523jPHCYFamlNxQwco60btkI6OgdAUqtE=;
        b=sncR1YxsbrasKeYodXQ0eKxVssNDli57j9HwdaEJHolaKZgX0QOD20f87nwFtGY/FH
         H7y9RXLA0MeiycY/joEzS1D89sjS1PWNqzC3nXN7zG1kMya7yOeHsLr1Ed4lXAxax/XP
         jyZefFItFl4oKHTY3VQ3RK3ILnkVCE/KFO4J5UA1a8mdw2F5UQdBjVw589tXvjIqn1Eo
         vR9RMj7HmKd/RDlNCGyjrim2kPEmyhMSkhSo3f+we1JWNZ1/vhIVbipkd9cudz0OARmf
         3nsSbGlJ412KhH7ZMfgMNhZbcq8YgHYMro5m0yh1aqkatxZ54AexOWkZahWUagpgVLVt
         v4Tw==
X-Gm-Message-State: APjAAAV8JASlgTb/eB1wI7S1t+zxC6hi6z5E8HsirbGcs2/vdAGiGduU
	emO0Yw9NXaNM6NJ8r5VTm7AoklCmV+bUm3Y8eQqxnUZmBpRBEMwD/XchLCIVcpf8jeR1ZRG/VuX
	+Kcd2J038LCOETK4CN2/r6SEbbqTVsmtNzi+UIzEs/O6TeLMN8E4WnQ710rsrJRVUww==
X-Received: by 2002:a17:902:e3:: with SMTP id a90mr12730022pla.45.1553312342035;
        Fri, 22 Mar 2019 20:39:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyoCe980dJS7eoJelVMQ25vf/P9J0sv4IOzM7qustTwSgsc8jkKZST6jZBmlr3U/yra4zlF
X-Received: by 2002:a17:902:e3:: with SMTP id a90mr12729974pla.45.1553312340794;
        Fri, 22 Mar 2019 20:39:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553312340; cv=none;
        d=google.com; s=arc-20160816;
        b=kS7cQGJUdK16/+wowdtzVBS+E+t6gAZO91Pnd9xiy0wxF9q2ChphCMzWiSiMr+ybkt
         1cemu86lYQu5YUflbIoPf5w1q2dNV58+ADnTImM5aR0uW8B6BCM8edRJGAbA90U896/F
         R5ey068vCeyXZqoem8kXsBC5tcgvZ0TBItKYFWy9NHIOqGaF3jLeTMqUq5/jmNSeHWEv
         mqb3CujSn1r3+aroTFdToh1Gwm5PPRSp5Ho5nUgD+FpeLT88u2hPi11mVfYh47Tc/biF
         Pr2dAijAe4NNGRimRfT64mZ3oczvFsRC1mXizSFkiI/NFsAA72Hv6aOGD84XUTOnv4iI
         2Phg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=Zx0aOprpnR523jPHCYFamlNxQwco60btkI6OgdAUqtE=;
        b=edAv3FMzEYUCc+blytk8vNnsAgSfriYCQc8J1U7hqxIk7yQ/uWwfpgOzGf7ezmrCwu
         XWppthLbh42xX0U+pwpV0Xg7JIRy+DlS8xMquIrFnPI74L1GAFhZqNHIsdMis9SCanIN
         HcvMUQoyJusURuoJiUuoc1V7CrRMyyvO0t5e1Y7e+gV1/6DaUSJ7auaMkwbyoXGnS8Fo
         ScR4XxcRKp/kkxvMf40Xy7wctUcKKZd6iIG86wnQTbPK34Zw+AeaNbw7mDSMpeIlqyba
         FeHdQMRWJwno+I/xfCUNfo5En7StnzEJdfD0pQeh9bE9fHcWm69QiByEC2mTot920y48
         pEBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YhO4cPeZ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r13si8307512pgr.213.2019.03.22.20.38.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Mar 2019 20:38:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YhO4cPeZ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Zx0aOprpnR523jPHCYFamlNxQwco60btkI6OgdAUqtE=; b=YhO4cPeZcA1aWq1qnKJhr/E6pD
	rXm8jsByeF0cL7khjnBnR9DXPEilEnPeE8E6rhsHqKNeauuxiWTWEtpKQnUusVhHIOLvWnF2seufr
	8dbDvzgdROcOG+OiNribfJ7AHql6TXe5CIwB0X0d5gOHHMYoI0SZHmqdWeFedlgxHawzWlFQMT6eH
	OPyMp1Sst/P9rSVT2IIxOm9w1CImItVFoKrhnm7l8hdumbhMC/gS5DOIifao6l2cK4kpwu5LsuPVN
	WuvxjUOJ0zz84fG2YlnLOwvKTNqZ/z6sUQ6Ky4d8ni8azAS5RBMzXgVShvCxaRnSsCySD9gRWQGlH
	G37RFURQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h7XUj-0003pH-1e; Sat, 23 Mar 2019 03:38:53 +0000
Date: Fri, 22 Mar 2019 20:38:52 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Qian Cai <cai@lca.pw>
Cc: Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org
Subject: Re: page cache: Store only head pages in i_pages
Message-ID: <20190323033852.GC10344@bombadil.infradead.org>
References: <1553285568.26196.24.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1553285568.26196.24.camel@lca.pw>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 04:12:48PM -0400, Qian Cai wrote:
> FYI, every thing involve swapping seems triggered a panic now since this patch.

Thanks for the report!  Does this fix it?

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 41858a3744b4..975aea9a49a5 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -335,6 +335,8 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
 static inline struct page *find_subpage(struct page *page, pgoff_t offset)
 {
 	VM_BUG_ON_PAGE(PageTail(page), page);
+	if (unlikely(PageSwapCache(page)))
+		return page;
 	VM_BUG_ON_PAGE(page->index > offset, page);
 	VM_BUG_ON_PAGE(page->index + compound_nr(page) <= offset, page);
 	return page - page->index + offset;

Huang, I'm pretty sure this isn't right for CONFIG_THP_SWAP, but I'm
not sure what the right answer is.  The patch this is on top of includes:

@@ -132,7 +132,7 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp)
                for (i = 0; i < nr; i++) {
                        VM_BUG_ON_PAGE(xas.xa_index != idx + i, page);
                        set_page_private(page + i, entry.val + i);
-                       xas_store(&xas, page + i);
+                       xas_store(&xas, page);
                        xas_next(&xas);
                }
                address_space->nrpages += nr;

so if we've added a THP page, we're going to find the head page.  I'm not
sure I understand how to get from the head page to the right subpage.  Is
it as simple as:

+	if (unlikely(PageSwapCache(page)))
+		return page + (offset & (compound_nr(page) - 1));

or are they not stored at an aligned location?

> [11653.484481] page:ffffea0006ef7080 count:2 mapcount:0 mapping:0000000000000000
> index:0x0
> [11653.525397] swap_aops 
> [11653.525404] flags:
> 0x5fffe000080454(uptodate|lru|workingset|owner_priv_1|swapbacked)
> [11653.573631] raw: 005fffe000080454 ffffea0006ef7048 ffffea0007c9c7c8
> 0000000000000000
> [11653.608547] raw: 0000000000000000 0000000000001afd 00000002ffffffff
> 0000000000000000
> [11653.643436] page dumped because: VM_BUG_ON_PAGE(page->index + (1 <<
> compound_order(page)) <= offset)
> [11653.684322] page allocated via order 0, migratetype Movable, gfp_mask
> 0x100cca(GFP_HIGHUSER_MOVABLE)
> [11653.725462]  prep_new_page+0x3a4/0x4d0
> [11653.742373]  get_page_from_freelist+0xcde/0x3550
> [11653.763449]  __alloc_pages_nodemask+0x859/0x2ab0
> [11653.784105]  alloc_pages_vma+0xb2/0x430
> [11653.801248]  __read_swap_cache_async+0x49c/0xc30
> [11653.821943]  swap_cluster_readahead+0x4a1/0x8b0
> [11653.842224]  swapin_readahead+0xb6/0xc3e
> [11653.859894]  do_swap_page+0xc87/0x24b0
> [11653.876664]  __handle_mm_fault+0x1601/0x3bc0
> [11653.895818]  handle_mm_fault+0x326/0x6cf
> [11653.913443]  __do_page_fault+0x333/0x8d0
> [11653.931068]  do_page_fault+0x75/0x48e
> [11653.947560]  page_fault+0x1b/0x20
> [11653.962558] ------------[ cut here ]------------
> [11653.983290] kernel BUG at include/linux/pagemap.h:341!
> [11654.006336] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
> [11654.036835] CPU: 12 PID: 14006 Comm: in:imjournal Kdump: loaded Tainted:
> G        W         5.1.0-rc1-mm1+ #17
> [11654.084191] Hardware name: HP ProLiant DL80 Gen9/ProLiant DL80 Gen9, BIOS U15
> 09/12/2016
> [11654.120401] RIP: 0010:find_get_entry+0x618/0x7f0
> [11654.141171] Code: c6 60 ae e9 97 4c 89 ff e8 c5 b2 0c 00 0f 0b 48 c7 c7 20 3b
> 42 98 e8 3c 3c 57 00 48 c7 c6 e0 b0 e9 97 4c 89 ff e8 a8 b2 0c 00 <0f> 0b 48 c7
> c7 e0 3a 42 98 e8 1f 3c 57 00 48 c7 c7 88 62 7e 98 e8
> [11654.226539] RSP: 0000:ffff8882095b7628 EFLAGS: 00010286
> [11654.249867] RAX: 0000000000000000 RBX: 0000000000000001 RCX: ffffffff9735700e
> [11654.281925] RDX: 0000000000000000 RSI: 0000000000000008 RDI: ffff888213e4d332
> [11654.313411] RBP: ffff8882095b7738 R08: ffffed1042d86a89 R09: ffffed1042d86a88
> [11654.346314] R10: ffffed1042d86a88 R11: ffff888216c35447 R12: 0000000000000000
> [11654.379144] R13: ffffea0006ef70a0 R14: ffff8881e5c16fc8 R15: ffffea0006ef7080
> [11654.411410] FS:  00007fb8daf56700(0000) GS:ffff888216c00000(0000)
> knlGS:0000000000000000
> [11654.447618] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [11654.473481] CR2: 00007f74c0647000 CR3: 0000000204860003 CR4: 00000000001606a0
> [11654.506282] Call Trace:
> [11654.517340]  ? __filemap_set_wb_err+0x1f0/0x1f0
> [11654.538684]  ? generic_make_request+0x283/0xc50
> [11654.562239]  ? mem_cgroup_uncharge+0x150/0x150
> [11654.582551]  pagecache_get_page+0x4a/0xb70
> [11654.600807]  ? release_pages+0xada/0x1750
> [11654.618847]  __read_swap_cache_async+0x1a8/0xc30
> [11654.640167]  ? lookup_swap_cache+0x570/0x570
> [11654.659274]  read_swap_cache_async+0x69/0xd0
> [11654.678354]  ? __read_swap_cache_async+0xc30/0xc30
> [11654.699775]  ? lru_add_drain_cpu+0x239/0x4e0
> [11654.718855]  swap_cluster_readahead+0x386/0x8b0
> [11654.739171]  ? read_swap_cache_async+0xd0/0xd0
> [11654.760517]  ? xas_load+0x8b/0xf0
> [11654.775357]  ? find_get_entry+0x39e/0x7f0
> [11654.793267]  swapin_readahead+0xb6/0xc3e
> [11654.810391]  ? exit_swap_address_space+0x1b0/0x1b0
> [11654.831816]  ? lookup_swap_cache+0x114/0x570
> [11654.850972]  ? xas_find+0x141/0x530
> [11654.866616]  ? free_pages_and_swap_cache+0x2f0/0x2f0
> [11654.889495]  ? swapcache_prepare+0x20/0x20
> [11654.907786]  ? filemap_map_pages+0x3af/0xec0
> [11654.926919]  do_swap_page+0xc87/0x24b0
> [11654.943758]  ? unmap_mapping_range+0x30/0x30
> [11654.962918]  ? kasan_check_read+0x11/0x20
> [11654.980900]  ? do_raw_spin_unlock+0x59/0x250
> [11655.000027]  __handle_mm_fault+0x1601/0x3bc0
> [11655.020130]  ? __lock_acquire.isra.14+0x7d7/0x2130
> [11655.041845]  ? vmf_insert_mixed_mkwrite+0x20/0x20
> [11655.066529]  ? lock_acquire+0x169/0x360
> [11655.085380]  handle_mm_fault+0x326/0x6cf
> [11655.102928]  __do_page_fault+0x333/0x8d0
> [11655.120429]  ? task_work_run+0xdd/0x190
> [11655.138322]  do_page_fault+0x75/0x48e
> [11655.154693]  ? page_fault+0x5/0x20
> [11655.170168]  page_fault+0x1b/0x20
> [11655.185007] RIP: 0033:0x7fb8dde3ae14
> [11655.201007] Code: 00 0f 1f 44 00 00 f3 0f 1e fa f2 ff 25 65 1a 29 00 0f 1f 44
> 00 00 f3 0f 1e fa f2 ff 25 5d 1a 29 00 0f 1f 44 00 00 f3 0f 1e fa <f2> ff 25 55
> 1a 29 00 0f 1f 44 00 00 f3 0f 1e fa f2 ff 25 4d 1a 29
> [11655.286038] RSP: 002b:00007fb8daf55b28 EFLAGS: 00010246
> [11655.309443] RAX: 0000000000000000 RBX: 0000562a76a844f0 RCX: 0000000000000000
> [11655.341503] RDX: 00007fb8daf55ac0 RSI: 0000000000000001 RDI: 0000562a76a844f0
> [11655.373906] RBP: 00000000000dbba0 R08: 0000000000000008 R09: 0000000000000000
> [11655.407498] R10: 0000000000000000 R11: 0000000000000000 R12: 000000000000000e
> [11655.439429] R13: 00007fb8da036760 R14: 00007fb8daf55be0 R15: 00007fb8daf55bd0
> [11655.471484] Modules linked in: brd nls_iso8859_1 nls_cp437 vfat fat ext4
> crc16 mbcache jbd2 overlay loop kvm_intel kvm irqbypass ip_tables x_tables xfs
> sd_mod igb ahci i2c_algo_bit libahci libata i2c_core dm_mirror dm_region_hash
> dm_log dm_mod

