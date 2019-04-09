Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CFF4C10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 20:09:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 065E82084C
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 20:09:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=gmx.net header.i=@gmx.net header.b="SMaFznGM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 065E82084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=gmx.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88EFA6B000D; Tue,  9 Apr 2019 16:09:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 865346B0266; Tue,  9 Apr 2019 16:09:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7543B6B0269; Tue,  9 Apr 2019 16:09:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4376B000D
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 16:09:57 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id n6so11569433wrm.2
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 13:09:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent:content-transfer-encoding;
        bh=D4jQvO0mBGJqUwfmCit7IZsasmJ93+nfPBcEDw+QQCE=;
        b=NyPzDjHf5NWJ9A4PGcckTHTh9BHOVtoMuJyx7UIF7daDvwQsQeqfXl4Cwq5VeQToU/
         3iKl6oB2Wz1TYGpCGve0CurZS10ZsT6+7AivFizzl1328/EtGJII5Xg/p1QDD72N2938
         jz1a8tpXMQ2ApR7FKhreb9JXFQfgWrNoiSrwk4GJdOEXrWOJ/qMu6Xt8bcEphh5HAfNO
         x2t4R/wFrYvqhuDXrcoRa7s2RFbwzCR9Nv1u7nY4LCjwtWkoWAfworlIU4TGtGX9ga4R
         jcrwKkNph16gbRhkkoTzr85RHHpnP/YgCmDIwBZDfANaQu9YyN9s15qBgbsHbZLG9tnV
         ImOQ==
X-Gm-Message-State: APjAAAVaHzyjedTMd4g3ogp3N6UpyrxpbM0TWT3zM1bOyN0een1DzV6G
	5LX6hVIjquMnIIdoXJZ+vOcbkA06DBTtDvM/1Re9bO4V3WzAGkPk2NSajDCVR0chBGAxg+d9Maz
	qeB/D4osscSXhohLTrfleQ5/SecBYD9hG7xx4Dy3dx67WcRzjPDwFcLO+gwC3GEehEQ==
X-Received: by 2002:adf:dc4a:: with SMTP id m10mr23737301wrj.0.1554840596619;
        Tue, 09 Apr 2019 13:09:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzprvF2zcur1gYUDsQvtl5Z2FayTpyJP64/LkQE7UvK7drpz4Ulu1S6CpjQFM0h/oJF/Quy
X-Received: by 2002:adf:dc4a:: with SMTP id m10mr23737257wrj.0.1554840595597;
        Tue, 09 Apr 2019 13:09:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554840595; cv=none;
        d=google.com; s=arc-20160816;
        b=wCysScvb7jL2xSBJJzcCSIieDfpeUciPwlYm6H7Hjz67X+SjVfb4ssmJxGjCgJQTwB
         MFtg1sMSQQOHKaF/YQzWbskKJsBQnfFgq9IiS0OGfBg+Tqb3vJvOwC500rHf5V2Mxw/6
         oLA5D8U5ezL7vVxeysrO9jvpJBWElG764uUyYr107Q/hcwmlyOVO7nSz107yjhbPV94z
         x9y1srBgC2E6zWZJaEnVGfPIsfEhxuf+pUHJ70eeNHERDbM/GRj/WOwee5g0ozlyHT19
         CuIdApMpUnIUlkz8dY9OttIaCg47RR1B/yMQm6iqUW3bCtGCCuNvN7BkRxd1j6iyMbwS
         Ioqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:user-agent:in-reply-to
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=D4jQvO0mBGJqUwfmCit7IZsasmJ93+nfPBcEDw+QQCE=;
        b=S67g3m7cCanvdY4dfPZrN8YYglfvS9sKgDZsNwjGvmBCZNUroyblXyP0o1Nu5K8jyZ
         KCWMoILLLWIQ+lGi3oPEQx9BiZSWJ1ilAh2bvEowNkwl7ix5BnvLYg6XJj2ANCLocIU1
         Y/VyybNi4guvSiaFHk//OGR3Ycyt/FMl2xlNA268C3IJEbGRSVNiTHlGQ4HCPcd1k7g/
         pzKK0pau7+0ERjSTIvATcA5q9555varz+adrsWfc8QHCeNjQOquNmHO7lEZTdqylWEZX
         JxSvxTXycaJYiv3AYR5iK/x1NRKQi+HYISIQn1tLvfgxuEUcY5om0wVfvjZTMzmc7AGR
         2jUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmx.net header.s=badeba3b8450 header.b=SMaFznGM;
       spf=pass (google.com: domain of deller@gmx.de designates 212.227.17.22 as permitted sender) smtp.mailfrom=deller@gmx.de
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.22])
        by mx.google.com with ESMTPS id x3si47963wmj.173.2019.04.09.13.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 13:09:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of deller@gmx.de designates 212.227.17.22 as permitted sender) client-ip=212.227.17.22;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmx.net header.s=badeba3b8450 header.b=SMaFznGM;
       spf=pass (google.com: domain of deller@gmx.de designates 212.227.17.22 as permitted sender) smtp.mailfrom=deller@gmx.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=gmx.net;
	s=badeba3b8450; t=1554840590;
	bh=fMr68XMbeYc4ZPmqwxro/3dZAU7fvVSg6bXxMQ046BA=;
	h=X-UI-Sender-Class:Date:From:To:Cc:Subject:References:In-Reply-To;
	b=SMaFznGMODy2NWKS7w36ckH3sR58IXj2uDHBxgJmG88VCBNeSVayPFpcj4MFTgi6o
	 wNLrCQdV57R1MhSv83okMMfnOldMVAPkPjrZQJNJ3GldATcD4mnBEkbZ0aqq9hD0go
	 DJayC7LWOyhFXJ9hHv9yylQqJLZ7rOXo0PxI0+gU=
