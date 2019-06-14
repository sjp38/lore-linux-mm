Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64F29C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 19:40:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4C0B2073F
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 19:40:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="F+YYh4rX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4C0B2073F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AEE56B0006; Fri, 14 Jun 2019 15:40:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65EA26B0007; Fri, 14 Jun 2019 15:40:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FF5E6B000D; Fri, 14 Jun 2019 15:40:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7FD6B0006
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 15:40:28 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z16so3043978qto.10
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:40:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=bjBy6Hvzlk7YG5WNGe0li08mtpWA+Ezg3AqqxJX1MSM=;
        b=YRgkovMPPuZpGne1f7S6+t0JeGyEV4keVPC6TR9qLm47FEIbfkq3a7nUjOq58hrMi8
         f4SMSV9OZI1DEFJbKE4QFRg3Ue6Mtjbv4Vpd5IcXNcbTQvqHZMMeVpqJ5esyxOzuICPJ
         m8XJsDR/Vy65kBk8QzWAjmsTA23WAy3Bab5lkjEuDLyIm7xDM6rIun8wmflmCqi7b7mA
         TJeUCFYl4SHzucygjqsGQvtUzP1lfaa1NLZuIhOOaI8hr9+cOraTwAVPodwJpNF5ohdl
         26rGRz/tcBMt0F+lT71Vc6cESkg2m3xvcPchv/34u0oa5VyOPqc7SS3dghxK+InyAbe2
         N/uw==
X-Gm-Message-State: APjAAAWHtwKJleUNlq/sz3byfkBpYiMkRS6eRyGFEtoqNNxvAG383Pbn
	3m8b3GQACFkk6kVY5B/uF2M10Hyz3rOwgHLEcj86qDdSK+VbsQdhlF/EAOEywCfPxKA6yCK1DHB
	yLwQ3zuJ1cGa30dAzqI7X8Yjx5w9/wBw610ZKhrApUYesSoQm7QvSG6mn93F/7bDESQ==
X-Received: by 2002:ac8:94f:: with SMTP id z15mr47959930qth.265.1560541227756;
        Fri, 14 Jun 2019 12:40:27 -0700 (PDT)
X-Received: by 2002:ac8:94f:: with SMTP id z15mr47959755qth.265.1560541224771;
        Fri, 14 Jun 2019 12:40:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560541224; cv=none;
        d=google.com; s=arc-20160816;
        b=WnOMHq7f8F7ODNA5BGfCjpaVnLbTWiesVVhVnohOwsraSLJIXoHz6pRmCahaRnXOF0
         oVv10sE3GbRoKvyCkPr5huTVoS9B7EtCPGU4E/fxPAFJi+eoxeD/Om32Z06yAJ013THc
         qKVQOMPfltKL+6md1tQPhIOLe8pXOuQI0dfwFRkcuH9/RXy3LlW3V5vVdx06Z3Ol3jZQ
         7kPNKyzjPAALDPR9E5BQZAEAxnxAmAUtFRv71IA9oXhyWGPL8cQQk4RYEvwia/v/QC7I
         l5ld0d8nOI4cnXsoRAtfLNE86OpHoYnUcTCql3iso6ME0sttRqCAhzNKA55TXz5xaXs2
         Tq9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=bjBy6Hvzlk7YG5WNGe0li08mtpWA+Ezg3AqqxJX1MSM=;
        b=bdB4Hy5tAKWPrHkT1tu+CxYaDLQJ6uIqqW/VydLAucHhc1+QpmtYsX54OYnZeR4t2h
         CAHpS/smPQ4tFJHOUpF+Q1QyOXDRCRysv03oh7iOEUnUVHckTbk5sgJbD75Ytizh4wtU
         coCMJSecvo2zrAMIVKuDsCHqrN15Ra7g2sGd+GYz8M3DNpx8oCrfXYW7TFuU9ihSKwXA
         Xx7tcaK2Phy/+NjcQzal8I8/2tt5V8Sd9E7373wQd0tgVQsB1hcRJkq4rWMs+haHC8W9
         2Vis74UAc9qwmbWDDIZoDGmKcfIocLNe5v87LtVMzdZJcU0udjb4XfvzqGtOp8hp+Kqy
         oV+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=F+YYh4rX;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor5947576qto.35.2019.06.14.12.40.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 12:40:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=F+YYh4rX;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=bjBy6Hvzlk7YG5WNGe0li08mtpWA+Ezg3AqqxJX1MSM=;
        b=F+YYh4rXMgJqOkIP8JUkZHUuHuW8n2b/5APfd/rleU+aCXVLiEXm5MK+wEfvXJWfkp
         8hyx6fs++z/xBFz0eGgLpRuRJyf0tko7YAb5394W6uANQ+4Tx7/mo2uFIV15gbJsd0L/
         RvZY0txUpKsGOzlRBN75bhxxkKYiJRIocFmSR24CQgP7jYNchwggW2PbSBobhR1YEhAm
         0UD3MTDhtj/0kUOEPhcqzh3sQzv7J0Q2i5+O/7aso8i+tVPxbBAsKWnDzM1Z/NdfLUO8
         EHE789VUQ6w1rSKJiK9uUNK2MRRjJHHZO3xqXXN8dV45o9LLDboHrnYncd/trl5RJPJ1
         uKYQ==
