Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A080CC282C2
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 03:01:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48E5A21907
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 03:01:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48E5A21907
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A35378E0071; Thu,  7 Feb 2019 22:01:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BE998E0002; Thu,  7 Feb 2019 22:01:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85FB18E0071; Thu,  7 Feb 2019 22:01:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40B978E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 22:01:31 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id q20so1443452pls.4
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 19:01:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=/3G1iEeHPynSPWKKIWjHp/QqgvUgbG7rN1g7bLfoxU8=;
        b=LhdTNGW7IvSIyv25GAk48aZIwrtJrMhe+wIlgMfgT6zdKjcX6kxRFAoBaKwvgBzKBq
         lN8IqSMlCu6viTBUAHoW0yMyl22dpdK8i+hfEGdvxt09GE5i/Y3XE3UMAy2CXOl1X+qF
         WHOKcTYeiADpSawaq2ytknAPc9g5ayUrUDaVM8+7nDahy+RI+Tti+TcK7kkEKFu3eLLo
         LrW/GRbC4FsuH0JRIHstjusq0ChSfXMmYfxt+UFGrgHSjiFKg4o/7E3SFYH5hHm1J0aJ
         Yr29Oivl5w1JOs6vXApfM4b1cns7skK3g/gMnEo1OJEg9Aszod7XCali3MxT/XtKop2X
         hcxQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AHQUAuZip0PBoXgcle139sshFo3qxxss5Q/jvkTI5RY9jHYU5HVQUMkf
	EbayS9UkQdCidZW0BsbYnZhXwILqfCulcwZybh92Wh6fDp4U2SVDh1P5QfHXUrQyescT1uiG2NF
	VYh/QKL1WCQ4M1Ah4GfeBO340ddrupPJMEzw7/QwfffekEC4Kyetnq8DjHDVdqEI=
X-Received: by 2002:a62:520b:: with SMTP id g11mr20017564pfb.53.1549594890142;
        Thu, 07 Feb 2019 19:01:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaNU/8yNgJLW19r4ElCHBR0y7IRFdijaU5yoP6P1vYOWLhbHqnAe/o2EBB/tpGweKP+iJHl
X-Received: by 2002:a62:520b:: with SMTP id g11mr20017370pfb.53.1549594887948;
        Thu, 07 Feb 2019 19:01:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549594887; cv=none;
        d=google.com; s=arc-20160816;
        b=XbwGEtoSadtZyVf9CEeL3MqWCOegdzU8KkR+U2sKXmejkUyE5nqI78kf6rHpbenClY
         g+YFJSNhEm2J6auqwNp5ieJRUaI1yGWtJqPXMS5pnuG4JWy/G3h55rsgt/2I5JKjH9jA
         o6U+4OCDOAqXANWe9P+sqsRRB7oJiIgt8qi6TK6/yYNrmtd/omyWZaK+KsQzd7UnV7Jh
         B0bUJp1duEytdeW51ZH9yiT6wYwOYNj5gCQX0keEpZfVtqXDcJKg6gPsnYDiujX5S6Jo
         1YhRizOIQ6OAeWO6JEXdNgkOlQLU6H5VLV7XbzMK2YxLCVh/GLI70ZSu6r5zZwiFODzi
         sC3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=/3G1iEeHPynSPWKKIWjHp/QqgvUgbG7rN1g7bLfoxU8=;
        b=xuvMm2dWN4NhHNBA3+PSYy9gwqegdGr/IPwilWeqT06v3MPuW7zCb85NseQKUjM+Sq
         GY+Ws3ACzHVWN6EwhlhBzPcXQ0bvRCNvn4fcDb9GwS3ofgPIy7GG3Qn4NBNmsxreyyko
         yXZLDgRATOJjydFKouO+M3nRkxr+Z6nD3IOMwQIIdUz7/olqXIXGzk3GLNAL9StL2fTH
         Q1uH/17sCcC/eDWinEw6LQ0ESn2l2hVdMrGet0N3afngAt93/AvsMNzO2TQlDFLsJWt2
         fcuiP5n+YjcDYt9RpxL4f6u6zm4FBIAUmM5JyzCkpIlQTN7pliVlpjNFwa/IxpwFwLmS
         PSAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id 6si926439plc.241.2019.02.07.19.01.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Feb 2019 19:01:27 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43wg1b29qsz9sBZ;
	Fri,  8 Feb 2019 14:01:23 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Jann Horn <jannh@google.com>, Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Mike Rapoport <rppt@linux.ibm.com>, kernel list <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, Linux-MM <linux-mm@kvack.org>
