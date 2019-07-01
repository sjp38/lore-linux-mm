Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB917C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 12:51:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79DB72053B
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 12:51:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79DB72053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1522A8E0003; Mon,  1 Jul 2019 08:51:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 102CF8E0002; Mon,  1 Jul 2019 08:51:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F34D28E0003; Mon,  1 Jul 2019 08:51:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f78.google.com (mail-ed1-f78.google.com [209.85.208.78])
	by kanga.kvack.org (Postfix) with ESMTP id A798A8E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 08:51:17 -0400 (EDT)
Received: by mail-ed1-f78.google.com with SMTP id l26so16825920eda.2
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 05:51:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=viwHWGnw8H6a0Oul+OF2OKG5zij6lMS1V1XYkkWnWwY=;
        b=sGrmlZZSm7dvPWyiTOnvhrH6t9bfjjkMGsC7CEcCAL9IklRVHFlPLn4U4Q0UAvUPpf
         C0N6Pkfcg/xbpabq0Fl9Uu/pPQ/l2Q075FsZfHD3J+Y3J7WyRXzDLY9J+aZu4gJB15+C
         Bp4phONCOouYPQwWaGP7ABuGKUQ7leKY+/UBC9P5sl5Oxf6IqQupohbE6QDqy1JdC2qc
         8SLowfVQF7iEJml63eI5LkwOq1vDojurbLH1wa71a4othoG3fMh6upkJTTIIsxx+Fn1X
         +KAygpvZIMENNAF17gS72Kl5RGciE0/c6YemlFwMblrKRQbIDeYFJj4FVXp+R22CJQMv
         8AYg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXYM3HRY/9pVuaxwJnIh89AQkvvhNAcf0FZ4SvD1WAJBW+WlNPV
	Df+QV/inyIZFy0k/aPYa0fdFZIgLPQNKqHthfBUgHcBUTtofE8QYZZ8A3k3p+dUJH0TfkcKDKmb
	PxFggZvUlNnb0/C+GglCrLW3umlVIQAMdebjsmLU3kQ3z9SE4S1QkhbvrF6dGSMo=
X-Received: by 2002:a05:6402:397:: with SMTP id o23mr29348999edv.68.1561985477257;
        Mon, 01 Jul 2019 05:51:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvXmn0/79rOAJ9rW0HCeObCXU/84fm4j3x3KokdgGiu8CDysIH0hCqCTIcWKt1+G0R48Ap
X-Received: by 2002:a05:6402:397:: with SMTP id o23mr29348942edv.68.1561985476474;
        Mon, 01 Jul 2019 05:51:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561985476; cv=none;
        d=google.com; s=arc-20160816;
        b=pS6MHGqi9bfAShf2L2aBzHdIzsbuqWUOzbZBZdmqe9PG+r+z23b/vSRvodqPymGnio
         t1Hcy+7mxRYzeSeVJ1XiOH1hiZ7GLnrdPwLhY/7DwUpceKFvUnZzfdVvxFwbr3qOPV3k
         Lce7m6dgl9bxKbqzwC36og8AJ0LIxNyYRvGo/wUMM0+I41Y/OTbG6rl6cXAbXb011xi+
         Kc3aV4BdqExg913cbGvbq9vveh05UuGY+MDot09vQhGc1HKJD7oLXpZfhBL1aG3WeZbB
         ejuwwVL2Flt5IiLcKzaxPH7a83dtFSQd1A/5xwYKtv2fzm7eMCaE9K2CjlX98dRsAhJU
         Pzlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=viwHWGnw8H6a0Oul+OF2OKG5zij6lMS1V1XYkkWnWwY=;
        b=d8Gey/wIsE+DTn1+jIt2IFk0zvknbIOY2NiHLsPhVGnvgsyCfDO/0sQq92KXUhdIs5
         fySs7i/s4Bxp01oCyIJSYz6UKzdRIpycCdbUQ6h5MBkRDgXhRo6cJPAYpT2VLtL2fEBm
         O+Msi8dRlzYUF6yw4OIojyNgPl0e1QljppDqoSzdb91dmW8qz7/xkOYZsdSqrgWyf5WR
         wXYBFDiGNEbeft/zDNahU4ZkEuE4zqoZYGbViFq0rWN/fIQRR78fJuS8seyRQTQlHZzX
         kc3NuWL/NNiSjO5HiQKVpYWlWSPYlLGe1Eiow6L9dDdhw9D25CwhWrpgNrSh5IhvuKtS
         FMxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k25si9345953ede.169.2019.07.01.05.51.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 05:51:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E9455AF2C;
	Mon,  1 Jul 2019 12:51:14 +0000 (UTC)
Date: Mon, 1 Jul 2019 14:51:12 +0200
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
Message-ID: <20190701125112.GW6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-7-david@redhat.com>
 <20190701080141.GF6376@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701080141.GF6376@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 01-07-19 10:01:41, Michal Hocko wrote:
> On Mon 27-05-19 13:11:47, David Hildenbrand wrote:
> > We want to improve error handling while adding memory by allowing
> > to use arch_remove_memory() and __remove_pages() even if
> > CONFIG_MEMORY_HOTREMOVE is not set to e.g., implement something like:
> > 
> > 	arch_add_memory()
> > 	rc = do_something();
> > 	if (rc) {
> > 		arch_remove_memory();
> > 	}
> > 
> > We won't get rid of CONFIG_MEMORY_HOTREMOVE for now, as it will require
> > quite some dependencies for memory offlining.
> 
> If we cannot really remove CONFIG_MEMORY_HOTREMOVE altogether then why
> not simply add an empty placeholder for arch_remove_memory when the
> config is disabled?

In other words, can we replace this by something as simple as:

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index ae892eef8b82..0329027fe740 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -128,6 +128,20 @@ extern void arch_remove_memory(int nid, u64 start, u64 size,
 			       struct vmem_altmap *altmap);
 extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
 			   unsigned long nr_pages, struct vmem_altmap *altmap);
+#else
+/*
+ * Allow code using
+ * arch_add_memory();
+ * rc = do_something();
+ * if (rc)
+ * 	arch_remove_memory();
+ *
+ * without ifdefery.
+ */
+static inline void arch_remove_memory(int nid, u64 start, u64 size,
+			       struct vmem_altmap *altmap)
+{
+}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /*
-- 
Michal Hocko
SUSE Labs