X-Google-Smtp-Source: APXvYqzneWzMZ1AvVIAj/TxcZxqjKH0XJ2W1oLfwfj+fRsCSSQOwfXq8tCAZw/JaPN1SyJEIK38Jqg==
X-Received: by 2002:aed:3b1c:: with SMTP id p28mr79018568qte.312.1560541222915;
        Fri, 14 Jun 2019 12:40:22 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id e8sm2137437qkn.95.2019.06.14.12.40.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 12:40:22 -0700 (PDT)
Message-ID: <1560541220.5154.23.camel@lca.pw>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from
 pfn_to_online_page()
From: Qian Cai <cai@lca.pw>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrew Morton
 <akpm@linux-foundation.org>, Oscar Salvador <osalvador@suse.de>, Linux MM
 <linux-mm@kvack.org>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>
Date: Fri, 14 Jun 2019 15:40:20 -0400
In-Reply-To: <CAPcyv4hjvBPDYKpp2Gns3-cc2AQ0AVS1nLk-K3fwXeRUvvzQLg@mail.gmail.com>
References: <1560366952-10660-1-git-send-email-cai@lca.pw>
	 <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
	 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
	 <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com>
	 <1560524365.5154.21.camel@lca.pw>
	 <CAPcyv4jAzMzFjSD22VU9Csw+kgGbf8r=XHbdJYzgL_uH_GVEvw@mail.gmail.com>
	 <CAPcyv4hjvBPDYKpp2Gns3-cc2AQ0AVS1nLk-K3fwXeRUvvzQLg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-14 at 11:57 -0700, Dan Williams wrote:
> On Fri, Jun 14, 2019 at 11:03 AM Dan Williams <dan.j.williams@intel.com>
> wrote:
> > 
> > On Fri, Jun 14, 2019 at 7:59 AM Qian Cai <cai@lca.pw> wrote:
> > > 
> > > On Fri, 2019-06-14 at 14:28 +0530, Aneesh Kumar K.V wrote:
> > > > Qian Cai <cai@lca.pw> writes:
> > > > 
> > > > 
> > > > > 1) offline is busted [1]. It looks like test_pages_in_a_zone() missed
> > > > > the
> > > > > same
> > > > > pfn_section_valid() check.
> > > > > 
> > > > > 2) powerpc booting is generating endless warnings [2]. In
> > > > > vmemmap_populated() at
> > > > > arch/powerpc/mm/init_64.c, I tried to change PAGES_PER_SECTION to
> > > > > PAGES_PER_SUBSECTION, but it alone seems not enough.
> > > > > 
> > > > 
> > > > Can you check with this change on ppc64.  I haven't reviewed this series
> > > > yet.
> > > > I did limited testing with change . Before merging this I need to go
> > > > through the full series again. The vmemmap poplulate on ppc64 needs to
> > > > handle two translation mode (hash and radix). With respect to vmemap
> > > > hash doesn't setup a translation in the linux page table. Hence we need
> > > > to make sure we don't try to setup a mapping for a range which is
> > > > arleady convered by an existing mapping.
> > > 
> > > It works fine.
> > 
> > Strange... it would only change behavior if valid_section() is true
> > when pfn_valid() is not or vice versa. They "should" be identical
> > because subsection-size == section-size on PowerPC, at least with the
> > current definition of SUBSECTION_SHIFT. I suspect maybe
> > free_area_init_nodes() is too late to call subsection_map_init() for
> > PowerPC.
> 
> Can you give the attached incremental patch a try? This will break
> support for doing sub-section hot-add in a section that was only
> partially populated early at init, but that can be repaired later in
> the series. First things first, don't regress.
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 874eb22d22e4..520c83aa0fec 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7286,12 +7286,10 @@ void __init free_area_init_nodes(unsigned long
> *max_zone_pfn)
> 
>         /* Print out the early node map */
>         pr_info("Early memory node ranges\n");
> -       for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
> +       for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
>                 pr_info("  node %3d: [mem %#018Lx-%#018Lx]\n", nid,
>                         (u64)start_pfn << PAGE_SHIFT,
>                         ((u64)end_pfn << PAGE_SHIFT) - 1);
> -               subsection_map_init(start_pfn, end_pfn - start_pfn);
> -       }
> 
>         /* Initialise every node */
>         mminit_verify_pageflags_layout();
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 0baa2e55cfdd..bca8e6fa72d2 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -533,6 +533,7 @@ static void __init sparse_init_nid(int nid,
> unsigned long pnum_begin,
>                 }
>                 check_usemap_section_nr(nid, usage);
>                 sparse_init_one_section(__nr_to_section(pnum), pnum,
> map, usage);
> +               subsection_map_init(section_nr_to_pfn(pnum),
> PAGES_PER_SECTION);
>                 usage = (void *) usage + mem_section_usage_size();
>         }
>         sparse_buffer_fini();

