Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2380FC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:26:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D777820857
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:26:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D777820857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F8898E0002; Wed, 30 Jan 2019 23:26:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A7888E0001; Wed, 30 Jan 2019 23:26:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BE6B8E0002; Wed, 30 Jan 2019 23:26:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25CC68E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 23:26:08 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id x26so1307801pgc.5
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 20:26:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=QHsp2UHGS9osXy7Vsw7jDvPjlMCIj2rnsb3EltN5wDo=;
        b=Z//gR2mG5ZZQMJd8bAt2XfwYM2NVVxyJbYCGgsCeHSi0QY7TypuEjB58B/v7+yQyXi
         f/K6suVbWxRu24WhqJVms63+pXWTnbHIec05HeEnd6+jZwFRBHdEW6uPTWVCoasok68q
         c6ooXpkYG74pPJ1L7FjkHPc6PqeLMK2Ea9akSjU/WQcJc3v3/Pz3J0t7CIGnqc63B2e0
         1Xj537ZxGnAROWKzITtwyAgoFgDmSimHdcO0kmgspW1E52cfu6s94yJYrw0jhJ8jpXXh
         KgauXG5Axf6XeGtYYy7sacuo6+UcwTyR97/HsxOHssJZQtcxrJnLbMV+Qt8T3rhOn9dN
         X0Nw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukfh2Dg9HExiY83qvNcoRJRRgXGbzR226aLEgE83+EupEoUosUM7
	yMdAOA0dyEXbbW7Sfm9CmAVhc+jmkxSZfoKEPh2zdQzSDki8HDN522b3KCKVc59h5C4HaqB12NS
	I8PtRN2keXYOrNQkuus6hgGFMZVqvI3CZB/AiGEmGrMBFPVdzkLD3iNX264pXCzE=
X-Received: by 2002:a17:902:887:: with SMTP id 7mr33036319pll.164.1548908767791;
        Wed, 30 Jan 2019 20:26:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6Ecd1pxFBdDFLebG/peWDM13F6m6674s7YHhlqb1MW857DDFYNcFKBpqufqLGsc9RAxVyo
X-Received: by 2002:a17:902:887:: with SMTP id 7mr33036298pll.164.1548908767062;
        Wed, 30 Jan 2019 20:26:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548908767; cv=none;
        d=google.com; s=arc-20160816;
        b=uM+CDbIxqDF4zjdNggTBOfVVPK+9YpDxqcVYv+TyqtgjUchOqEJW0nUlbtw5SyGTba
         IUsSNZ0hFvV7qgvdYubpaaVdNFJBB5Zb8HMIIRd8eRwIsIsCKbZUNq2cxtAeCneBuUxX
         2EWT8+DiShtW3h2g/+QIFaOsBNqzapSaCzF9GHOwOJuVzJ5TgeB2t05qAOZcH9UbUS65
         oKOfZv6jTp9LOZaepEviWVoXgX33Aeg/2Tib3AMjhVPTTi+RuV1axuFFEL1k7usLrS7s
         Xsmxcq2VimTeTOF+eQqOlsxdhnD8a/tEB6QQmTO43uAlakQCz6Uhk6w25jQkVq0ttT8g
         VndA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=QHsp2UHGS9osXy7Vsw7jDvPjlMCIj2rnsb3EltN5wDo=;
        b=sZDU1bHCI0MyAEBU5mwDxfHT6sHY1L5MtXU/msP+tiN+UhVEe17dLGOBzXmvRHH25W
         6HnqV4Kz1WYrb1Uu686Od+I2xdjI0K1VWxaI9jRnV1gg6hNpOn9uD6a4snFEDluYRbQf
         8QsTLJvKWjo8xwlGYhwK2lW6DLV+1n3H9qBzueekL4DesDT/5Q9ISoYVomotXVh9zWcD
         ODTr1rPdkgSolpdljP/Im5BvpSln3/vCpi4ppjIqNXucnHoE1l3a6pjFzNjecqbOGNUD
         KQYEO4vcJHMSAfrT9GjB3WHVHDEmDSCCg0XDA+7Ih/3WYtFOsHTh/9bI3CursjQqoD6N
         Ijww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id 128si1502793pfe.4.2019.01.30.20.26.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 20:26:07 -0800 (PST)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43qnGz6QyHz9sBb;
	Thu, 31 Jan 2019 15:26:03 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Christophe Leroy <christophe.leroy@c-s.fr>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org