X-UI-Sender-Class: 01bb95c1-4bf8-414a-932a-4f6e2808ef9c
Received: from p100.box ([92.116.130.134]) by mail.gmx.com (mrgmx102
 [212.227.17.168]) with ESMTPSA (Nemesis) id 0MIyCj-1hC1Fn0qsb-002V8I; Tue, 09
 Apr 2019 22:09:50 +0200
Date: Tue, 9 Apr 2019 22:09:46 +0200
From: Helge Deller <deller@gmx.de>
To: Helge Deller <deller@gmx.de>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Mikulas Patocka <mpatocka@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	John David Anglin <dave.anglin@bell.net>,
	linux-parisc@vger.kernel.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: Memory management broken by "mm: reclaim small amounts of memory
 when an external fragmentation event occurs"
Message-ID: <20190409200946.GA3274@p100.box>
References: <alpine.LRH.2.02.1904061042490.9597@file01.intranet.prod.int.rdu2.redhat.com>
 <20190408095224.GA18914@techsingularity.net>
 <1554733749.3137.6.camel@HansenPartnership.com>
 <1aca1299-8713-3d54-7c5e-adf791509987@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1aca1299-8713-3d54-7c5e-adf791509987@gmx.de>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Provags-ID: V03:K1:iCs4YH/LdjPQUe55mvSgBwltjGtjEQvRuyfVMtEHWTps6qaGVt6
 GUXsTOqdIJ+4hCsnD77GgVRdclPKtrD9G6q3hC82hXDpXoDC9zpULpHaMEpBxU/+lwmIAy9
 JP1qB04E8UdDV8x7de15SgdNUYLisRIG7jeGfEyv2K+sR6Ck3OPvLIvZJduHuHibTGpwR9v
 PeTUl0D6/ucPSuaRrTCQQ==
