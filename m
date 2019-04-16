Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1ADC7C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:42:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA1E920693
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:42:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA1E920693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63AE66B02AB; Tue, 16 Apr 2019 10:42:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E83C6B02AC; Tue, 16 Apr 2019 10:42:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FFB16B02AD; Tue, 16 Apr 2019 10:42:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 03A696B02AB
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 10:42:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s21so3669918edd.10
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:42:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=CxdsewtR/DFtr6SMDixgk+HeGf5UD/IZwNl3RgmliRg=;
        b=rCSHGCDQragI5SYMmj69jdchy1q9iLo9jM4Bf7FuuNLOrsCADKfvkPLjuTIGEgISWC
         WbdLYwe1lfzZ4yJrEuW4u3k9ytPkCyTFAVkOvJrrmKp7lCJZ8OjuRXsvtMhcoBRl4bG3
         P33REc1r+x/JgYcrP6S5Fy208gtkY4rMj6sgIpVgFlrT4UytzbYEaFdlfz7Uj7lEFw4M
         L+phINBX9EzHPTEClJ/lLqFy9E6yKO5uM9gpm/pam7mWejyaYWA0rnrnC3Dp2uXBd/hy
         8AUphNAJ35XDvYCpNncnSbrIcqm1WnFYbFrshrgv9xJ0k5LWBYmtaiBqtlP+G6i6Lji9
         j61g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAU+czDRPAOYta2+aHrtb7Iqk2AiD0cFMrxfXo8mmvsqzTVj8a4h
	9QK66p9HzFLGdgUIZttqSa3p8xnHr1JZIUWWiSH8d4DtDYY82PTVF3FTVV3H05nH3T1aq6FhOcq
	Dvl6000gilJ5inr75qOAU3Jn70WDECGmN8xbgelm8p1pXgOi0Tn718Kzo06aL8TlDgQ==
X-Received: by 2002:a17:906:4ac1:: with SMTP id u1mr43468006ejt.179.1555425727544;
        Tue, 16 Apr 2019 07:42:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxOCojla++zVG5WGVP2/87AUYYWh2BtSt6Z4Asu6qZe0UdhrHx76gbflUtAK6OlWh1xO5n
X-Received: by 2002:a17:906:4ac1:: with SMTP id u1mr43467969ejt.179.1555425726818;
        Tue, 16 Apr 2019 07:42:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555425726; cv=none;
        d=google.com; s=arc-20160816;
        b=JwgnIoakpwKjP5ERdB9dftPBBXXM8yUTRAcPM13HXQ9Cm2CNwsw/Ox96XGmmuqgAXx
         tVv/z4ZBdciId7LVf9Mav5hBuOCV7zCEeGlOfqyUnMWuYzrrpwlSnt3qNav43FeIDMkb
         kwNmikpRY6YYyBxNsHnoeHNdmtrbNL2B5xigznUfBiqsJtaSUIQXfmq85PajadZsDRO+
         jGX1Jw1IizJPbbA4hAprfYE1bsmsvCh8rSCkcKN5FZwZ3C9m/aCtmAlG24WgrhCBFXI8
         S4koNjtRzBIGE5/O6Vo5dnW5gDZvZ10KE4cNls4RjpS81BA4cLq/l7FonRmAPZNRTzVK
         69cQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=CxdsewtR/DFtr6SMDixgk+HeGf5UD/IZwNl3RgmliRg=;
        b=CsIQst23E07P/9S/4RcmoCpowjON+KJYT8XRUUYyh049+duaEA/02KUhj7DEl5JaNl
         7MC1PAoqkm8lvf5WEB99uYPfSGGGgBtXJuBPd5MM2DNtSBl/RZe8mXsfElNhTwmnIimr
         UD9llChwSAhw/XYfhzRxQ8R4adS3MYkxjhi8SLW17ofT+0dLcMItlVHiTR5cwsCyVI2+
         0zUip29cuMjtF2SeCllEMm70p+WJSrU+C1pnbJlRnlOY0WU7Nzw4ScGIyCW0FxxieAFT
         1HZeo9DOtOIcAYXCBui+gYxNdw8hLCctkzVMYiDI6n5lwKM28NeZHLPgXl/8rEvsdAgg
         LMEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n12si2726462edr.419.2019.04.16.07.42.06
        for <linux-mm@kvack.org>;
        Tue, 16 Apr 2019 07:42:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AEB1780D;
	Tue, 16 Apr 2019 07:42:05 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EFAB83F59C;
	Tue, 16 Apr 2019 07:41:58 -0700 (PDT)
Date: Tue, 16 Apr 2019 15:41:56 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
	kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
	jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
	mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 04/31] arm64/mm: define
 ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
Message-ID: <20190416144156.GB54708@lakrids.cambridge.arm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-5-ldufour@linux.ibm.com>
 <20190416142710.GA54515@lakrids.cambridge.arm.com>
 <4ef9ff4b-2230-0644-2254-c1de22d41e6c@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4ef9ff4b-2230-0644-2254-c1de22d41e6c@linux.ibm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 04:31:27PM +0200, Laurent Dufour wrote:
> Le 16/04/2019 à 16:27, Mark Rutland a écrit :
> > On Tue, Apr 16, 2019 at 03:44:55PM +0200, Laurent Dufour wrote:
> > > From: Mahendran Ganesh <opensource.ganesh@gmail.com>
> > > 
> > > Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for arm64. This
> > > enables Speculative Page Fault handler.
> > > 
> > > Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> > 
> > This is missing your S-o-B.
> 
> You're right, I missed that...
> 
> > The first patch noted that the ARCH_SUPPORTS_* option was there because
> > the arch code had to make an explicit call to try to handle the fault
> > speculatively, but that isn't addeed until patch 30.
> > 
> > Why is this separate from that code?
> 
> Andrew was recommended this a long time ago for bisection purpose. This
> allows to build the code with CONFIG_SPECULATIVE_PAGE_FAULT before the code
> that trigger the spf handler is added to the per architecture's code.

Ok. I think it would be worth noting that in the commit message, to
avoid anyone else asking the same question. :)

Thanks,
Mark.

