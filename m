Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91515C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:38:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5825120C01
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:38:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5825120C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4C3C8E001A; Wed, 27 Feb 2019 12:38:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD4248E0001; Wed, 27 Feb 2019 12:38:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4DB08E001A; Wed, 27 Feb 2019 12:38:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC558E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:38:50 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id f18so12244631pfd.1
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:38:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=TGqecmHSYfu4bRdWr0B5jmLBg2CIXliUM8pZs6QQhM8=;
        b=R/jzMGV2hhV/NnLTmk3zArSIKsXgYEolHn5DKSN4l4ssVyjwKidHLwCfPKmcUdn5dY
         EmI0W5CcyFW7TBvkpEnM0lg+JwhQ2UPSBkLR5AdY5GwH5wo0xu7wfI1iYPFSb03t7KVa
         LG9BMGetN+qp2KKrzMU9lf6Dh5uE/rdiZ92DsP2Xh9Ot7xkv+ADeGYwyEmxRHa/+C7Yf
         PB9knTaPd6/9LbOtEcdrWRCSAXZL31VPONNC5nrOPE40yaiSo8603aDfDPSjiQ8fZGrp
         9YL+0XKwgFCS0HR//N2tuq2BjYENU7Ap5BEZ2DEH9vqf2TX6rTo0c4eq6a3w8IA4Md+b
         joYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAualdcxq748mnRMHXjGelzUNyTbl3WfPYhn+XqsTFwZncoxDO2Tm
	9ayHtR0XaL+eV8GWWh2CgzbOdfVWztLaYcRRK0F9S/qFBEUkJhYQaG5tnjZ99MGC1qekVbhRz/k
	b98E4NKmoarPYBNSUtxTRy7pZZiCFe0BXAWz4vuzTIOqzc7lmKrW9SzzdLU3H6S+g9w==
X-Received: by 2002:a62:2008:: with SMTP id g8mr2736285pfg.121.1551289130175;
        Wed, 27 Feb 2019 09:38:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaVpN2mJyWfcKwE3mheGz1S7yRvoDtlLZpvyAbULMaFyF6SA3IoDP3aUK0/n9EznS+w2IZs
X-Received: by 2002:a62:2008:: with SMTP id g8mr2736219pfg.121.1551289129333;
        Wed, 27 Feb 2019 09:38:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551289129; cv=none;
        d=google.com; s=arc-20160816;
        b=zCc5zDYVwO0w+vaWlXtQNaEUHnpGBzSQA36b+WGpHucor43GBK9hw4CDybZN+9bYqC
         vCKRITCgdH3s5t2DNZIC3l/xqMo9yhnB+BlHCJlXlmFd6X0UfM9L5hWbdnoGCNav82uE
         gHiSGuibATnrV9///OQ/rfRJcBYo0sui0CKJdZk5nhIV/W3Vzf/NjRCg2cTaeLk+6E1p
         CWEESQpSFzCMDBdZvUQcYMp004DWzFFBb9qz3kLfTOoFrOLgqYbLAD0u6qaPjrTnhMQv
         72PaIl+T8JE88lyBlpR7bNkQfFhCE8pWJ+VxxKhJCnMetUmspFXEPVZWPZRKmJ388S9u
         tAyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=TGqecmHSYfu4bRdWr0B5jmLBg2CIXliUM8pZs6QQhM8=;
        b=lW80o+LwstMe7I4DH0Rr7P4TDIE8sXoZQ24DsmndXArJniFj4NzdZGq5byOOprowAq
         18ciiRPqBcI+HnrkRtb7vTzRi9psn4ZlxVnK5AJO11iqEg/jDKuKWR7u2QhBdYiRZfwW
         5j1l/ewsqX1qwGW6QDXDdR/AbkewloWD//u8IjIv1Sr5WKJtf6fhOrA1DtKG22WfigqX
         CYA1lxTEpXPH6MdkIPDu9T1zbxZ6mrGtZAzZq8MU6hofrmwhi/ELVSOTxRrjZHsQ9LGP
         jqxSHfkfYBqbuJGgLSTS3WYvBiWgxeLiT0aQ4NLiYNQTzVNOK9m98X1azLqZ0Ji50zjl
         blRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p65si16003803pfi.76.2019.02.27.09.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 09:38:49 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Feb 2019 09:38:48 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,420,1544515200"; 
   d="scan'208";a="136767317"
Received: from unknown (HELO [10.254.89.112]) ([10.254.89.112])
  by FMSMGA003.fm.intel.com with ESMTP; 27 Feb 2019 09:38:47 -0800
Subject: Re: [PATCH v3 27/34] mm: pagewalk: Add 'depth' parameter to pte_hole
To: Steven Price <steven.price@arm.com>, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@kernel.org>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>,
 James Morse <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>,
 x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 Mark Rutland <Mark.Rutland@arm.com>, "Liang, Kan" <kan.liang@linux.intel.com>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-28-steven.price@arm.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <aece3046-6040-e2ec-fcd7-204113d40eb7@intel.com>
Date: Wed, 27 Feb 2019 09:38:48 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190227170608.27963-28-steven.price@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/27/19 9:06 AM, Steven Price wrote:
>  #ifdef CONFIG_SHMEM
>  static int smaps_pte_hole(unsigned long addr, unsigned long end,
> -		struct mm_walk *walk)
> +			  __always_unused int depth, struct mm_walk *walk)
>  {

I think this 'depth' argument is a mistake.  It's synthetic and it's
surely going to be a source of bugs.

The page table dumpers seem to be using this to dump out the "name" of a
hole which seems a bit bogus in the first place.  I'd much rather teach
the dumpers about the length of the hole, "the hole is 0x12340000 bytes
long", rather than "there's a hole at this level".

