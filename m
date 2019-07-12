Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8567C742A2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 02:46:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66113214AF
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 02:46:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Wwvuit12"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66113214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D24578E010F; Thu, 11 Jul 2019 22:46:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFAA58E00DB; Thu, 11 Jul 2019 22:46:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE9C28E010F; Thu, 11 Jul 2019 22:46:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A77B8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 22:46:21 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 21so4642496pfu.9
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 19:46:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CE9lRDNR3rg1yz6aah5KMfonhpsYj2jNZxnH84MyUXA=;
        b=Qflil7z6gRtWgMfTbh4H1tSfcCjg7ioV3rGMLpAYdzCpcuimj6dlb84U07TpkzOJgw
         5CXFe7tGXrW/N/BcVakgQ+ooISAipNkdsJsifjnhKBqZcSkcMHTkfsY+rY7yPfb5N0ch
         J3/OVEYMF9vsED8UoSg7+eLUM8/TWkkWOW1VJhDREqlxNog/+mJ6CqkHoyxhR5SbjXv9
         EFskUKKCGs0gnFJNO/HNZRi7koVubE1UL0bAjKTRC7KY+qQwBkp7vEgdilMC0Vonz7fJ
         hfxsmTDv2aoMDdr0CILgI2ZAK5D6+F+1nOzqB8EKun1UHD1dISsL5RHseCs2d5Q4DxeA
         iTww==
X-Gm-Message-State: APjAAAUE7Fa6c17MEvH49+q6GSzURdxrCEoKcoeh+4U5ci4X+w30oGzi
	zfZ8z1fHdf2P43B2WGFQrJbif3cg6rKXWQUYuMMND6l2a1rYu20lKKiwZbqqtaIIIxThutQo6/X
	4S0wvCbikd3df/wr/MU5lucBI2D2dE82+KYPZwt06Zhy5I4zYBok123MQVGUpDwsUww==
X-Received: by 2002:a17:90a:601:: with SMTP id j1mr8525919pjj.96.1562899581081;
        Thu, 11 Jul 2019 19:46:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5JvnJI1bdpPekKksh9kKRv2d3Bvr/lsKOExADC93vvOSrl+E7mtqqHc0jzlL0ImsFcCBd
X-Received: by 2002:a17:90a:601:: with SMTP id j1mr8525858pjj.96.1562899580301;
        Thu, 11 Jul 2019 19:46:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562899580; cv=none;
        d=google.com; s=arc-20160816;
        b=FBakdGHh0eyNDACj6n+EJNxryMrTpJW97D8GsKGgR1OVgiNKv5uf2H2MEzJq5ROJN+
         ztyOqZboYkYDkjOhIN9qVwafNrqO/h8pxYYRzl/TKKCR0GQ0oKQItWJbLr+vM8Qrm8ov
         fxkAUBm+R0Hr3XYtKnqkZDZ7zQSmS9SzalLmlBfJy6nZIBJGpxr8zop43q3iJF+cfOvF
         M1uphZxeAWuYn0UmvwxsDmx728uixRIDQphZxJqzEPT/q8uqis2jsH8XYjlws7ykWxTT
         B9Wt95iSScB5I2E4oYUFPWm5j/MkU+fB2yfq152e8LOdnjrHhPmwDaEBEJCwGsyIyjYc
         55kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CE9lRDNR3rg1yz6aah5KMfonhpsYj2jNZxnH84MyUXA=;
        b=xLzUdlKS0PGsEStEPyCGkQz4aaKKcKkY8sMvAn7DptLarMfp8PGnHdebFwSv4LMkpX
         5Qxx7e8OMsaHZQLSNKK2b2P/ZdX+N03mm37TkBd07tSAoR8F1m9SU2ofrsSb2lCAazhc
         e5fZddU/bqDQ9PPLH5hDqWq8SCUno59Ir+LOetu6dLF1tV3pqnKXKw8IYNy0Lm7qM+38
         saZcP7DhFbxRCnv6E/hIrM0EHk8diY6QZ0nNouKVmGPb4PCsDA+KVMkniW6kFoWYSISj
         sJcH8VdsmPoXCM0F2fdMzasXHMoba0abCVv85Si6LrHHKQ//bBFLeO3CY9Fw9awrlQVx
         BN5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Wwvuit12;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id az12si1269699plb.5.2019.07.11.19.46.20
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Jul 2019 19:46:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Wwvuit12;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=CE9lRDNR3rg1yz6aah5KMfonhpsYj2jNZxnH84MyUXA=; b=Wwvuit121V9ZexPPxKanwzYwi
	ddflUWN9v4CPX9+H9bPbsvo6jxG2wAC3BBUGG9cauFnrXCTSOlPmcxTfJ4cy1SoI/qV0rZFfQ8wXK
	twKXl0uRqWh6MZCEQ4HqlEM/PWywXXcbt23O50K/7l8UCi6eUz+0WWlTABE3X/EmQ8vMCNgrdJOUI
	XmrxItz1Xzoi+k4KF8fMeEEpmheizoVHxyVD+cHZm12cjh4pB42mf75Kc1mH4q1gaP9QIS4uoV1m1
	wCsORVvxaufFYS8GiSdvH5t76Q0DsCgP2JngRttI2f6/InFGOA/gWbNVKK/mNSfIwMK1nlVEdHuym
	hVorcePaw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hllYv-0001rK-Qf; Fri, 12 Jul 2019 02:45:29 +0000
Date: Thu, 11 Jul 2019 19:45:29 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Hoan Tran OS <hoan@os.amperecomputing.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	"David S . Miller" <davem@davemloft.net>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Open Source Submission <patches@amperecomputing.com>
Subject: Re: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
Message-ID: <20190712024529.GU32320@bombadil.infradead.org>
References: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 11:25:44PM +0000, Hoan Tran OS wrote:
> In NUMA layout which nodes have memory ranges that span across other nodes,
> the mm driver can detect the memory node id incorrectly.
> 
> For example, with layout below
> Node 0 address: 0000 xxxx 0000 xxxx
> Node 1 address: xxxx 1111 xxxx 1111
> 
> Note:
>  - Memory from low to high
>  - 0/1: Node id
>  - x: Invalid memory of a node
> 
> When mm probes the memory map, without CONFIG_NODES_SPAN_OTHER_NODES
> config, mm only checks the memory validity but not the node id.
> Because of that, Node 1 also detects the memory from node 0 as below
> when it scans from the start address to the end address of node 1.
> 
> Node 0 address: 0000 xxxx xxxx xxxx
> Node 1 address: xxxx 1111 1111 1111
> 
> This layout could occur on any architecture. This patch enables
> CONFIG_NODES_SPAN_OTHER_NODES by default for NUMA to fix this issue.

How do you know it could occur on any architecture?  Surely you should
just enable this for the architecture where you've noticed the problem.

