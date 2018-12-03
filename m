Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13A0A6B6A57
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 12:11:15 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id t62-v6so4556513wmg.6
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 09:11:15 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id n4si6250693wmn.59.2018.12.03.09.11.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 09:11:13 -0800 (PST)
Subject: Re: [RFC PATCH] mm: add probe_user_read() and probe_user_address()
References: <336eb81e62d6c683a69d312f533899dcb6bcf770.1539959864.git.christophe.leroy@c-s.fr>
 <CAGXu5jJzp0v_Ox4gJcSdMVT7Rzuoy4mH-J3tPfrpeyCTi4o5YQ@mail.gmail.com>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <a6d785e7-c01d-eb3c-89da-e960abc40c6d@c-s.fr>
Date: Mon, 3 Dec 2018 18:11:11 +0100
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJzp0v_Ox4gJcSdMVT7Rzuoy4mH-J3tPfrpeyCTi4o5YQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, LKML <linux-kernel@vger.kernel.org>, PowerPC <linuxppc-dev@lists.ozlabs.org>, Linux-MM <linux-mm@kvack.org>



Le 19/10/2018 à 17:42, Kees Cook a écrit :
> On Fri, Oct 19, 2018 at 8:14 AM, Christophe Leroy
> <christophe.leroy@c-s.fr> wrote:
>> In the powerpc, there are several places implementing safe
>> access to user data. This is sometimes implemented using
>> probe_kerne_address() with additional access_ok() verification,
>> sometimes with get_user() enclosed in a pagefault_disable()/enable()
>> pair, etc... :
>>      show_user_instructions()
>>      bad_stack_expansion()
>>      p9_hmi_special_emu()
>>      fsl_pci_mcheck_exception()
>>      read_user_stack_64()
>>      read_user_stack_32() on PPC64
>>      read_user_stack_32() on PPC32
>>      power_pmu_bhrb_to()
>>
>> In the same spirit as probe_kernel_read() and probe_kernel_address(),
>> this patch adds probe_user_read() and probe_user_address().
>>
>> probe_user_read() does the same as probe_kernel_read() but
>> first checks that it is really a user address.
>>
>> probe_user_address() is a shortcut to probe_user_read()
>>
>> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
>> ---
>>   include/linux/uaccess.h | 10 ++++++++++
>>   mm/maccess.c            | 33 +++++++++++++++++++++++++++++++++
>>   2 files changed, 43 insertions(+)
>>
>> diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
>> index efe79c1cdd47..fb00e3f847d7 100644
>> --- a/include/linux/uaccess.h
>> +++ b/include/linux/uaccess.h
>> @@ -266,6 +266,16 @@ extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
>>   #define probe_kernel_address(addr, retval)             \
>>          probe_kernel_read(&retval, addr, sizeof(retval))
>>
>> +/**
>> + * probe_user_address(): safely attempt to read from a user location
>> + * @addr: address to read from
>> + * @retval: read into this variable
>> + *
>> + * Returns 0 on success, or -EFAULT.
>> + */
>> +#define probe_user_address(addr, retval)               \
>> +       probe_user_read(&(retval), addr, sizeof(retval))
>> +
>>   #ifndef user_access_begin
>>   #define user_access_begin() do { } while (0)
>>   #define user_access_end() do { } while (0)
>> diff --git a/mm/maccess.c b/mm/maccess.c
>> index ec00be51a24f..85d4a88a6917 100644
>> --- a/mm/maccess.c
>> +++ b/mm/maccess.c
>> @@ -67,6 +67,39 @@ long __probe_kernel_write(void *dst, const void *src, size_t size)
>>   EXPORT_SYMBOL_GPL(probe_kernel_write);
>>
>>   /**
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
>> + */
>> +
>> +long __weak probe_user_read(void *dst, const void *src, size_t size)
>> +       __attribute__((alias("__probe_user_read")));
> 
> Let's use #defines to deal with per-arch aliases so we can keep the
> inline I'm suggesting below...
> 
>> +
>> +long __probe_user_read(void *dst, const void __user *src, size_t size)
> 
> Please make this __always_inline so the "size" variable can be
> examined for const-ness by the check_object_size() in
> __copy_from_user_inatomic().

Ok, I did as suggested in the patch I just sent.

Would it be worth doing the same with the existing probe_kernel_read() 
and probe_kernel_write() ?

Christophe

> 
> -Kees
> 
