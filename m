Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BED0DC32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:33:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7981620679
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:33:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YOxge0Yl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7981620679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 095338E000D; Wed, 31 Jul 2019 13:33:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0458C8E0001; Wed, 31 Jul 2019 13:33:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E76848E000D; Wed, 31 Jul 2019 13:33:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3C128E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:33:26 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 91so37868737pla.7
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:33:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1mUzN69TbVh9yZT+F3MQDO+6tQ5Mp+B1rUEtD2T6Huc=;
        b=kb2Rfc1gqyFhi/n8zgZ1k2lnqhOZvMQKmFjRfmAYJpbqx0QKD+NGZfuBZ8J5Ct/dgp
         zMFai7fZ1rif8K+Zlb0kH+xyDRI7MT6a3wG8u/MfmGMh6qruX8VGdrqbotCXt95BZPZr
         87PvXbGCwzZxcPoQ2RZN3a7rnCKVH0sZXR9Jbfdf4OuDm7mamFqrA5udUTby7QD5MXrG
         +73SO5ADuz5QoohEQGyDAAAn8H3KSvR2B7WIg8AF5o/QulGeUufpwDNPMFI/OppinJmS
         wZW8g4IJNISOJgPkY70RVOA4n1j13vP7SxkqbZI45wjJ5eFRFQw8kBbmopbpQfxKe8ek
         jpWQ==
X-Gm-Message-State: APjAAAVEJaf9LM/r8dbCaGW8a4ShKwNTOlQisRfdmSJrn9PZQbnbgI8F
	xW4r/Tbu6drAQ6BYB7rxy9CfHoz6ZbOa0enY3l0D++Vz3oTyIe+I4OwrVscf1OCLyuENnk0qwYs
	TuQXaWP4UXm7M1uQ/dO2u1zH1Bgxw5D3QQt1X7j0sApCbGUS1HAzqQoHRiptn044=
X-Received: by 2002:a17:90a:9505:: with SMTP id t5mr4043399pjo.96.1564594406218;
        Wed, 31 Jul 2019 10:33:26 -0700 (PDT)
X-Received: by 2002:a17:90a:9505:: with SMTP id t5mr4043340pjo.96.1564594405017;
        Wed, 31 Jul 2019 10:33:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564594405; cv=none;
        d=google.com; s=arc-20160816;
        b=VPvrVAG6Kx4o7jZoEyPIsKoubQ08wuhO5L8ykJ3brWr4IoHsgXfgGbbHnrH9hb0OuH
         5D7VP+Rs2XCe7G5+lkvlPwtQf1pzHPuZvuZE2LRPKfrQhefa7+cUZbwNHtzAHT0dpK/Q
         1HgAf+KuzAhKLgaMAl1A1gBS89BOSxYUrGFkn7mw6isfyHoxeI9fI2jVEjexeFvtH4cu
         l+UoE+cfnjFrji8xfvajFj1jQ+UMwX3qOIsjLA09Np5OikmngYT0XyNx0uc5yK5m4EI0
         7eYfVbG6olBchn8RFxJzEvuhEJ3fQWfunlmMukjdNylIeUyaXcq9XJzHonerviC1GiF4
         Gkfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=1mUzN69TbVh9yZT+F3MQDO+6tQ5Mp+B1rUEtD2T6Huc=;
        b=Tcq1owm5pKPDdnzEfKcZlPESNNFr7mq/vXzfHT062v3bble5sVnZ99oVK4vdOhNtOY
         ZgcfVq1fM5/lAkKD3aBV0aDe0Kn6mE6TxLEO7eqC/aByzmtBTDO/7v4O+xC5I6y86Hz7
         esqOQtsN0TBouUxWEz6l3srRK2hKu16VKKp9FhE+O71R56UaKJjJD1cHSERPVlg1ciLo
         k0baiK2B+Mx5Vr16EOdmwSy0Kr9gUnNOtmv/qn1MolKQcanvJGTTP4onoeNmJqEPMdL9
         tXqwbwI8QzO/6e38CyaaZPb9EAQl4SX0ZRhLDfREF8mcxo5QxKZZ/5DKT4xJUpurg3qj
         6A2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YOxge0Yl;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j19sor50054893pfd.55.2019.07.31.10.33.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 10:33:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YOxge0Yl;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1mUzN69TbVh9yZT+F3MQDO+6tQ5Mp+B1rUEtD2T6Huc=;
        b=YOxge0Yl9i70G+adD8fcIAQFr/+MKP/AFeajQGmNOUU3PSBiJFy13XEVeByt0H23Fm
         eQzDcQe68Apu1iZpVUkzBjb1K8sNEmZZT1vTc0iVLJa71adt7IaZsg7HXfFrupSDvu2t
         /AbaO7TzbQzEOfsYUnbE8+0dT8MWRwsp1fjykU0avS6hF4Jk57q5gwhJWRcTwnruRx8D
         PzGi9hcvi/tT1aDkbKf0dLDit1UyoCPYI0SUX4i4V74v4YxmWPog8KRGZn0aniBLbdUA
         HNRGCy5jpKlcLfKvyalbj8kL5hQfmFY6LXC6ZzkipEieZEKSDhpcT5WZw6P56IE6NcoA
         AxYw==
