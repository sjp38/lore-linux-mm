Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C6E3C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 10:56:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEF782084D
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 10:56:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="J9Jg2R5g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEF782084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91DB16B0010; Fri, 12 Apr 2019 06:56:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A85A6B026B; Fri, 12 Apr 2019 06:56:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 722056B026C; Fri, 12 Apr 2019 06:56:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 353CF6B0010
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 06:56:41 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g92so6069222plb.9
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 03:56:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ngFAQdcMqMVNRpiFsEBZBxKngJSPU1lSHcrtbpHUw60=;
        b=QiDh/eg92JidKlihDTknqNz0KzY2ilE1tjf3cFFdrLOhHPmVJBoGh3dfzeotdt0dQt
         XDqI11B6Qag2UnjpE5NUjEfCEToUvIqMJ1YnymqqD85dbMzrxi+71fDtz0OJbh+h5cYk
         mbL0HwPi8dq5MH4+EA4P8B0TuNwcrrrHgXUrt0m2TCoV6OntUbfl3CQHfAWUKOG3T6ir
         tMhI80epZqTAAn3fhnT01Yz7WoJDoIF8HWfwLI0MUiOHRRKdSqxXlBO+vz4O2TI4uWCb
         +xNVTp6oeEHZK3CwJpnybAyR01jlgRFijfOsF53ibiVTMcBFmTPc6Rhxw1n3wC/xmfyt
         XB8Q==
X-Gm-Message-State: APjAAAWTQBcyV/Nc/IYaVWbyGmsvMogiwanx7ga34TRaW8QQ+5gFEQNj
	D5soYGnhrtKGEbn5VE7ym2A7G44z+QXPC401PotgKFYstiHj30QE1k3C9tNslr8cassb70KLd3L
	mXjz3wPsCb4iT7SJiJTt0BOu/8jB9LPSUTP1XWUQVntTA833z5IVRbKA9/n57NwyIhQ==
X-Received: by 2002:a62:4649:: with SMTP id t70mr56281289pfa.100.1555066600219;
        Fri, 12 Apr 2019 03:56:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsw2DC7mFhkIbYUuf8C1x5+ojupbVDkRPs/THXTPXWvjI28l9tYRU3kovaqqj/LZ1n2NxD
X-Received: by 2002:a62:4649:: with SMTP id t70mr56281212pfa.100.1555066598967;
        Fri, 12 Apr 2019 03:56:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555066598; cv=none;
        d=google.com; s=arc-20160816;
        b=nisiZ8lroaP5JwQVEYM1C+s0rIgw55jslTR2JWKxwhCZFOEBGd8TppTPP+DoZQLQD0
         I699o3LgKW45gmWZiJPgltzgn1GOwUf08wCZm4tWW+8sVIBA7Tjo+RYYjg7xhxzRQU4V
         +LNCdjbFHvoZLry5kgrwu2RNv94+QeGRHaIBQfvrwEpXsITGC09eFk7Q3C4La6+SsyC/
         rCtDK+/sztFmziBWOen1c5KrvvqWUqZs4uJq9XWfdv4MJDEsWZajkc6OjFSMTyPI+9jx
         bIKlcKSt4cC/XnTo4kzy56BRYB8CqpSTagyBYTtI3Bj9/JKNPfvbms7HfOm5MC4bKDrM
         d0Jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ngFAQdcMqMVNRpiFsEBZBxKngJSPU1lSHcrtbpHUw60=;
        b=RESHhxQYhVmvTBEJpDkkFpgx2xCaCuKx5k5q0cHk6sLH2FNEHXp3RYuM215TU5o88o
         fBdihtIk1MThh1M7WVb9Cg0xsCAuw84coZeWp/44yq3eMClA/0dDzLMxKOskE89LIj+L
         ZJNfw4VF1edgr6OFpgC+mgiMp/w3tk0khVWQxHpzrTFfiLYz+pfrD+aVAAtHvgQ60vLf
         jED4w50+Ng4sf7XwbjOBF1Arrj7hGm8GqghSB9OCKHGvVCOlft6K+bZtGkrCAP4+1QgO
         qouqfz16lcfnShqeq27TWyLYVBFpZNwSz4+XPONsbm5sZVVUVRYlRiOizMbOTkWnfu5Z
         nkiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=J9Jg2R5g;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l191si23572870pfc.213.2019.04.12.03.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Apr 2019 03:56:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=J9Jg2R5g;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ngFAQdcMqMVNRpiFsEBZBxKngJSPU1lSHcrtbpHUw60=; b=J9Jg2R5gsQ02PmCTXqmXprt9P
	T5ITwdjTav79v9DkbMhz5rdvN7e3qfbEGzNTW277SoE9BPBK7blCBnHG+lLI3rjH+LvAhOARWiExx
	eGhhuyxAGIK1Yw0J5eguj+3ZlN1cF8vLt32XcMQ68LGMHR5IFZcm5L2eKFPYBiBTiVCY50VpqllLg
	tozvrGvwjdydn3hhR4dcnFnyh04OCPFw3BeEVZio8KMWoSn3PbOSRkirsSRb8Gx/UGNavZAd/wDNX
	ZtoLnnDrbpb6k+PBXLDCi+15kRu7nvkufY3hyc5QP5kWtgiKSgsSIb2yUVbW6teiUhtuwMyQsETZK
	RVbZb0R5g==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hEtrH-0006rc-J8; Fri, 12 Apr 2019 10:56:35 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 9CE092038C257; Fri, 12 Apr 2019 12:56:33 +0200 (CEST)
