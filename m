Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 88D286006B4
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 23:34:42 -0400 (EDT)
Date: Tue, 20 Jul 2010 11:34:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/6] writeback: avoid unnecessary calculation of bdi
 dirty thresholds
Message-ID: <20100720033437.GE6087@localhost>
References: <20100711020656.340075560@intel.com>
 <20100711021748.879183413@intel.com>
 <20100719143520.d9af9649.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100719143520.d9af9649.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 20, 2010 at 05:35:20AM +0800, Andrew Morton wrote:
> On Sun, 11 Jul 2010 10:06:59 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > Split get_dirty_limits() into global_dirty_limits()+bdi_dirty_limit(),
> > so that the latter can be avoided when under global dirty background
> > threshold (which is the normal state for most systems).
> > 
> 
> mm/page-writeback.c: In function 'balance_dirty_pages_ratelimited_nr':
> mm/page-writeback.c:466: warning: 'dirty_exceeded' may be used uninitialized in this function
> 
> This was a real bug.

Thanks! But how do you catch this? There are no warnings in my compile test.

I noticed that there is a gcc option "-Wuninitialized", which will be turned on
with "-Wall" and "-O2" as used in the following command:

  gcc -Wp,-MD,mm/.page-writeback.o.d  -nostdinc -isystem /usr/lib/gcc/x86_64-linux-gnu/4.4.4/include -I/cc/linux-2.6.33/arch/x86/include -Iinclude  -include include/generated/autoconf.h -D__KERNEL__ -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -fno-delete-null-pointer-checks -O2 -m64 -march=core2 -mno-red-zone -mcmodel=kernel -funit-at-a-time -maccumulate-outgoing-args -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1 -pipe -Wno-sign-compare -fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -Wframe-larger-than=2048 -fno-stack-protector -fno-omit-frame-pointer -fno-optimize-sibling-calls -g -pg -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fno-dwarf2-cfi-asm -fconserve-stack   -D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(page_writeback)"  -D"KBUILD_MODNAME=KBUILD_STR(page_writeback)"  -c -o mm/page-writeback.o mm/page-writeback.c


My gcc version is 

$ gcc -v
Using built-in specs.
Target: x86_64-linux-gnu
Configured with: ../src/configure -v --with-pkgversion='Debian 4.4.4-6' --with-bugurl=file:///usr/share/doc/gcc-4.4/README.Bugs --ena
ble-languages=c,c++,fortran,objc,obj-c++ --prefix=/usr --enable-shared --enable-multiarch --enable-linker-build-id --with-system-zlib --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --with-gxx-include-dir=/usr/include/c++/4.4 --program-suffix=-4.4 --enable-nls --enable-clocale=gnu --enable-libstdcxx-debug --enable-objc-gc --with-arch-32=i586 --with-tune=generic --enable-checking=release --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu                                            Thread model: posix
gcc version 4.4.4 (Debian 4.4.4-6) 

Thanks,
Fengguang

> --- a/mm/page-writeback.c~writeback-avoid-unnecessary-calculation-of-bdi-dirty-thresholds-fix
> +++ a/mm/page-writeback.c
> @@ -463,7 +463,7 @@ static void balance_dirty_pages(struct a
>  	unsigned long bdi_thresh;
>  	unsigned long pages_written = 0;
>  	unsigned long pause = 1;
> -	int dirty_exceeded;
> +	bool dirty_exceeded = false;
>  	struct backing_dev_info *bdi = mapping->backing_dev_info;
>  
>  	for (;;) {
> _

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
