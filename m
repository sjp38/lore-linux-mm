Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1433C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:48:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 463202146E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:48:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 463202146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB43E8E0007; Tue, 19 Feb 2019 07:48:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E64618E0002; Tue, 19 Feb 2019 07:48:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D53A98E0007; Tue, 19 Feb 2019 07:48:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B7248E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:48:07 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i20so625470edv.21
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 04:48:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gy1ZqSiskX7ciDoVuiqqbT0lgrfAmi/jxYk1P1TAfCs=;
        b=fSbCKPOEiQr40zbWTteRQdR1hEmDo4bBjXOfQ4U2UVqa3IvRiExEDockftiPaDt7m0
         8gLok+NnPJlBGuwAQ4qYacxp6vy9Q1rLs+UCwIbvnpWGgupMjjqao47vYuJ0XuQ0ET4z
         oDQqSFkO1r/Fi2vpZajd8oQkcU+TTqhOUDq6M0kJ7y1YTr+JUcWdcedK6oSgJ69fXIBF
         GWShNb45unOAtJmWScdqIUhhim95nS4ClmlkaljdnAZc5TparHKipfPqNeSjDkddqfOn
         5TSnwIvonUNcUaHcaLy3OW/ux7cjTrmzM67Xk8a4Lo6HwY6bSnQNSifRpjOLbJa/osLa
         Hh7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: AHQUAuaJu81LoUGAs3094XKHO5ZxhxCtnsWdpC/gAf2Sk0w0yJi2keAQ
	MAI6xAo87ZkXiAq2Oi1ma/I8t6vuHxviYnO3c2xJ1OIuxGXimGqemhbfYj6PQbs6/r0L+uUg/p0
	LhZTZNP34D45TipU1iM2AuykRbYRFfz2eJWSqaENFNZDCTAaWB0kqY/2euwDbOM7o5w==
X-Received: by 2002:a17:906:5008:: with SMTP id s8mr19849593ejj.113.1550580487057;
        Tue, 19 Feb 2019 04:48:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY1ooW5qDSKncRAqxpHdzuunYssokaoH4oA2+uZnBfU6jueMK2a5i1IxZ2dwq2tPbczu+EL
X-Received: by 2002:a17:906:5008:: with SMTP id s8mr19849558ejj.113.1550580486226;
        Tue, 19 Feb 2019 04:48:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550580486; cv=none;
        d=google.com; s=arc-20160816;
        b=g3tsHjeaWI2bVm7R8FuDTDwoekYN0V/Vg2Lo0Ws2Lw9/1/7qkuJ1NjAJEQr2QARN88
         5JRjfU6LKEqnhnIfyX9cnnBF6ORUbCd+y+6BRV27/HX3CKU5S3kXjHuVub9eCVS0ylLT
         obBkMWgO3XA1BYwI60bDTUzZ1XRdA86Yt/SikMHkIYLdtFY6z8KuBBmdURqUBdAOtM7+
         3m9zVosnZulBNXFyi8+xlmSUrO7EWLQrcH74J1YDdmeKLKGfXYt3u/MCvilMtqszqZcM
         SGML0sWxGSwT4npEVRE3/Ekp8V6V9wK9oq3ch30JnJDy3IrggeLQnkAAMchmgfSmeC+/
         jwCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gy1ZqSiskX7ciDoVuiqqbT0lgrfAmi/jxYk1P1TAfCs=;
        b=NbjQzxo0/Ccm7IAMWCxQS+HhfAK7UsZxV31W/smr+sTGnA0p5nAgXZKIRR9+cfPY8p
         gRFx1co8YwaQmCr+AjgFuqZrD5Vw5Gvh88wYIh8ckHZhczpdQZGl1Z3FtdC+k11VB3gs
         Dso2TIQ6PIUFg6WjsVPtEe2Bf4jrTnnkfDnbDFZnu1lM/cEXrZOKn2GEU9bvwBmxOi76
         vfQ7FhMzVL/hBm1z7WjWGw+WIWZ0RpxtFxoiJBUxU4JTjls2RANEp/OLMrI5PToB4QSv
         VrH2R/V332YHLnNi/sz8K1QaIHNnr4cGjT2IrKftQKinAbrjTNKrVhCyXaQp4ahxRjns
         d91A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id gv8si540995ejb.278.2019.02.19.04.48.05
        for <linux-mm@kvack.org>;
        Tue, 19 Feb 2019 04:48:06 -0800 (PST)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 240A1EBD;
	Tue, 19 Feb 2019 04:48:03 -0800 (PST)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0F6D03F720;
	Tue, 19 Feb 2019 04:48:00 -0800 (PST)
Date: Tue, 19 Feb 2019 12:47:58 +0000
From: Will Deacon <will.deacon@arm.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org,
	npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux@armlinux.org.uk,
	heiko.carstens@de.ibm.com, riel@surriel.com,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH v6 13/18] asm-generic/tlb: Introduce
 HAVE_MMU_GATHER_NO_GATHER
Message-ID: <20190219124758.GF8501@fuggles.cambridge.arm.com>
References: <20190219103148.192029670@infradead.org>
 <20190219103233.633310832@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190219103233.633310832@infradead.org>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 11:32:01AM +0100, Peter Zijlstra wrote:
> Add the Kconfig option HAVE_MMU_GATHER_NO_GATHER to the generic
> mmu_gather code. If the option is set the mmu_gather will not
> track individual pages for delayed page free anymore. A platform
> that enables the option needs to provide its own implementation
> of the __tlb_remove_page_size function to free pages.
> 
> Cc: npiggin@gmail.com
> Cc: heiko.carstens@de.ibm.com
> Cc: will.deacon@arm.com
> Cc: aneesh.kumar@linux.vnet.ibm.com
> Cc: akpm@linux-foundation.org
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: linux@armlinux.org.uk
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> Link: http://lkml.kernel.org/r/20180918125151.31744-2-schwidefsky@de.ibm.com
> ---
>  arch/Kconfig              |    3 +
>  include/asm-generic/tlb.h |    9 +++
>  mm/mmu_gather.c           |  107 +++++++++++++++++++++++++---------------------
>  3 files changed, 70 insertions(+), 49 deletions(-)

Acked-by: Will Deacon <will.deacon@arm.com>

Will