X-Google-Smtp-Source: APXvYqwzc3V4hpBjzjfpPb1vXFYPZ0Qeb7PGWHW8bph0fdJAOdbQdQV14uAoPp6X+iZ/zBHaMBAOoQ==
X-Received: by 2002:a62:7d13:: with SMTP id y19mr48612603pfc.62.1564594404588;
        Wed, 31 Jul 2019 10:33:24 -0700 (PDT)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id e10sm71043899pfi.173.2019.07.31.10.33.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 10:33:23 -0700 (PDT)
Date: Wed, 31 Jul 2019 10:33:22 -0700
From: Guenter Roeck <linux@roeck-us.net>
To: Alex Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v5 14/14] riscv: Make mmap allocation top-down by default
Message-ID: <20190731173322.GA30870@roeck-us.net>
References: <20190730055113.23635-1-alex@ghiti.fr>
 <20190730055113.23635-15-alex@ghiti.fr>
 <88a9bbf8-872f-97cc-fc1a-83eb7694478f@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <88a9bbf8-872f-97cc-fc1a-83eb7694478f@ghiti.fr>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 02:05:23AM -0400, Alex Ghiti wrote:
> On 7/30/19 1:51 AM, Alexandre Ghiti wrote:
> >In order to avoid wasting user address space by using bottom-up mmap
> >allocation scheme, prefer top-down scheme when possible.
> >
> >Before:
> >root@qemuriscv64:~# cat /proc/self/maps
> >00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
> >00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
> >00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
> >00018000-00039000 rw-p 00000000 00:00 0          [heap]
> >1555556000-155556d000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
> >155556d000-155556e000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
> >155556e000-155556f000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
> >155556f000-1555570000 rw-p 00000000 00:00 0
> >1555570000-1555572000 r-xp 00000000 00:00 0      [vdso]
> >1555574000-1555576000 rw-p 00000000 00:00 0
> >1555576000-1555674000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
> >1555674000-1555678000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
> >1555678000-155567a000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
> >155567a000-15556a0000 rw-p 00000000 00:00 0
> >3fffb90000-3fffbb1000 rw-p 00000000 00:00 0      [stack]
> >
> >After:
> >root@qemuriscv64:~# cat /proc/self/maps
> >00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
> >00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
> >00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
> >2de81000-2dea2000 rw-p 00000000 00:00 0          [heap]
> >3ff7eb6000-3ff7ed8000 rw-p 00000000 00:00 0
> >3ff7ed8000-3ff7fd6000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
> >3ff7fd6000-3ff7fda000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
> >3ff7fda000-3ff7fdc000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
> >3ff7fdc000-3ff7fe2000 rw-p 00000000 00:00 0
> >3ff7fe4000-3ff7fe6000 r-xp 00000000 00:00 0      [vdso]
> >3ff7fe6000-3ff7ffd000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
> >3ff7ffd000-3ff7ffe000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
> >3ff7ffe000-3ff7fff000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
> >3ff7fff000-3ff8000000 rw-p 00000000 00:00 0
> >3fff888000-3fff8a9000 rw-p 00000000 00:00 0      [stack]
> >
> >Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> >Reviewed-by: Christoph Hellwig <hch@lst.de>
> >Reviewed-by: Kees Cook <keescook@chromium.org>
> >Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
> >---
> >  arch/riscv/Kconfig | 13 +++++++++++++
> >  1 file changed, 13 insertions(+)
> >
> >diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
> >index 8ef64fe2c2b3..8d0d8af1a744 100644
> >--- a/arch/riscv/Kconfig
> >+++ b/arch/riscv/Kconfig
> >@@ -54,6 +54,19 @@ config RISCV
> >  	select EDAC_SUPPORT
> >  	select ARCH_HAS_GIGANTIC_PAGE
> >  	select ARCH_WANT_HUGE_PMD_SHARE if 64BIT
> >+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
> >+	select HAVE_ARCH_MMAP_RND_BITS
> >+
> >+config ARCH_MMAP_RND_BITS_MIN
> >+	default 18 if 64BIT
> >+	default 8
> >+
> >+# max bits determined by the following formula:
> >+#  VA_BITS - PAGE_SHIFT - 3
> >+config ARCH_MMAP_RND_BITS_MAX
> >+	default 33 if RISCV_VM_SV48
> >+	default 24 if RISCV_VM_SV39
> >+	default 17 if RISCV_VM_SV32
> >  config MMU
> >  	def_bool y
> 
> 
> Hi Andrew,
> 
> I have just seen you took this series into mmotm but without Paul's patch
> ("riscv: kbuild: add virtual memory system selection") on which this commit
> relies, I'm not sure it could
> compile without it as there is no default for ARCH_MMAP_RND_BITS_MAX.
> 
Yes, this patch results in a bad configuration file.

