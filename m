Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 46F256B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 18:14:28 -0500 (EST)
Received: by wmuu63 with SMTP id u63so80032376wmu.0
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 15:14:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ch4si21584107wjb.109.2015.12.04.15.14.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 15:14:26 -0800 (PST)
Date: Fri, 4 Dec 2015 15:14:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 4174/4356] kernel/built-in.o:undefined
 reference to `mmap_rnd_bits'
Message-Id: <20151204151424.e73641da44c61f20f10d93e9@linux-foundation.org>
In-Reply-To: <201512050045.l2G9WhTi%fengguang.wu@intel.com>
References: <201512050045.l2G9WhTi%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Daniel Cashman <dcashman@google.com>, kbuild-all@01.org, Mark Brown <broonie@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, 5 Dec 2015 00:18:47 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   dcccebc04ddba852aad354270986d508e8f011c0
> commit: a8f025e63718534d6a9224a0b069b772ef21cb5d [4174/4356] arm: mm: support ARCH_MMAP_RND_BITS
> config: arm-vf610m4_defconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout a8f025e63718534d6a9224a0b069b772ef21cb5d
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm 
> 
> All errors (new ones prefixed by >>):
> 
> >> kernel/built-in.o:(.data+0x754): undefined reference to `mmap_rnd_bits'
> >> kernel/built-in.o:(.data+0x76c): undefined reference to `mmap_rnd_bits_min'
> >> kernel/built-in.o:(.data+0x770): undefined reference to `mmap_rnd_bits_max'

OK, the patches are pretty broken when HAVE_ARCH_MMAP_RND_BITS=n.  I
guess a pile of new ifdefs need adding for this case.

There's also the matter of CONFIG_MMU=n.  mm/mmap.o doesn't get
included in the build in this case, so that will also break things.  I
suggest that can be fixed by making HAVE_ARCH_MMAP_RND_BITS and
HAVE_ARCH_MMAP_RND_COMPAT_BITS depend on MMU.  That should fix things
up when combined with the new ifdef-sprinkling.

This stuff is going to break quite a lot of test builds so I think I'll
consolidate the patches then drop 'em for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
