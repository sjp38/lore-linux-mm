Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD674C282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 10:51:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D2752789E
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 10:51:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qHKeCOdm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D2752789E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CC1C6B000E; Sun,  2 Jun 2019 06:51:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87CC26B0010; Sun,  2 Jun 2019 06:51:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76B876B0266; Sun,  2 Jun 2019 06:51:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8326B000E
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 06:51:55 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d7so11186603pfq.15
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 03:51:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PfTrtT36Gn17nPtbXHoxi/Jx7QDUfN6tc9VcJoAdbC8=;
        b=jdi0sE7b6fe1Cp/v2oXg/zLIkugDBke6RhZkSf880lzLaO51uYjGQbLc1zKgTLkOKV
         P0fLlu8+7XYQ3RwtdO9oHI2jQybIi1e6hTdIM6FVzGU79bgg3WD3J01lM8S1DCELLmbE
         fam94ELMz4Arp6w1pqVi+SRW3zja8wnH4Sf8mhHZZzR2uiZM/tg2dmPZXdSYSyVVdgCz
         jHOZTxaVBkbDcJ6rEwRhJ8/RcyX3jOFWtK/rnmSqKwgoi6al6wk05koEalAsWkibGRGi
         JF0xWoYf61Aoa70raVhOzY/iJQoGJmzWg85HMFRgC1Qu3PkCqHI6k/8M5+4p7NBS5k9k
         9v/Q==
X-Gm-Message-State: APjAAAVJfLxmeWt8pSfITI60WWD7R4znz8EEnK9VUKBIcYpPaDkLipJU
	FcneFCiX36PCr2m8Vidn9QrY2gD75b8JShwvnkjFxQQ9yUf1+m0GyAO3LT3O2lI4JrnQ4prsHUk
	pdZCVFP8qr+b1h5iV78bNXaCPGePGtqWy6yFW8Fw8VIdtkUQ29I2KouPS1q1BdxnZGQ==
X-Received: by 2002:aa7:8495:: with SMTP id u21mr23373669pfn.125.1559472714639;
        Sun, 02 Jun 2019 03:51:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHcd7qKCZpQP1TJpndSaQULKSxaUZYEsHfz2QO281klr+RUFN/N+eJECJvAvms5jRuGpv8
X-Received: by 2002:aa7:8495:: with SMTP id u21mr23373627pfn.125.1559472713441;
        Sun, 02 Jun 2019 03:51:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559472713; cv=none;
        d=google.com; s=arc-20160816;
        b=pnkjVFsqiH8zvnth0BZR8TRZg27YKssguhxmYneMQyjeYLfn1TPb+/Xk0Oky4Z/LSc
         C3FD4CLAaPvFIF5b8btZbfJxRQa9AtyVDPzFXBSNUnZMBMk727m4RV2ckhNYQF4xRRen
         l/7P4ZdLxViD+VxRKky1SVNUPrvOEZkyswjKXH3pdT08EqnxSmmty47v0R0SYNh8/FPF
         4wwJ63tHcc8AC4JtfrCzdj6TqIXPUXj+64ysIPHLtIWRiMqatCEEhzO7qEy2tnJoA6Tw
         Eflw2bbAoW4vSYL/jMAk4yVmkY65GYABxF4Ul89O0Cem2lVUyztBz7N+fnO/dCIThgX4
         4nEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PfTrtT36Gn17nPtbXHoxi/Jx7QDUfN6tc9VcJoAdbC8=;
        b=tnw/QCd1CcCkUPOsYRriHi+q8bFBrEFrsfHV0DoXU4mpqzLoCeXLYNpOBUDgV37iJX
         iAhFL/eTyg/s5PWuIE3kmZ/O4w6F4xqdffLA5lNRGYN119wclf3SC6WN6t5tXq8VNm1N
         SmgLvBVPVF48nqo6ptEDZ+hrjenbNIYYL1oX7VTroZIu+aidDO8sJMVOljew+SyBgCNH
         uJk0KiZHuE2/XmYxjXUx4OAUT09ttku1TiJkbJZxhhcc25BJskkcJjh3wnKBeh07NgqL
         S2ZC6jNiHpqQXgzAE6khD8fj5MSbuIvjDmRkqCj3kie7Oc9QVC1d/aYFB+Ht5Lw2Hz1E
         NYcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qHKeCOdm;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id ay3si13426943plb.298.2019.06.02.03.51.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 02 Jun 2019 03:51:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qHKeCOdm;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=PfTrtT36Gn17nPtbXHoxi/Jx7QDUfN6tc9VcJoAdbC8=; b=qHKeCOdmR2osGY5UXzuCb7SQF
	tM80uCUKDQk0aIKkwrPZ71T/7hhkyqtiE42WqPVw7Q6pXg3HR8T7hk5a8zMoGtt3PUMyez55dHmob
	XUlTOopWynXCso7DRgXGW6DANm08xtuKSR/zKwQ4Dl44T4Nls/bt00FRr7cYizTSdapIABRQJZP2n
	B65/Kpd76A7sP1De+q1mah+OkCqESDUtjmbzQvXRYDa6pXnThZQqmF2NuBvVl27WHiKXiCnRrQWC2
	j3msSoUK35bQlUdALPBp/Pnr+rc+4R+kW/2m9dD6k/HOuVeYrDIukC0dqcm8gvOmPDVD6X6/vDlJE
	G1MiqhDSQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hXO5e-0003VD-Hr; Sun, 02 Jun 2019 10:51:50 +0000
