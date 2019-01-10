Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA6F8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:03:53 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id f2so13016987qtg.14
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:03:53 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f194sor36894295qka.45.2019.01.10.13.03.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 13:03:52 -0800 (PST)
Message-ID: <1547154231.6911.10.camel@lca.pw>
Subject: Re: PROBLEM: syzkaller found / pool corruption-overwrite / page in
 user-area or NULL
From: Qian Cai <cai@lca.pw>
Date: Thu, 10 Jan 2019 16:03:51 -0500
In-Reply-To: <4u36JfbOrbu9CXLDErzQKvorP0gc2CzyGe60rBmZsGAGIw6RacZnIfoSsAF0I0TCnVx0OvcqCZFN6ntbgicJ66cWew9cOXRgcuWxSPdL3ko=@protonmail.ch>
References: 
	<t78EEfgpy3uIwPUvqvmuQEYEWKG9avWzjUD3EyR93Qaf_tfx1gqt4XplrqMgdxR1U9SsrVdA7G9XeUZacgUin0n6lBzoxJHVJ9Ko0yzzrxI=@protonmail.ch>
	 <1547150339.2814.9.camel@linux.ibm.com> <1547153074.6911.8.camel@lca.pw>
	 <4u36JfbOrbu9CXLDErzQKvorP0gc2CzyGe60rBmZsGAGIw6RacZnIfoSsAF0I0TCnVx0OvcqCZFN6ntbgicJ66cWew9cOXRgcuWxSPdL3ko=@protonmail.ch>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Esme <esploit@protonmail.ch>
Cc: James Bottomley <jejb@linux.ibm.com>, "dgilbert@interlog.com" <dgilbert@interlog.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 2019-01-10 at 20:47 +0000, Esme wrote:
> Sure thing;
> 
> cmdline;
> qemu-system-x86_64 -kernel linux//arch/x86/boot/bzImage -append console=ttyS0
> root=/dev/sda debug earlyprintk=serial slub_debug=QUZ -hda stretch.img -net
> user,hostfwd=tcp::10021-:22 -net nic -enable-kvm -nographic -m 2G -smp 2
> -pidfile
> 
> CONFIG_PAGE*; (full file attached);
> 
> # CONFIG_DEBUG_PAGEALLOC is not set
> CONFIG_PAGE_POISONING=y
> CONFIG_PAGE_POISONING_NO_SANITY=y
> # CONFIG_PAGE_POISONING_ZERO is not set
> # CONFIG_DEBUG_PAGE_REF is not set
> CONFIG_FAIL_PAGE_ALLOC=y

Confused.

https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1896410.html

It said 5.0.0-rc1+

https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1896410/repro.repor
t

It said 4.20.0+, and it also have,

"general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI"

which indicated CONFIG_DEBUG_PAGEALLOC=y but your .config said NO.

However, it looks like a mess that KASAN does not play well with all those
SLUB_DEBUG, CONFIG_DEBUG_PAGEALLOC etc, because it essentially step into each
others' toes by redzoning, poisoning in allocate and free pages.