Subject: Re: [PATCH v3 1/2] mm: add probe_user_read()
In-Reply-To: <39fb6c5a191025378676492e140dc012915ecaeb.1547652372.git.christophe.leroy@c-s.fr>
References: <39fb6c5a191025378676492e140dc012915ecaeb.1547652372.git.christophe.leroy@c-s.fr>
Date: Thu, 31 Jan 2019 15:26:03 +1100
Message-ID: <875zu5pi5g.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Christophe Leroy <christophe.leroy@c-s.fr> writes:

> In powerpc code, there are several places implementing safe
> access to user data. This is sometimes implemented using
> probe_kernel_address() with additional access_ok() verification,
> sometimes with get_user() enclosed in a pagefault_disable()/enable()
> pair, etc. :
>     show_user_instructions()
>     bad_stack_expansion()
>     p9_hmi_special_emu()
>     fsl_pci_mcheck_exception()
>     read_user_stack_64()
>     read_user_stack_32() on PPC64
>     read_user_stack_32() on PPC32
>     power_pmu_bhrb_to()
>
> In the same spirit as probe_kernel_read(), this patch adds
> probe_user_read().
>
> probe_user_read() does the same as probe_kernel_read() but
> first checks that it is really a user address.
>
> The patch defines this function as a static inline so the "size"
> variable can be examined for const-ness by the check_object_size()
> in __copy_from_user_inatomic()
>
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>  v3: Moved 'Returns:" comment after description.
>      Explained in the commit log why the function is defined static inline
>
>  v2: Added "Returns:" comment and removed probe_user_address()
>
>  include/linux/uaccess.h | 34 ++++++++++++++++++++++++++++++++++
>  1 file changed, 34 insertions(+)
>
> diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
> index 37b226e8df13..ef99edd63da3 100644
> --- a/include/linux/uaccess.h
> +++ b/include/linux/uaccess.h
> @@ -263,6 +263,40 @@ extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
>  #define probe_kernel_address(addr, retval)		\
>  	probe_kernel_read(&retval, addr, sizeof(retval))
>  
> +/**
> + * probe_user_read(): safely attempt to read from a user location
> + * @dst: pointer to the buffer that shall take the data
> + * @src: address to read from
> + * @size: size of the data chunk
> + *
> + * Safely read from address @src to the buffer at @dst.  If a kernel fault
> + * happens, handle that and return -EFAULT.
> + *
> + * We ensure that the copy_from_user is executed in atomic context so that
> + * do_page_fault() doesn't attempt to take mmap_sem.  This makes
> + * probe_user_read() suitable for use within regions where the caller
> + * already holds mmap_sem, or other locks which nest inside mmap_sem.
> + *
> + * Returns: 0 on success, -EFAULT on error.
> + */
> +
> +#ifndef probe_user_read
> +static __always_inline long probe_user_read(void *dst, const void __user *src,
> +					    size_t size)
> +{
> +	long ret;
> +

I wonder if we should explicitly switch to USER_DS here?

That would be sort of unusual, but the whole reason for this helper
existing is to make sure we safely read from user memory and not
accidentally from kernel.

cheers

> +	if (!access_ok(src, size))
> +		return -EFAULT;
> +
> +	pagefault_disable();
> +	ret = __copy_from_user_inatomic(dst, src, size);
> +	pagefault_enable();
> +
> +	return ret ? -EFAULT : 0;
> +}
> +#endif
> +
>  #ifndef user_access_begin
>  #define user_access_begin(ptr,len) access_ok(ptr, len)
>  #define user_access_end() do { } while (0)
> -- 
> 2.13.3

