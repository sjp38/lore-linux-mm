Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9EAE76B0038
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 02:42:19 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so113548147wia.0
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 23:42:19 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id bh5si16319528wib.110.2015.03.29.23.42.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 29 Mar 2015 23:42:17 -0700 (PDT)
Message-ID: <5518F030.4040003@nod.at>
Date: Mon, 30 Mar 2015 08:41:52 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<551164ED.5000907@nod.at>	<m2twxacw13.wl@sfc.wide.ad.jp>	<55117565.6080002@nod.at>	<m2sicuctb2.wl@sfc.wide.ad.jp>	<55118277.5070909@nod.at>	<m2bnjhcevt.wl@sfc.wide.ad.jp>	<55133BAF.30301@nod.at>	<m2h9t7bubh.wl@wide.ad.jp>	<5514560A.7040707@nod.at>	<m28uejaqyn.wl@wide.ad.jp>	<55152137.20405@nod.at> <m2sicnalnh.wl@sfc.wide.ad.jp>
In-Reply-To: <m2sicnalnh.wl@sfc.wide.ad.jp>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com, rusty@rustcorp.com.au, mathieu.lacage@gmail.com

Am 29.03.2015 um 17:06 schrieb Hajime Tazaki:
>> What about putting libos into tools/testing/ and make it much more generic and framework alike.
> 
> it's trivial though, libos is not only for the testing (i.e., NUSE).
> # of course tools/libos or something can be the place.

Yep, tool/libos is also perfectly fine.

>> With more generic I mean that libos could be a stubbing framework for the kernel.
>> i.e. you specify the subsystem you want to test/stub and the framework helps you doing so.
>> A lot of the stubs you're placing in arch/lib could be auto-generated as the
>> vast majority of all kernel methods you stub are no-ops which call only lib_assert(false).
> 
> the issue here is the decision between 'no-ops' and
> 'assert(false)' depends on the context. an auto-generated
> mechanism needs some hand-written parameters I think.

The questions is, why do you need stubs which are a no-op but not a
lib_assert(false).
Sounds more like these dependencies shouldn't be linked at all.
Same applies to lib_assert(false) stubs. If they must not get
called from libos better try hard to avoid these dependencies at all.

> one more concern on the out-of-arch-tree design is that how
> to handle our asm-generic-based header files
> (arch/lib/include/asm). we have been heavily used
> 'generic-y' in the Kbuild file to reuse header files.

As noted before, libos is something in between. Maybe the asm-generic
stuff needs some modifications to make it work for libos.

> OTOH, I agree with you on the point of auto-generated glues
> (stubs), or trying to avoid glues (reuse the originals as
> much as possible) as Antti mentioned. that will definitely
> be reduce the amount of maintenance effort.

BTW: There is something really fishy wrt to your build process.
I did a ARCH=i386 build due to my regular kernel work and later a ARCH=lib build.
It seems to pickup old/unrelated object files.
After a make clean ARCH=i386 it build fine.

---cut---
  LIB           liblinux-4.0.0-rc5.so
/usr/lib64/gcc/x86_64-suse-linux/4.8/../../../../x86_64-suse-linux/bin/ld: Warning: size of symbol `skb_copy_bits' changed from 10 in ./kernel/bpf/core.o to 441 in ./net/core/skbuff.o
./net/ipv6/fib6_rules.o: In function `fib6_rule_lookup':
/home/rw/linux/net/ipv6/fib6_rules.c:34: multiple definition of `fib6_rule_lookup'
./net/ipv6/ip6_fib.o:ip6_fib.c:(.text+0xd50): first defined here
/usr/lib64/gcc/x86_64-suse-linux/4.8/../../../../x86_64-suse-linux/bin/ld: i386 architecture of input file `./kernel/sysctl.o' is incompatible with i386:x86-64 output
/usr/lib64/gcc/x86_64-suse-linux/4.8/../../../../x86_64-suse-linux/bin/ld: i386 architecture of input file `./kernel/params.o' is incompatible with i386:x86-64 output
/usr/lib64/gcc/x86_64-suse-linux/4.8/../../../../x86_64-suse-linux/bin/ld: i386 architecture of input file `./kernel/notifier.o' is incompatible with i386:x86-64 output
/usr/lib64/gcc/x86_64-suse-linux/4.8/../../../../x86_64-suse-linux/bin/ld: i386 architecture of input file `./kernel/time/time.o' is incompatible with i386:x86-64 output
/usr/lib64/gcc/x86_64-suse-linux/4.8/../../../../x86_64-suse-linux/bin/ld: i386 architecture of input file `./kernel/rcu/update.o' is incompatible with i386:x86-64 output
/usr/lib64/gcc/x86_64-suse-linux/4.8/../../../../x86_64-suse-linux/bin/ld: i386 architecture of input file `./kernel/locking/mutex.o' is incompatible with i386:x86-64 output
/usr/lib64/gcc/x86_64-suse-linux/4.8/../../../../x86_64-suse-linux/bin/ld: i386 architecture of input file `./kernel/locking/semaphore.o' is incompatible with i386:x86-64 output
/usr/lib64/gcc/x86_64-suse-linux/4.8/../../../../x86_64-suse-linux/bin/ld: i386 architecture of input file `./kernel/locking/rwsem.o' is incompatible with i386:x86-64 output
/usr/lib64/gcc/x86_64-suse-linux/4.8/../../../../x86_64-suse-linux/bin/ld: i386 architecture of input file `./kernel/bpf/core.o' is incompatible with i386:x86-64 output
[...]
./kernel/rcu/update.o:(.ref.data+0x20): undefined reference to `trace_event_raw_init'
collect2: error: ld returned 1 exit status
arch/lib/Makefile:223: recipe for target 'liblinux-4.0.0-rc5.so' failed
make: *** [liblinux-4.0.0-rc5.so] Error 1
---cut---

While we're talking about the build process, how can I cross build libos?
Say a i386 libos on x86_64. For UML we have use SUBARCH.
i.e. make linux ARCH=um SUBARCH=i386

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
