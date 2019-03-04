Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99C1EC10F03
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 19:06:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63A0220663
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 19:06:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63A0220663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F37B68E0003; Mon,  4 Mar 2019 14:06:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE7A58E0001; Mon,  4 Mar 2019 14:06:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D896E8E0003; Mon,  4 Mar 2019 14:06:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 918288E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 14:06:40 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id x17so6300578pfn.16
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 11:06:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Pmi7+ElO+j/JcaUkFsAkmSizmZ+6c0Db2Sy1MOv+E2Q=;
        b=m0t7JmFMbvSARW+damCxZh0977Hy8R8j3OLvsYDETRxDA8aQPmPhVDZust7L6mHL1S
         QqLRt0it60LfsF6muv9amFOUt0uhLj46a1i+IJrsoNqLsmirUVGFf+0MubFtGCUO2dF3
         JUealZ2dM585KiefRtVk0Qr62y7xXJjgGNw2r3yrAVcaZYbcwpmN+X4HOVN5aXDACHv/
         cXBhtdqww96WqCITsT2vB+rEa1b4fhGZbx0ndzaAkKCJ6NmWROMCCgTkXmPupKCaxkZM
         3jKrX15oRQCkfJcnYaPsmsAW8sFDjhWbTz6Dhvs0ehcVajmqFVzmOSxe+gQuI+2zZ2uB
         epKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tony.luck@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=tony.luck@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVscmpLE5WUMeHr9xGiZ74nFgtMOKvcZgxQgiVNPfrN5SPqmjuH
	JC78BEXUEVZhm3EiHuiftiXzZUJi0UIPKaMV7QTwNNtTxhzvnYmjPsRibbeGboxQCManmUgEwSm
	dNJcX3vy3XsURsFh7JavW0XUeV84ZRQo2gx9g2yytI7jAmS2rZKvykRpYSxo3v2WCuw==
X-Received: by 2002:a17:902:b117:: with SMTP id q23mr22245514plr.160.1551726400228;
        Mon, 04 Mar 2019 11:06:40 -0800 (PST)
X-Google-Smtp-Source: APXvYqxfqE0ir88kPxFdFrx8klyo90A+QKqM9Qe9uRls9mtujqdEifrXylBb+YdCcl0qFgI9m+ie
X-Received: by 2002:a17:902:b117:: with SMTP id q23mr22245404plr.160.1551726398926;
        Mon, 04 Mar 2019 11:06:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551726398; cv=none;
        d=google.com; s=arc-20160816;
        b=gEevwSvffcfK/eZKEhDmoKI2EEjqmx/FuOnBPZbMYLJGHxCao6Xm5mR9xoS3SU1Mhs
         RjZlV9y6aHeqW3PX//yklpzX43Ztn3GU02j+8CFehOZcy0JpSdUUK8DN8ntWkNTL/Twu
         Ury0XEJbx7+QkW4AGMru036EdzA0oJMYzrybibfy9sXXU6Zvy9dEb8h9zoSpubFJLDtK
         c1OCLV/ulFklA3C/oSQqEkIXAl/+12bBWnT7SOJfSl7/6dQHgGrv/vSLDpN5qGr0AhNm
         CLvUtP0azsb6+eUD/S1L98isdD3X7KPA8jDX8hsTkLlRy2JiAqveTgZ+Jw08mQvEHMRM
         DNBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Pmi7+ElO+j/JcaUkFsAkmSizmZ+6c0Db2Sy1MOv+E2Q=;
        b=NAyKBMCe4GMvzxIdqaw5Myq8UVAalPign1nLu9OClYsVSKxyzdxhB+d5FwqEgL5yI/
         /0CYP6ORFQ/9e5DMqkT90Z6WtJrwwVQr1ieC/3+lG5RG3F97TLjMGzPItVw6/IhaG9qd
         80GeLuF6cf0lX4DQ2aEembQEIf+Q0GXHvlIOOG43WyK8joGEibyU4+p8xPWjCABG3laV
         i0MfWeonLzl+JzQoY76MIxfXhHx0/42ADqNqYH69jKViGNFhLhAmHTD+oeJ2G7R91PzL
         3VEll9I1xG3wHEvu5mOQnBVgESJtZoMSPATC3gCfMPuoFwwZb3bZj0U7fqgYTHZoUV2s
         OLJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tony.luck@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=tony.luck@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id x14si5822540pgh.98.2019.03.04.11.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 11:06:38 -0800 (PST)
Received-SPF: pass (google.com: domain of tony.luck@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tony.luck@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=tony.luck@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Mar 2019 11:06:38 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,441,1544515200"; 
   d="scan'208";a="128940141"
Received: from agluck-desk.sc.intel.com (HELO agluck-desk) ([10.3.52.160])
  by fmsmga008.fm.intel.com with ESMTP; 04 Mar 2019 11:06:37 -0800
Date: Mon, 4 Mar 2019 11:06:37 -0800
From: "Luck, Tony" <tony.luck@intel.com>
To: Steven Price <steven.price@arm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>, x86@kernel.org,
	Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>,
	Arnd Bergmann <arnd@arndb.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-arm-kernel@lists.infradead.org,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	linux-kernel@vger.kernel.org, James Morse <james.morse@arm.com>
Subject: Re: [PATCH v3 08/34] ia64: mm: Add p?d_large() definitions
Message-ID: <20190304190637.GA13947@agluck-desk>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-9-steven.price@arm.com>
 <20190301215728.nk7466zohdlgelcb@kshutemo-mobl1>
 <15100043-26e4-2ee1-28fe-101e12f74926@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15100043-26e4-2ee1-28fe-101e12f74926@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2019 at 01:16:47PM +0000, Steven Price wrote:
> On 01/03/2019 21:57, Kirill A. Shutemov wrote:
> > On Wed, Feb 27, 2019 at 05:05:42PM +0000, Steven Price wrote:
> >> walk_page_range() is going to be allowed to walk page tables other than
> >> those of user space. For this it needs to know when it has reached a
> >> 'leaf' entry in the page tables. This information is provided by the
> >> p?d_large() functions/macros.
> >>
> >> For ia64 leaf entries are always at the lowest level, so implement
> >> stubs returning 0.
> > 
> > Are you sure about this? I see pte_mkhuge defined for ia64 and Kconfig
> > contains hugetlb references.
> > 
> 
> I'm not completely familiar with ia64, but my understanding is that it
> doesn't have the situation where a page table walk ends early - there is
> always the full depth of entries. The p?d_huge() functions always return 0.
> 
> However my understanding is that it does support huge TLB entries, so
> when populating the TLB a region larger than a standard page can be mapped.
> 
> I'd definitely welcome review by someone more familiar with ia64 to
> check my assumptions.

ia64 has several ways to manage page tables. The one
used by Linux has multi-level table walks like other
architectures, but we don't allow mixing of different
page sizes within a "region" (there are eight regions
selected by the high 3 bits of the virtual address).

Is the series in some GIT tree that I can pull, rather
than tracking down all 34 pieces?  I can try it out and
see if things work/break.

-Tony