Subject: Re: [PATCH v3 1/2] mm: add probe_user_read()
In-Reply-To: <CAG48ez1gXgsBG6bYGG5+B4Dqkhk_iVaYLqt63RaxURxE0yt9eA@mail.gmail.com>
References: <39fb6c5a191025378676492e140dc012915ecaeb.1547652372.git.christophe.leroy@c-s.fr> <CAG48ez1gXgsBG6bYGG5+B4Dqkhk_iVaYLqt63RaxURxE0yt9eA@mail.gmail.com>
Date: Fri, 08 Feb 2019 14:01:22 +1100
Message-ID: <87imxvj859.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Jann Horn <jannh@google.com> writes:
> On Thu, Feb 7, 2019 at 10:22 AM Christophe Leroy
> <christophe.leroy@c-s.fr> wrote:
>> In powerpc code, there are several places implementing safe
>> access to user data. This is sometimes implemented using
>> probe_kernel_address() with additional access_ok() verification,
>> sometimes with get_user() enclosed in a pagefault_disable()/enable()
>> pair, etc. :
>>     show_user_instructions()
>>     bad_stack_expansion()
>>     p9_hmi_special_emu()
>>     fsl_pci_mcheck_exception()
>>     read_user_stack_64()
>>     read_user_stack_32() on PPC64
>>     read_user_stack_32() on PPC32
>>     power_pmu_bhrb_to()
>>
>> In the same spirit as probe_kernel_read(), this patch adds
>> probe_user_read().
>>
>> probe_user_read() does the same as probe_kernel_read() but
>> first checks that it is really a user address.
>>
>> The patch defines this function as a static inline so the "size"
>> variable can be examined for const-ness by the check_object_size()
>> in __copy_from_user_inatomic()
>>
>> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
>
>
>
>> ---
>>  v3: Moved 'Returns:" comment after description.
>>      Explained in the commit log why the function is defined static inline
>>
>>  v2: Added "Returns:" comment and removed probe_user_address()
>>
>>  include/linux/uaccess.h | 34 ++++++++++++++++++++++++++++++++++
>>  1 file changed, 34 insertions(+)
>>
>> diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
>> index 37b226e8df13..ef99edd63da3 100644
>> --- a/include/linux/uaccess.h
>> +++ b/include/linux/uaccess.h
>> @@ -263,6 +263,40 @@ extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
>>  #define probe_kernel_address(addr, retval)             \
>>         probe_kernel_read(&retval, addr, sizeof(retval))
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
>> +                                           size_t size)
>> +{
>> +       long ret;
>> +
>> +       if (!access_ok(src, size))
>> +               return -EFAULT;
>
> If this happens in code that's running with KERNEL_DS, the access_ok()
> is a no-op. If this helper is only intended for accessing real
> userspace memory, it would be more robust to add
> set_fs(USER_DS)/set_fs(oldfs) around this thing. Looking at the
> functions you're referring to in the commit message, e.g.
> show_user_instructions() does an explicit `__access_ok(pc,
> NR_INSN_TO_PRINT * sizeof(int), USER_DS)` to get the same effect.

Yeah I raised the same question up thread.

I think we're both right :) - it should explicitly set USER_DS.

There's precedent for that in the code you mentioned and also in the
perf code, eg:

  88b0193d9418 ("perf/callchain: Force USER_DS when invoking perf_callchain_user()")


cheers

