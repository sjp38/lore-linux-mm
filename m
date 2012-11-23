Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 440896B0044
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 15:44:04 -0500 (EST)
Date: Fri, 23 Nov 2012 21:44:02 +0100 (CET)
From: Jan Engelhardt <jengelh@inai.de>
Subject: percpu section failure with Gold linker
Message-ID: <alpine.LNX.2.01.1211232136380.11359@nerf07.vanv.qr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, cl@linux-foundation.org
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi,


when compiling a kernel with the gold linker (3.7.0-rc6 26d29d06ea0204, 
gcc-4.7 and binutils-2.23 in my case), certain pcpu symbols are 
seemingly errneously copied over from .o files to .ko files, leading to 
a hard warning during depmod:

	gold$ make -j8 LD=gold HOSTLD=gold
	gold$ make modules_install INSTALL_MOD_PATH=/tmp/foo
	[...]
	WARNING: /tmp/foo/lib/modules/3.7.0-rc6-jng6-default+
	/kernel/net/rds/rds_tcp.ko needs unknown symbol
	__pcpu_scope_rds_tcp_stats

This happens with many modules using percpu; looking at things with nm 
reveals:

	gold/net/ipv6$ nm ipv6.o | grep __pcpu_
	0000000000000000 D __pcpu_unique_ipv6_cookie_scratch
	gold/net/ipv6$ nm ipv6.ko | grep __pcpu_
	                 U __pcpu_unique_ipv6_cookie_scratch

On the other hand, in a linux tree built with the original ld (ld.bfd), 
things look like:

	bfd$ make -j8
	[...]
	bfd/net/ipv6$ nm ipv6.o | grep pcpu
	0000000000000000 D __pcpu_unique_ipv6_cookie_scratch
	bfd/net/ipv6$ nm ipv6.ko | grep pcpu
	(no result)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
