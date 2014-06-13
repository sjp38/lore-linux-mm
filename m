Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id B029D6B007D
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 00:56:01 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id u57so2159252wes.5
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 21:56:01 -0700 (PDT)
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
        by mx.google.com with ESMTPS id dr2si208285wid.14.2014.06.12.21.55.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 21:56:00 -0700 (PDT)
Received: by mail-wg0-f47.google.com with SMTP id k14so2127249wgh.6
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 21:55:59 -0700 (PDT)
Date: Fri, 13 Jun 2014 07:55:55 +0300
From: Dan Aloni <dan@kernelim.com>
Subject: Re: mm/sched/net: BUG when running simple code
Message-ID: <20140613045555.GB20729@gmail.com>
References: <539A6850.4090408@oracle.com>
 <20140613032754.GA20729@gmail.com>
 <539A77A1.60700@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <539A77A1.60700@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Fri, Jun 13, 2014 at 12:01:37AM -0400, Sasha Levin wrote:
> On 06/12/2014 11:27 PM, Dan Aloni wrote:
> > On Thu, Jun 12, 2014 at 10:56:16PM -0400, Sasha Levin wrote:
> >> > Hi all,
> >> > 
> >> > Okay, I'm really lost. I got the following when fuzzing, and can't really explain what's
> >> > going on. It seems that we get a "unable to handle kernel paging request" when running
> >> > rather simple code, and I can't figure out how it would cause it.
> > [..]
> >> > Which agrees with the trace I got:
> >> > 
> >> > [  516.309720] BUG: unable to handle kernel paging request at ffffffffa0f12560
> >> > [  516.309720] IP: netlink_getsockopt (net/netlink/af_netlink.c:2271)
> > [..]
> >> > [  516.309720] RIP netlink_getsockopt (net/netlink/af_netlink.c:2271)
> >> > [  516.309720]  RSP <ffff8803fc85fed8>
> >> > [  516.309720] CR2: ffffffffa0f12560
> >> > 
> >> > They only theory I had so far is that netlink is a module, and has gone away while the code
> >> > was executing, but netlink isn't a module on my kernel.
> > The RIP - 0xffffffffa0f12560 is in the range (from Documentation/x86/x86_64/mm.txt):
> > 
> >     ffffffffa0000000 - ffffffffff5fffff (=1525 MB) module mapping space
> > 
> > So seems it was in a module.
> 
> Yup, that's why that theory came up, but when I checked my config:
> 
> $ cat .config | grep NETLINK
> CONFIG_COMPAT_NETLINK_MESSAGES=y
> CONFIG_NETFILTER_NETLINK=y
> CONFIG_NETFILTER_NETLINK_ACCT=y
> CONFIG_NETFILTER_NETLINK_QUEUE=y
> CONFIG_NETFILTER_NETLINK_LOG=y
> CONFIG_NF_CT_NETLINK=y
> CONFIG_NF_CT_NETLINK_TIMEOUT=y
> CONFIG_NF_CT_NETLINK_HELPER=y
> CONFIG_NETFILTER_NETLINK_QUEUE_CT=y
> CONFIG_NETLINK_MMAP=y
> CONFIG_NETLINK_DIAG=y
> CONFIG_SCSI_NETLINK=y
> CONFIG_QUOTA_NETLINK_INTERFACE=y
> 
> that theory went away. (also confirmed by not finding a netlink module.)
> 
> What about the kernel .text overflowing into the modules space? The loader
> checks for that, but can something like that happen after everything is
> up and running? I'll look into that tomorrow.

The kernel .text needs to be more than 512MB for the overlap to happen. 

    ffffffff80000000 - ffffffffa0000000 (=512 MB)  kernel text mapping, from phys 0

Also, it is bizarre that symbol resolution resolved ffffffffa0f12560 to 
a symbol that is in module space where af_netlink.o is surely not because of 
"obj-y := af_netlink.o" in the Makefile. 

What does your /proc/kallsyms show when sorted with regards to the symbols
in question?

Also curious are the addresses you have on the stack:

> [  516.309720] Stack:
> [  516.309720]  ffff8803fc85ff18 ffff8803fc85ff18 ffff8803fc85fef8 8900200549908020
> [  516.309720]  ffff8803fc85ff18 ffffffff9ff66470 ffff8803fc85ff18 0000000000000037
> [  516.309720]  ffff8803fc85ff78 ffffffff9ff69d26 0000000000000037 0000000000000004

0xffffffff9ff69d26 is just a small space before the beginning of the module 
mapping space, at the end of the kernel text mapping. Unless there are 
some tricks on those mappings, they should be unused, or perhaps 
CONFIG_DEBUG_PAGEALLOC is at play here?

And also, the Oops code of 0003 (PF_WRITE and PF_USER) might hint at
what Dave wrote.

-- 
Dan Aloni

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
