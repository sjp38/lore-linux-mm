Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5D51C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:58:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94039213F2
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:58:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94039213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24B826B0006; Mon,  1 Jul 2019 05:58:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D68E8E0003; Mon,  1 Jul 2019 05:58:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C5548E0002; Mon,  1 Jul 2019 05:58:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f80.google.com (mail-ed1-f80.google.com [209.85.208.80])
	by kanga.kvack.org (Postfix) with ESMTP id B2A436B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 05:58:28 -0400 (EDT)
Received: by mail-ed1-f80.google.com with SMTP id r21so16440301edp.11
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 02:58:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Ff0IkY/etQsIjzYazy+jlXyYnF6WPeV3Hgac/ibQklA=;
        b=ZCNV7lxpQVdeLUaIvBdlDWBsRqWvxdmkK9WlXNdOFwtQ5Z2JGIkAKteejFw/TWof0N
         VC/YhtEh8eAAXp5+ja18ra4XsqzgH5NZHdDON7XNtLi1JPn5qdSxpsOA4hyWCEDBDMFv
         NBuc7Qcu6hNnnn3uqG78SbNwGBYj2uN+zO6E3TUUbPORvmBXArd52baNyQu4gQ/8QKtq
         psvdae2txR91pa0g79EjH75vn3JVnzLUjac7/K6m7cc9+cgw97dZFTQjp9R8NXgnBS4F
         ADMARb8EAB4iFSJtwlgDo3VVYrLJr7Zp0TEr8R4joJ0wO1/3A+335ipcYrGT5bHppA+3
         dDQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAU8AFub3Cy+uS1aoxArre4tvDWhhjV93rmbNivPAZ3YTd21bHqq
	Qdd7jTmhtOHXDyiQlyvz/lsrXMxske9hvkrdOCxUYx2N76NjGL++tm6vLDVi6IMOYOOLf/nG023
	+MZFqlvoLjbpjhEol0GgQTafUdnJotH+nPTVFiZKfmwBFcQBL1vBwsnMmaXXAjzcgYg==
X-Received: by 2002:a50:92e1:: with SMTP id l30mr27321120eda.141.1561975108330;
        Mon, 01 Jul 2019 02:58:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwS/7gg/TS/ZISxpi1iyG14p8VdrDlzJqeIefMM6H3mZR+Vil07M1GYbRMPlVnJcGPqeD3l
X-Received: by 2002:a50:92e1:: with SMTP id l30mr27321082eda.141.1561975107747;
        Mon, 01 Jul 2019 02:58:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561975107; cv=none;
        d=google.com; s=arc-20160816;
        b=sbs9YEpTKD5/I8PdoczJ7d5FC86NtaEd3JQdlBC7MSi54S+R0B0P2g0cQ3GF2Goinm
         FF3wIa9ZjfYVmehpPYUyDgUyCtsb9lDLAAkoXasT52t8H2MJ1vnOO6a8dBHCvHp7tNBN
         5PE6tkWxIGX0cMAyaDqcM5hy1aNItpwDlkdl2K26tkiMMGPk5kCi9iVBc3Y7oCBMqsgj
         sLDkS1m7z80Wj9qL/XgIhoE0fAweJ0Z4QnxEld6mcXkIg5kql/bHjti5rPCjYlQpUBD5
         54Lx/2Cw+5YNbu6uCflyi4xz2L+jeKt93T+cy2ecZxY0KmuoKVatpdXdTS5JjCNqv965
         Y5rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Ff0IkY/etQsIjzYazy+jlXyYnF6WPeV3Hgac/ibQklA=;
        b=kZDU1pRywYVhTY0z6e/sIGlLlCIjVDvGqTQ/jJUn6yhE2mnSWBOSIRuMJCp2A6rdIq
         iAvLzqHz/JNDOcTSthD+lrfAAr7LbyhvHdGnbAJddb9XKkSCJFmtqnGkGYsXzxxJGWPn
         a70By/LIomXiB3PpKBy90tUqZT3QOKwX7bsTjeNiLOz90w7l50gRJ8oTezhnHyn2PpnO
         hMIkODu+3Q6TVPS2KSD2n16K/LlwZxxGARQwIXY1jynLenst5YLLlAX12H397h2xEl/5
         IYzZ4G8bzCkLZ7S5UWA36i2xPSZvp8IACC6f/wWYqxwAWib/WN1gxmbkoMKMLccaQJkH
         Sfaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id z25si7075865ejq.47.2019.07.01.02.58.27
        for <linux-mm@kvack.org>;
        Mon, 01 Jul 2019 02:58:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F2FB82B;
	Mon,  1 Jul 2019 02:58:26 -0700 (PDT)
Received: from [10.162.42.133] (p8cg001049571a15.blr.arm.com [10.162.42.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C5EAF3F718;
	Mon,  1 Jul 2019 02:58:24 -0700 (PDT)
Subject: Re: [PATCH v2 3/3] mm/vmalloc: fix vmalloc_to_page for huge vmap
 mappings
To: Nicholas Piggin <npiggin@gmail.com>,
 "linux-mm @ kvack . org" <linux-mm@kvack.org>
Cc: "linux-arm-kernel @ lists . infradead . org"
 <linux-arm-kernel@lists.infradead.org>,
 "linuxppc-dev @ lists . ozlabs . org" <linuxppc-dev@lists.ozlabs.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Mark Rutland <mark.rutland@arm.com>
References: <20190701064026.970-1-npiggin@gmail.com>
 <20190701064026.970-4-npiggin@gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <8369ca48-ebab-fe2d-363d-00769827fd0b@arm.com>
Date: Mon, 1 Jul 2019 15:28:51 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190701064026.970-4-npiggin@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 07/01/2019 12:10 PM, Nicholas Piggin wrote:
> vmalloc_to_page returns NULL for addresses mapped by larger pages[*].
> Whether or not a vmap is huge depends on the architecture details,
> alignments, boot options, etc., which the caller can not be expected
> to know. Therefore HUGE_VMAP is a regression for vmalloc_to_page.
> 
> This change teaches vmalloc_to_page about larger pages, and returns
> the struct page that corresponds to the offset within the large page.
> This makes the API agnostic to mapping implementation details.
> 
> [*] As explained by commit 029c54b095995 ("mm/vmalloc.c: huge-vmap:
>     fail gracefully on unexpected huge vmap mappings")
> 
> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