CONFIG_ARCH_MMAP_RND_BITS_MIN=18
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_ARCH_MMAP_RND_BITS=0

CONFIG_ARCH_MMAP_RND_BITS=0 is outside the valid range, causing make to ask
for a valid number. Since none exists, one is stuck with something like:

Number of bits to use for ASLR of mmap base address (ARCH_MMAP_RND_BITS) [0] (NEW) 1
Number of bits to use for ASLR of mmap base address (ARCH_MMAP_RND_BITS) [0] (NEW) 2
Number of bits to use for ASLR of mmap base address (ARCH_MMAP_RND_BITS) [0] (NEW) 3
Number of bits to use for ASLR of mmap base address (ARCH_MMAP_RND_BITS) [0] (NEW) 4
Number of bits to use for ASLR of mmap base address (ARCH_MMAP_RND_BITS) [0] (NEW) 5
Number of bits to use for ASLR of mmap base address (ARCH_MMAP_RND_BITS) [0] (NEW) 6
Number of bits to use for ASLR of mmap base address (ARCH_MMAP_RND_BITS) [0] (NEW) 7
Number of bits to use for ASLR of mmap base address (ARCH_MMAP_RND_BITS) [0] (NEW) 8
Number of bits to use for ASLR of mmap base address (ARCH_MMAP_RND_BITS) [0] (NEW) 19
Number of bits to use for ASLR of mmap base address (ARCH_MMAP_RND_BITS) [0] (NEW) 18

when trying to compile riscv images. Plus, of course, all automatic builders
bail out as result. 

Guenter

