Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B1F4C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:10:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F23220855
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:10:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Dx6cJvdR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F23220855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42BA16B0007; Thu,  4 Apr 2019 09:10:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B3E46B0008; Thu,  4 Apr 2019 09:10:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27AC06B000C; Thu,  4 Apr 2019 09:10:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 02EC06B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 09:10:18 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n13so2185425qtn.6
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 06:10:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=MtOEzIwA5pZzxc3zgMmWaEsmQLLJ/RXyI1IrdyyXXgM=;
        b=SfOmahS/DgansdPzL5wizVci3oE6BFFbmwByMT1AvU4FTvNFJcw421lUpA0CwkszlA
         64/Bu5ZdHTG3GnmwEkl/9AwZ3A95knQdYyB2XpQy6RRxxYkLEeFM6DpEY4rECN3w4jdF
         iOQC4pxeqQVj5OAAfhro3gqwZ2ddW+q4zOG62ZIqcWKu1hVve1gQiAIjXI0wAa1OfZ9v
         rMgnX8wd8/Qn6dMaWUPbhhG3j9M58GQOA7yXxgsV7P+B+RJVsp6rlm5NxAXqzelVu7jI
         1gk70iUvLQAT0G2BfZjASzDlT9zug50dcoCGG10MtJz4HSQtBHgXAiD0AO9OzabBGVhU
         1Xgw==
X-Gm-Message-State: APjAAAV2vGyXfGHmtY0ehUJbxgnxnp8q0hAJphAVzMg8VT/AwrVUggGP
	qnQiAZn07tU2pfHoK0+XwEcgS8DMJxWI1/+ScGqd+ShurRUXqrYX5bdz4bLrjFYueF/Z36Lmlj4
	wK5E5cjV0BfOHgzojGG5tI2BJj933J8+LuyvbbBpiL4Jt95C3uSqLDn6Xc2uiUqqPHg==
X-Received: by 2002:ac8:3449:: with SMTP id v9mr5302652qtb.352.1554383416267;
        Thu, 04 Apr 2019 06:10:16 -0700 (PDT)
X-Received: by 2002:ac8:3449:: with SMTP id v9mr5302510qtb.352.1554383412825;
        Thu, 04 Apr 2019 06:10:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554383412; cv=none;
        d=google.com; s=arc-20160816;
        b=BW9Kb+ppBU1s2YedBlYElrdNksA7YNV2y/F/2NATWdD/39YCQm6YfXnrevPEk6qUJ9
         MjEVGA1kUca8D7qHltLgfxGIx3yVVijFMUKJEMCiTmJDfUFtZAHXgyzHpNCWtoKkvKlQ
         /AKeYRLLEsX/F1R8uF5CmCR0Gi5W2tBlwgc/e9EmF10/fV4I4zDVCT2hK4HBHx/GVdPb
         D5mwwXVVmUzTyAKxmaMocXnQjj0KS4XXWCoD2pA5zyaGbFJnpq9+2dxU4RhcYvWzCEwP
         UYT80QTwxs+I8YbiqSGHEPG6hPerdpPZ3WyGgVNofkpvknLkLkIZ044d777p/EeIXLjw
         k9/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=MtOEzIwA5pZzxc3zgMmWaEsmQLLJ/RXyI1IrdyyXXgM=;
        b=PsZdSEXnWVyCXEwngV6edtAO4/zvLsyL1h7KH6IX/VGPFiV1YFUhOfFRBSX3GXbyOo
         QKgzKBQjxKOrfTJuiUtGmIArmhc9oN6GxlLrC1acd1b02/NqJjBj+A2Tk6jGaVkM0WKc
         JOb8aEy1wccgDZXj4vy4Ubu+NVTyMqjwNDYFMuT3p8LDed8Pp+G+OtiCa+/G48DwyaQm
         trwEzUMpokUKcVPdp/tagJpHSii9gDX9KCdQkZWdVvcoXN6D3pjN8rfb1bazD6g4fFaA
         GSvt+EJ5TahAyYXhponZOyg6zW9m1hII1DPOFWHSUXg2x83Cmxkh8gHY+hW89QT8Zelm
         /1qw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Dx6cJvdR;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b16sor26523728qtk.22.2019.04.04.06.10.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 06:10:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Dx6cJvdR;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=MtOEzIwA5pZzxc3zgMmWaEsmQLLJ/RXyI1IrdyyXXgM=;
        b=Dx6cJvdRoQ0j/hgb8mR7Ca3BTWDOGd2PtLgVCsEWT8/9lClReb+1YNapAawG4VrywK
         E7vap1yY13dxXsIwXCiFwZChigD3xtik5ncuC2sGWO4dd4MdIm72mM5g3ZceLvcpea6L
         4d5FLsq8/U+KKb+7OzJawRiotfbRt7y9jVNbdbjPHB4jwmvrlml/YAOQxN9vCNjwvwT3
         05uPju5ZPB77CA2TQrCW8wOLK1EvAmQEV+3j0gnG8WdIEXQC12tbHJjJyLXD5aTjRsaZ
         FHb/CFXQBMmyjzR3M39YzbJy/blMREv2kuOZxwSgtQgTL+m8/JccOpluu+UU9KDzwIXD
         YuDA==