It works fine except it starts to trigger slab debugging errors during boot. Not
sure if it is related yet.

[  OK  ] Mounted /boot.
[  OK  ] Started LVM event activation on device 8:1.
[  OK  ] Found device /dev/mapper/rhel_ibm--p9wr--06-home.
         Mounting /home...
[   47.553541][  T920]
=============================================================================
[   47.553586][  T920] BUG kmem_cache (Not tainted): Poison overwritten
[   47.553618][  T920] -------------------------------------------------------
----------------------
[   47.553618][  T920] 
[   47.553655][  T920] Disabling lock debugging due to kernel taint
[   47.553697][  T920] INFO: 0x0000000056823988-0x0000000050e781ac. First byte
0x0 instead of 0x6b
[   47.553739][  T920] INFO: Allocated in create_cache+0x9c/0x2f0 age=1381
cpu=104 pid=751
[   47.553777][  T920] 	__slab_alloc+0x34/0x60
[   47.553801][  T920] 	kmem_cache_alloc+0x4e4/0x5a0
[   47.553815][  T920] 	create_cache+0x9c/0x2f0
[   47.553856][  T920] 	memcg_create_kmem_cache+0x150/0x1b0
[   47.553871][  T920] 	memcg_kmem_cache_create_func+0x3c/0x150
[   47.553888][  T920] 	process_one_work+0x300/0x800
[   47.553939][  T920] 	worker_thread+0x78/0x540
[   47.553991][  T920] 	kthread+0x1b8/0x1c0
[   47.554030][  T920] 	ret_from_kernel_thread+0x5c/0x70
[   47.554057][  T920] INFO: Freed in slab_kmem_cache_release+0x60/0xc0 age=379
cpu=94 pid=484
[   47.554100][  T920] 	kmem_cache_free+0x58c/0x680
[   47.554128][  T920] 	slab_kmem_cache_release+0x60/0xc0
[   47.554166][  T920] 	kmem_cache_release+0x24/0x40
[   47.554204][  T920] 	kobject_put+0x12c/0x300
[   47.554253][  T920] 	sysfs_slab_release+0x38/0x50
[   47.554293][  T920] 	shutdown_cache+0x2d4/0x3b0
[   47.554331][  T920] 	kmemcg_cache_shutdown_fn+0x20/0x40
[   47.554360][  T920] 	kmemcg_workfn+0x64/0xb0
[   47.554385][  T920] 	process_one_work+0x300/0x800
[   47.554420][  T920] 	worker_thread+0x78/0x540
[   47.554461][  T920] 	kthread+0x1b8/0x1c0
[   47.554486][  T920] 	ret_from_kernel_thread+0x5c/0x70
[   47.554534][  T920] INFO: Slab 0x00000000e5a3850e objects=21 used=21
fp=0x000000001c184c17 flags=0x83fffc000000200
[   47.554616][  T920] INFO: Object 0x000000004f30f83e @offset=40064
fp=0x00000000c5c64399
[   47.554616][  T920] 
[   47.554690][  T920] Redzone 00000000e463ee75: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.554758][  T920] Redzone 000000004b6f4884: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.554813][  T920] Redzone 000000005c73936a: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.554881][  T920] Redzone 00000000e294755c: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.554956][  T920] Redzone 0000000026ba2e61: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.555038][  T920] Redzone 00000000210aec0a: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.555108][  T920] Redzone 0000000047851caf: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.555181][  T920] Redzone 00000000a88fe569: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.555262][  T920] Object 000000004f30f83e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.555307][  T920] Object 00000000d4d50ef6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.555375][  T920] Object 000000002c43675d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.555441][  T920] Object 000000002b7fff5c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.555511][  T920] Object 00000000eaa8b500: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.555581][  T920] Object 00000000e149fa9d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.555660][  T920] Object 000000004a87fa48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.555741][  T920] Object 0000000093301b2a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.555797][  T920] Object 00000000dc013892: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.555864][  T920] Object 000000005fc6a904: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.555931][  T920] Object 000000005f9f9d53: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.555994][  T920] Object 000000003b35200a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.556063][  T920] Object 000000006800397f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.556132][  T920] Object 0000000004744c02: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.556200][  T920] Object 000000003241106b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.556267][  T920] Object 00000000b051d781: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.556324][  T920] Object 00000000ee00435d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.556394][  T920] Object 00000000e4c76b09: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.556452][  T920] Object 00000000a955601d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.556521][  T920] Object 00000000f23d6d54: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.556589][  T920] Object 00000000948d914f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.556671][  T920] Object 000000009b83b552: 6b 6b 6b 6b 6b 6b 6b 6b 00 00 00
00 00 00 00 00  kkkkkkkk........
[   47.556742][  T920] Object 0000000098183b83: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.556798][  T920] Object 000000005ae5b5d3: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.556867][  T920] Object 00000000abd5b5de: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.556923][  T920] Object 00000000e876d61c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557018][  T920] Object 0000000013c0228e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557084][  T920] Object 00000000307c7694: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557164][  T920] Object 000000000367c078: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557234][  T920] Object 000000008665e37a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557307][  T920] Object 0000000086fd7e15: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557376][  T920] Object 00000000429b53bb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557431][  T920] Object 00000000cea8da45: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557487][  T920] Object 00000000ca4efb98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557557][  T920] Object 000000005a281995: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557626][  T920] Object 00000000cf084d69: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557687][  T920] Object 000000001fdf79e5: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557777][  T920] Object 000000005f5e054e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557833][  T920] Object 0000000046b6818a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557891][  T920] Object 00000000caac6967: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.557958][  T920] Object 00000000d540458f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.558029][  T920] Object 00000000c0bf366b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.558098][  T920] Object 00000000d3dfbf6f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.558165][  T920] Object 000000001a35dd94: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.558248][  T920] Object 00000000e5f4aba1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.558328][  T920] Object 00000000c566b1d4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.558384][  T920] Object 00000000633ab657: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.558442][  T920] Object 000000007312cef0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.558512][  T920] Object 00000000c8b1d277: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.558631][  T920] Object 00000000a6e5ae5f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.558748][  T920] Object 0000000094fa22e6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.558862][  T920] Object 000000004df6b97f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.559003][  T920] Object 0000000027e179b2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.559099][  T920] Object 000000001aa9ac19: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.559245][  T920] Object 000000006ba9ce74: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.559363][  T920] Object 00000000c9dcd994: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.559478][  T920] Object 00000000741f43aa: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.559595][  T920] Object 00000000b933f584: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.559723][  T920] Object 000000003fcd984d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.559834][  T920] Object 0000000097669358: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.559949][  T920] Object 0000000086db6bff: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.560069][  T920] Object 00000000fda6b38a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.560191][  T920] Object 000000008d81cdc4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.560307][  T920] Object 00000000a9b762b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.560437][  T920] Object 0000000030205af6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.560546][  T920] Object 000000000232113f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.560664][  T920] Object 00000000de5e4928: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.560792][  T920] Object 00000000b6bfd22c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.560902][  T920] Object 00000000bcf857ae: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.561016][  T920] Object 0000000049aad6d1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.561131][  T920] Object 00000000e95cd85d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.561255][  T920] Object 000000002354a060: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.561361][  T920] Object 0000000099fb38b6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.561521][  T920] Object 00000000622d0c0d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.561630][  T920] Object 00000000802f3461: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.561750][  T920] Object 000000000f29e0cd: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.561868][  T920] Object 0000000079ec25b2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.561979][  T920] Object 0000000014d121be: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.562108][  T920] Object 000000001751c3dc: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.562207][  T920] Object 00000000fa176337: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.562328][  T920] Object 000000009fd0cdfb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.562456][  T920] Object 00000000e3504fc7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.562568][  T920] Object 000000005610dc63: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.562686][  T920] Object 00000000566eae63: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.562812][  T920] Object 00000000e3bb1fde: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.562945][  T920] Object 00000000bf6c1146: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.563059][  T920] Object 000000005c9138b3: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.563174][  T920] Object 000000005e2563c6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.563291][  T920] Object 00000000a140b499: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.563412][  T920] Object 00000000d9a0bf91: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.563542][  T920] Object 0000000078b76649: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.563651][  T920] Object 000000009ea820a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.563770][  T920] Object 0000000028c41bed: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.563900][  T920] Object 00000000f51e38ad: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.564021][  T920] Object 00000000c02d82b9: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.564158][  T920] Object 0000000058ebb46f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.564264][  T920] Object 00000000ea08dece: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.564386][  T920] Object 000000007a3b09c4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.564498][  T920] Object 000000001a5867fa: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.564608][  T920] Object 0000000032da9381: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.564723][  T920] Object 00000000ff06b6e1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.564859][  T920] Object 00000000c498e74f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.564962][  T920] Object 00000000fa5b10ba: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.565094][  T920] Object 0000000091a64fdf: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.565211][  T920] Object 00000000d8cbdea4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.565330][  T920] Object 00000000822f8c2b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.565458][  T920] Object 0000000077baccaa: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.565574][  T920] Object 0000000020f7f917: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.565692][  T920] Object 000000002665ae1e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.565803][  T920] Object 000000009a085cfd: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.565914][  T920] Object 00000000a6349306: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.566043][  T920] Object 00000000ed8bb9c6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.566187][  T920] Object 000000007b63b8ca: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.566345][  T920] Object 00000000ccc27101: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.566471][  T920] Object 00000000ef4a11c7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.566600][  T920] Object 00000000990e4e67: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.566729][  T920] Object 000000001441daf8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.566830][  T920] Object 00000000629b60fd: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.566959][  T920] Object 0000000005756df5: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.567095][  T920] Object 000000001335c55d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.567202][  T920] Object 000000008a10e58c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.567311][  T920] Object 0000000075bd1fe7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.567466][  T920] Object 000000007e35380c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.567583][  T920] Object 00000000845eff4e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.567704][  T920] Object 00000000785bc98b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.567847][  T920] Object 0000000014e0c8d4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.567962][  T920] Object 0000000016a9470d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.568077][  T920] Object 0000000043305971: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.568190][  T920] Object 000000008c5c5689: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.568340][  T920] Object 0000000036f07dab: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.568445][  T920] Object 00000000b2bfcacf: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.568542][  T920] Object 000000000ae7f17b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.568650][  T920] Object 00000000a8314823: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.568791][  T920] Object 000000008edcb310: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.568937][  T920] Object 00000000c1c5a76b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.569040][  T920] Object 00000000d3df47c1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.569163][  T920] Object 00000000409f0701: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.569289][  T920] Object 00000000d905df04: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.569413][  T920] Object 0000000093e68225: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.569556][  T920] Object 00000000e31c71b1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.569658][  T920] Object 00000000bb083b6d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.569764][  T920] Object 0000000033ec023f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.569905][  T920] Object 0000000059b795ff: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.570030][  T920] Object 00000000a433364d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.570143][  T920] Object 0000000056e6045e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.570260][  T920] Object 00000000496ffb36: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.570391][  T920] Object 0000000053fd9d70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.570528][  T920] Object 000000005ba5d6bc: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.570625][  T920] Object 0000000022c2afa2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.570745][  T920] Object 0000000035b58153: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.570888][  T920] Object 00000000cf9e2d08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.571024][  T920] Object 0000000020e2e55a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.571136][  T920] Object 00000000dded7e78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.571237][  T920] Object 000000005b5dc165: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.571357][  T920] Object 00000000ed1631b2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.571489][  T920] Object 00000000bb9fcf9e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.571628][  T920] Object 000000000b203ce1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[   47.571724][  T920] Redzone 000000004649abf0: bb bb bb bb bb bb bb
bb                          ........
[   47.571827][  T920] Padding 000000009c7fa5f3: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   47.571970][  T920] Padding 00000000693f60d5: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   47.572091][  T920] Padding 000000002f6715e7: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   47.572205][  T920] Padding 00000000dd7440e4: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   47.572349][  T920] Padding 000000003da6a5e5: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   47.572472][  T920] Padding 00000000ddafc3df: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   47.572576][  T920] Padding 000000001892aa1d: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   47.572717][  T920] CPU: 73 PID: 920 Comm: kworker/73:1 Tainted:
G    B             5.2.0-rc4-next-20190614+ #15
[   47.572835][  T920] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
[   47.572934][  T920] Call Trace:
[   47.572972][  T920] [c00020152898f680] [c00000000089793c]
dump_stack+0xb0/0xf4 (unreliable)
[   47.573063][  T920] [c00020152898f6c0] [c0000000003df8a8]
print_trailer+0x23c/0x264
[   47.573153][  T920] [c00020152898f750] [c0000000003cedd8]
check_bytes_and_report+0x138/0x160
[   47.573266][  T920] [c00020152898f7f0] [c0000000003d1de8]
check_object+0x348/0x3e0
[   47.573363][  T920] [c00020152898f860] [c0000000003d2038]
alloc_debug_processing+0x1b8/0x2c0
[   47.573447][  T920] [c00020152898f900] [c0000000003d5214]
___slab_alloc+0xb94/0xf80
[   47.573538][  T920] [c00020152898fa30] [c0000000003d5634]
__slab_alloc+0x34/0x60
[   47.573639][  T920] [c00020152898fa60] [c0000000003d5b44]
kmem_cache_alloc+0x4e4/0x5a0
[   47.573731][  T920] [c00020152898faf0] [c00000000033288c]
create_cache+0x9c/0x2f0
[   47.573830][  T920] [c00020152898fb60] [c000000000333350]
memcg_create_kmem_cache+0x150/0x1b0
[   47.573931][  T920] [c00020152898fc00] [c00000000040f15c]
memcg_kmem_cache_create_func+0x3c/0x150
[   47.574032][  T920] [c00020152898fc40] [c00000000014b060]
process_one_work+0x300/0x800
[   47.574148][  T920] [c00020152898fd20] [c00000000014b5d8]
worker_thread+0x78/0x540
[   47.574235][  T920] [c00020152898fdb0] [c000000000155ef8] kthread+0x1b8/0x1c0
[   47.574338][  T920] [c00020152898fe20] [c00000000000b4cc]
ret_from_kernel_thread+0x5c/0x70
[   47.574407][  T920] FIX kmem_cache: Restoring 0x0000000056823988-
0x0000000050e781ac=0x6b
[   47.574407][  T920] 
[   47.574550][  T920] FIX kmem_cache: Marking all objects used
[   47.622056][ T3790] XFS (dm-2): Mounting V5 Filesystem
[  OK  ] Started LVM event activation on device 8:19.
[   47.833132][ T3790] XFS (dm-2): Ending clean mount
[  OK  ] Mounted /home.
[  OK  ] Reached target Local File Systems.
         Starting Tell Plymouth To Write Out Runtime Data...
         Starting Import network configuration from initramfs...
         Starting Restore /run/initramfs on shutdown...