Date: Fri, 12 Apr 2019 12:56:33 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: kernel test robot <lkp@intel.com>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	Andy Lutomirski <luto@kernel.org>, Nadav Amit <namit@vmware.com>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"):  BUG:
 KASAN: stack-out-of-bounds in __change_page_attr_set_clr
Message-ID: <20190412105633.GM14281@hirez.programming.kicks-ass.net>
References: <5cae03c4.iIPk2cWlfmzP0Zgy%lkp@intel.com>
 <20190411193906.GA12232@hirez.programming.kicks-ass.net>
 <20190411195424.GL14281@hirez.programming.kicks-ass.net>
 <20190411211348.GA8451@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411211348.GA8451@worktop.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 11:13:48PM +0200, Peter Zijlstra wrote:
> On Thu, Apr 11, 2019 at 09:54:24PM +0200, Peter Zijlstra wrote:
> > On Thu, Apr 11, 2019 at 09:39:06PM +0200, Peter Zijlstra wrote:
> > > I think this bisect is bad. If you look at your own logs this patch
> > > merely changes the failure, but doesn't make it go away.
> > > 
> > > Before this patch (in fact, before tip/core/mm entirely) the errror
> > > reads like the below, which suggests there is memory corruption
> > > somewhere, and the fingered patch just makes it trigger differently.
> > > 
> > > It would be very good to find the source of this corruption, but I'm
> > > fairly certain it is not here.
> > 
> > I went back to v4.20 to try and find a time when the below error did not
> > occur, but even that reliably triggers the warning.
> 
> So I also tested v4.19 and found that that was good, which made me
> bisect v4.19..v4.20
> 
> # bad: [8fe28cb58bcb235034b64cbbb7550a8a43fd88be] Linux 4.20
> # good: [84df9525b0c27f3ebc2ebb1864fa62a97fdedb7d] Linux 4.19
> git bisect start 'v4.20' 'v4.19'
> # bad: [ec9c166434595382be3babf266febf876327774d] Merge tag 'mips_fixes_4.20_1' of git://git.kernel.org/pub/scm/linux/kernel/git/mips/linux
> git bisect bad ec9c166434595382be3babf266febf876327774d
> # bad: [50b825d7e87f4cff7070df6eb26390152bb29537] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
> git bisect bad 50b825d7e87f4cff7070df6eb26390152bb29537
> # good: [99e9acd85ccbdc8f5785f9e961d4956e96bd6aa5] Merge tag 'mlx5-updates-2018-10-17' of git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux
> git bisect good 99e9acd85ccbdc8f5785f9e961d4956e96bd6aa5
> # good: [c403993a41d50db1e7d9bc2d43c3c8498162312f] Merge tag 'for-linus-4.20' of https://github.com/cminyard/linux-ipmi
> git bisect good c403993a41d50db1e7d9bc2d43c3c8498162312f
> # good: [c05f3642f4304dd081876e77a68555b6aba4483f] Merge branch 'perf-core-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
> git bisect good c05f3642f4304dd081876e77a68555b6aba4483f
> # bad: [44786880df196a4200c178945c4d41675faf9fb7] Merge branch 'parisc-4.20-1' of git://git.kernel.org/pub/scm/linux/kernel/git/deller/parisc-linux
> git bisect bad 44786880df196a4200c178945c4d41675faf9fb7
> # bad: [99792e0cea1ed733cdc8d0758677981e0cbebfed] Merge branch 'x86-mm-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
> git bisect bad 99792e0cea1ed733cdc8d0758677981e0cbebfed
> # good: [fec98069fb72fb656304a3e52265e0c2fc9adf87] Merge branch 'x86-cpu-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
> git bisect good fec98069fb72fb656304a3e52265e0c2fc9adf87
> # bad: [a31acd3ee8f7dbc0370bdf4a4bfef7a8c13c7542] x86/mm: Page size aware flush_tlb_mm_range()
> git bisect bad a31acd3ee8f7dbc0370bdf4a4bfef7a8c13c7542
> # good: [a7295fd53c39ce781a9792c9dd2c8747bf274160] x86/mm/cpa: Use flush_tlb_kernel_range()
> git bisect good a7295fd53c39ce781a9792c9dd2c8747bf274160
> # good: [9cf38d5559e813cccdba8b44c82cc46ba48d0896] kexec: Allocate decrypted control pages for kdump if SME is enabled
> git bisect good 9cf38d5559e813cccdba8b44c82cc46ba48d0896
> # good: [5b12904065798fee8b153a506ac7b72d5ebbe26c] x86/mm/doc: Clean up the x86-64 virtual memory layout descriptions
> git bisect good 5b12904065798fee8b153a506ac7b72d5ebbe26c
> # good: [cf089611f4c446285046fcd426d90c18f37d2905] proc/vmcore: Fix i386 build error of missing copy_oldmem_page_encrypted()
> git bisect good cf089611f4c446285046fcd426d90c18f37d2905
> # good: [a5b966ae42a70b194b03eaa5eaea70d8b3790c40] Merge branch 'tlb/asm-generic' of git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux into x86/mm
> git bisect good a5b966ae42a70b194b03eaa5eaea70d8b3790c40
> # first bad commit: [a31acd3ee8f7dbc0370bdf4a4bfef7a8c13c7542] x86/mm: Page size aware flush_tlb_mm_range()
> 
> And 'funnily' the bad patch is one of mine too :/
> 
> I'll go have a look at that tomorrow, because currrently I'm way past
> tired.