X-UI-Out-Filterresults: notjunk:1;V03:K0:J6g6zbXe1uE=:Bbt/W5rIpSpb8Pef2p/iJW
 9uu5ShJr3GWj+QOhhjXxTrYMUzh48ap6mBUxyN9BiQ1sye8Xia0Jf1IIB0nxN/hNW7dsaIdVm
 cS9ZYg27gCJg7lMUVTbpk4p09ZuO2mv0sBksB3v6F9talit9h/NUDdNH6MbwguTFXdKSMCTZO
 40w/P9+7fKOxF3Bgn/n80KSl381HQaykcjyuy3Ztc0EjH6S0lZhoqhn95ub7EmviBcUUnpfQ7
 ufbJtSd4nXcKx6aFNJ8IiuJ+6OQYCx0fccGjqEz/Jp3+cGBinZG+C3b6pmcClt7be5Gpc73Ag
 wqdw1XFOGDTsADWepYkzIfMuWzI46oReJ1TrlAe1dAtg3U03ZMv+aEDvKh4XiwJpCWmYFMpZr
 hvPbVLzNpQaYoXaoRPsoVdEsZfVTHGbYAZC0MxqI+v6XRTKXdmgJ+mQyaK8TXCCgK3X9Bbfon
 FMhKxQg37As3PlP6D9BcYbTrQmTNvtwFdqmsZX3dfKGcy10Z2eV5TG0Z976cOFmqqj+Dqt/Z1
 qx1Fahe/WdRJ2WTCK2buoRA96lyjht5MnWIVkB/hyR0twltfDpVybWVnwWpzlwt2NRXzsQ8UD
 8wKsKY79/qp45U1OFuR6xkgm/GJvzItNK5ajc2wKwU0+asjv73a/IFwO+Kqu10S0V7TzMYSdN
 zToO8JF1y2J4UHvd026tf1LphGP7KgCEMstHc+2ZGCsyyb3Xm/vryY4meJ5pnKMt2bM2hRyj4
 4YkEu/ziM8N08TluQpMdrqOqrakZmcfjvFC7FGyJyM0PsdeWYeiBcJpUZZuw3OHHG62tXDzXV
 vBgkBHTT6KysCc+fjmGXMXtOrj6OLzM0ljX/LnmUyzQXKH6aOWuhGJM1BhGY/Welx2ZiAetYp
 NOYmsIARPzBdc+z5lidJrDtkod5O/xCeavN9rbssjvrOKXgVjWygWnD7aWPa8H
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Helge Deller <deller@gmx.de>:
> On 08.04.19 16:29, James Bottomley wrote:
> > On Mon, 2019-04-08 at 10:52 +0100, Mel Gorman wrote:
> >> First, if pa-risc is !NUMA then why are separate local ranges
> >> represented as separate nodes? Is it because of DISCONTIGMEM or
> >> something else? DISCONTIGMEM is before my time so I'm not familiar
> >> with it and I consider it "essentially dead" but the arch init code
> >> seems to setup pgdats for each physical contiguous range so it's a
> >> possibility. The most likely explanation is pa-risc does not have
> >> hardware with addressing limitations smaller than the CPUs physical
> >> address limits and it's possible to have more ranges than available
> >> zones but clarification would be nice.
> >
> > Let me try, since I remember the ancient history.  In the early days,
> > there had to be a single mem_map array covering all of physical memory=
.
> >  Some pa-risc systems had huge gaps in the physical memory; I think on=
e
> > gap was somewhere around 1GB, so this lead us to wasting huge amounts
> > of space in mem_map on non-existent memory.  What CONFIG_DISCONTIGMEM
> > did was allow you to represent this discontinuity on a non-NUMA system
> > using numa nodes, so we effectively got one node per discontiguous
> > range.  It's hacky, but it worked.  I thought we finally got converted
> > to sparsemem by the NUMA people, but I can't find the commit.
>
> James, you tried once:
> https://patchwork.kernel.org/patch/729441/
>
> It seems we better should move over to sparsemem now?

Below is an updated patch to convert parisc from DISCONTIGMEM to
SPARSEMEM. It builds and boots for me on 32- and 64-bit machines.
Mikulas, could you try if you still see the the cache limited to 1GiB
with this patch applied ?

Helge

=2D--------------------

=46rom 2c30c3a61bbfb56850862a7f7127416325fe126f Mon Sep 17 00:00:00 2001
From: Helge Deller <deller@gmx.de>
Date: Tue, 9 Apr 2019 21:52:35 +0200
Subject: [PATCH] parisc: Switch from DISCONTIGMEM to SPARSEMEM

Signed-off-by: Helge Deller <deller@gmx.de>

diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index c8e6212..4f1397f 100644
=2D-- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -36,6 +36,7 @@ config PARISC
 	select GENERIC_STRNCPY_FROM_USER
 	select SYSCTL_ARCH_UNALIGN_ALLOW
 	select SYSCTL_EXCEPTION_TRACE
+	select ARCH_DISCARD_MEMBLOCK
 	select HAVE_MOD_ARCH_SPECIFIC
 	select VIRT_TO_BUS
 	select MODULES_USE_ELF_RELA
@@ -311,21 +312,16 @@ config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
 	depends on 64BIT

-config ARCH_DISCONTIGMEM_ENABLE
+config ARCH_SPARSEMEM_ENABLE
 	def_bool y
 	depends on 64BIT

 config ARCH_FLATMEM_ENABLE
 	def_bool y

-config ARCH_DISCONTIGMEM_DEFAULT
+config ARCH_SPARSEMEM_DEFAULT
 	def_bool y
-	depends on ARCH_DISCONTIGMEM_ENABLE
-
-config NODES_SHIFT
-	int
-	default "3"
-	depends on NEED_MULTIPLE_NODES
+	depends on ARCH_SPARSEMEM_ENABLE

 source "kernel/Kconfig.hz"

