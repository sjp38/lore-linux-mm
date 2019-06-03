Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FFD4C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 22:15:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD15726741
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 22:15:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AgSXQB1m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD15726741
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57C6F6B0272; Mon,  3 Jun 2019 18:15:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52DDF6B0273; Mon,  3 Jun 2019 18:15:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41C916B0274; Mon,  3 Jun 2019 18:15:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E1F266B0272
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 18:15:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p14so29522987edc.4
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 15:15:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PlL+0OL4BvjO84qlKDFGxdeteGvielp4Lu2VfMx5Y0E=;
        b=tpfTrgYYbBmgEOtTEh9FwGe+7dHUth7VM7pF+Z1Gpze0XNOGTO9VOEyGVSF+omQmy4
         Iv7NKJhKHdTFUpscut0BLSwk0cb+e6kxpzhQBBjmwOeLL6BJJbbRfVMngpkkb32Smw+G
         sCIaaSF7DJPwQZdWgyrNtz0MxpqqwKCNhXuBGgeHLwJhr6rs1EKNw7jhrHaJ2Ohj2BOb
         iWXJ+HE8mjXwegQptq0s3ckgYGwf2mrwyJWhvhNjt33cuLTmWRAVxhGxvJM2HUGJeqfp
         Bjc5L3xwxqlhoubqz04IMQRPqSqj74qqqGCG9JDOkHWpn1T17ru5UbyNokalmI6Z9vwG
         BMPg==
X-Gm-Message-State: APjAAAUCBakYEBIg6D6vRcz4fXtIou9YeNEwmXbfBLbkkj7lDVwpHfwZ
	y8HS25ifGdr1fC29niwN6M/aDl0erV7u3lCsZZcwBpldSiYZyMRpEM+63pSTU84lr2YcRV51Vhs
	RYdvgqt0YU4aSfB4NUQjeQmNPnUeLsAn2Nn80owjno6ZTHpOm8U4LJJycKixRdRcXcg==
X-Received: by 2002:a17:906:3e8d:: with SMTP id a13mr26104383ejj.71.1559600143380;
        Mon, 03 Jun 2019 15:15:43 -0700 (PDT)
X-Received: by 2002:a17:906:3e8d:: with SMTP id a13mr26104324ejj.71.1559600142314;
        Mon, 03 Jun 2019 15:15:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559600142; cv=none;
        d=google.com; s=arc-20160816;
        b=Xzy2d6C9M6xou0hAmwyKm5PRpR7xaATs2iZ3ca5RGM5RWIpPFNR/B4VHE0pbI6pFMM
         DohlT+3Mwdw7OVXZ9AkEBz8As2bUL/AdrwdGhnU3gFmXoVGHpMhtFnITIUHUj227XInM
         cIZm7UKsjdoO9FDsFfBuYRqm4oWT/7R1LgBmUSdoziWD79ArHkqzUL+tVrMUX9n1NarK
         1ZlUR3IFVhxJm1MZwKcUBBh2lrcJp/Daud95oWWz+5fYUN+na3/W3OnER8wqMfTMlRRX
         zFFQb2nvXLLJqmuwMZRQXLjBoOivl1LMnRDMcnSqqOj7/1kuXdUdXoHHyi33QZ7Ni58n
         IeeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=PlL+0OL4BvjO84qlKDFGxdeteGvielp4Lu2VfMx5Y0E=;
        b=oJ+5GrIn/uaOQHnnT6v9iLeWuxQGC5doS6ee86li0AuKTQcXkH5IyD6ahn0MaFPv55
         C3beWgpPB9WBZJ9xv67gKRwjf9ZUyRZtLtX3V1OjqJD5EocjFz1NdqpRa+tnMwq+qTYd
         p4MsSNoWxnmoQeyRPa1NPvOii2qr+VoOmyhT4YZBJfaEElIqMz40K6axu30odMCa704/
         EyUvnHAlmA5aRVoCvo6cPtFH+vLf2W8Bu7kd8e4HpjH0Ot+LLW1onYOU85sqGorWmm1d
         mz4CwK88Ui89+Z9zXbcJBtu6yUDz5Lcyozg29vc711FnQf35U8MLhf/7dJgz9kzhvhkp
         L0Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AgSXQB1m;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 33sor1201731eds.23.2019.06.03.15.15.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 15:15:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AgSXQB1m;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=PlL+0OL4BvjO84qlKDFGxdeteGvielp4Lu2VfMx5Y0E=;
        b=AgSXQB1m5sFJTwV3A0spiIfpI67Lb2p+r7XngOD5KtoEryQ5lZZ2EePOJRHzPpGp7n
         rbBt/Nf3TfkouLVhsu3iz3EZskel5pcMo5DQScRs0BoQ12ATmkQY71QxCnsRNF2euVi0
         fb1CtZtnqvWqUVdF/jBq9qg7sX/nAw44sYUpiMx9OeUhNI8It1LYhwHa9THy3Qx7nmyI
         56GBOncMd51FZwKs/M2UySN8sOES9AEDA+4xArUz4D18xeGC/+iRi0cCF7/T3M+nExqD
         lLVOE4W3yx9CeWGAVvuF/piBYSOZ4zZR6YblexIlGxMIpHWBI0Nwk8W7aeAJDJLjwF1n
         tzNg==
