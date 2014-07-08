Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 77A1B6B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 16:27:30 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hi2so1753586wib.2
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 13:27:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z2si55460668wjz.98.2014.07.08.13.27.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jul 2014 13:27:29 -0700 (PDT)
Date: Tue, 8 Jul 2014 16:27:23 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [next:master 284/380] cpu_pm.c:undefined reference to
 `crypto_alloc_shash'
Message-ID: <20140708202723.GB18382@redhat.com>
References: <53b516e4.rgxkJyIm0d6ktGNY%fengguang.wu@intel.com>
 <20140707120414.2cb6c1da2b71a91c24ced4aa@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140707120414.2cb6c1da2b71a91c24ced4aa@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Mon, Jul 07, 2014 at 12:04:14PM -0700, Andrew Morton wrote:
> On Thu, 03 Jul 2014 16:40:04 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > head:   0e9ce823ad7bc6b85c279223ae6638d47089461e
> > commit: ba0dc4038c9fec5fa2f94756065f02b8011f270b [284/380] kexec: load and relocate purgatory at kernel load time
> > config: make ARCH=arm nuc950_defconfig
> > 
> > All error/warnings:
> > 
> >    kernel/built-in.o: In function `sys_kexec_file_load':
> > >> cpu_pm.c:(.text+0x4a580): undefined reference to `crypto_alloc_shash'
> > >> cpu_pm.c:(.text+0x4a654): undefined reference to `crypto_shash_update'
> > >> cpu_pm.c:(.text+0x4a698): undefined reference to `crypto_shash_update'
> > >> cpu_pm.c:(.text+0x4a778): undefined reference to `crypto_shash_final'
> 
> yup, kexec now requires crypto but the patch only fixes x86's Kconfig.
> 
> Was selecting crypto the correct decision?  Is there no case for using
> kexec without this signing capability?

Hi Andrew,

CRYPTO is required even without signing capability. kexec caculates the
sha256 hashes of loaded segments and just before jumping to next kernel
is recalculates the digests and matches with the stored ones to make
sure there is no data corruption.

So far user space used to do it and now we have moved that functionality in
kernel space hence kexec functionality becomes dependent on crypto.

Admittedly that this dependency is required only for new syscall and not
the old one. I did not create a config option for new syscall. So as a 
side affect old syscall also becomes dependent on crypto.

Creating more config option soon becomes cumbersome and anyway plan is
that in long term old syscall will give way to new syscall. So I felt it
is better not to create a config option for new syscall (until and unless
it becomes clear that a separate config option is a good idea).

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
