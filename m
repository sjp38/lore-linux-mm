Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 30E7E6B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 18:12:16 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so44306177pab.5
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 15:12:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id tl3si3590587pac.215.2015.01.29.15.12.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jan 2015 15:12:15 -0800 (PST)
Date: Thu, 29 Jan 2015 15:12:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 01/17] Add kernel address sanitizer infrastructure.
Message-Id: <20150129151213.09d1f9e0a01490712d0eb071@linux-foundation.org>
In-Reply-To: <1422544321-24232-2-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-2-git-send-email-a.ryabinin@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

On Thu, 29 Jan 2015 18:11:45 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> Kernel Address sanitizer (KASan) is a dynamic memory error detector. It provides
> fast and comprehensive solution for finding use-after-free and out-of-bounds bugs.
> 
> KASAN uses compile-time instrumentation for checking every memory access,
> therefore GCC >= v4.9.2 required.
> 
> ...
>
> Based on work by Andrey Konovalov <adech.fo@gmail.com>

Can we obtain Andrey's signed-off-by: please?
 
> +void kasan_unpoison_shadow(const void *address, size_t size)
> +{
> +	kasan_poison_shadow(address, size, 0);
> +
> +	if (size & KASAN_SHADOW_MASK) {
> +		u8 *shadow = (u8 *)kasan_mem_to_shadow((unsigned long)address
> +						+ size);
> +		*shadow = size & KASAN_SHADOW_MASK;
> +	}
> +}

There's a lot of typecasting happening with kasan_mem_to_shadow().  In
this patch the return value gets typecast more often than not, and the
argument gets cast quite a lot as well.  I suspect the code would turn
out better if kasan_mem_to_shadow() were to take a (const?) void* arg
and were to return a void*.

> +static __always_inline bool memory_is_poisoned_1(unsigned long addr)

What's with all the __always_inline in this file?  When I remove them
all, kasan.o .text falls from 8294 bytes down to 4543 bytes.  That's
massive, and quite possibly faster.

If there's some magical functional reason for this then can we please
get a nice prominent comment into this code apologetically explaining
it?

> +{
> +	s8 shadow_value = *(s8 *)kasan_mem_to_shadow(addr);
> +
> +	if (unlikely(shadow_value)) {
> +		s8 last_accessible_byte = addr & KASAN_SHADOW_MASK;
> +		return unlikely(last_accessible_byte >= shadow_value);
> +	}
> +
> +	return false;
> +}
> +
> 
> ...
>
> +
> +#define DECLARE_ASAN_CHECK(size)				\

DEFINE_ASAN_CHECK would be more accurate.  Because this macro expands
to definitions, not declarations.

