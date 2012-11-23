Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 8EEE96B004D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 16:26:04 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so2801919dak.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2012 13:26:03 -0800 (PST)
Date: Fri, 23 Nov 2012 13:25:59 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: percpu section failure with Gold linker
Message-ID: <20121123212559.GW15971@htj.dyndns.org>
References: <alpine.LNX.2.01.1211232136380.11359@nerf07.vanv.qr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1211232136380.11359@nerf07.vanv.qr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Engelhardt <jengelh@inai.de>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hello, Jan.

On Fri, Nov 23, 2012 at 09:44:02PM +0100, Jan Engelhardt wrote:
> when compiling a kernel with the gold linker (3.7.0-rc6 26d29d06ea0204, 
> gcc-4.7 and binutils-2.23 in my case), certain pcpu symbols are 
> seemingly errneously copied over from .o files to .ko files, leading to 
> a hard warning during depmod:
> 
> 	gold$ make -j8 LD=gold HOSTLD=gold
> 	gold$ make modules_install INSTALL_MOD_PATH=/tmp/foo
> 	[...]
> 	WARNING: /tmp/foo/lib/modules/3.7.0-rc6-jng6-default+
> 	/kernel/net/rds/rds_tcp.ko needs unknown symbol
> 	__pcpu_scope_rds_tcp_stats

Yeah, this is from the nasty tricks percpu plays to get percpu decls
working on s390 and alpha.  Take a look at
DECLARE/DEFINE_PER_CPU_SECTION() definitions in
include/linux/percpu-defs.h for details.

> This happens with many modules using percpu; looking at things with nm 
> reveals:
> 
> 	gold/net/ipv6$ nm ipv6.o | grep __pcpu_
> 	0000000000000000 D __pcpu_unique_ipv6_cookie_scratch
> 	gold/net/ipv6$ nm ipv6.ko | grep __pcpu_
> 	                 U __pcpu_unique_ipv6_cookie_scratch
> 
> On the other hand, in a linux tree built with the original ld (ld.bfd), 
> things look like:
> 
> 	bfd$ make -j8
> 	[...]
> 	bfd/net/ipv6$ nm ipv6.o | grep pcpu
> 	0000000000000000 D __pcpu_unique_ipv6_cookie_scratch
> 	bfd/net/ipv6$ nm ipv6.ko | grep pcpu
> 	(no result)

So, those __pcpu_unique and __pcpu_scope variables are only used so
that multiple copy of them collide with each other and trigger compile
failure (as the actual percpu variable needs to be declared __weak).
They're all put into .discard section, so should go away once it
passes through the linker.  gold left reference to that symbol while
discarding the definition.  Hmmm... different interpretation of
.discard?  Still weird tho.  There's nothing dereferencing that
symbol.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
