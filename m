Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BCA9D6B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 05:46:08 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3E9k5Qw029120
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Apr 2010 18:46:05 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BDD3245DE50
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 18:46:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 888E545DE54
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 18:46:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 26E771DB8040
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 18:46:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 97D511DB803F
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 18:46:03 +0900 (JST)
Date: Wed, 14 Apr 2010 18:42:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-Id: <20100414184213.f6bf11a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <w2u28c262361004140019pd8fe696ez609ece4a35527658@mail.gmail.com>
References: <20100414135945.2b0a1e0d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414054144.GH2493@dastard>
	<20100414145056.D147.A69D9226@jp.fujitsu.com>
	<y2x28c262361004132313r1e2ca71frd042d5460d897730@mail.gmail.com>
	<w2u28c262361004140019pd8fe696ez609ece4a35527658@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Apr 2010 16:19:02 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed, Apr 14, 2010 at 3:13 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> > On Wed, Apr 14, 2010 at 2:54 PM, KOSAKI Motohiro
> > <kosaki.motohiro@jp.fujitsu.com> wrote:
> >>> On Wed, Apr 14, 2010 at 01:59:45PM +0900, KAMEZAWA Hiroyuki wrote:
> >>> > On Wed, 14 Apr 2010 11:40:41 +1000
> >>> > Dave Chinner <david@fromorbit.com> wrote:
> >>> >
> >>> > > A 50) A  A  3168 A  A  A 64 A  xfs_vm_writepage+0xab/0x160 [xfs]
> >>> > > A 51) A  A  3104 A  A  384 A  shrink_page_list+0x65e/0x840
> >>> > > A 52) A  A  2720 A  A  528 A  shrink_zone+0x63f/0xe10
> >>> >
> >>> > A bit OFF TOPIC.
> >>> >
> >>> > Could you share disassemble of shrink_zone() ?
> >>> >
> >>> > In my environ.
> >>> > 00000000000115a0 <shrink_zone>:
> >>> > A  A 115a0: A  A  A  55 A  A  A  A  A  A  A  A  A  A  A push A  %rbp
> >>> > A  A 115a1: A  A  A  48 89 e5 A  A  A  A  A  A  A  A mov A  A %rsp,%rbp
> >>> > A  A 115a4: A  A  A  41 57 A  A  A  A  A  A  A  A  A  push A  %r15
> >>> > A  A 115a6: A  A  A  41 56 A  A  A  A  A  A  A  A  A  push A  %r14
> >>> > A  A 115a8: A  A  A  41 55 A  A  A  A  A  A  A  A  A  push A  %r13
> >>> > A  A 115aa: A  A  A  41 54 A  A  A  A  A  A  A  A  A  push A  %r12
> >>> > A  A 115ac: A  A  A  53 A  A  A  A  A  A  A  A  A  A  A push A  %rbx
> >>> > A  A 115ad: A  A  A  48 83 ec 78 A  A  A  A  A  A  sub A  A $0x78,%rsp
> >>> > A  A 115b1: A  A  A  e8 00 00 00 00 A  A  A  A  A callq A 115b6 <shrink_zone+0x16>
> >>> > A  A 115b6: A  A  A  48 89 75 80 A  A  A  A  A  A  mov A  A %rsi,-0x80(%rbp)
> >>> >
> >>> > disassemble seems to show 0x78 bytes for stack. And no changes to %rsp
> >>> > until retrun.
> >>>
> >>> I see the same. I didn't compile those kernels, though. IIUC,
> >>> they were built through the Ubuntu build infrastructure, so there is
> >>> something different in terms of compiler, compiler options or config
> >>> to what we are both using. Most likely it is the compiler inlining,
> >>> though Chris's patches to prevent that didn't seem to change the
> >>> stack usage.
> >>>
> >>> I'm trying to get a stack trace from the kernel that has shrink_zone
> >>> in it, but I haven't succeeded yet....
> >>
> >> I also got 0x78 byte stack usage. Umm.. Do we discussed real issue now?
> >>
> >
> > In my case, 0x110 byte in 32 bit machine.
> > I think it's possible in 64 bit machine.
> >
> > 00001830 <shrink_zone>:
> > A  A 1830: A  A  A  55 A  A  A  A  A  A  A  A  A  A  A push A  %ebp
> > A  A 1831: A  A  A  89 e5 A  A  A  A  A  A  A  A  A  mov A  A %esp,%ebp
> > A  A 1833: A  A  A  57 A  A  A  A  A  A  A  A  A  A  A push A  %edi
> > A  A 1834: A  A  A  56 A  A  A  A  A  A  A  A  A  A  A push A  %esi
> > A  A 1835: A  A  A  53 A  A  A  A  A  A  A  A  A  A  A push A  %ebx
> > A  A 1836: A  A  A  81 ec 10 01 00 00 A  A  A  sub A  A $0x110,%esp
> > A  A 183c: A  A  A  89 85 24 ff ff ff A  A  A  mov A  A %eax,-0xdc(%ebp)
> > A  A 1842: A  A  A  89 95 20 ff ff ff A  A  A  mov A  A %edx,-0xe0(%ebp)
> > A  A 1848: A  A  A  89 8d 1c ff ff ff A  A  A  mov A  A %ecx,-0xe4(%ebp)
> > A  A 184e: A  A  A  8b 41 04 A  A  A  A  A  A  A  A mov A  A 0x4(%ecx)
> >
> > my gcc is following as.
> >
> > barrios@barriostarget:~/mmotm$ gcc -v
> > Using built-in specs.
> > Target: i486-linux-gnu
> > Configured with: ../src/configure -v --with-pkgversion='Ubuntu
> > 4.3.3-5ubuntu4'
> > --with-bugurl=file:///usr/share/doc/gcc-4.3/README.Bugs
> > --enable-languages=c,c++,fortran,objc,obj-c++ --prefix=/usr
> > --enable-shared --with-system-zlib --libexecdir=/usr/lib
> > --without-included-gettext --enable-threads=posix --enable-nls
> > --with-gxx-include-dir=/usr/include/c++/4.3 --program-suffix=-4.3
> > --enable-clocale=gnu --enable-libstdcxx-debug --enable-objc-gc
> > --enable-mpfr --enable-targets=all --with-tune=generic
> > --enable-checking=release --build=i486-linux-gnu --host=i486-linux-gnu
> > --target=i486-linux-gnu
> > Thread model: posix
> > gcc version 4.3.3 (Ubuntu 4.3.3-5ubuntu4)
> >
> >
> > Is it depends on config?
> > I attach my config.
> 
> I changed shrink list by noinline_for_stack.
> The result is following as.
> 
> 
> 00001fe0 <shrink_zone>:
>     1fe0:       55                      push   %ebp
>     1fe1:       89 e5                   mov    %esp,%ebp
>     1fe3:       57                      push   %edi
>     1fe4:       56                      push   %esi
>     1fe5:       53                      push   %ebx
>     1fe6:       83 ec 4c                sub    $0x4c,%esp
>     1fe9:       89 45 c0                mov    %eax,-0x40(%ebp)
>     1fec:       89 55 bc                mov    %edx,-0x44(%ebp)
>     1fef:       89 4d b8                mov    %ecx,-0x48(%ebp)
> 
> 0x110 -> 0x4c.
> 
> Should we have to add noinline_for_stack for shrink_list?
> 

Hmm. about shirnk_zone(), I don't think uninlining functions directly called
by shrink_zone() can be a help.
Total stack size of call-chain will be still big.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
