Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 00D4E6B0006
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 14:12:14 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 31-v6so7049599plf.19
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 11:12:14 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z6-v6si10945592pgo.364.2018.06.30.11.12.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jun 2018 11:12:13 -0700 (PDT)
Date: Sat, 30 Jun 2018 11:12:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: /tmp/cctnQ1CM.s:35: Error: .err encountered
Message-Id: <20180630111210.ec9de2c2923a0c58b1357965@linux-foundation.org>
In-Reply-To: <20180630110720.c80f060abe6d163eef78e9a6@linux-foundation.org>
References: <201806301538.bewm1wka%fengguang.wu@intel.com>
	<CACT4Y+b+7T3M=5EbHSpJmMAkRQnXih2+JZqeAvxht2zzKyjD2A@mail.gmail.com>
	<20180630110720.c80f060abe6d163eef78e9a6@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, kbuild test robot <lkp@intel.com>, kbuild-all@01.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, 30 Jun 2018 11:07:20 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> On Sat, 30 Jun 2018 12:27:09 +0200 Dmitry Vyukov <dvyukov@google.com> wrote:
> 
> > > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> > > head:   1904148a361a07fb2d7cba1261d1d2c2f33c8d2e
> > > commit: 758517202bd2e427664857c9f2aa59da36848aca arm: port KCOV to arm
> > > date:   2 weeks ago
> > > config: arm-allmodconfig (attached as .config)
> > > compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
> > > reproduce:
> > >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> > >         chmod +x ~/bin/make.cross
> > >         git checkout 758517202bd2e427664857c9f2aa59da36848aca
> > >         # save the attached .config to linux build tree
> > >         GCC_VERSION=7.2.0 make.cross ARCH=arm
> > >
> > > All errors (new ones prefixed by >>):
> > >
> > >    /tmp/cctnQ1CM.s: Assembler messages:
> > >>> /tmp/cctnQ1CM.s:35: Error: .err encountered
> > >    /tmp/cctnQ1CM.s:36: Error: .err encountered
> > >    /tmp/cctnQ1CM.s:37: Error: .err encountered
> > 
> > Hi kbuild test robot,
> > 
> > The fix was mailed more than a month ago, but still not merged into
> > the tree. That's linux...
> 
> That was a rather unhelpful email.
> 
> I've just scanned all your lkml emails since the start of May and
> cannot find anything which looks like a fix for this issue.
> 
> Please resend.   About three weks ago :(

OK, with a bi of amazing sleuthing I found this from Arnd, which is what
I presume you're referring to?



From: Arnd Bergmann <arnd@arndb.de>
Subject: ARM: disable KCOV for trusted foundations code

The ARM trusted foundations code is currently broken in linux-next when
CONFIG_KCOV_INSTRUMENT_ALL is set:

/tmp/ccHdQsCI.s: Assembler messages:
/tmp/ccHdQsCI.s:37: Error: .err encountered
/tmp/ccHdQsCI.s:38: Error: .err encountered
/tmp/ccHdQsCI.s:39: Error: .err encountered
scripts/Makefile.build:311: recipe for target 'arch/arm/firmware/trusted_foundations.o' failed

I could not find a function attribute that lets me disable
-fsanitize-coverage=trace-pc for just one function, so this turns it off
for the entire file instead.

Link: http://lkml.kernel.org/r/20180529103636.1535457-1-arnd@arndb.de
Fixes: 758517202bd2e4 ("arm: port KCOV to arm")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---


diff -puN arch/arm/firmware/Makefile~arm-disable-kcov-for-trusted-foundations-code arch/arm/firmware/Makefile
--- a/arch/arm/firmware/Makefile~arm-disable-kcov-for-trusted-foundations-code
+++ a/arch/arm/firmware/Makefile
@@ -1 +1,4 @@
 obj-$(CONFIG_TRUSTED_FOUNDATIONS)	+= trusted_foundations.o
+
+# tf_generic_smc() fails to build with -fsanitize-coverage=trace-pc
+KCOV_INSTRUMENT                := n
_