[   47.959491][  T924]
=============================================================================
[   47.959532][  T924] BUG kmem_cache (Tainted: G    B            ): Poison
overwritten
[   47.959565][  T924] -------------------------------------------------------
----------------------
[   47.959565][  T924] 
[   47.959601][  T924] INFO: 0x000000005bf9327f-0x0000000012b186d0. First byte
0x0 instead of 0x6b
[   47.959643][  T924] INFO: Allocated in create_cache+0x9c/0x2f0 age=1444
cpu=104 pid=751
[   47.959684][  T924] 	__slab_alloc+0x34/0x60
[   47.959708][  T924] 	kmem_cache_alloc+0x4e4/0x5a0
[   47.959722][  T924] 	create_cache+0x9c/0x2f0
[   47.959761][  T924] 	memcg_create_kmem_cache+0x150/0x1b0
[   47.959811][  T924] 	memcg_kmem_cache_create_func+0x3c/0x150
[   47.959850][  T924] 	process_one_work+0x300/0x800
[   47.959874][  T924] 	worker_thread+0x78/0x540
[   47.959900][  T924] 	kthread+0x1b8/0x1c0
[   47.959913][  T924] 	ret_from_kernel_thread+0x5c/0x70
[   47.959938][  T924] INFO: Freed in slab_kmem_cache_release+0x60/0xc0 age=472
cpu=94 pid=484
[   47.960008][  T924] 	kmem_cache_free+0x58c/0x680
[   47.960045][  T924] 	slab_kmem_cache_release+0x60/0xc0
[   47.960081][  T924] 	kmem_cache_release+0x24/0x40
[   47.960121][  T924] 	kobject_put+0x12c/0x300
[   47.960146][  T924] 	sysfs_slab_release+0x38/0x50
[   47.960171][  T924] 	shutdown_cache+0x2d4/0x3b0
[   47.960246][  T924] 	kmemcg_cache_shutdown_fn+0x20/0x40
[   47.960282][  T924] 	kmemcg_workfn+0x64/0xb0
[   47.960330][  T924] 	process_one_work+0x300/0x800
[   47.960366][  T924] 	worker_thread+0x78/0x540
[   47.960413][  T924] 	kthread+0x1b8/0x1c0
[   47.960448][  T924] 	ret_from_kernel_thread+0x5c/0x70
[   47.960462][  T924] INFO: Slab 0x00000000db2ed41f objects=21 used=21
fp=0x000000001c184c17 flags=0x83fffc000000200
[   47.960506][  T924] INFO: Object 0x00000000c0f66338 @offset=21632
fp=0x00000000b3cc6b7b
[   47.960506][  T924] 
[   47.960580][  T924] Redzone 00000000ff912fe4: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.960659][  T924] Redzone 0000000071d29417: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.960717][  T924] Redzone 000000001cc1e9aa: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.960784][  T924] Redzone 0000000057ad4648: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.960876][  T924] Redzone 0000000063aa1956: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.960943][  T924] Redzone 000000005e03e281: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.961013][  T924] Redzone 00000000d1d049b4: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.961068][  T924] Redzone 00000000ea455f4b: bb bb bb bb bb bb bb bb bb bb
bb bb bb bb bb bb  ................
[   47.961134][  T924] Object 00000000c0f66338: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.961201][  T924] Object 0000000054d58d73: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.961270][  T924] Object 0000000080b3d18f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.961326][  T924] Object 00000000cbecca66: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.961395][  T924] Object 00000000e6f9bb18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.961462][  T924] Object 00000000528c4c8d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.961532][  T924] Object 000000002cac1453: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.961601][  T924] Object 000000002e2b052f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.961647][  T924] Object 00000000af6b3436: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.961714][  T924] Object 00000000d8c9093b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.961782][  T924] Object 00000000a443983c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.961862][  T924] Object 000000007140fb0a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.961942][  T924] Object 0000000092423efb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.962008][  T924] Object 00000000068bbb54: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.962065][  T924] Object 00000000e1ec757d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.962134][  T924] Object 000000005dfea769: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.962201][  T924] Object 0000000044039bb7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.962271][  T924] Object 000000002f80f51a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.962369][  T924] Object 0000000030e34515: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.962451][  T924] Object 0000000055d8fc06: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.962506][  T924] Object 00000000f59d5107: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.962573][  T924] Object 00000000874e788f: 6b 6b 6b 6b 6b 6b 6b 6b 00 00 00
00 00 00 00 00  kkkkkkkk........
[   47.962628][  T924] Object 000000006b718d20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.962711][  T924] Object 00000000340f3026: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.962778][  T924] Object 00000000d4e61a50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.962864][  T924] Object 000000007038e3bb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.962956][  T924] Object 000000009960f486: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.963033][  T924] Object 000000006cad65a2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.963114][  T924] Object 00000000c99fba18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.963182][  T924] Object 00000000a106e4d7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.963251][  T924] Object 00000000aeaeedbf: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.963345][  T924] Object 00000000719d60fd: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.963410][  T924] Object 00000000dfd03254: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.963466][  T924] Object 000000008ad4ff34: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.963534][  T924] Object 00000000e881cddb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.963606][  T924] Object 00000000cf1484d6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.963675][  T924] Object 00000000695331d9: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.963732][  T924] Object 00000000cdded125: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.963815][  T924] Object 000000006ce2abec: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.963882][  T924] Object 00000000b211e85a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.963977][  T924] Object 0000000053457b75: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.964031][  T924] Object 00000000a6f8d40e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.964097][  T924] Object 00000000a02a557f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.964152][  T924] Object 0000000059a320fb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.964218][  T924] Object 00000000aaa0c239: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.964288][  T924] Object 000000001add4b11: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.964358][  T924] Object 000000007bf168d6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.964426][  T924] Object 0000000084150200: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.964493][  T924] Object 000000000642da96: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.964562][  T924] Object 00000000f1c32a58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.964632][  T924] Object 00000000cfd89b02: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.964698][  T924] Object 000000000c486447: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.964803][  T924] Object 0000000011627406: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.964928][  T924] Object 000000008d53fcdc: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.965024][  T924] Object 000000009dffdfd4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.965143][  T924] Object 000000005d0eae17: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.965270][  T924] Object 0000000075227d08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.965388][  T924] Object 00000000c8898d84: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.965520][  T924] Object 000000005914b371: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.965659][  T924] Object 00000000a96aa124: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.965773][  T924] Object 00000000c22b7e51: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.965860][  T924] Object 00000000a7c6ee60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.966008][  T924] Object 0000000009caf8c1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.966118][  T924] Object 00000000135fecb7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.966238][  T924] Object 00000000370f2819: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.966351][  T924] Object 0000000055aac92d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.966484][  T924] Object 00000000ca111fe9: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.966603][  T924] Object 00000000b8ad384d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.966728][  T924] Object 000000001b7ced3d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.966858][  T924] Object 0000000078732f09: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.966968][  T924] Object 00000000ee57157a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.967106][  T924] Object 000000000f1d3779: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.967230][  T924] Object 00000000eacfc252: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.967332][  T924] Object 000000006abcee92: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.967470][  T924] Object 00000000d1381811: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.967589][  T924] Object 00000000a8b70685: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.967711][  T924] Object 00000000ac0cc71f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.967837][  T924] Object 000000005f11afd2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.967940][  T924] Object 000000009b914a99: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.968079][  T924] Object 00000000ae873765: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.968195][  T924] Object 00000000057d5d97: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.968327][  T924] Object 000000007fcca92d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.968432][  T924] Object 00000000f09756c6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.968551][  T924] Object 0000000095172d31: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.968681][  T924] Object 000000009ca23ebb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.968805][  T924] Object 000000003e8e08f5: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.968909][  T924] Object 00000000d908bbe6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.969031][  T924] Object 000000001a41d8fc: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.969149][  T924] Object 0000000062402f77: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.969270][  T924] Object 00000000dba67e95: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.969403][  T924] Object 00000000a8001b4d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.969518][  T924] Object 0000000006400943: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.969640][  T924] Object 00000000fc2c21bb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.969762][  T924] Object 000000003be34237: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.969875][  T924] Object 00000000d2cddc41: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.970008][  T924] Object 0000000046257224: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.970127][  T924] Object 00000000bc6dd975: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.970248][  T924] Object 00000000397e5d55: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.970363][  T924] Object 0000000022bd4778: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.970477][  T924] Object 00000000963f1ff1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.970604][  T924] Object 00000000043daeca: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.970744][  T924] Object 00000000ee7d0bf1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.970859][  T924] Object 00000000e4e7ea50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.971005][  T924] Object 000000009ed61c4e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.971087][  T924] Object 00000000064b9367: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.971242][  T924] Object 0000000079caca89: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.971344][  T924] Object 00000000b511810c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.971479][  T924] Object 0000000080ad1f92: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.971578][  T924] Object 000000006ca56518: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.971702][  T924] Object 000000000815f5f3: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.971818][  T924] Object 000000005550f6c1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.971952][  T924] Object 00000000d3291dbe: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.972060][  T924] Object 00000000bb53e90f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.972177][  T924] Object 00000000459055fc: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.972299][  T924] Object 0000000064bfcd86: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.972425][  T924] Object 0000000052b345e7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.972552][  T924] Object 00000000f64553cc: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.972666][  T924] Object 00000000e39fc888: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.972775][  T924] Object 0000000037e7c5f2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.972897][  T924] Object 00000000251af3d2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.973048][  T924] Object 00000000bf4035c9: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.973132][  T924] Object 00000000df11fb12: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.973309][  T924] Object 000000004c13fbfe: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.973412][  T924] Object 00000000a6ba6ac5: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.973530][  T924] Object 000000004328e43a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.973668][  T924] Object 000000003538c4db: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.973782][  T924] Object 000000004314dd6f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.973889][  T924] Object 000000000303753f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.974023][  T924] Object 0000000004c2996d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.974151][  T924] Object 00000000498eff7f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.974339][  T924] Object 00000000aea60dfa: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.974453][  T924] Object 00000000a122fe27: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.974577][  T924] Object 00000000fcd25601: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.974729][  T924] Object 00000000c02923fb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.974822][  T924] Object 0000000058301ba5: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.974971][  T924] Object 000000006f987dfb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.975128][  T924] Object 0000000027a5dedc: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.975264][  T924] Object 0000000005b3ecd7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.975375][  T924] Object 00000000a6946bb3: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.975474][  T924] Object 00000000df895e5e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.975609][  T924] Object 000000005a8cfb87: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.975729][  T924] Object 000000005a718b0e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.975863][  T924] Object 0000000029f7cb73: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.975961][  T924] Object 00000000c49cf6fe: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.976092][  T924] Object 00000000382c5b8a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.976223][  T924] Object 00000000bbdbbd53: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.976326][  T924] Object 0000000009866104: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.976479][  T924] Object 000000006fb54a35: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.976593][  T924] Object 00000000ba138b15: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.976714][  T924] Object 000000004896d243: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.976836][  T924] Object 00000000715e3719: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.976961][  T924] Object 00000000b31a6327: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.977080][  T924] Object 00000000469b3fa7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.977211][  T924] Object 000000000ca34717: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.977324][  T924] Object 0000000062afcbf2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.977452][  T924] Object 00000000ec39b624: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   47.977578][  T924] Object 00000000d9874c53: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[   47.977686][  T924] Redzone 000000004d458caf: bb bb bb bb bb bb bb
bb                          ........
[   47.977805][  T924] Padding 000000003393d98c: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   47.977909][  T924] Padding 000000000d637794: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   47.978025][  T924] Padding 00000000d4fd521d: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   47.978192][  T924] Padding 00000000325c4503: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   47.978304][  T924] Padding 00000000f795c69f: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   47.978412][  T924] Padding 00000000e6145184: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   47.978570][  T924] Padding 000000001665d379: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[   47.978706][  T924] CPU: 83 PID: 924 Comm: kworker/83:1 Tainted:
G    B             5.2.0-rc4-next-20190614+ #15
[   47.978840][  T924] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
[   47.978920][  T924] Call Trace:
[   47.978980][  T924] [c0002015285cf680] [c00000000089793c]
dump_stack+0xb0/0xf4 (unreliable)
[   47.979069][  T924] [c0002015285cf6c0] [c0000000003df8a8]
print_trailer+0x23c/0x264
[   47.979192][  T924] [c0002015285cf750] [c0000000003cedd8]
check_bytes_and_report+0x138/0x160
[   47.979288][  T924] [c0002015285cf7f0] [c0000000003d1de8]
check_object+0x348/0x3e0
[   47.979373][  T924] [c0002015285cf860] [c0000000003d2038]
alloc_debug_processing+0x1b8/0x2c0
[   47.979495][  T924] [c0002015285cf900] [c0000000003d5214]
___slab_alloc+0xb94/0xf80
[   47.979582][  T924] [c0002015285cfa30] [c0000000003d5634]
__slab_alloc+0x34/0x60
[   47.979669][  T924] [c0002015285cfa60] [c0000000003d5b44]
kmem_cache_alloc+0x4e4/0x5a0
[   47.979765][  T924] [c0002015285cfaf0] [c00000000033288c]
create_cache+0x9c/0x2f0
[   47.979898][  T924] [c0002015285cfb60] [c000000000333350]
memcg_create_kmem_cache+0x150/0x1b0
[   47.979997][  T924] [c0002015285cfc00] [c00000000040f15c]
memcg_kmem_cache_create_func+0x3c/0x150
[   47.980102][  T924] [c0002015285cfc40] [c00000000014b060]
process_one_work+0x300/0x800
[   47.980206][  T924] [c0002015285cfd20] [c00000000014b5d8]
worker_thread+0x78/0x540
[   47.980292][  T924] [c0002015285cfdb0] [c000000000155ef8] kthread+0x1b8/0x1c0
[   47.980400][  T924] [c0002015285cfe20] [c00000000000b4cc]
ret_from_kernel_thread+0x5c/0x70
[   47.980488][  T924] FIX kmem_cache: Restoring 0x000000005bf9327f-
0x0000000012b186d0=0x6b
[   47.980488][  T924] 
[   47.980640][  T924] FIX kmem_cache: Marking all objects used
[  OK  ] Started Restore /run/initramfs on shutdown.
[  OK  ] Started Tell Plymouth To Write Out Runtime Data.
[  OK  ] Started Import network configuration from initramfs.
         Starting Create Volatile Files and Directories...
[  OK  ] Started Create Volatile Files and Directories.
         Starting Update UTMP about System Boot/Shutdown...

