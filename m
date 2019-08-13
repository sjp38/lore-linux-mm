Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C830C41514
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 20:17:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 260D820842
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 20:17:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 260D820842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E5676B0005; Tue, 13 Aug 2019 16:17:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 896E16B0006; Tue, 13 Aug 2019 16:17:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7ABD26B0007; Tue, 13 Aug 2019 16:17:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0012.hostedemail.com [216.40.44.12])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE2F6B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 16:17:18 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C20C2180AD7C3
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 20:17:17 +0000 (UTC)
X-FDA: 75818514114.02.side53_3fa0506867142
X-HE-Tag: side53_3fa0506867142
X-Filterd-Recvd-Size: 3392
Received: from mail-wr1-f67.google.com (mail-wr1-f67.google.com [209.85.221.67])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 20:17:17 +0000 (UTC)
Received: by mail-wr1-f67.google.com with SMTP id r3so15208174wrt.3
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:17:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=xLqB1iHsnjstXwaiMKShyj00W23FVz4l/tiZwn13DNg=;
        b=kvRIgIsws+GiCmKL2x/2RfxTgWYpxj1ioqO0rf5v3CtpDTMAUEIOCPXKcHfMJjC3CI
         RIgh2sHBbtxwgKSvL+yPGQ0ACsBfB/D06xU8uxGdd/D2I3M71BioBalfpkq4LiBDEYKN
         D7YQMnLJdJ6+qjeMxt/tFxiML1zOl/RXgaE/iYLdTKV4zt5N5wD6voeooK1I03I+ApCP
         iIRZcxFHKDvUxNcLzJ5UtU+sV88q6ANNmQ49e8kCjl/PePMfoMHO1VXWoEa2nyf5TUQD
         onNmSYz6mkAe/Fd62JxUQOt53jsGh9XRpQII8dPA3hGYnBRnUlteKZE/njuOngDME68K
         ncEA==
X-Gm-Message-State: APjAAAUHToejTrjbhYdV4m2vIgP5YfUH00u9QaB+0wpiPTuge/HF+GRH
	uf9BvrrMA+Z/m4QQKeyn65Cxfg==
X-Google-Smtp-Source: APXvYqzp0rrfeaSg7ovOyhbIMVvBcqf42VfsAkGU431CuFYIXFBgFQnuBHDzMSsNaKLpDL8fUR0Iig==
X-Received: by 2002:adf:dc51:: with SMTP id m17mr2040964wrj.256.1565727435844;
        Tue, 13 Aug 2019 13:17:15 -0700 (PDT)
Received: from ?IPv6:2001:b07:6468:f312:5193:b12b:f4df:deb6? ([2001:b07:6468:f312:5193:b12b:f4df:deb6])
        by smtp.gmail.com with ESMTPSA id h97sm39854573wrh.74.2019.08.13.13.17.13
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 13:17:15 -0700 (PDT)
Subject: Re: [Question-kvm] Can hva_to_pfn_fast be executed in interrupt
 context?
To: Bharath Vedartham <linux.bhar@gmail.com>, rkrcmar@redhat.com
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 khalid.aziz@oracle.com
References: <20190813191435.GB10228@bharath12345-Inspiron-5559>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <54182261-88a4-9970-1c3c-8402e130dcda@redhat.com>
Date: Tue, 13 Aug 2019 22:17:09 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190813191435.GB10228@bharath12345-Inspiron-5559>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13/08/19 21:14, Bharath Vedartham wrote:
> Hi all,
> 
> I was looking at the function hva_to_pfn_fast(in virt/kvm/kvm_main) which is 
> executed in an atomic context(even in non-atomic context, since
> hva_to_pfn_fast is much faster than hva_to_pfn_slow).
> 
> My question is can this be executed in an interrupt context? 

No, it cannot for the reason you mention below.

Paolo

> The motivation for this question is that in an interrupt context, we cannot
> assume "current" to be the task_struct of the process of interest.
> __get_user_pages_fast assume current->mm when walking the process page
> tables. 
> 
> So if this function hva_to_pfn_fast can be executed in an
> interrupt context, it would not be safe to retrive the pfn with
> __get_user_pages_fast. 
> 
> Thoughts on this?
> 
> Thank you
> Bharath
> 