OK, so the below patchlet makes it all good. It turns out that the
provided config has:

CONFIG_X86_L1_CACHE_SHIFT=7

which then, for some obscure raisin, results in flush_tlb_mm_range()
compiling to use 320 bytes of stack:

  sub    $0x140,%rsp

Where a 'defconfig' build results in:

  sub    $0x58,%rsp

The thing that pushes it over the edge in the above fingered patch is
the addition of a field to struct flush_tlb_info, which grows if from 32
to 36 bytes.

So my proposal is to basically revert that, unless we can come up with
something that GCC can't screw up.

---
 arch/x86/mm/tlb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index bc4bc7b2f075..487b8474c01c 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -728,7 +728,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 {
 	int cpu;
 
-	struct flush_tlb_info info __aligned(SMP_CACHE_BYTES) = {
+	struct flush_tlb_info info = {
 		.mm = mm,
 		.stride_shift = stride_shift,
 		.freed_tables = freed_tables,


> > > [   10.273617] rodata_test: all tests were successful
> > > [   10.275015] x86/mm: Checking user space page tables
> > > [   10.295444] x86/mm: Checked W+X mappings: passed, no W+X pages found.
> > > [   10.296334] Run /init as init process
> > > [   10.301465] ==================================================================
> > > [   10.302460] BUG: KASAN: stack-out-of-bounds in __unwind_start+0x7e/0x4fe
> > > [   10.303355] Write of size 88 at addr ffff8880191efa28 by task init/1
> > > [   10.304241]
> > > [   10.304455] CPU: 0 PID: 1 Comm: init Not tainted 5.1.0-rc4-00288-ga131d61b43e0-dirty #10
> > > [   10.305542] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> > > [   10.306641] Call Trace:
> > > [   10.306990]  print_address_description+0x9d/0x26b
> > > [   10.307654]  ? __unwind_start+0x7e/0x4fe
> > > [   10.308222]  ? __unwind_start+0x7e/0x4fe
> > > [   10.308755]  __kasan_report+0x145/0x18a
> > > [   10.309266]  ? __unwind_start+0x7e/0x4fe
> > > [   10.309823]  kasan_report+0xe/0x12
> > > [   10.310273]  memset+0x1f/0x31
> > > [   10.310703]  __unwind_start+0x7e/0x4fe
> > > [   10.311223]  ? unwind_next_frame+0x10a9/0x10a9
> > > [   10.311839]  ? native_flush_tlb_one_user+0x54/0x95
> > > [   10.312504]  ? kasan_unpoison_shadow+0xf/0x2e
> > > [   10.313090]  __save_stack_trace+0x65/0xe7
> > > [   10.313667]  ? trace_irq_enable_rcuidle+0x21/0xf5
> > > [   10.314284]  ? tracer_hardirqs_on+0xb/0x1b
> > > [   10.314830]  ? trace_hardirqs_on+0x2c/0x37
> > > [   10.315369]  save_stack+0x32/0xa3
> > > [   10.315842]  ? __put_compound_page+0x91/0x91
> > > [   10.316458]  ? preempt_latency_start+0x22/0x68
> > > [   10.317052]  ? free_swap_cache+0x51/0xd5
> > > [   10.317586]  ? tlb_flush_mmu_free+0x31/0xca
> > > [   10.318140]  ? arch_tlb_finish_mmu+0x8c/0x112
> > > [   10.318759]  ? tlb_finish_mmu+0xc7/0xd6
> > > [   10.319298]  ? unmap_region+0x275/0x2b9
> > > [   10.319835]  ? special_mapping_fault+0x26d/0x26d
> > > [   10.320448]  ? trace_irq_disable_rcuidle+0x21/0xf5
> > > [   10.321085]  __kasan_slab_free+0xd3/0xf4
> > > [   10.321623]  ? remove_vma+0xdf/0xe7
> > > [   10.322105]  kmem_cache_free+0x4e/0xca
> > > [   10.322600]  remove_vma+0xdf/0xe7
> > > [   10.323038]  __do_munmap+0x72c/0x75e
> > > [   10.323514]  __vm_munmap+0xd0/0x135
> > > [   10.323980]  ? __x64_sys_brk+0x40e/0x40e
> > > [   10.324496]  ? trace_irq_disable_rcuidle+0x21/0xf5
> > > [   10.325160]  __x64_sys_munmap+0x6a/0x6f
> > > [   10.325670]  do_syscall_64+0x3f0/0x462
> > > [   10.326162]  ? syscall_return_slowpath+0x154/0x154
> > > [   10.326810]  ? entry_SYSCALL_64_after_hwframe+0x3e/0xbe
> > > [   10.327485]  ? trace_irq_disable_rcuidle+0x21/0xf5
> > > [   10.328153]  ? entry_SYSCALL_64_after_hwframe+0x3e/0xbe
> > > [   10.328873]  ? trace_hardirqs_off_caller+0x3e/0x40
> > > [   10.329505]  ? trace_hardirqs_off_thunk+0x1a/0x1c
> > > [   10.330162]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > > [   10.330830] RIP: 0033:0x7efc4d707457
> > > [   10.331306] Code: f0 ff ff 73 01 c3 48 8d 0d 5a be 20 00 31 d2 48 29 c2 89 11 48 83 c8 ff eb eb 90 90 90 90 90 90 90 90 90 b8 0b 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8d 0d 2d be 20 00 31 d2 48 29 c2 89
> > > [   10.333711] RSP: 002b:00007fff973da398 EFLAGS: 00000203 ORIG_RAX: 000000000000000b
> > > [   10.334728] RAX: ffffffffffffffda RBX: 00007efc4d9132c8 RCX: 00007efc4d707457
> > > [   10.335670] RDX: 0000000000000000 RSI: 0000000000001d67 RDI: 00007efc4d90d000
> > > [   10.336596] RBP: 00007fff973da4f0 R08: 0000000000000007 R09: 00000000ffffffff
> > > [   10.337512] R10: 0000000000000000 R11: 0000000000000203 R12: 000000073dd74283
> > > [   10.338457] R13: 000000073db1ab4f R14: 00007efc4d909700 R15: 00007efc4d9132c8
> > > [   10.339373]
> > > [   10.339585] The buggy address belongs to the page:
> > > [   10.340224] page:ffff88801de82c48 count:0 mapcount:0 mapping:0000000000000000 index:0x0
> > > [   10.341338] flags: 0x680000000000()
> > > [   10.341832] raw: 0000680000000000 ffff88801de82c50 ffff88801de82c50 0000000000000000
> > > [   10.342846] raw: 0000000000000000 0000000000000000 00000000ffffffff
> > > [   10.343679] page dumped because: kasan: bad access detected
> > > [   10.344415]
> > > [   10.344629] Memory state around the buggy address:
> > > [   10.345254]  ffff8880191ef900: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> > > [   10.346245]  ffff8880191ef980: 00 00 f1 f1 f1 f1 00 f2 f2 f2 00 00 00 00 00 00
> > > [   10.347217] >ffff8880191efa00: 00 00 00 00 00 f2 f2 f2 00 00 00 00 00 00 00 00
> > > [   10.348152]                                   ^
> > > [   10.348755]  ffff8880191efa80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> > > [   10.349698]  ffff8880191efb00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> > > [   10.350650] ==================================================================

