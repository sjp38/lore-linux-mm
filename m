Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3987C06510
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:01:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 670E620673
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:01:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 670E620673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02F136B0003; Mon,  1 Jul 2019 04:01:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F22728E0003; Mon,  1 Jul 2019 04:01:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE93B8E0002; Mon,  1 Jul 2019 04:01:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f80.google.com (mail-ed1-f80.google.com [209.85.208.80])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEB26B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 04:01:47 -0400 (EDT)
Received: by mail-ed1-f80.google.com with SMTP id n49so16268535edd.15
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 01:01:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=o3y3ieEVIchwgWn14EEm202sSTZppr7UkInY6o+JMlo=;
        b=AVYhFeFtVjPrA6bLmbPCTSWZiK89Mc3MRs6SEG4M5sKGd8hQ2LfQPT5nxKpr4ikjAw
         RTFrEGzWLDX3XaecjeN0nDfMpCeenJyKLr0P7PmYU94y/8AR4GcKcp7+GIlhN9kB+8uI
         2PTerVFNUe1eG/gzbIbZu8zltG0mZKnYwodJdzBkvM7AyCCG9PC9XgpPy/yfbuDrS1Sw
         b/6yriqA4k9F7JvL/IVuOG0jS5oWckofS10HD6qXO+EOwmaWGsDw/rfBV5u0qTGilE8/
         30Y+XwZD13WsYUdxw7HW4PeEL5wkogBBplwVMx0vaP2MAZeY9I6gb4NjDQhW3ACQKu4R
         faVw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX7Fs5oy/iBKt8g883iiEBmG+7Zuf3sDnZJ7WZrSgCcAdtbNnKE
	zvDo9VmcBeE39BscVxSRUilm45aG3QLoEfR/XUjIJB8gLQoneDw2JVzGz95XXTMm2o1+U0A8PB3
	j83sFPZQefgudVk/N8BzEd2+3WB9DoL3K10w9UxZ68Be2VjTvmFg3lG1RCROw5Sg=
X-Received: by 2002:a17:906:fae0:: with SMTP id lu32mr21590789ejb.283.1561968107101;
        Mon, 01 Jul 2019 01:01:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3dCRmYgRsIE2w0+qtp32LeIn9NwRi/82gOd1v8q4Aj0xyIeAsHG03pFICYrwYljlTlmbX
X-Received: by 2002:a17:906:fae0:: with SMTP id lu32mr21590719ejb.283.1561968106109;
        Mon, 01 Jul 2019 01:01:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561968106; cv=none;
        d=google.com; s=arc-20160816;
        b=J28ZfiyPwQGuRm2ZP9ekAavhD0cuqkRdCWN3Qig2MGDSHU3TZkXbXaRG5hL4A2GIpQ
         gy4OuM00sMb5Ax5aIKkwNPEXqsTWACIxnD36/g9xjzf3FMp7iW5b9tpQvdKg5NeT2leA
         n9MVMUOCMxgq6/6IVNc5Isc5tj6/xK6t8ALD0xWMNPOI8/BETF4eroXGsfzN+NfVSxyA
         JuczoYiWxnpDBI8UrKyaqCgQej8wP/U8TFtAxgq2yurKV5Q/+Y6IqEvxW1zFpeIrcrlh
         dlofDZGDswzMOwQ1txEmAe2pKge1XKwXSAzBNcxV5Llw4vfPSRhXcKEFIAv2aUuXJzeO
         CraQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=o3y3ieEVIchwgWn14EEm202sSTZppr7UkInY6o+JMlo=;
        b=SwgeL7TuxQ02OuSwsO0yUOq2jgHwAbXgGfUFOuhWOoHnXHLAHAIYw35lU3pNLjXhe/
         uhmZ4mArYeWFkye59t/bjRnBmn9y5HfMu7zftij4hcs4XkEM9m7e6N5MXxKmKgphBxKx
         cwG3zEvBuyO+CZNiWDOZ98CWTWSQXc/wkxonqJ3gysY6k77WsPP93Pa+tMJ6HelgaEkM
         DxfRY+Ub/h6hS8mra/EOwemW1b2hzzJT1uUeoffgxhl4IP5QD3OAgQFHymX6e9mS4R1I
         W0+/u1AhtveXixi+Jgwo8QDBBi5goDVBdQulekijf/W+CXtF9IxOPFqigWBjxULc+Zpf
         IGvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e24si8270395ede.59.2019.07.01.01.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 01:01:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7BCDDAF1B;
	Mon,  1 Jul 2019 08:01:44 +0000 (UTC)
Date: Mon, 1 Jul 2019 10:01:41 +0200
From: Michal Hocko <mhocko@kernel.org>
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
	Mike Rapoport <rppt@linux.ibm.com>,
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
Message-ID: <20190701080141.GF6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-7-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-7-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 13:11:47, David Hildenbrand wrote:
> We want to improve error handling while adding memory by allowing
> to use arch_remove_memory() and __remove_pages() even if
> CONFIG_MEMORY_HOTREMOVE is not set to e.g., implement something like:
> 
> 	arch_add_memory()
> 	rc = do_something();
> 	if (rc) {
> 		arch_remove_memory();
> 	}
> 
> We won't get rid of CONFIG_MEMORY_HOTREMOVE for now, as it will require
> quite some dependencies for memory offlining.

