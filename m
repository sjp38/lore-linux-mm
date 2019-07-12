Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E509FC742B3
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 11:45:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FB9B2083B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 11:45:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="THypPdhe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FB9B2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 290408E013C; Fri, 12 Jul 2019 07:45:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 240BA8E00DB; Fri, 12 Jul 2019 07:45:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 108998E013C; Fri, 12 Jul 2019 07:45:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CF6F28E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 07:45:06 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id c18so5576397pgk.2
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 04:45:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7WheT2sFPbpAYUphDY20RcxiluEPP2yGBWlv6nqCcpo=;
        b=MKRZOjioe7a+wgB37A7LGkPvu0jjwXyetPTDV8yR6Nxuy+NVncfwP9W8t9My0UnDRT
         h7EN+6bt3FYirho/3k0NuWvvYFdYagIfiJUc5vE+/+/dLI7sYdVtu4qO9MVM/6uwewWJ
         V52EBOPLmRCjDgvl1gyruXQLLoSPqBvo9L7degzX/MELK5ohr6lC4Wa1BYq064gN5j5A
         F4jlhwFC6tp0ZRYTZfsVq44Ay48u7LTx9iEVEopINUG/9pfy6R9qVXGctma8p3Op2GYX
         Yy1QYSYxPpFRoeZfcdSEAIdbzntrqz5b5ybwkONAU8/8TQcYKCbteuidw2pOVJvv8dcq
         Yymw==
X-Gm-Message-State: APjAAAWpFNtOO+Z/eMjiOMvU/9MBfFWs8VAwiPdYYl3skW7Yvmnv4OF1
	qm+WVaAa+aLd2zEoIasXJ32aeaBPNAKUa5vUhNRYNKGO+fLp0XGzEtqBujmpcTjAOddsx+fBxSA
	8jbJGRZqSMHweCCUAgTS5f37fLkpfriCwpu4ocmhhavpqe8Sm2lUwLKQW+mq4QLIqtg==
X-Received: by 2002:a17:902:2a68:: with SMTP id i95mr11137702plb.167.1562931906418;
        Fri, 12 Jul 2019 04:45:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwd/vmJ5Vb1xJJf/fmtGgRDCcb26Vk3TkY+FmJGVfKV1s053yliFpxHh5V5JEnrBVCKoICX
X-Received: by 2002:a17:902:2a68:: with SMTP id i95mr11137592plb.167.1562931905526;
        Fri, 12 Jul 2019 04:45:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562931905; cv=none;
        d=google.com; s=arc-20160816;
        b=w09KeK+IXYZtoUdqEVGQLJQXBMIVURBYM1/PCTHEugsS2Ya7/Ec6m+5oeKXEKVB/L/
         TCsGWMHq2NXnIASACgybCnQALCrTj+9mqNhJaTeLBtkaj3UUuoYIaeXy8JIN4k0uaN5Y
         8G34gZ+oMXy6odtBRmfDu0zWJvRqeREsKhlrvuhDkcjirmp7UNohWb+CfMMcJERl+xRU
         8nFdJGQ904Zrq0mTK0WURRy739IE8O4ZlsZEmfga8hDX2/S34SH9FWUmmqbn/oET68n1
         dDv6cv8LySX0By9Em7Fzo9jf2Cb+GTww80KJGUtpnFKdUwM0OgXGYAxnPVjvfqCg+hTM
         CKXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7WheT2sFPbpAYUphDY20RcxiluEPP2yGBWlv6nqCcpo=;
        b=EbbY4Sy95j76GhN+Sa6Ni44eaYREk2pLxATW/n8vLFMINkcWRZUIuLE55bz7KOOpfq
         geHT17InK1riJ1ljIiagHZX7MNYqdwnGj9JQ/J1ZcI1ERlrRxs0Bt+mmlL0W4zc3A8i6
         bdEss929ugsmmqyLTAGuferLPb6LYDmxqF1jQEVHDNq/gI4b/EthN5eYiBLldlP1alMD
         Oc95bMX01mG9EJETYwtHlHURjfuaUI7wSSIWsyur8s9yEgwM6dmAGFfzGPvy4lwX7UrX
         Wga8DEgwrwoTOyVUEVw9cn1O1ehnyQZkNGJ7loHNEJhpp9YIbphr9uVbHjAT11VYqUXf
         Re3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=THypPdhe;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h18si7504032pjt.9.2019.07.12.04.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 04:45:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=THypPdhe;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=7WheT2sFPbpAYUphDY20RcxiluEPP2yGBWlv6nqCcpo=; b=THypPdhej8/b1YWUg1gyexApx
	27rbpPcSBzGOOshG/kAYscKus1Ew/eOU5gf9H9brrUNp/PL/1yAXw/FRqTM9KeGIFKW0sT6VvmMfK
	dxA2HakjTPM7ZH5hjJb9dFsW475nPrHOSuB4zbm2t4DTMfP0ymwVL8uXw/pmmGlO/LSMZiZrYLz+E
	Uhd/JjQBAgym+6ZFFGwIegs47sVyGzYM7riZt8FU2L+e5mHTfJxzE1sYtiCrqPj9r9w/Hg2Z6pbks
	RYpGUb6epfiraNJqrQNpNOUonB1BaYJTo9nW9B3w6Bfs1yQ5z+bsLC0Td5ReYT0TnhNrB6jvGZx3z
	OGOpmAd7Q==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hltz2-0005PZ-N5; Fri, 12 Jul 2019 11:45:00 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id C66F4209772E7; Fri, 12 Jul 2019 13:44:58 +0200 (CEST)
Date: Fri, 12 Jul 2019 13:44:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
	mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
	x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
	liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
	rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
Message-ID: <20190712114458.GU3402@hirez.programming.kicks-ass.net>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 04:25:12PM +0200, Alexandre Chartre wrote:
> Kernel Address Space Isolation aims to use address spaces to isolate some
> parts of the kernel (for example KVM) to prevent leaking sensitive data
> between hyper-threads under speculative execution attacks. You can refer
> to the first version of this RFC for more context:
> 
>    https://lkml.org/lkml/2019/5/13/515

No, no, no!

That is the crux of this entire series; you're not punting on explaining
exactly why we want to go dig through 26 patches of gunk.

You get to exactly explain what (your definition of) sensitive data is,
and which speculative scenarios and how this approach mitigates them.

And included in that is a high level overview of the whole thing.

On the one hand you've made this implementation for KVM, while on the
other hand you're saying it is generic but then fail to describe any
!KVM user.

AFAIK all speculative fails this is relevant to are now public, so
excruciating horrible details are fine and required.

AFAIK2 this is all because of MDS but it also helps with v1.

AFAIK3 this wants/needs to be combined with core-scheduling to be
useful, but not a single mention of that is anywhere.