X-Google-Smtp-Source: APXvYqw4eQQAc2X5245xt9jb7pmoE8he7RqKqpXEYzOol24EoptbdvUkwNdHhI7lTUH9GwP3zbUYIQ==
X-Received: by 2002:ac8:367d:: with SMTP id n58mr5348868qtb.260.1554383412232;
        Thu, 04 Apr 2019 06:10:12 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id q50sm12798953qtq.34.2019.04.04.06.10.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 06:10:11 -0700 (PDT)
Message-ID: <1554383410.26196.39.camel@lca.pw>
Subject: Re: page cache: Store only head pages in i_pages
From: Qian Cai <cai@lca.pw>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox
	 <willy@infradead.org>
Cc: Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org
Date: Thu, 04 Apr 2019 09:10:10 -0400
In-Reply-To: <20190401092716.mxw32y4sl66ywc2o@kshutemo-mobl1>
References: <20190324020614.GD10344@bombadil.infradead.org>
	 <897cfdda-7686-3794-571a-ecb8b9f6101f@lca.pw>
	 <20190324030422.GE10344@bombadil.infradead.org>
	 <d35bc0a3-07b7-f0ee-fdae-3d5c750a4421@lca.pw>
	 <20190329195941.GW10344@bombadil.infradead.org>
	 <1553894734.26196.30.camel@lca.pw>
	 <20190330030431.GX10344@bombadil.infradead.org>
	 <20190330141052.GZ10344@bombadil.infradead.org>
	 <20190331032326.GA10344@bombadil.infradead.org>
	 <20190401091858.s7clitbvf46nomjm@kshutemo-mobl1>
	 <20190401092716.mxw32y4sl66ywc2o@kshutemo-mobl1>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-04-01 at 12:27 +0300, Kirill A. Shutemov wrote:
> What about patch like this? (completely untested)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index f939e004c5d1..e3b9bf843dcb 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -335,12 +335,12 @@ static inline struct page *grab_cache_page_nowait(struct
> address_space *mapping,
>  
>  static inline struct page *find_subpage(struct page *page, pgoff_t offset)
>  {
> -	unsigned long index = page_index(page);
> +	unsigned long mask;
>  
>  	VM_BUG_ON_PAGE(PageTail(page), page);
> -	VM_BUG_ON_PAGE(index > offset, page);
> -	VM_BUG_ON_PAGE(index + (1 << compound_order(page)) <= offset, page);
> -	return page - index + offset;
> +
> +	mask = (1UL << compound_order(page)) - 1;
> +	return page + (offset & mask);
>  }
>  
>  struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);

No, this then leads to a panic below by LTP hugemmap05.  Still reverting the
whole "mm: page cache: store only head pages in i_pages" commit fixed the
problem.

# /opt/ltp/testcases/bin/hugemmap05
tst_test.c:1096: INFO: Timeout per run is 0h 05m 00s
hugemmap05.c:235: INFO: original nr_hugepages is 0
hugemmap05.c:248: INFO: original nr_overcommit_hugepages is 0
hugemmap05.c:116: INFO: check /proc/meminfo before allocation.
hugemmap05.c:297: INFO: HugePages_Total is 192.
hugemmap05.c:297: INFO: HugePages_Free is 192.
hugemmap05.c:297: INFO: HugePages_Surp is 64.
hugemmap05.c:297: INFO: HugePages_Rsvd is 192.
hugemmap05.c:272: INFO: First hex is 7070707
hugemmap05.c:151: INFO: check /proc/meminfo.
hugemmap05.c:297: INFO: HugePages_Total is 192.
hugemmap05.c:297: INFO: HugePages_Free is 0.
hugemmap05.c:297: INFO: HugePages_Surp is 64.
hugemmap05.c:297: INFO: HugePages_Rsvd is 0.