diff --git a/arch/parisc/include/asm/mmzone.h b/arch/parisc/include/asm/mm=
zone.h
index fafa389..8d39040 100644
=2D-- a/arch/parisc/include/asm/mmzone.h
+++ b/arch/parisc/include/asm/mmzone.h
@@ -2,62 +2,6 @@
 #ifndef _PARISC_MMZONE_H
 #define _PARISC_MMZONE_H

-#define MAX_PHYSMEM_RANGES 8 /* Fix the size for now (current known max i=
s 3) */
+#define MAX_PHYSMEM_RANGES 4 /* Fix the size for now (current known max i=
s 3) */

-#ifdef CONFIG_DISCONTIGMEM
-
-extern int npmem_ranges;
-
-struct node_map_data {
-    pg_data_t pg_data;
-};
-
-extern struct node_map_data node_data[];
-
-#define NODE_DATA(nid)          (&node_data[nid].pg_data)
-
-/* We have these possible memory map layouts:
- * Astro: 0-3.75, 67.75-68, 4-64
- * zx1: 0-1, 257-260, 4-256
- * Stretch (N-class): 0-2, 4-32, 34-xxx
- */
-
-/* Since each 1GB can only belong to one region (node), we can create
- * an index table for pfn to nid lookup; each entry in pfnnid_map
- * represents 1GB, and contains the node that the memory belongs to. */
-
-#define PFNNID_SHIFT (30 - PAGE_SHIFT)
-#define PFNNID_MAP_MAX  512     /* support 512GB */
-extern signed char pfnnid_map[PFNNID_MAP_MAX];
-
-#ifndef CONFIG_64BIT
-#define pfn_is_io(pfn) ((pfn & (0xf0000000UL >> PAGE_SHIFT)) =3D=3D (0xf0=
000000UL >> PAGE_SHIFT))
-#else
-/* io can be 0xf0f0f0f0f0xxxxxx or 0xfffffffff0000000 */
-#define pfn_is_io(pfn) ((pfn & (0xf000000000000000UL >> PAGE_SHIFT)) =3D=
=3D (0xf000000000000000UL >> PAGE_SHIFT))
-#endif
-
-static inline int pfn_to_nid(unsigned long pfn)
-{
-	unsigned int i;
-
-	if (unlikely(pfn_is_io(pfn)))
-		return 0;
-
-	i =3D pfn >> PFNNID_SHIFT;
-	BUG_ON(i >=3D ARRAY_SIZE(pfnnid_map));
-
-	return pfnnid_map[i];
-}
-
-static inline int pfn_valid(int pfn)
-{
-	int nid =3D pfn_to_nid(pfn);
-
-	if (nid >=3D 0)
-		return (pfn < node_end_pfn(nid));
-	return 0;
-}
-
-#endif
 #endif /* _PARISC_MMZONE_H */
diff --git a/arch/parisc/include/asm/page.h b/arch/parisc/include/asm/page=
.h
index b77f49c..93caf17 100644
=2D-- a/arch/parisc/include/asm/page.h
+++ b/arch/parisc/include/asm/page.h
@@ -147,9 +147,9 @@ extern int npmem_ranges;
 #define __pa(x)			((unsigned long)(x)-PAGE_OFFSET)
 #define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))

-#ifndef CONFIG_DISCONTIGMEM
+#ifndef CONFIG_SPARSEMEM
 #define pfn_valid(pfn)		((pfn) < max_mapnr)
-#endif /* CONFIG_DISCONTIGMEM */
+#endif

 #ifdef CONFIG_HUGETLB_PAGE
 #define HPAGE_SHIFT		PMD_SHIFT /* fixed for transparent huge pages */
diff --git a/arch/parisc/include/asm/sparsemem.h b/arch/parisc/include/asm=
/sparsemem.h
new file mode 100644
index 0000000..b7d1dc9
=2D-- /dev/null
+++ b/arch/parisc/include/asm/sparsemem.h
@@ -0,0 +1,14 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef ASM_PARISC_SPARSEMEM_H
+#define ASM_PARISC_SPARSEMEM_H
+
+/* We have these possible memory map layouts:
+ * Astro: 0-3.75, 67.75-68, 4-64
+ * zx1: 0-1, 257-260, 4-256
+ * Stretch (N-class): 0-2, 4-32, 34-xxx
+ */
+
+#define MAX_PHYSMEM_BITS	42
+#define SECTION_SIZE_BITS	37
+
+#endif
diff --git a/arch/parisc/kernel/parisc_ksyms.c b/arch/parisc/kernel/parisc=
_ksyms.c
index 7baa226..174213b 100644
=2D-- a/arch/parisc/kernel/parisc_ksyms.c
+++ b/arch/parisc/kernel/parisc_ksyms.c
@@ -138,12 +138,6 @@ extern void $$dyncall(void);
 EXPORT_SYMBOL($$dyncall);
 #endif

