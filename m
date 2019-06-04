Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68A4DC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 22:28:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3067520684
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 22:28:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="xKnpAHQa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3067520684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9ED706B000D; Tue,  4 Jun 2019 18:28:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99D8F6B0273; Tue,  4 Jun 2019 18:28:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88BA06B0277; Tue,  4 Jun 2019 18:28:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 680886B000D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 18:28:33 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id z19so17627747ioi.15
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 15:28:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9A8itsAphAb/as8ui3xdV6CzJFxywKBTzPtaBp5prAw=;
        b=ARzVHkuNaV1qlFLl11b4bKZwBlVnOI0GWliCwC9Zkj2zPm4mJ9bPUOYnQPFg4IXLGY
         BpfXqxw49gOxy84TCsihFoNg0UIqJ+OO8Stg9KBEI568mlOjT+euYemw59z0pkVNjcC9
         dEjLMS8YGugCbXAgqTzc3sfVmLBTCNljoGkuvlCvMaZ/arquatCLJF3OxdMF0JIBhj63
         Js1npJADvVJMqoMCEsRTiJ/rR2mDjlUkL+f5jQGwjH+5pVaX8GdLyGOeqnZdDtIzfAQB
         yLxkoiIYr3G6/cHrqMdLKI+Ax3gHC9pa/JEm9QZuKLGTs9IhqnVt8704+rAy2kPbDPE2
         BlQQ==
X-Gm-Message-State: APjAAAU6cZP8F6Ycp6yyAbIChx3UV1CU77LmNq1M4vAr/4CGbtVqSS60
	iyYweaHPujrCwF9/NDdUjE7ki1bq/gLVZ85LRAhyszKG/EOhAXwZJk8obfW1a3b0F09WxbhyEeF
	VTuayTk2dhNNv0CpslHmBBu/iu0J+i5dNl6yh8MUpVNkRhDBGpCxF9AhMiZ0vLfK+zg==
X-Received: by 2002:a24:6c4a:: with SMTP id w71mr24404963itb.128.1559687313144;
        Tue, 04 Jun 2019 15:28:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyT/X7IMiJuSXfOjRgSaMVOOHlDzkB1KSbNY//1bFjc3XmcyV0U4eWxDr/D48XOe7TZqpp4
X-Received: by 2002:a24:6c4a:: with SMTP id w71mr24404923itb.128.1559687312381;
        Tue, 04 Jun 2019 15:28:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559687312; cv=none;
        d=google.com; s=arc-20160816;
        b=yJdDC0l/vXh/p7HgPW/WMnTBWh1I/lAgXP08DdzZDIplqAECXFLXRvQh1M0srAHOmK
         zwKd5O7BjPoEZYybedInBaI85S6/iCgfls4Pvt5nyrn3q7W25j6MB5TwXsT/Azg6ggXW
         Qna4dK7wT2NTyVzN+6apGneSM0hA4hpn88XYH6jVXaoDH7VoaQpmH5kMP81v6yJxXbxz
         BYkIp7SGRMh4o0jnqk6QwPSY0dmOqQjuLrYd5tw+NN5zDFB6FfMEsPKB6dzeRZjzlv8r
         6bYQPChZ47aTeq5P4YwokuIKECLqDoD/LCpSYD+3rJw2mequ/84qjaMkFs9CqlTkLBLp
         omUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=9A8itsAphAb/as8ui3xdV6CzJFxywKBTzPtaBp5prAw=;
        b=ZPzVs4AlOyn8xe9+XVeFgCEGYm1mjrbyuR11ry/yUXp8+CFCHQ+nt8/eGOI+lEX2+I
         lFIDCTvx69X/3epwL/IMSB4TV9pWbFajXAzuTsox2ZalfrrGOjnIQOZR/Rt/UNikRc/I
         nfWKFIOWC2mThsuVjxgBZwHQ0tHBsY3UGxekCM+L+sHUY/lLUPzE2gL+nlewKIJ5HYcu
         xB3aOPHW776fYCwOA3uZ4XbelQ10oFQ/5mgNoP6vzPIfihNYUaOujYbvyKCLeyOKTfno
         /5dWGsoebW5uTjgGTW8RpQbKXLLDxZ5iCd7KS5Mni35FE0fKY04sAgqlFqszr7B+syv2
         ej5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=xKnpAHQa;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id y5si11464292iof.64.2019.06.04.15.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 15:28:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=xKnpAHQa;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:Subject:Sender:
	Reply-To:Cc:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=9A8itsAphAb/as8ui3xdV6CzJFxywKBTzPtaBp5prAw=; b=xKnpAHQa0UnnwpRa1epErIXLim
	wF5aEkvyjVUxbMCnqhdWkGGL/rZZ5cf7F5oANx1XJj2yTomOnpCiJg2tfGzR6pvy16H0wm3mIvxvA
	deTxDJ2HwluuSPJm0yfymqe9pJUuw4eI3L18NynVm/ddTj94JbslLcqrxJM6s4cfIpqbETgJAyxtU
	FIA+NMuCZEvsoZyRkgNQRuhHkA5UdOXkbvmHaIAtEXNQFxNbnl1GuQXBaZh+c1VrCe9lZN/Nx2Imj
	A4Ej1f5lFBCRbzrFawHioxY+YTygzpkLh5DhFitayYOTViIIHD740/1pmIaBfDelgCZLvM92ACPqv
	aDVfc0lQ==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hYHur-0001CN-LF; Tue, 04 Jun 2019 22:28:26 +0000
Subject: Re: mmotm 2019-05-29-20-52 uploaded (mpls) +linux-next
To: akpm@linux-foundation.org, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
 mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
References: <20190530035339.hJr4GziBa%akpm@linux-foundation.org>
 <5a9fc4e5-eb29-99a9-dff6-2d4fdd5eb748@infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <2b1e5628-cc36-5a33-9259-08100a01d579@infradead.org>
Date: Tue, 4 Jun 2019 15:28:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <5a9fc4e5-eb29-99a9-dff6-2d4fdd5eb748@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/30/19 3:28 PM, Randy Dunlap wrote:
> On 5/29/19 8:53 PM, akpm@linux-foundation.org wrote:
>> The mm-of-the-moment snapshot 2019-05-29-20-52 has been uploaded to
>>
>>    http://www.ozlabs.org/~akpm/mmotm/
>>
>> mmotm-readme.txt says
>>
>> README for mm-of-the-moment:
>>
>> http://www.ozlabs.org/~akpm/mmotm/
>>
>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
>> more than once a week.
>>
>> You will need quilt to apply these patches to the latest Linus release (5.x
>> or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
>> http://ozlabs.org/~akpm/mmotm/series
>>
>> The file broken-out.tar.gz contains two datestamp files: .DATE and
>> .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
>> followed by the base kernel version against which this patch series is to
>> be applied.
>>
> 
> on i386 or x86_64:
> 
> when CONFIG_PROC_SYSCTL is not set/enabled:
> 
> ld: net/mpls/af_mpls.o: in function `mpls_platform_labels':
> af_mpls.c:(.text+0x162a): undefined reference to `sysctl_vals'
> ld: net/mpls/af_mpls.o:(.rodata+0x830): undefined reference to `sysctl_vals'
> ld: net/mpls/af_mpls.o:(.rodata+0x838): undefined reference to `sysctl_vals'
> ld: net/mpls/af_mpls.o:(.rodata+0x870): undefined reference to `sysctl_vals'
> 

Hi,
This now happens in linux-next 20190604.


-- 
~Randy