[10022.547977] ------------[ cut here ]------------ 
[10022.571941] kernel BUG at fs/hugetlbfs/inode.c:475! 
[10022.598304] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI 
[10022.626383] CPU: 39 PID: 13074 Comm: hugemmap05 Kdump: loaded Tainted:
G        W         5.1.0-rc3-next-20190403+ #16 
[10022.674421] Hardware name: HP ProLiant XL420 Gen9/ProLiant XL420 Gen9, BIOS
U19 12/27/2015 
[10022.711990] RIP: 0010:remove_inode_hugepages+0x706/0xa60 
[10022.735997] Code: fd ff ff e8 9c a0 99 ff e9 bc fc ff ff 48 c7 c6 40 ae 50 9f
4c 89 f7 e8 c8 3f ca ff 0f 0b 48 c7 c7 80 18 ba 9f e8 2f 63 15 00 <0f> 0b 48 c7
c7 40 18 ba 9f e8 21 63 15 00 48 8b bd 88 fd ff ff e8 
[10022.820547] RSP: 0018:ffff88883ea5f920 EFLAGS: 00010202 
[10022.844039] RAX: 015fffe000002000 RBX: 0000000000000001 RCX:
ffffffff9e2adf5c 
[10022.876130] RDX: 0000000000000001 RSI: 00000000000001df RDI:
ffffea001a0f8048 
[10022.908202] RBP: ffff88883ea5fbf8 R08: fffff9400341f00b R09:
fffff9400341f00a 
[10022.940369] R10: fffff9400341f00a R11: ffffea001a0f8057 R12:
0000000000000001 
[10022.972615] R13: ffff88883ea5fbd0 R14: ffffea001a0f8040 R15:
dffffc0000000000 
[10023.004633] FS:  00007ff5964d7740(0000) GS:ffff888847b80000(0000)
knlGS:0000000000000000 
[10023.040462] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033 
[10023.066242] CR2: 00007ff595800000 CR3: 00000004be5d0006 CR4:
00000000001606a0 
[10023.103426] Call Trace: 
[10023.114997]  ? hugetlbfs_size_to_hpages+0xe0/0xe0 
[10023.136032]  ? fsnotify_grab_connector+0x9f/0x130 
[10023.157131]  ? __lock_acquire.isra.14+0x7d7/0x2130 
[10023.178540]  ? kasan_check_read+0x11/0x20 
[10023.196471]  ? do_raw_spin_unlock+0x59/0x250 
[10023.215893]  hugetlbfs_evict_inode+0x20/0x90 
[10023.235249]  evict+0x2a4/0x5c0 
[10023.249393]  ? do_raw_spin_unlock+0x59/0x250 
[10023.268885]  iput+0x3d9/0x790 
[10023.282210]  do_unlinkat+0x461/0x650 
[10023.298318]  ? __x64_sys_rmdir+0x40/0x40 
[10023.316058]  ? __check_object_size+0x4b4/0x7f1 
[10023.336241]  ? __kasan_kmalloc.constprop.1+0xac/0xc0 
[10023.358681]  ? blkcg_exit_queue+0x1a0/0x1a0 
[10023.377428]  ? getname_flags+0x90/0x400 
[10023.394859]  __x64_sys_unlink+0x3e/0x50 
[10023.411987]  do_syscall_64+0xeb/0xb78 
[10023.428386]  ? syscall_return_slowpath+0x160/0x160 
[10023.449987]  ? __do_page_fault+0x583/0x8d0 
[10023.468333]  ? schedule+0x81/0x180 
[10023.483515]  ? exit_to_usermode_loop+0xab/0x100 
[10023.503763]  entry_SYSCALL_64_after_hwframe+0x44/0xa9 
[10023.526369] RIP: 0033:0x7ff595bbcedb 

