Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24211C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:54:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFE0D24DB4
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:54:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HARn4yCl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFE0D24DB4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46CCB6B000A; Tue,  4 Jun 2019 02:54:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41EE56B000C; Tue,  4 Jun 2019 02:54:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E54A6B000D; Tue,  4 Jun 2019 02:54:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6F546B000A
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 02:54:16 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bb9so13402610plb.2
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 23:54:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=o0/x+1oKv0SZnOXYtDRUsgML6+umJV3GQkxVLH8VplA=;
        b=gytMV7FbdScXiSI1Vz34TX7y0w5IMKKm4Ox7PHkQdHHPlOBRqaUav+INIPvBQZqY21
         9yh2WYpwo+aUuPYw8iDalyTuEP8hdnfY2BsvAgw2UfdGj7He0weSDlnOTIiPZMm6ULDU
         xcmhig/I84gRKuBqCUu6Vi9wEmp4bnRCiW3pdKBbhIBIiBn/7aXpqpa7o+VEkWinD84v
         qh1x7zNC86FOYuoAKu2Ola84uyndU7z6ew21kiPIJxnob2vMElQZIwVNtyfiK9XUQghl
         flbgYE6ZyjCB0aVmbvg+mJPxsZN3w9FT2lboIagFbFsHL1pCsVfkbqQLSS7KcX0LnmkO
         410Q==
X-Gm-Message-State: APjAAAUR9t6ops+PTEouks3+Vr3geTrj6qdJVToIZ566dxKBpJ4bGPud
	0rUGVFllorj2omsqKCaco6cwlJdAobhZTNTQgi5X28TaAjvWf8W1dQjOypJwVqNrPCz9tyy/rEL
	5aY4o0f5vvqPayDlIVk+CYWQjE6+eY0nJhRNF2iRomLcDE9+jPNEkPG4uIzWudjaEsw==
X-Received: by 2002:a17:90a:8a10:: with SMTP id w16mr34875442pjn.133.1559631256578;
        Mon, 03 Jun 2019 23:54:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynaHYXIzRJAwgfVi/1mGaTw0IjjEc4gSf98z24Np6MGkM9sUQ8fXn80hRgFlWIAc0PrXMQ
X-Received: by 2002:a17:90a:8a10:: with SMTP id w16mr34875403pjn.133.1559631255825;
        Mon, 03 Jun 2019 23:54:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559631255; cv=none;
        d=google.com; s=arc-20160816;
        b=TfM4lUnim8xuSM6wbcKMA5VAEN48BIYWsMU0n8rEUc4Vn5ufvr/VPO2EbceeR1gnSq
         RMknKJvg2dqu3aCExmcpClEucH5mYaz+o3r//1fx1K5xzu7SWRITp7xeQZ5toN8ZE227
         TWMT+DW7tMdvG+53tGaxPs7PpyTNAFqTmNhjG2ato31d7t4lRzEkqtYzTJuTJj/YY6Lf
         aYC3f8KOdl6a/c0QWzlP00LV/iKnXwUJkI9zQPMASnr4Cr9Vc2lN0AvjhsY1kf7O4cwh
         /mM9kjKo+r0lj6n4k6lyDTK7KM8Y1Y9DrUnXjJljdYaDKDdXI/Fl9kb0hh8f5ZLCZK1k
         y5/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=o0/x+1oKv0SZnOXYtDRUsgML6+umJV3GQkxVLH8VplA=;
        b=Tb5uv+Ks2Sl4fRVQ1kgWJ5pGDt6RraLQzKhF4JB35/YMHVVtg9ENcEzVvYqL3cQZsG
         x9u/9GKOE23ciU/SjlSCJiQmxYu3MRVJKXzdJ1mwnrAENtpSaz/vjHpMzFk/mtFvcZpp
         l0uqAh7CGxUXK5Ti6gOk4vuJzKKoKqhBl8CoL7x92T1R4VNaroVbICtCikm9YPMN+wsr
         gHCMCpRXclBh0xnd1zmjEyT5W0QTiYfrSxfdk6u30XBGfDCS9044wm1Ee8cC9A5UqGQG
         UzlTDl/36+rBez6iFGkIAKfGsKKHgxEPYTyVJGQqCrL7lqLMN5/un888VZcTatFCOEx0
         /trw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HARn4yCl;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m23si20060058pgj.296.2019.06.03.23.54.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 23:54:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HARn4yCl;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=o0/x+1oKv0SZnOXYtDRUsgML6+umJV3GQkxVLH8VplA=; b=HARn4yClLyKIcGgcTwTDD+jMd
	1ef7NULcX2Ny2MFe3bZpZHb30cLWSrPWc+xLr8ShYTmRRwEt49WdLKzvXVE7+BLps/iqR4Kkhg4+D
	Jv5IlCPj9JeZ/4Zj90FKMkkfDVWaeU3eqEvefbikGR7rzaj7QViz1N46SKGNWu7zI4W3PoR20bU0u
	bPCRXeOfyT/1kv9ZkyME/bMQcBf1vGP9Zo0EO4Dgrn0hnw+ygmh+mzIgTUlc9k3aSnSRuQDc5mgfz
	1Hk0TIi/arJ70lLgpQO+eOM7NwXLFKSxYHf4sA/TaUDXS1/nqt5n66d+x7GKHDaCKsR0BqTZraZkJ
	0Wa5VbknA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hY3Ke-0001TW-0y; Tue, 04 Jun 2019 06:54:04 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 9627520761B5F; Tue,  4 Jun 2019 08:54:01 +0200 (CEST)
Date: Tue, 4 Jun 2019 08:54:01 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Andrey Konovalov <andreyknvl@google.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>,
	Dave Hansen <dave.hansen@linux.intel.com>
Subject: Re: [RFC V2] mm: Generalize notify_page_fault()
Message-ID: <20190604065401.GE3402@hirez.programming.kicks-ass.net>
References: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 12:04:06PM +0530, Anshuman Khandual wrote:
> diff --git a/mm/memory.c b/mm/memory.c
> index ddf20bd..b6bae8f 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -52,6 +52,7 @@
>  #include <linux/pagemap.h>
>  #include <linux/memremap.h>
>  #include <linux/ksm.h>
> +#include <linux/kprobes.h>
>  #include <linux/rmap.h>
>  #include <linux/export.h>
>  #include <linux/delayacct.h>
> @@ -141,6 +142,21 @@ static int __init init_zero_pfn(void)
>  core_initcall(init_zero_pfn);
>  
>  
> +int __kprobes notify_page_fault(struct pt_regs *regs, unsigned int trap)
> +{
> +	int ret = 0;
> +
> +	/*
> +	 * To be potentially processing a kprobe fault and to be allowed
> +	 * to call kprobe_running(), we have to be non-preemptible.
> +	 */
> +	if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
> +			ret = 1;
> +	}
> +	return ret;
> +}

That thing should be called kprobe_page_fault() or something,
notify_page_fault() is a horribly crap name for this function.

