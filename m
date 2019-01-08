Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F68B8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 02:51:15 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id x67so2155089pfk.16
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 23:51:15 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u4si54983024pga.91.2019.01.07.23.51.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 23:51:13 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x087nHqK108984
	for <linux-mm@kvack.org>; Tue, 8 Jan 2019 02:51:13 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pvpcmm90f-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Jan 2019 02:51:13 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 8 Jan 2019 07:51:10 -0000
Date: Tue, 8 Jan 2019 09:51:04 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 1/2] mm: add probe_user_read()
References: <0b0db24e18063076e9d9f4e376994af83da05456.1546932949.git.christophe.leroy@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0b0db24e18063076e9d9f4e376994af83da05456.1546932949.git.christophe.leroy@c-s.fr>
Message-Id: <20190108075104.GA4396@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Tue, Jan 08, 2019 at 07:37:44AM +0000, Christophe Leroy wrote:
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
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>  v2: Added "Returns:" comment and removed probe_user_address()
> 
>  Changes since RFC: Made a static inline function instead of weak function as recommended by Kees.
> 
>  include/linux/uaccess.h | 34 ++++++++++++++++++++++++++++++++++
>  1 file changed, 34 insertions(+)
> 
> diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
> index 37b226e8df13..07f4f0ed69bc 100644
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
> + * Returns: 0 on success, -EFAULT on error.

Nit: please put the "Returns:" comment after the description, otherwise
kernel-doc considers it a part of the elaborate description.

> + *
> + * Safely read from address @src to the buffer at @dst.  If a kernel fault
> + * happens, handle that and return -EFAULT.
> + *
> + * We ensure that the copy_from_user is executed in atomic context so that
> + * do_page_fault() doesn't attempt to take mmap_sem.  This makes
> + * probe_user_read() suitable for use within regions where the caller
> + * already holds mmap_sem, or other locks which nest inside mmap_sem.
> + */
> +
> +#ifndef probe_user_read
> +static __always_inline long probe_user_read(void *dst, const void __user *src,
> +					    size_t size)
> +{
> +	long ret;
> +
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
> 

-- 
Sincerely yours,
Mike.