Date: Sun, 2 Jun 2019 03:51:50 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>,
	Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>,
	Song Liu <liu.song.a23@gmail.com>
Subject: Re: [PATCH v4] page cache: Store only head pages in i_pages
Message-ID: <20190602105150.GB23346@bombadil.infradead.org>
References: <20190307153051.18815-1-willy@infradead.org>
 <155938118174.22493.11599751119608173366@skylake-alporthouse-com>
 <155938946857.22493.6955534794168533151@skylake-alporthouse-com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155938946857.22493.6955534794168533151@skylake-alporthouse-com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 01, 2019 at 12:44:28PM +0100, Chris Wilson wrote:
> Quoting Chris Wilson (2019-06-01 10:26:21)
> > Quoting Matthew Wilcox (2019-03-07 15:30:51)
> > > Transparent Huge Pages are currently stored in i_pages as pointers to
> > > consecutive subpages.  This patch changes that to storing consecutive
> > > pointers to the head page in preparation for storing huge pages more
> > > efficiently in i_pages.
> > > 
> > > Large parts of this are "inspired" by Kirill's patch
> > > https://lore.kernel.org/lkml/20170126115819.58875-2-kirill.shutemov@linux.intel.com/
> > > 
> > > Signed-off-by: Matthew Wilcox <willy@infradead.org>
> > > Acked-by: Jan Kara <jack@suse.cz>
> > > Reviewed-by: Kirill Shutemov <kirill@shutemov.name>
> > > Reviewed-and-tested-by: Song Liu <songliubraving@fb.com>
> > > Tested-by: William Kucharski <william.kucharski@oracle.com>
> > > Reviewed-by: William Kucharski <william.kucharski@oracle.com>
> > 
> > I've bisected some new softlockups under THP mempressure to this patch.
> > They are all rcu stalls that look similar to:
> > [  242.645276] rcu: INFO: rcu_preempt detected stalls on CPUs/tasks:
> > [  242.645293] rcu:     Tasks blocked on level-0 rcu_node (CPUs 0-3): P828
> > [  242.645301]  (detected by 1, t=5252 jiffies, g=55501, q=221)
> > [  242.645307] gem_syslatency  R  running task        0   828    815 0x00004000
> > [  242.645315] Call Trace:
> > [  242.645326]  ? __schedule+0x1a0/0x440
> > [  242.645332]  ? preempt_schedule_irq+0x27/0x50
> > [  242.645337]  ? apic_timer_interrupt+0xa/0x20
> > [  242.645342]  ? xas_load+0x3c/0x80
> > [  242.645347]  ? xas_load+0x8/0x80
> > [  242.645353]  ? find_get_entry+0x4f/0x130
> > [  242.645358]  ? pagecache_get_page+0x2b/0x210
> > [  242.645364]  ? lookup_swap_cache+0x42/0x100
> > [  242.645371]  ? do_swap_page+0x6f/0x600
> > [  242.645375]  ? unmap_region+0xc2/0xe0
> > [  242.645380]  ? __handle_mm_fault+0x7a9/0xfa0
> > [  242.645385]  ? handle_mm_fault+0xc2/0x1c0
> > [  242.645393]  ? __do_page_fault+0x198/0x410
> > [  242.645399]  ? page_fault+0x5/0x20
> > [  242.645404]  ? page_fault+0x1b/0x20
> > 
> > Any suggestions as to what information you might want?
> 
> Perhaps,
> [   76.175502] page:ffffea00098e0000 count:0 mapcount:0 mapping:0000000000000000 index:0x1
> [   76.175525] flags: 0x8000000000000000()
> [   76.175533] raw: 8000000000000000 ffffea0004a7e988 ffffea000445c3c8 0000000000000000
> [   76.175538] raw: 0000000000000001 0000000000000000 00000000ffffffff 0000000000000000
> [   76.175543] page dumped because: VM_BUG_ON_PAGE(entry != page)
> [   76.175560] ------------[ cut here ]------------
> [   76.175564] kernel BUG at mm/swap_state.c:170!
> [   76.175574] invalid opcode: 0000 [#1] PREEMPT SMP
> [   76.175581] CPU: 0 PID: 131 Comm: kswapd0 Tainted: G     U            5.1.0+ #247
> [   76.175586] Hardware name:  /NUC6CAYB, BIOS AYAPLCEL.86A.0029.2016.1124.1625 11/24/2016
> [   76.175598] RIP: 0010:__delete_from_swap_cache+0x22e/0x340
> [   76.175604] Code: e8 b7 3e fd ff 48 01 1d a8 7e 04 01 48 83 c4 30 5b 5d 41 5c 41 5d 41 5e 41 5f c3 48 c7 c6 03 7e bf 81 48 89 c7 e8 92 f8 fd ff <0f> 0b 48 c7 c6 c8 7c bf 81 48 89 df e8 81 f8 fd ff 0f 0b 48 c7 c6
> [   76.175613] RSP: 0000:ffffc900008dba88 EFLAGS: 00010046
> [   76.175619] RAX: 0000000000000032 RBX: ffffea00098e0040 RCX: 0000000000000006
> [   76.175624] RDX: 0000000000000007 RSI: 0000000000000000 RDI: ffffffff81bf6d4c
> [   76.175629] RBP: ffff888265ed8640 R08: 00000000000002c2 R09: 0000000000000000
> [   76.175634] R10: 0000000273a4626d R11: 0000000000000000 R12: 0000000000000001
> [   76.175639] R13: 0000000000000040 R14: 0000000000000000 R15: ffffea00098e0000
> [   76.175645] FS:  0000000000000000(0000) GS:ffff888277a00000(0000) knlGS:0000000000000000
> [   76.175651] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   76.175656] CR2: 00007f24e4399000 CR3: 0000000002c09000 CR4: 00000000001406f0
> [   76.175661] Call Trace:
> [   76.175671]  __remove_mapping+0x1c2/0x380
> [   76.175678]  shrink_page_list+0x11db/0x1d10
> [   76.175684]  shrink_inactive_list+0x14b/0x420
> [   76.175690]  shrink_node_memcg+0x20e/0x740
> [   76.175696]  shrink_node+0xba/0x420
> [   76.175702]  balance_pgdat+0x27d/0x4d0
> [   76.175709]  kswapd+0x216/0x300
> [   76.175715]  ? wait_woken+0x80/0x80
> [   76.175721]  ? balance_pgdat+0x4d0/0x4d0
> [   76.175726]  kthread+0x106/0x120
> [   76.175732]  ? kthread_create_on_node+0x40/0x40
> [   76.175739]  ret_from_fork+0x1f/0x30
> [   76.175745] Modules linked in: i915 intel_gtt drm_kms_helper
> [   76.175754] ---[ end trace 8faf2ec849d50724 ]---
> [   76.206689] RIP: 0010:__delete_from_swap_cache+0x22e/0x340
> [   76.206708] Code: e8 b7 3e fd ff 48 01 1d a8 7e 04 01 48 83 c4 30 5b 5d 41 5c 41 5d 41 5e 41 5f c3 48 c7 c6 03 7e bf 81 48 89 c7 e8 92 f8 fd ff <0f> 0b 48 c7 c6 c8 7c bf 81 48 89 df e8 81 f8 fd ff 0f 0b 48 c7 c6
> [   76.206718] RSP: 0000:ffffc900008dba88 EFLAGS: 00010046
> [   76.206723] RAX: 0000000000000032 RBX: ffffea00098e0040 RCX: 0000000000000006
> [   76.206729] RDX: 0000000000000007 RSI: 0000000000000000 RDI: ffffffff81bf6d4c
> [   76.206734] RBP: ffff888265ed8640 R08: 00000000000002c2 R09: 0000000000000000
> [   76.206740] R10: 0000000273a4626d R11: 0000000000000000 R12: 0000000000000001
> [   76.206745] R13: 0000000000000040 R14: 0000000000000000 R15: ffffea00098e0000
> [   76.206750] FS:  0000000000000000(0000) GS:ffff888277a00000(0000) knlGS:0000000000000000
> [   76.206757] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033

Thanks for the reports, Chris.

I think they're both canaries; somehow the page cache / swap cache has
got corrupted and contains entries that it shouldn't.

This second one (with the VM_BUG_ON_PAGE in __delete_from_swap_cache)
shows a regular (non-huge) page at index 1.  There are two ways we might
have got there; one is that we asked to delete a page at index 1 which is
no longer in the cache.  The other is that we asked to delete a huge page
at index 0, but the page wasn't subsequently stored in indices 1-511.

We dump the page that we found; not the page we're looking for, so I don't
know which.  If this one's easy to reproduce, you could add:

        for (i = 0; i < nr; i++) {
                void *entry = xas_store(&xas, NULL);
+		if (entry != page) {
+			printk("Oh dear %d %d\n", i, nr);
+			dump_page(page, "deleting page");
+		}
                VM_BUG_ON_PAGE(entry != page, entry);
                set_page_private(page + i, 0);
                xas_next(&xas);
        }

I'll re-read the patch and see if I can figure out how the cache is getting
screwed up.  Given what you said, probably on the swap-in path.