X-Google-Smtp-Source: APXvYqydYliSc4v9RfY9YN8tc+zJR0qZqdokT/izjqKnh5rVNK7DOL3ujNksQ4QOc3hiysCUaFM7WQ==
X-Received: by 2002:a50:ba83:: with SMTP id x3mr31554921ede.266.1559600141951;
        Mon, 03 Jun 2019 15:15:41 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id b10sm2816102eja.58.2019.06.03.15.15.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 15:15:41 -0700 (PDT)
Date: Mon, 3 Jun 2019 22:15:40 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Nicholas Piggin <npiggin@gmail.com>,
	Vasily Gorbik <gor@linux.ibm.com>, Rob Herring <robh@kernel.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Andrew Banman <andrew.banman@hpe.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Arun KS <arunks@codeaurora.org>, Qian Cai <cai@lca.pw>,
	Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH v3 06/11] mm/memory_hotplug: Allow arch_remove_pages()
 without CONFIG_MEMORY_HOTREMOVE
Message-ID: <20190603221540.bvhuvltlwuirm5sl@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-7-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-7-david@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Allow arch_remove_pages() or arch_remove_memory()?

And want to confirm the kernel build on affected arch succeed?

On Mon, May 27, 2019 at 01:11:47PM +0200, David Hildenbrand wrote:
>We want to improve error handling while adding memory by allowing
>to use arch_remove_memory() and __remove_pages() even if
>CONFIG_MEMORY_HOTREMOVE is not set to e.g., implement something like:
>
>	arch_add_memory()
>	rc = do_something();
>	if (rc) {
>		arch_remove_memory();
>	}
>
>We won't get rid of CONFIG_MEMORY_HOTREMOVE for now, as it will require
>quite some dependencies for memory offlining.
>
>Cc: Tony Luck <tony.luck@intel.com>
>Cc: Fenghua Yu <fenghua.yu@intel.com>
>Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>Cc: Paul Mackerras <paulus@samba.org>
>Cc: Michael Ellerman <mpe@ellerman.id.au>
>Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
>Cc: Rich Felker <dalias@libc.org>
>Cc: Dave Hansen <dave.hansen@linux.intel.com>
>Cc: Andy Lutomirski <luto@kernel.org>
>Cc: Peter Zijlstra <peterz@infradead.org>
>Cc: Thomas Gleixner <tglx@linutronix.de>
>Cc: Ingo Molnar <mingo@redhat.com>
>Cc: Borislav Petkov <bp@alien8.de>
>Cc: "H. Peter Anvin" <hpa@zytor.com>
>Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: Mike Rapoport <rppt@linux.ibm.com>
>Cc: David Hildenbrand <david@redhat.com>
>Cc: Oscar Salvador <osalvador@suse.com>
>Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>Cc: Alex Deucher <alexander.deucher@amd.com>
>Cc: "David S. Miller" <davem@davemloft.net>
>Cc: Mark Brown <broonie@kernel.org>
>Cc: Chris Wilson <chris@chris-wilson.co.uk>
>Cc: Christophe Leroy <christophe.leroy@c-s.fr>
>Cc: Nicholas Piggin <npiggin@gmail.com>
>Cc: Vasily Gorbik <gor@linux.ibm.com>
>Cc: Rob Herring <robh@kernel.org>
>Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
>Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
>Cc: Andrew Banman <andrew.banman@hpe.com>
>Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>Cc: Wei Yang <richardw.yang@linux.intel.com>
>Cc: Arun KS <arunks@codeaurora.org>
>Cc: Qian Cai <cai@lca.pw>
>Cc: Mathieu Malaterre <malat@debian.org>
>Cc: Baoquan He <bhe@redhat.com>
>Cc: Logan Gunthorpe <logang@deltatee.com>
>Cc: Anshuman Khandual <anshuman.khandual@arm.com>
>Signed-off-by: David Hildenbrand <david@redhat.com>
>---
> arch/arm64/mm/mmu.c            | 2 --
> arch/ia64/mm/init.c            | 2 --
> arch/powerpc/mm/mem.c          | 2 --
> arch/s390/mm/init.c            | 2 --
> arch/sh/mm/init.c              | 2 --
> arch/x86/mm/init_32.c          | 2 --
> arch/x86/mm/init_64.c          | 2 --
> drivers/base/memory.c          | 2 --
> include/linux/memory.h         | 2 --
> include/linux/memory_hotplug.h | 2 --
> mm/memory_hotplug.c            | 2 --
> mm/sparse.c                    | 6 ------
> 12 files changed, 28 deletions(-)
>
>diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>index e569a543c384..9ccd7539f2d4 100644
>--- a/arch/arm64/mm/mmu.c
>+++ b/arch/arm64/mm/mmu.c
>@@ -1084,7 +1084,6 @@ int arch_add_memory(int nid, u64 start, u64 size,
> 	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
> 			   restrictions);
> }
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> void arch_remove_memory(int nid, u64 start, u64 size,
> 			struct vmem_altmap *altmap)
> {
>@@ -1103,4 +1102,3 @@ void arch_remove_memory(int nid, u64 start, u64 size,
> 	__remove_pages(zone, start_pfn, nr_pages, altmap);
> }
> #endif
>-#endif
>diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
>index d28e29103bdb..aae75fd7b810 100644
>--- a/arch/ia64/mm/init.c
>+++ b/arch/ia64/mm/init.c
>@@ -681,7 +681,6 @@ int arch_add_memory(int nid, u64 start, u64 size,
> 	return ret;
> }
> 
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> void arch_remove_memory(int nid, u64 start, u64 size,
> 			struct vmem_altmap *altmap)
> {
>@@ -693,4 +692,3 @@ void arch_remove_memory(int nid, u64 start, u64 size,
> 	__remove_pages(zone, start_pfn, nr_pages, altmap);
> }
> #endif
>-#endif
>diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
>index e885fe2aafcc..e4bc2dc3f593 100644
>--- a/arch/powerpc/mm/mem.c
>+++ b/arch/powerpc/mm/mem.c
>@@ -130,7 +130,6 @@ int __ref arch_add_memory(int nid, u64 start, u64 size,
> 	return __add_pages(nid, start_pfn, nr_pages, restrictions);
> }
> 
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> void __ref arch_remove_memory(int nid, u64 start, u64 size,
> 			     struct vmem_altmap *altmap)
> {
>@@ -164,7 +163,6 @@ void __ref arch_remove_memory(int nid, u64 start, u64 size,
> 		pr_warn("Hash collision while resizing HPT\n");
> }
> #endif
>-#endif /* CONFIG_MEMORY_HOTPLUG */
> 
> #ifndef CONFIG_NEED_MULTIPLE_NODES
> void __init mem_topology_setup(void)
>diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
>index 14955e0a9fcf..ffb81fe95c77 100644
>--- a/arch/s390/mm/init.c
>+++ b/arch/s390/mm/init.c
>@@ -239,7 +239,6 @@ int arch_add_memory(int nid, u64 start, u64 size,
> 	return rc;
> }
> 
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> void arch_remove_memory(int nid, u64 start, u64 size,
> 			struct vmem_altmap *altmap)
> {
>@@ -251,5 +250,4 @@ void arch_remove_memory(int nid, u64 start, u64 size,
> 	__remove_pages(zone, start_pfn, nr_pages, altmap);
> 	vmem_remove_mapping(start, size);
> }
>-#endif
> #endif /* CONFIG_MEMORY_HOTPLUG */
>diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
>index 13c6a6bb5fd9..dfdbaa50946e 100644
>--- a/arch/sh/mm/init.c
>+++ b/arch/sh/mm/init.c
>@@ -429,7 +429,6 @@ int memory_add_physaddr_to_nid(u64 addr)
> EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
> #endif
> 
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> void arch_remove_memory(int nid, u64 start, u64 size,
> 			struct vmem_altmap *altmap)
> {
>@@ -440,5 +439,4 @@ void arch_remove_memory(int nid, u64 start, u64 size,
> 	zone = page_zone(pfn_to_page(start_pfn));
> 	__remove_pages(zone, start_pfn, nr_pages, altmap);
> }
>-#endif
> #endif /* CONFIG_MEMORY_HOTPLUG */
>diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
>index f265a4316179..4068abb9427f 100644
>--- a/arch/x86/mm/init_32.c
>+++ b/arch/x86/mm/init_32.c
>@@ -860,7 +860,6 @@ int arch_add_memory(int nid, u64 start, u64 size,
> 	return __add_pages(nid, start_pfn, nr_pages, restrictions);
> }
> 
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> void arch_remove_memory(int nid, u64 start, u64 size,
> 			struct vmem_altmap *altmap)
> {
>@@ -872,7 +871,6 @@ void arch_remove_memory(int nid, u64 start, u64 size,
> 	__remove_pages(zone, start_pfn, nr_pages, altmap);
> }
> #endif
>-#endif
> 
> int kernel_set_to_readonly __read_mostly;
> 
>diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
>index 693aaf28d5fe..8335ac6e1112 100644
>--- a/arch/x86/mm/init_64.c
>+++ b/arch/x86/mm/init_64.c
>@@ -1196,7 +1196,6 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
> 	remove_pagetable(start, end, false, altmap);
> }
> 
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> static void __meminit
> kernel_physical_mapping_remove(unsigned long start, unsigned long end)
> {
>@@ -1221,7 +1220,6 @@ void __ref arch_remove_memory(int nid, u64 start, u64 size,
> 	__remove_pages(zone, start_pfn, nr_pages, altmap);
> 	kernel_physical_mapping_remove(start, start + size);
> }
>-#endif
> #endif /* CONFIG_MEMORY_HOTPLUG */
> 
> static struct kcore_list kcore_vsyscall;
>diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>index f914fa6fe350..ac17c95a5f28 100644
>--- a/drivers/base/memory.c
>+++ b/drivers/base/memory.c
>@@ -727,7 +727,6 @@ int hotplug_memory_register(int nid, struct mem_section *section)
> 	return ret;
> }
> 
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> static void
> unregister_memory(struct memory_block *memory)
> {
>@@ -766,7 +765,6 @@ void unregister_memory_section(struct mem_section *section)
> out_unlock:
> 	mutex_unlock(&mem_sysfs_mutex);
> }
>-#endif /* CONFIG_MEMORY_HOTREMOVE */
> 
> /* return true if the memory block is offlined, otherwise, return false */
> bool is_memblock_offlined(struct memory_block *mem)
>diff --git a/include/linux/memory.h b/include/linux/memory.h
>index e1dc1bb2b787..474c7c60c8f2 100644
>--- a/include/linux/memory.h
>+++ b/include/linux/memory.h
>@@ -112,9 +112,7 @@ extern void unregister_memory_notifier(struct notifier_block *nb);
> extern int register_memory_isolate_notifier(struct notifier_block *nb);
> extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
> int hotplug_memory_register(int nid, struct mem_section *section);
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> extern void unregister_memory_section(struct mem_section *);
>-#endif
> extern int memory_dev_init(void);
> extern int memory_notify(unsigned long val, void *v);
> extern int memory_isolate_notify(unsigned long val, void *v);
>diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>index ae892eef8b82..2d4de313926d 100644
>--- a/include/linux/memory_hotplug.h
>+++ b/include/linux/memory_hotplug.h
>@@ -123,12 +123,10 @@ static inline bool movable_node_is_enabled(void)
> 	return movable_node_enabled;
> }
> 
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> extern void arch_remove_memory(int nid, u64 start, u64 size,
> 			       struct vmem_altmap *altmap);
> extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
> 			   unsigned long nr_pages, struct vmem_altmap *altmap);
>-#endif /* CONFIG_MEMORY_HOTREMOVE */
> 
> /*
>  * Do we want sysfs memblock files created. This will allow userspace to online
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index 762887b2358b..4b9d2974f86c 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -318,7 +318,6 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
> 	return err;
> }
> 
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> /* find the smallest valid pfn in the range [start_pfn, end_pfn) */
> static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
> 				     unsigned long start_pfn,
>@@ -582,7 +581,6 @@ void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
> 
> 	set_zone_contiguous(zone);
> }
>-#endif /* CONFIG_MEMORY_HOTREMOVE */
> 
> int set_online_page_callback(online_page_callback_t callback)
> {
>diff --git a/mm/sparse.c b/mm/sparse.c
>index fd13166949b5..d1d5e05f5b8d 100644
>--- a/mm/sparse.c
>+++ b/mm/sparse.c
>@@ -604,7 +604,6 @@ static void __kfree_section_memmap(struct page *memmap,
> 
> 	vmemmap_free(start, end, altmap);
> }
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> static void free_map_bootmem(struct page *memmap)
> {
> 	unsigned long start = (unsigned long)memmap;
>@@ -612,7 +611,6 @@ static void free_map_bootmem(struct page *memmap)
> 
> 	vmemmap_free(start, end, NULL);
> }
>-#endif /* CONFIG_MEMORY_HOTREMOVE */
> #else
> static struct page *__kmalloc_section_memmap(void)
> {
>@@ -651,7 +649,6 @@ static void __kfree_section_memmap(struct page *memmap,
> 			   get_order(sizeof(struct page) * PAGES_PER_SECTION));
> }
> 
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> static void free_map_bootmem(struct page *memmap)
> {
> 	unsigned long maps_section_nr, removing_section_nr, i;
>@@ -681,7 +678,6 @@ static void free_map_bootmem(struct page *memmap)
> 			put_page_bootmem(page);
> 	}
> }
>-#endif /* CONFIG_MEMORY_HOTREMOVE */
> #endif /* CONFIG_SPARSEMEM_VMEMMAP */
> 
> /**
>@@ -746,7 +742,6 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
> 	return ret;
> }
> 
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> #ifdef CONFIG_MEMORY_FAILURE
> static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
> {
>@@ -823,5 +818,4 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
> 			PAGES_PER_SECTION - map_offset);
> 	free_section_usemap(memmap, usemap, altmap);
> }
>-#endif /* CONFIG_MEMORY_HOTREMOVE */
> #endif /* CONFIG_MEMORY_HOTPLUG */
>-- 
>2.20.1

-- 
Wei Yang
Help you, Help me

