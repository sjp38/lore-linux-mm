Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id D14208E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 16:11:53 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id 129so1374464wmy.7
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 13:11:53 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id l12si41534421wrg.404.2019.01.08.13.11.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 13:11:52 -0800 (PST)
Subject: Re: [PATCH v2 1/2] mm: add probe_user_read()
References: <0b0db24e18063076e9d9f4e376994af83da05456.1546932949.git.christophe.leroy@c-s.fr>
 <20190108114803.583f203b86d4a368ac9796f3@linux-foundation.org>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <19c99d33-b796-72df-4212-20255f84efa0@c-s.fr>
Date: Tue, 8 Jan 2019 22:11:50 +0100
MIME-Version: 1.0
In-Reply-To: <20190108114803.583f203b86d4a368ac9796f3@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org



Le 08/01/2019 à 20:48, Andrew Morton a écrit :
> On Tue,  8 Jan 2019 07:37:44 +0000 (UTC) Christophe Leroy <christophe.leroy@c-s.fr> wrote:
> 
>> In powerpc code, there are several places implementing safe
>> access to user data. This is sometimes implemented using
>> probe_kernel_address() with additional access_ok() verification,
>> sometimes with get_user() enclosed in a pagefault_disable()/enable()
>> pair, etc. :
>>      show_user_instructions()
>>      bad_stack_expansion()
>>      p9_hmi_special_emu()
>>      fsl_pci_mcheck_exception()
>>      read_user_stack_64()
>>      read_user_stack_32() on PPC64
>>      read_user_stack_32() on PPC32
>>      power_pmu_bhrb_to()
>>
>> In the same spirit as probe_kernel_read(), this patch adds
>> probe_user_read().
>>
>> probe_user_read() does the same as probe_kernel_read() but
>> first checks that it is really a user address.
>>
>> ...
>>
>> --- a/include/linux/uaccess.h
>> +++ b/include/linux/uaccess.h
>> @@ -263,6 +263,40 @@ extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
>>   #define probe_kernel_address(addr, retval)		\
>>   	probe_kernel_read(&retval, addr, sizeof(retval))
>>   
>> +/**
>> + * probe_user_read(): safely attempt to read from a user location
>> + * @dst: pointer to the buffer that shall take the data
>> + * @src: address to read from
>> + * @size: size of the data chunk
>> + *
>> + * Returns: 0 on success, -EFAULT on error.
>> + *
>> + * Safely read from address @src to the buffer at @dst.  If a kernel fault
>> + * happens, handle that and return -EFAULT.
>> + *
>> + * We ensure that the copy_from_user is executed in atomic context so that
>> + * do_page_fault() doesn't attempt to take mmap_sem.  This makes
>> + * probe_user_read() suitable for use within regions where the caller
>> + * already holds mmap_sem, or other locks which nest inside mmap_sem.
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
>> +
>> +	pagefault_disable();
>> +	ret = __copy_from_user_inatomic(dst, src, size);
>> +	pagefault_enable();
>> +
>> +	return ret ? -EFAULT : 0;
>> +}
>> +#endif
> 
> Why was the __always_inline needed?
> 
> This function is pretty large.  Why is it inlined?
> 

Kees told to do that way, see https://patchwork.ozlabs.org/patch/986848/

Christophe
