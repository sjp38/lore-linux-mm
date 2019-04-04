Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3C67C10F06
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 00:57:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA983214AF
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 00:57:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="YYg9X80s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA983214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F77B6B0006; Wed,  3 Apr 2019 20:57:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27FBC6B0008; Wed,  3 Apr 2019 20:57:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 121FF6B000C; Wed,  3 Apr 2019 20:57:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C80F36B0006
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 20:57:51 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s22so674955plq.1
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 17:57:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=N9HCmrm8VY61caTtmpBOWPl6XeIKwin31jSQm9heKkE=;
        b=BLw8AsEJgY/b6ro34AGvLV3R/0xraYR9UCZIDraRuWEyWPTj63ORp6lg93hT1z3MpS
         sL9hezii/hMYrRmHjpYK4tpjr1WL8tT9V3gXtODEQ1v8IW5VM0AE6hFHlOD+b1gTBGzW
         ZB1NmjQDoZnYRVb2tyAtdGHxdvvZ3HAUriWoXMQ0HOmA4phn34Ewj9iWcDf68aWrVkKZ
         YDKjkyayd36wAIC8DcnnHFSxwjcHUalyCeGniVuZ4FzQjUQtCe1t6DLbLGYZPi+NNyYS
         +eu6t+FiR4Xoij6WPo6gaZ1MWQpwur3NsJUxP0ElmxVOfo7r5p/C/gUzJwkOnrhCtT8u
         eqrg==
X-Gm-Message-State: APjAAAWGpd7TaqDA7pfiFt8w22huMQnKCgCdG9nWoClxvjwwl7+3wb8g
	NV/xFb6OWkHR1svJT87eypVztzuhe1NnLUHs+p9TYHxJ5bCH2M8ee2MkTAmfPPtNHEV5KpZnH9d
	GljMY/fRSDOm9RlOF723cGLpImphCRdq0FkJnKDYbVj9aUvTu0jFJSX+CYeVP2wBUfw==
X-Received: by 2002:a17:902:bb98:: with SMTP id m24mr3235256pls.17.1554339471361;
        Wed, 03 Apr 2019 17:57:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz++mNqtog/XcfkNJo9v2B4ikclO8q4ZlmBtN2pjrGJVL0DxpPgQwHdlDxvMzvgVyPHIfqe
X-Received: by 2002:a17:902:bb98:: with SMTP id m24mr3235203pls.17.1554339470583;
        Wed, 03 Apr 2019 17:57:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554339470; cv=none;
        d=google.com; s=arc-20160816;
        b=DZTLRexes2VKcWVlDjnm86Flcslyi4IRZN2b3sLqzzdFSLZydrulnIIUCELyPZ9H91
         IE2aMQ1SPRh5jROfRxinGOwQ9ibkAhZUi+C8uCrQRS6dtoO3pCGIBE1f4pkSvE/kzQZ2
         WtwjLrv748lBb7iZD3AzeM+12HPHWrTVLWF0CgBXA2Lu99rRTWggzReKyr4aOj4OcBv+
         +ZjwKRXbQmRXb9n0w8gsBizKyjrC0ON6Y6+QjAR4xw87Li2KegaQT1yH55OIejv/i/Zi
         77vUKZRLQKYFGbd4ArQa1Wa7JKcvnwwXN5PvkYaqUhdpmdbG4CecJgO/YosMPSVB7bD3
         ko1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=N9HCmrm8VY61caTtmpBOWPl6XeIKwin31jSQm9heKkE=;
        b=0x56ADTMq2yTw22QtaORoSI/ZBOWTZGVcnRA0++GHCn7HSKCNT+lrgxYwUzA/Rfx8O
         6xec6alV5l/fqpgPIcE9f95GwLU21rhZ858oqyEBYm1IUakcGtBbuVsxztD5FdGHcfbG
         Ifmaphsxjg/NBJBe+TiBPsCiN93RAVYMcAt0pG63ZTsULtKbJOK8a2wK4El0z9uWxYkJ
         5KLVIUjYybe6cpt9RWIeRE4Sia5VqvfxWNG94SoQp+zdACRovp+SoSkp+WsilaMiO/Ts
         HrSqq2yuDlq+DFnXILLHRNw+6dXmxp3E/mXU4bgGmXenMbY3cdI9zkqIrSaupMSvguoC
         PFKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YYg9X80s;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z4si15120499plo.166.2019.04.03.17.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 17:57:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YYg9X80s;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F278C2082E;
	Thu,  4 Apr 2019 00:57:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1554339470;
	bh=mJwodE2gRa2C3WW5YdRbgfUkn8szJ9u1XhmMgYBgYBE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=YYg9X80sINpVkIevZK5YRlzuwm0+NB1xTF+vpBpkMQnI4BlXUVa3ItjY0O9e4GYm6
	 t6Q7tRM3rgDP7r6EYRrh/FJ4mrSr1avZZkifdEoeXcKMQxMSwbznEe3lQd/hjJuUy7
	 2dByCQhDwXcwg4uZVBI9YgDUAM9WHinBax6BHAU8=
Date: Wed, 3 Apr 2019 20:57:49 -0400
From: Sasha Levin <sashal@kernel.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Christoph Hellwig <hch@lst.de>,
	"David S. Miller" <davem@davemloft.net>,
	Dennis Zhou <dennis@kernel.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Greentime Hu <green.hu@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>,
	Guo Ren <ren_guo@c-sky.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Juergen Gross <jgross@suse.com>, Mark Salter <msalter@redhat.com>,
	Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>,
	Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>,
	Petr Mladek <pmladek@suse.com>, Richard Weinberger <richard@nod.at>,
	Rich Felker <dalias@libc.org>, Rob Herring <robh+dt@kernel.org>,
	Rob Herring <robh@kernel.org>, Russell King <linux@armlinux.org.uk>,
	Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>,
	Vineet Gupta <vgupta@synopsys.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org
Subject: Re: [PATCH AUTOSEL 5.0 015/262] memblock:
 memblock_phys_alloc_try_nid(): don't panic
Message-ID: <20190404005748.GJ16241@sasha-vm>
References: <20190327180158.10245-1-sashal@kernel.org>
 <20190327180158.10245-15-sashal@kernel.org>
 <20190328055720.GB14864@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190328055720.GB14864@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 07:57:21AM +0200, Mike Rapoport wrote:
>Hi,
>
>On Wed, Mar 27, 2019 at 01:57:50PM -0400, Sasha Levin wrote:
>> From: Mike Rapoport <rppt@linux.ibm.com>
>>
>> [ Upstream commit 337555744e6e39dd1d87698c6084dd88a606d60a ]
>>
>> The memblock_phys_alloc_try_nid() function tries to allocate memory from
>> the requested node and then falls back to allocation from any node in
>> the system.  The memblock_alloc_base() fallback used by this function
>> panics if the allocation fails.
>>
>> Replace the memblock_alloc_base() fallback with the direct call to
>> memblock_alloc_range_nid() and update the memblock_phys_alloc_try_nid()
>> callers to check the returned value and panic in case of error.
>
>This is a part of memblock refactoring, I don't think it should be applied
>to -stable.

Dropped, thanks!

--
Thanks,
Sasha