If we cannot really remove CONFIG_MEMORY_HOTREMOVE altogether then why
not simply add an empty placeholder for arch_remove_memory when the
config is disabled?
 
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> Cc: Rich Felker <dalias@libc.org>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Oscar Salvador <osalvador@suse.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Alex Deucher <alexander.deucher@amd.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Mark Brown <broonie@kernel.org>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Christophe Leroy <christophe.leroy@c-s.fr>
> Cc: Nicholas Piggin <npiggin@gmail.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Rob Herring <robh@kernel.org>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
> Cc: Andrew Banman <andrew.banman@hpe.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Wei Yang <richardw.yang@linux.intel.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Mathieu Malaterre <malat@debian.org>
> Cc: Baoquan He <bhe@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  arch/arm64/mm/mmu.c            | 2 --
>  arch/ia64/mm/init.c            | 2 --
>  arch/powerpc/mm/mem.c          | 2 --
>  arch/s390/mm/init.c            | 2 --
>  arch/sh/mm/init.c              | 2 --
>  arch/x86/mm/init_32.c          | 2 --
>  arch/x86/mm/init_64.c          | 2 --
>  drivers/base/memory.c          | 2 --
>  include/linux/memory.h         | 2 --
>  include/linux/memory_hotplug.h | 2 --
>  mm/memory_hotplug.c            | 2 --
>  mm/sparse.c                    | 6 ------
>  12 files changed, 28 deletions(-)
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index e569a543c384..9ccd7539f2d4 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -1084,7 +1084,6 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
>  			   restrictions);
>  }
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  void arch_remove_memory(int nid, u64 start, u64 size,
>  			struct vmem_altmap *altmap)
>  {
> @@ -1103,4 +1102,3 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>  	__remove_pages(zone, start_pfn, nr_pages, altmap);
>  }
>  #endif
> -#endif
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index d28e29103bdb..aae75fd7b810 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -681,7 +681,6 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  	return ret;
>  }
>  
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  void arch_remove_memory(int nid, u64 start, u64 size,
>  			struct vmem_altmap *altmap)
>  {
> @@ -693,4 +692,3 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>  	__remove_pages(zone, start_pfn, nr_pages, altmap);
>  }
>  #endif
> -#endif
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index e885fe2aafcc..e4bc2dc3f593 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -130,7 +130,6 @@ int __ref arch_add_memory(int nid, u64 start, u64 size,
>  	return __add_pages(nid, start_pfn, nr_pages, restrictions);
>  }
>  
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  void __ref arch_remove_memory(int nid, u64 start, u64 size,
>  			     struct vmem_altmap *altmap)
>  {
> @@ -164,7 +163,6 @@ void __ref arch_remove_memory(int nid, u64 start, u64 size,
>  		pr_warn("Hash collision while resizing HPT\n");
>  }
>  #endif
> -#endif /* CONFIG_MEMORY_HOTPLUG */
>  
>  #ifndef CONFIG_NEED_MULTIPLE_NODES
>  void __init mem_topology_setup(void)
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index 14955e0a9fcf..ffb81fe95c77 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -239,7 +239,6 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  	return rc;
>  }
>  
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  void arch_remove_memory(int nid, u64 start, u64 size,
>  			struct vmem_altmap *altmap)
>  {
> @@ -251,5 +250,4 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>  	__remove_pages(zone, start_pfn, nr_pages, altmap);
>  	vmem_remove_mapping(start, size);
>  }
> -#endif
>  #endif /* CONFIG_MEMORY_HOTPLUG */
> diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
> index 13c6a6bb5fd9..dfdbaa50946e 100644
> --- a/arch/sh/mm/init.c
> +++ b/arch/sh/mm/init.c
> @@ -429,7 +429,6 @@ int memory_add_physaddr_to_nid(u64 addr)
>  EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
>  #endif
>  
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  void arch_remove_memory(int nid, u64 start, u64 size,
>  			struct vmem_altmap *altmap)
>  {
> @@ -440,5 +439,4 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>  	zone = page_zone(pfn_to_page(start_pfn));
>  	__remove_pages(zone, start_pfn, nr_pages, altmap);
>  }
> -#endif
>  #endif /* CONFIG_MEMORY_HOTPLUG */
> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
> index f265a4316179..4068abb9427f 100644
> --- a/arch/x86/mm/init_32.c
> +++ b/arch/x86/mm/init_32.c
> @@ -860,7 +860,6 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  	return __add_pages(nid, start_pfn, nr_pages, restrictions);
>  }
>  
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  void arch_remove_memory(int nid, u64 start, u64 size,
>  			struct vmem_altmap *altmap)
>  {
> @@ -872,7 +871,6 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>  	__remove_pages(zone, start_pfn, nr_pages, altmap);
>  }
>  #endif
> -#endif
>  
>  int kernel_set_to_readonly __read_mostly;
>  
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 693aaf28d5fe..8335ac6e1112 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1196,7 +1196,6 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
>  	remove_pagetable(start, end, false, altmap);
>  }
>  
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  static void __meminit
>  kernel_physical_mapping_remove(unsigned long start, unsigned long end)
>  {
> @@ -1221,7 +1220,6 @@ void __ref arch_remove_memory(int nid, u64 start, u64 size,
>  	__remove_pages(zone, start_pfn, nr_pages, altmap);
>  	kernel_physical_mapping_remove(start, start + size);
>  }
> -#endif
>  #endif /* CONFIG_MEMORY_HOTPLUG */
>  
>  static struct kcore_list kcore_vsyscall;
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index f914fa6fe350..ac17c95a5f28 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -727,7 +727,6 @@ int hotplug_memory_register(int nid, struct mem_section *section)
>  	return ret;
>  }
>  
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  static void
>  unregister_memory(struct memory_block *memory)
>  {
> @@ -766,7 +765,6 @@ void unregister_memory_section(struct mem_section *section)
>  out_unlock:
>  	mutex_unlock(&mem_sysfs_mutex);
>  }
> -#endif /* CONFIG_MEMORY_HOTREMOVE */
>  
>  /* return true if the memory block is offlined, otherwise, return false */
>  bool is_memblock_offlined(struct memory_block *mem)
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index e1dc1bb2b787..474c7c60c8f2 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -112,9 +112,7 @@ extern void unregister_memory_notifier(struct notifier_block *nb);
>  extern int register_memory_isolate_notifier(struct notifier_block *nb);
>  extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
>  int hotplug_memory_register(int nid, struct mem_section *section);
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  extern void unregister_memory_section(struct mem_section *);
> -#endif
>  extern int memory_dev_init(void);
>  extern int memory_notify(unsigned long val, void *v);
>  extern int memory_isolate_notify(unsigned long val, void *v);
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index ae892eef8b82..2d4de313926d 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -123,12 +123,10 @@ static inline bool movable_node_is_enabled(void)
>  	return movable_node_enabled;
>  }
>  
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  extern void arch_remove_memory(int nid, u64 start, u64 size,
>  			       struct vmem_altmap *altmap);
>  extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
>  			   unsigned long nr_pages, struct vmem_altmap *altmap);
> -#endif /* CONFIG_MEMORY_HOTREMOVE */
>  
>  /*
>   * Do we want sysfs memblock files created. This will allow userspace to online
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 762887b2358b..4b9d2974f86c 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -318,7 +318,6 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>  	return err;
>  }
>  
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  /* find the smallest valid pfn in the range [start_pfn, end_pfn) */
>  static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
>  				     unsigned long start_pfn,
> @@ -582,7 +581,6 @@ void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
>  
>  	set_zone_contiguous(zone);
>  }
> -#endif /* CONFIG_MEMORY_HOTREMOVE */
>  
>  int set_online_page_callback(online_page_callback_t callback)
>  {
> diff --git a/mm/sparse.c b/mm/sparse.c
> index fd13166949b5..d1d5e05f5b8d 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -604,7 +604,6 @@ static void __kfree_section_memmap(struct page *memmap,
>  
>  	vmemmap_free(start, end, altmap);
>  }
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  static void free_map_bootmem(struct page *memmap)
>  {
>  	unsigned long start = (unsigned long)memmap;
> @@ -612,7 +611,6 @@ static void free_map_bootmem(struct page *memmap)
>  
>  	vmemmap_free(start, end, NULL);
>  }
> -#endif /* CONFIG_MEMORY_HOTREMOVE */
>  #else
>  static struct page *__kmalloc_section_memmap(void)
>  {
> @@ -651,7 +649,6 @@ static void __kfree_section_memmap(struct page *memmap,
>  			   get_order(sizeof(struct page) * PAGES_PER_SECTION));
>  }
>  
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  static void free_map_bootmem(struct page *memmap)
>  {
>  	unsigned long maps_section_nr, removing_section_nr, i;
> @@ -681,7 +678,6 @@ static void free_map_bootmem(struct page *memmap)
>  			put_page_bootmem(page);
>  	}
>  }
> -#endif /* CONFIG_MEMORY_HOTREMOVE */
>  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
>  
>  /**
> @@ -746,7 +742,6 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  	return ret;
>  }
>  
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  #ifdef CONFIG_MEMORY_FAILURE
>  static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  {
> @@ -823,5 +818,4 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>  			PAGES_PER_SECTION - map_offset);
>  	free_section_usemap(memmap, usemap, altmap);
>  }
> -#endif /* CONFIG_MEMORY_HOTREMOVE */
>  #endif /* CONFIG_MEMORY_HOTPLUG */
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs

