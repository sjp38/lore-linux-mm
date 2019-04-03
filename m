Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34712C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 06:26:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEB6F20882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 06:26:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Egt3C7o0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEB6F20882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 773506B0008; Wed,  3 Apr 2019 02:26:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7212E6B0010; Wed,  3 Apr 2019 02:26:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 637496B0266; Wed,  3 Apr 2019 02:26:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2786B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 02:26:20 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y2so7406587pfn.13
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 23:26:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=lC6hE2KuwwHKTH9SauG+GT77MaDyLO6Sr1YmLYpCR3M=;
        b=dAlW6LV0/UGjCmfuMF1YTRo0rx2WkOLl07gZBAx94IRZJJXW7RitgUOBEG3zj4e9FD
         22ApK2wkLB+8+UEY28f1i+Hl3g8P1BMbrfITIJ2+dtKDomDV0Pb/nG6rUbFJV6fguBky
         1jgPAvF8fCRwJNfMFJskwEjX30EvawOgez/jWtjxgXlPCgalhNEY6nzYivjq/UuiAmP4
         pq6S31lJHp3ibc3oBef/ZFzr/Fw/I3yuK12ZyemQAG5UQ7LT0TUIiwCf6lAWbd6DWfEl
         RmiKkFRpGlRzQMwFKQJDf/kfSmG9t7fW6QSYC72MZKEDP9U5Ey+0IjC/a50TievK8Va4
         J8gw==
X-Gm-Message-State: APjAAAUqeSw+84hmXWuFjFJuSqpt1rM/6SiartqikiyzR3piGNEw6RLy
	kTYWHPxaSLjILV+YPDjJQ+lgu9l3tauuyWY4WPhfo9moZC87/rQU16Ya+7w7rEL7sU7/mUCtK/D
	+wfuGqxcnxHFy1oj8b9VJTwUvGxVnkOeCQ4WjTSKZdhkbBpciDHoAzhKV5sSYZB6BYg==
X-Received: by 2002:a17:902:aa5:: with SMTP id 34mr72460890plp.302.1554272779746;
        Tue, 02 Apr 2019 23:26:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwopTxWVra6G/jNMaC4ckJNtVNPjKIQlLm5MfibRG5Y2QPKuJOxIAOaQYjCO5jW39ACRpvL
X-Received: by 2002:a17:902:aa5:: with SMTP id 34mr72460820plp.302.1554272778590;
        Tue, 02 Apr 2019 23:26:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554272778; cv=none;
        d=google.com; s=arc-20160816;
        b=tcbyfipAF6yThTwWiobNJixRBzLg5ngt7NVUX/uFOUMsHMOw4seWKMwgMYN8SBPWEe
         rdy3zHXjUGVaV3SbZuWgtpK0aFAm/Z8wqztLbOoYJSRU7e4OAM+SL0Kae8qI8rl9pk4A
         xU56ufC8HOqkOUEKPwjBOtpv3+CWYUxfyRmhQym/SKNIC7G6DJaoZEVMNkzIDyYDR/3L
         WHchtufo9krYJVIvRhVfjU9W+hS5hdN2jA67xz2qZ8dRXPaam0QvERkesJmTpOYRKwhN
         W7K1rgCEt/sf5ffXFYiEBk9S/3xYS/QJuBNzfp3WseR8tnkdkZIjw6/nT73z5x7P4xk1
         xGbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=lC6hE2KuwwHKTH9SauG+GT77MaDyLO6Sr1YmLYpCR3M=;
        b=niVryuHGeeWdjo9oIiutTpw8vvEjwl3w3owHk2EOi2uaYPo/ADsl1jLA8kMbPZt7gx
         xnJ4OuWa1GUsfb780cC89kd14IxFJ9sLlfktWJT9RzZeqxNubqreJsL+k3XZ4x8OFQwN
         gOBHW3mFNv+CWDL0skX//EsLWDAJNa4CCztxTMx3kFQZ7ivgiCMGY3zNfSS0+h0y3LrY
         zpET/XBM5aAXeAAjqXsqDvg9mKiW2BaEAO2StvSNeYffE8iZ6k59sOj3qA0ulrv6/1ra
         JQyjWKgq/LSM6rTsgOi9I7debt42/aADuHR5d1Nd9x5g6+TpCWZD5fZ1KjMTE6acG8WW
         FmEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Egt3C7o0;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b2si13487287pgn.93.2019.04.02.23.26.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 23:26:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Egt3C7o0;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=lC6hE2KuwwHKTH9SauG+GT77MaDyLO6Sr1YmLYpCR3M=; b=Egt3C7o0B2r6a/hbeDaKJ4RET
	5wZF20wMi/xTmImEpVn1cjilWYO9mjwpji3LIr1BGociuBkZUnQhXJE/DN7y9TaMngHG8MnBIVBXH
	Qez6ZK/n/BfKc0Ms0sirl1W/WayyS5h/ZaKdbgHhDNahxtSYoOvL11/rHNSNzSCCv8x5VCMwN4QMG
	XBpcGNo4NZruEh4oaCLfSU8WZxTnIO6KUXWNw/Z5xL+1D0FslZqqqO8R591Y0TV/CoxC9X/4hxSj/
	jgjBQGcgUEgoaYLF4GYSPPchCAitIzK1CniZlMQ7MPzzvy74sfzElgKMe6kvoOmyHD60zzSQraYll
	InVcK97Vw==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hBZLX-0003QH-6D; Wed, 03 Apr 2019 06:26:03 +0000
Subject: Re: [mmotm:master 19/222]
 arch/sh/kernel/cpu/sh2/clock-sh7619.o:undefined reference to
 `followparent_recalc'
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linux Memory Management List <linux-mm@kvack.org>
References: <201904031355.srXJo4hh%lkp@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <2af6aff3-ac3f-1d53-0d33-f81dd0dfa605@infradead.org>
Date: Tue, 2 Apr 2019 23:26:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <201904031355.srXJo4hh%lkp@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/2/19 10:54 PM, kbuild test robot wrote:
> Hi Randy,
> 
> It's probably a bug fix that unveils the link errors.
> 
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   03590d39c08e0f2969871a5efcf27a366c1e8c60
> commit: cffa367bb8abe4c1424e93e345c7d63844d1c5db [19/222] sh: fix multiple function definition build errors
> config: sh-allmodconfig (attached as .config)
> compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout cffa367bb8abe4c1424e93e345c7d63844d1c5db
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.2.0 make.cross ARCH=sh 
> 
> All errors (new ones prefixed by >>):
> 
>>> arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 

Hi,
I suspect that it's more of an invalid .config file.
How do you generate the .config files?  or is it a defconfig?

Yes, I have seen this build error, but I was able to get around it
by modifying the .config file.  That's why I suspect that it may be
an invalid .config file.

thanks.
-- 
~Randy

