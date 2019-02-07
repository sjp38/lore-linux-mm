Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D606BC4151A
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 05:04:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8052C2147C
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 05:04:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8052C2147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB10E8E0017; Thu,  7 Feb 2019 00:04:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C37678E0002; Thu,  7 Feb 2019 00:04:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD8278E0017; Thu,  7 Feb 2019 00:04:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 696C28E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 00:04:11 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id e68so6648088plb.3
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 21:04:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=x+asooKvJQwJjAfphAzY2OuJWCR5RVUO3LHg2DwDj6g=;
        b=ANw7TJGBi/yhsYK0f8rkq6ULI0LcxoqDFYmVkFN+UkfGHb6+fkUD0zHkna1Kf6eT/e
         GVmru8v7OyhCWoDXYLiaoz8BWtCxsPizSJPOn8xOlxkYJ9mJyP2fhbho+Y8NiO20Q1bK
         hyXqpdDUv4+ujLXR1UlwDGuhoB0j5H3ikCukAaD6trtoPcxyr/aU96+0WkzOsVUDD8iO
         Qf+kS1a/X97A2ht259c1urEfXqtcTLcj1CLhd29d5FEfwzKFNi4RJhxDNAMLh5JILZu0
         l6ka0sCMlwcdlgHEGi7mMehgI/GpuxXjVEwN0gvx4wiwJL2kyfEIqUKmytGDrANNRXsN
         gV0g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AHQUAub8YX5nlp+tyx32KYvb+lwO+5mFAHpa0CiLMmmFZBqiYU+XF0NP
	VIMg/YOQDSEQscWCBADbY+Zl3ek5s8P1JB1T9sKC1DgPi7s+2zhOUOAxFLHPfK+wM5uQZMIcFjT
	Ot3tU82pmZ3heQ6upvhyjuc/wQuQrlp/FHX22WatWEXyhaq5srYBXNGNjXUX+krg=
X-Received: by 2002:a65:43c5:: with SMTP id n5mr13467953pgp.250.1549515850971;
        Wed, 06 Feb 2019 21:04:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbczDAbYo23jBfO/PBmrWhAahZdIzFi+26dhkXFGqMNl2cwBV/vJ8FbSBzjAlWnKJcZKK7A
X-Received: by 2002:a65:43c5:: with SMTP id n5mr13467899pgp.250.1549515850173;
        Wed, 06 Feb 2019 21:04:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549515850; cv=none;
        d=google.com; s=arc-20160816;
        b=vokOTPdVa782RbXwn84qRKMfQ52sjuR0ht4k5Pj1KBMv3Jmek7TAbDS1p45Ery7P49
         JiR85wZOEHv/JdDDkleDXn3dZDLbCYzP8Wdl4XBHSJB7zhSkN9PwXu1hd9QD5PsqW3je
         +Vr23Pvmmfz1zpjDP+rkgHDK49a+u8v/VJZpxHQbGpQ+0fvIeheZqlV8B7RFVNAPuWN2
         vF8JJLgWvVml3h8V1yi8+d0Lx+fnlyc6Otx3dye8uF2qJvc52yHNjo6rgTmmyIP+edX2
         n7MDsLIvPi4/KW7bU4vgm7RsNR0IGnZ8QrDMXQ20ur0IwA8BdRnKrXRYW3EbEFF+cmUM
         FUDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=x+asooKvJQwJjAfphAzY2OuJWCR5RVUO3LHg2DwDj6g=;
        b=jx/jfg5QOjZkzDYiLHrM34dD4ut8kxBOWFJ/BVJKPeF1zSfOsWeUqTQ7OmjHitsLvY
         naw8B/9UhgDgM4T3eZDcqcMAoqYDay0X+tnHuR2fufiYY5ON/a2iOL+wMVmuGffi56wr
         HA2R7uaelRiz9J4xMRNREMEaNPItC/BY6NvCl2f5Y8mFXWz8jbuALAIfCkbKJUEVYqkS
         tH/OA/dbUpsjTGV6y3uEvMC2Y/Jpzz4+T1A5Bt0uW673cQOcehsLsRVtnBLl+V5Dh9yU
         YMj3tt9nom5DnaEc2QxFAuC/DqQd0msY2eWuDvXw32jnGanJ3a5V6KuDkn0wWhnmqLuP
         dHPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id cp14si9131351plb.170.2019.02.06.21.04.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 21:04:09 -0800 (PST)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43w5ng2hX4z9s6w;
	Thu,  7 Feb 2019 16:04:07 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Murilo Opsfelder Araujo <muriloo@linux.ibm.com>, Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 1/2] mm: add probe_user_read()
In-Reply-To: <20190205174242.GA24427@kermit.br.ibm.com>
References: <39fb6c5a191025378676492e140dc012915ecaeb.1547652372.git.christophe.leroy@c-s.fr> <20190205174242.GA24427@kermit.br.ibm.com>
Date: Thu, 07 Feb 2019 16:04:07 +1100
Message-ID: <87zhr8jik8.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Murilo Opsfelder Araujo <muriloo@linux.ibm.com> writes:
>> diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
>> index 37b226e8df13..ef99edd63da3 100644
>> --- a/include/linux/uaccess.h
>> +++ b/include/linux/uaccess.h
>> @@ -263,6 +263,40 @@ extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
>>  #define probe_kernel_address(addr, retval)		\
>>  	probe_kernel_read(&retval, addr, sizeof(retval))
>>
>> +/**
>> + * probe_user_read(): safely attempt to read from a user location
>> + * @dst: pointer to the buffer that shall take the data
>> + * @src: address to read from
>> + * @size: size of the data chunk
>> + *
>> + * Safely read from address @src to the buffer at @dst.  If a kernel fault
>> + * happens, handle that and return -EFAULT.
>> + *
>> + * We ensure that the copy_from_user is executed in atomic context so that
>> + * do_page_fault() doesn't attempt to take mmap_sem.  This makes
>> + * probe_user_read() suitable for use within regions where the caller
>> + * already holds mmap_sem, or other locks which nest inside mmap_sem.
>> + *
>> + * Returns: 0 on success, -EFAULT on error.
>> + */
>> +
>> +#ifndef probe_user_read
>> +static __always_inline long probe_user_read(void *dst, const void __user *src,
>> +					    size_t size)
>> +{
>> +	long ret;
>> +
>> +	if (!access_ok(src, size))
>> +		return -EFAULT;
>
> Hopefully, there is still time for a minor comment.
>
> Do we need to differentiate the returned error here, e.g.: return
> -EACCES?
>
> I wonder if there will be situations where callers need to know why
> probe_user_read() failed.

It's pretty standard to return EFAULT when an access_ok() check fails,
so I think using EFAULT here is the safest option.

If we used EACCES we'd need to be more careful about converting code to
use this helper, as doing so would potentially cause the error value to
change, which in some cases is not OK.

cheers

