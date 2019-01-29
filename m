Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B4F1C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:56:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EDB420869
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:56:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EDB420869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CEDD8E0004; Tue, 29 Jan 2019 04:56:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07F2D8E0001; Tue, 29 Jan 2019 04:56:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E88AC8E0004; Tue, 29 Jan 2019 04:56:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A6CBB8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 04:56:58 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 89so13889162ple.19
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 01:56:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=WbE8t9KAvtVePuQuvsmVC/LGoOb3TuwrhK/Zmu4WaXI=;
        b=ujtzXhe8i37q34Y1HiCTXVzV1pSW1fN+XNXSUlNywpA/iAG6L8C0n3Xh5P6kAT1Si5
         Jhem/hdU7c9USO06Vd+FjfUx7PiST4XJSmYHkM8FkNEkuOhMnTw6VkMMP6gjJUKq4G7O
         +SHesute2sO4oDBsUWn85IzLo7EBQ5FHDphWZyoQg1KLIThW/xg/lM5eU2NYuJGZ0KqD
         wLoew3cmR9tKEGiBRDY8haqm/NKEPrEJMoegB70n0VU0QmaNlGyy40RMzzbYBsqKPW0X
         WtNaB/ZS2L8i77jcr0RgIUCzerjKbfCBlL5X7QD5IfO1bFUS3FSRYKCDS1Qo4wqXyuMF
         AxXA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukeXZZls0ra3PkxsTlle1AkyZunCoZ181m+02PdcDsEPdgd8OfQ1
	0oO0FqdSYGsv6FJzsjTJ+YlwkV49kLT63CoNlpr4QoWYNCM6r8gK8YVmLIH2atjJHD+rP+KRR/h
	zRWFjS04+2e0D1lLDLRjM2Y9+XKQTdHl9YtUeximmlz387q9k6jr46w5pSBUgyoU=
X-Received: by 2002:a63:5346:: with SMTP id t6mr23420320pgl.40.1548755818285;
        Tue, 29 Jan 2019 01:56:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5aaeFuhGGnCKsBzSAKvitq9a8ntT8MR72phmBSbNBiRS0LZ5wjB5RK4bbkc6VaWYjCls0x
X-Received: by 2002:a63:5346:: with SMTP id t6mr23420299pgl.40.1548755817694;
        Tue, 29 Jan 2019 01:56:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548755817; cv=none;
        d=google.com; s=arc-20160816;
        b=Qz1nvgFHdZW3vDnjmUuuI6Eyk9Dt4PNrDC6IHK0/gBk6cj0rFW2S0fI54frEW9Qb34
         Rxv0mv81BkcVCbuzWNrd0sN6wUbibClQpph3GxdgnGjThTxfVAhPHAdLxosS/pJDYtQz
         wyxppEdINHcoa33rX+mJZXqzAvHO+VGut0AXuTyvpxLiIJJANHyZNVQKtmHmFnJZAHjE
         7BMQWddQkz3e5BqJfZwVgVQnV65huhARD0bsA+JPmiTvrWpT+YUVIgFqfK5SUgIWX+oL
         GWEnGBWC19h2L6xdmOvcAstzrlXHPryu63QEwBod//YjrU2w7N7pBAY1LsB8Rm+bcqcK
         FONg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=WbE8t9KAvtVePuQuvsmVC/LGoOb3TuwrhK/Zmu4WaXI=;
        b=nNa7OlyKFev4ZeduFZ4NGxCuz2M14GtrhZ/II0G+zWyQbaXXvH7hE8XdpwKcHjcf0/
         Sq1XlGGcD7n7GZRCuEHaBXvYeoWFmJ9FisIw2rwklWtCEFKzw4zzlbj2/NP3gjhdLTLv
         nQxltqvh1we4vKP8qcDSL7amZnhNfP7YGcdb5tk/l+zMkioYESQmM+2K4rWg8aMgaiS4
         GeY1jFWyLTpMDC/Q53Xw+cK62NzdKxcA/jFjsEPDX0LanD04YvWuKA6/1gEYTT7OjetF
         LfoYc1Y7UP2OsjV0jd8GSGe9Z8d9pvzo5olERwgx2ACRH/f/ooj05F9AaVL09UghJPOw
         Pwgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id k5si33004870pfi.176.2019.01.29.01.56.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 01:56:57 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43phjg3h9Pz9sDr;
	Tue, 29 Jan 2019 20:56:55 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas
 <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S.
 Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert
 Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao
 <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner
 <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michal Simek
 <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek
 <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger
 <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King
 <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck
 <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato
 <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org,
 kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org,
 linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org,
 linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org,
 linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org,
 sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp,
 x86@kernel.org, xen-devel@lists.xenproject.org, Mike Rapoport
 <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 06/21] memblock: memblock_phys_alloc_try_nid(): don't panic
In-Reply-To: <1548057848-15136-7-git-send-email-rppt@linux.ibm.com>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com> <1548057848-15136-7-git-send-email-rppt@linux.ibm.com>
Date: Tue, 29 Jan 2019 20:56:54 +1100
Message-ID: <87y373rdll.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mike Rapoport <rppt@linux.ibm.com> writes:

> diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
> index ae34e3a..2c61ea4 100644
> --- a/arch/arm64/mm/numa.c
> +++ b/arch/arm64/mm/numa.c
> @@ -237,6 +237,10 @@ static void __init setup_node_data(int nid, u64 start_pfn, u64 end_pfn)
>  		pr_info("Initmem setup node %d [<memory-less node>]\n", nid);
>  
>  	nd_pa = memblock_phys_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
> +	if (!nd_pa)
> +		panic("Cannot allocate %zu bytes for node %d data\n",
> +		      nd_size, nid);
> +
>  	nd = __va(nd_pa);

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