-#ifdef CONFIG_DISCONTIGMEM
-#include <asm/mmzone.h>
-EXPORT_SYMBOL(node_data);
-EXPORT_SYMBOL(pfnnid_map);
-#endif
-
 #ifdef CONFIG_FUNCTION_TRACER
 extern void _mcount(void);
 EXPORT_SYMBOL(_mcount);
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index d0b1662..9523394 100644
=2D-- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -48,11 +48,6 @@ pmd_t pmd0[PTRS_PER_PMD] __attribute__ ((__section__ ("=
.data..vm0.pmd"), aligned
 pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__ ((__section__ (".data..v=
m0.pgd"), aligned(PAGE_SIZE)));
 pte_t pg0[PT_INITIAL * PTRS_PER_PTE] __attribute__ ((__section__ (".data.=
.vm0.pte"), aligned(PAGE_SIZE)));

-#ifdef CONFIG_DISCONTIGMEM
-struct node_map_data node_data[MAX_NUMNODES] __read_mostly;
-signed char pfnnid_map[PFNNID_MAP_MAX] __read_mostly;
-#endif
-
 static struct resource data_resource =3D {
 	.name	=3D "Kernel data",
 	.flags	=3D IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
@@ -76,11 +71,11 @@ static struct resource sysram_resources[MAX_PHYSMEM_RA=
NGES] __read_mostly;
  * information retrieved in kernel/inventory.c.
  */

-physmem_range_t pmem_ranges[MAX_PHYSMEM_RANGES] __read_mostly;
-int npmem_ranges __read_mostly;
+physmem_range_t pmem_ranges[MAX_PHYSMEM_RANGES] __initdata;
+int npmem_ranges __initdata;

 #ifdef CONFIG_64BIT
-#define MAX_MEM         (~0UL)
+#define MAX_MEM         (1UL << MAX_PHYSMEM_BITS)
 #else /* !CONFIG_64BIT */
 #define MAX_MEM         (3584U*1024U*1024U)
 #endif /* !CONFIG_64BIT */
@@ -119,7 +114,7 @@ static void __init mem_limit_func(void)
 static void __init setup_bootmem(void)
 {
 	unsigned long mem_max;
-#ifndef CONFIG_DISCONTIGMEM
+#ifndef CONFIG_SPARSEMEM
 	physmem_range_t pmem_holes[MAX_PHYSMEM_RANGES - 1];
 	int npmem_holes;
 #endif
@@ -137,23 +132,20 @@ static void __init setup_bootmem(void)
 		int j;

 		for (j =3D i; j > 0; j--) {
-			unsigned long tmp;
+			physmem_range_t tmp;

 			if (pmem_ranges[j-1].start_pfn <
 			    pmem_ranges[j].start_pfn) {

 				break;
 			}
-			tmp =3D pmem_ranges[j-1].start_pfn;
-			pmem_ranges[j-1].start_pfn =3D pmem_ranges[j].start_pfn;
-			pmem_ranges[j].start_pfn =3D tmp;
-			tmp =3D pmem_ranges[j-1].pages;
-			pmem_ranges[j-1].pages =3D pmem_ranges[j].pages;
-			pmem_ranges[j].pages =3D tmp;
+			tmp =3D pmem_ranges[j-1];
+			pmem_ranges[j-1] =3D pmem_ranges[j];
+			pmem_ranges[j] =3D tmp;
 		}
 	}

-#ifndef CONFIG_DISCONTIGMEM
+#ifndef CONFIG_SPARSEMEM
 	/*
 	 * Throw out ranges that are too far apart (controlled by
 	 * MAX_GAP).
@@ -165,7 +157,7 @@ static void __init setup_bootmem(void)
 			 pmem_ranges[i-1].pages) > MAX_GAP) {
 			npmem_ranges =3D i;
 			printk("Large gap in memory detected (%ld pages). "
-			       "Consider turning on CONFIG_DISCONTIGMEM\n",
+			       "Consider turning on CONFIG_SPARSEMEM\n",
 			       pmem_ranges[i].start_pfn -
 			       (pmem_ranges[i-1].start_pfn +
 			        pmem_ranges[i-1].pages));
@@ -230,9 +222,8 @@ static void __init setup_bootmem(void)

 	printk(KERN_INFO "Total Memory: %ld MB\n",mem_max >> 20);

-#ifndef CONFIG_DISCONTIGMEM
+#ifndef CONFIG_SPARSEMEM
 	/* Merge the ranges, keeping track of the holes */
-
 	{
 		unsigned long end_pfn;
 		unsigned long hole_pages;
@@ -255,18 +246,6 @@ static void __init setup_bootmem(void)
 	}
 #endif

-#ifdef CONFIG_DISCONTIGMEM
-	for (i =3D 0; i < MAX_PHYSMEM_RANGES; i++) {
-		memset(NODE_DATA(i), 0, sizeof(pg_data_t));
-	}
-	memset(pfnnid_map, 0xff, sizeof(pfnnid_map));
-
-	for (i =3D 0; i < npmem_ranges; i++) {
-		node_set_state(i, N_NORMAL_MEMORY);
-		node_set_online(i);
-	}
-#endif
-
 	/*
 	 * Initialize and free the full range of memory in each range.
 	 */
@@ -314,7 +293,7 @@ static void __init setup_bootmem(void)
 	memblock_reserve(__pa(KERNEL_BINARY_TEXT_START),
 			(unsigned long)(_end - KERNEL_BINARY_TEXT_START));

-#ifndef CONFIG_DISCONTIGMEM
+#ifndef CONFIG_SPARSEMEM

 	/* reserve the holes */

@@ -360,6 +339,9 @@ static void __init setup_bootmem(void)

 	/* Initialize Page Deallocation Table (PDT) and check for bad memory. */
 	pdc_pdt_init();
+
+	memblock_allow_resize();
+	memblock_dump_all();
 }

 static int __init parisc_text_address(unsigned long vaddr)
@@ -709,37 +691,46 @@ static void __init gateway_init(void)
 		  PAGE_SIZE, PAGE_GATEWAY, 1);
 }

-void __init paging_init(void)
+static void __init parisc_bootmem_free(void)
 {
+	unsigned long zones_size[MAX_NR_ZONES] =3D { 0, };
+	unsigned long holes_size[MAX_NR_ZONES] =3D { 0, };
+	unsigned long mem_start_pfn =3D ~0UL, mem_end_pfn =3D 0, mem_size_pfn =
=3D 0;
 	int i;

+	for (i =3D 0; i < npmem_ranges; i++) {
+		unsigned long start =3D pmem_ranges[i].start_pfn;
+		unsigned long size =3D pmem_ranges[i].pages;
+		unsigned long end =3D start + size;
+
+		if (mem_start_pfn > start)
+			mem_start_pfn =3D start;
+		if (mem_end_pfn < end)
+			mem_end_pfn =3D end;
+		mem_size_pfn +=3D size;
+	}
+
+	zones_size[0] =3D mem_end_pfn - mem_start_pfn;
+	holes_size[0] =3D zones_size[0] - mem_size_pfn;
+
+	free_area_init_node(0, zones_size, mem_start_pfn, holes_size);
+}
+
+void __init paging_init(void)
+{
 	setup_bootmem();
 	pagetable_init();
 	gateway_init();
 	flush_cache_all_local(); /* start with known state */
 	flush_tlb_all_local(NULL);

-	for (i =3D 0; i < npmem_ranges; i++) {
-		unsigned long zones_size[MAX_NR_ZONES] =3D { 0, };
-
-		zones_size[ZONE_NORMAL] =3D pmem_ranges[i].pages;
-
-#ifdef CONFIG_DISCONTIGMEM
-		/* Need to initialize the pfnnid_map before we can initialize
-		   the zone */
-		{
-		    int j;
-		    for (j =3D (pmem_ranges[i].start_pfn >> PFNNID_SHIFT);
-			 j <=3D ((pmem_ranges[i].start_pfn + pmem_ranges[i].pages) >> PFNNID_S=
HIFT);
-			 j++) {
-			pfnnid_map[j] =3D i;
-		    }
-		}
-#endif
-
-		free_area_init_node(i, zones_size,
-				pmem_ranges[i].start_pfn, NULL);
-	}
+	/*
+	 * Mark all memblocks as present for sparsemem using
+	 * memory_present() and then initialize sparsemem.
+	 */
+	memblocks_present();
+	sparse_init();
+	parisc_bootmem_free();
 }

 #ifdef CONFIG_PA20

