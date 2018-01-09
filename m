Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 699816B0038
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 22:44:21 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id q4so8194000wre.14
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 19:44:21 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.18])
        by mx.google.com with ESMTPS id h130si8701889wme.230.2018.01.08.19.44.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jan 2018 19:44:19 -0800 (PST)
Message-ID: <1515469448.6766.12.camel@gmx.de>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
From: Mike Galbraith <efault@gmx.de>
Date: Tue, 09 Jan 2018 04:44:08 +0100
In-Reply-To: <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
References: <20171222084623.668990192@linuxfoundation.org>
	 <20171222084625.007160464@linuxfoundation.org>
	 <1515302062.6507.18.camel@gmx.de>
	 <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
	 <20180108174653.7muglyihpngxp5tl@black.fi.intel.com>
	 <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, kexec@lists.infradead.org

On Tue, 2018-01-09 at 03:13 +0300, Kirill A. Shutemov wrote:
> 
> Mike, could you test this? (On top of the rest of the fixes.)

homer:..crash/2018-01-09-04:25 # ll
total 1863604
-rw------- 1 root root      66255 Jan  9 04:25 dmesg.txt
-rw-r--r-- 1 root root        182 Jan  9 04:25 README.txt
-rw-r--r-- 1 root root    2818240 Jan  9 04:25 System.map-4.15.0.gb2cd1df-master
-rw------- 1 root root 1832914928 Jan  9 04:25 vmcore
-rw-r--r-- 1 root root   72514993 Jan  9 04:25 vmlinux-4.15.0.gb2cd1df-master.gz

Yup, all better.

> Sorry for the mess.

(why, developers not installing shiny new bugs is a whole lot worse:)

> From 100fd567754f1457be94732046aefca204c842d2 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Tue, 9 Jan 2018 02:55:47 +0300
> Subject: [PATCH] kdump: Write a correct address of mem_section into vmcoreinfo
> 
> Depending on configuration mem_section can now be an array or a pointer
> to an array allocated dynamically. In most cases, we can continue to refer
> to it as 'mem_section' regardless of what it is.
> 
> But there's one exception: '&mem_section' means "address of the array" if
> mem_section is an array, but if mem_section is a pointer, it would mean
> "address of the pointer".
> 
> We've stepped onto this in kdump code. VMCOREINFO_SYMBOL(mem_section)
> writes down address of pointer into vmcoreinfo, not array as we wanted.
> 
> Let's introduce VMCOREINFO_ARRAY() that would handle the situation
> correctly for both cases.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: 83e3c48729d9 ("mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y")
> ---
>  include/linux/crash_core.h | 2 ++
>  kernel/crash_core.c        | 2 +-
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/crash_core.h b/include/linux/crash_core.h
> index 06097ef30449..83ae04950269 100644
> --- a/include/linux/crash_core.h
> +++ b/include/linux/crash_core.h
> @@ -42,6 +42,8 @@ phys_addr_t paddr_vmcoreinfo_note(void);
>  	vmcoreinfo_append_str("PAGESIZE=%ld\n", value)
>  #define VMCOREINFO_SYMBOL(name) \
>  	vmcoreinfo_append_str("SYMBOL(%s)=%lx\n", #name, (unsigned long)&name)
> +#define VMCOREINFO_ARRAY(name) \
> +	vmcoreinfo_append_str("SYMBOL(%s)=%lx\n", #name, (unsigned long)name)
>  #define VMCOREINFO_SIZE(name) \
>  	vmcoreinfo_append_str("SIZE(%s)=%lu\n", #name, \
>  			      (unsigned long)sizeof(name))
> diff --git a/kernel/crash_core.c b/kernel/crash_core.c
> index b3663896278e..d4122a837477 100644
> --- a/kernel/crash_core.c
> +++ b/kernel/crash_core.c
> @@ -410,7 +410,7 @@ static int __init crash_save_vmcoreinfo_init(void)
>  	VMCOREINFO_SYMBOL(contig_page_data);
>  #endif
>  #ifdef CONFIG_SPARSEMEM
> -	VMCOREINFO_SYMBOL(mem_section);
> +	VMCOREINFO_ARRAY(mem_section);
>  	VMCOREINFO_LENGTH(mem_section, NR_SECTION_ROOTS);
>  	VMCOREINFO_STRUCT_SIZE(mem_section);
>  	VMCOREINFO_OFFSET(mem_section, section_mem_map);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