> +	void __asan_load##size(unsigned long addr)		\
> +	{							\
> +		check_memory_region(addr, size, false);		\
> +	}							\
> +	EXPORT_SYMBOL(__asan_load##size);			\
> +	__attribute__((alias("__asan_load"#size)))		\
> +	void __asan_load##size##_noabort(unsigned long);	\
> +	EXPORT_SYMBOL(__asan_load##size##_noabort);		\
> +	void __asan_store##size(unsigned long addr)		\
> +	{							\
> +		check_memory_region(addr, size, true);		\
> +	}							\
> +	EXPORT_SYMBOL(__asan_store##size);			\
> +	__attribute__((alias("__asan_store"#size)))		\
> +	void __asan_store##size##_noabort(unsigned long);	\
> +	EXPORT_SYMBOL(__asan_store##size##_noabort)
> +
> +DECLARE_ASAN_CHECK(1);
> +DECLARE_ASAN_CHECK(2);
> +DECLARE_ASAN_CHECK(4);
> +DECLARE_ASAN_CHECK(8);
> +DECLARE_ASAN_CHECK(16);
> +
> +void __asan_loadN(unsigned long addr, size_t size)
> +{
> +	check_memory_region(addr, size, false);
> +}
> +EXPORT_SYMBOL(__asan_loadN);
> +
> +__attribute__((alias("__asan_loadN")))

Maybe we need a __alias.  Like __packed and various other helpers.

> +void __asan_loadN_noabort(unsigned long, size_t);
> +EXPORT_SYMBOL(__asan_loadN_noabort);
> +
> +void __asan_storeN(unsigned long addr, size_t size)
> +{
> +	check_memory_region(addr, size, true);
> +}
> +EXPORT_SYMBOL(__asan_storeN);
> +
> +__attribute__((alias("__asan_storeN")))
> +void __asan_storeN_noabort(unsigned long, size_t);
> +EXPORT_SYMBOL(__asan_storeN_noabort);
> +
> +/* to shut up compiler complaints */
> +void __asan_handle_no_return(void) {}
> +EXPORT_SYMBOL(__asan_handle_no_return);
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> new file mode 100644
> index 0000000..da0e53c
> --- /dev/null
> +++ b/mm/kasan/kasan.h
> @@ -0,0 +1,47 @@
> +#ifndef __MM_KASAN_KASAN_H
> +#define __MM_KASAN_KASAN_H
> +
> +#include <linux/kasan.h>
> +
> +#define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
> +#define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
> +
> +struct access_info {

kasan_access_info would be a better name.

> +	unsigned long access_addr;
> +	unsigned long first_bad_addr;
> +	size_t access_size;
> +	bool is_write;
> +	unsigned long ip;
> +};
> +
> +void kasan_report_error(struct access_info *info);
> +void kasan_report_user_access(struct access_info *info);
> +
> +static inline unsigned long kasan_shadow_to_mem(unsigned long shadow_addr)
> +{
> +	return (shadow_addr - KASAN_SHADOW_OFFSET) << KASAN_SHADOW_SCALE_SHIFT;
> +}
> +
> +static inline bool kasan_enabled(void)
> +{
> +	return !current->kasan_depth;
> +}
> +
> +static __always_inline void kasan_report(unsigned long addr,
> +					size_t size,
> +					bool is_write)

Again, why the inline?  This is presumably not a hotpath and
kasan_report has sixish call sites.


> +{
> +	struct access_info info;
> +
> +	if (likely(!kasan_enabled()))
> +		return;
> +
> +	info.access_addr = addr;
> +	info.access_size = size;
> +	info.is_write = is_write;
> +	info.ip = _RET_IP_;
> +	kasan_report_error(&info);
> +}
> 
> ...
>
> +static void print_error_description(struct access_info *info)
> +{
> +	const char *bug_type = "unknown crash";
> +	u8 shadow_val;
> +
> +	info->first_bad_addr = find_first_bad_addr(info->access_addr,
> +						info->access_size);
> +
> +	shadow_val = *(u8 *)kasan_mem_to_shadow(info->first_bad_addr);
> +
> +	switch (shadow_val) {
> +	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
> +		bug_type = "out of bounds access";
> +		break;
> +	}
> +
> +	pr_err("BUG: AddressSanitizer: %s in %pS at addr %p\n",

Sometimes it's called "kasan", sometimes "AddressSanitizer".  Wouldn't
it be better to use the same name everywhere?

> +		bug_type, (void *)info->ip,
> +		(void *)info->access_addr);
> +	pr_err("%s of size %zu by task %s/%d\n",
> +		info->is_write ? "Write" : "Read",
> +		info->access_size, current->comm, task_pid_nr(current));
> +}
> +
> +static void print_address_description(struct access_info *info)
> +{
> +	dump_stack();
> +}

dump_stack() uses KERN_INFO but the callers or
print_address_description() use KERN_ERR.  This means that at some
settings of `dmesg -n', the kasan output will have large missing
chunks.

Please test this and deide how bad it is.  A proper fix will be
somewhat messy (new_dump_stack(KERN_ERR)).

> +static bool row_is_guilty(unsigned long row, unsigned long guilty)
> +{
> +	return (row <= guilty) && (guilty < row + SHADOW_BYTES_PER_ROW);
> +}
> +
> +static int shadow_pointer_offset(unsigned long row, unsigned long shadow)
> +{
> +	/* The length of ">ff00ff00ff00ff00: " is
> +	 *    3 + (BITS_PER_LONG/8)*2 chars.
> +	 */
> +	return 3 + (BITS_PER_LONG/8)*2 + (shadow - row)*2 +
> +		(shadow - row) / SHADOW_BYTES_PER_BLOCK + 1;
> +}
> +
> +static void print_shadow_for_address(unsigned long addr)
> +{
> +	int i;
> +	unsigned long shadow = kasan_mem_to_shadow(addr);
> +	unsigned long aligned_shadow = round_down(shadow, SHADOW_BYTES_PER_ROW)
> +		- SHADOW_ROWS_AROUND_ADDR * SHADOW_BYTES_PER_ROW;

You don't *have* to initialize at the definition site.  You can do

	unsigned long aligned_shadow;
	...
	aligned_shadow = ...;

and the 80-col tricks often come out looking better.

> +	pr_err("Memory state around the buggy address:\n");
> +
> +	for (i = -SHADOW_ROWS_AROUND_ADDR; i <= SHADOW_ROWS_AROUND_ADDR; i++) {
> +		unsigned long kaddr = kasan_shadow_to_mem(aligned_shadow);
> +		char buffer[4 + (BITS_PER_LONG/8)*2];
> +
> +		snprintf(buffer, sizeof(buffer),
> +			(i == 0) ? ">%lx: " : " %lx: ", kaddr);
> +
> +		kasan_disable_local();
> +		print_hex_dump(KERN_ERR, buffer,
> +			DUMP_PREFIX_NONE, SHADOW_BYTES_PER_ROW, 1,
> +			(void *)aligned_shadow, SHADOW_BYTES_PER_ROW, 0);
> +		kasan_enable_local();
> +
> +		if (row_is_guilty(aligned_shadow, shadow))
> +			pr_err("%*c\n",
> +				shadow_pointer_offset(aligned_shadow, shadow),
> +				'^');
> +
> +		aligned_shadow += SHADOW_BYTES_PER_ROW;
> +	}
> +}
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
