Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE706B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 23:18:28 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id r2so3705264igi.12
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 20:18:27 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id b2si23321712icl.16.2014.06.16.20.18.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 20:18:27 -0700 (PDT)
Message-ID: <539FB363.1070302@oracle.com>
Date: Mon, 16 Jun 2014 23:17:55 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm/sched/net: BUG when running simple code
References: <539A6850.4090408@oracle.com> <20140613032754.GA20729@gmail.com> <539A77A1.60700@oracle.com> <20140613041331.GA31688@redhat.com>
In-Reply-To: <20140613041331.GA31688@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Dan Aloni <dan@kernelim.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

On 06/13/2014 12:13 AM, Dave Jones wrote:
> On Fri, Jun 13, 2014 at 12:01:37AM -0400, Sasha Levin wrote:
>  > On 06/12/2014 11:27 PM, Dan Aloni wrote:
>  > > On Thu, Jun 12, 2014 at 10:56:16PM -0400, Sasha Levin wrote:
>  > >> > Hi all,
>  > >> > 
>  > >> > Okay, I'm really lost. I got the following when fuzzing, and can't really explain what's
>  > >> > going on. It seems that we get a "unable to handle kernel paging request" when running
>  > >> > rather simple code, and I can't figure out how it would cause it.
>  > > [..]
>  > >> > Which agrees with the trace I got:
>  > >> > 
>  > >> > [  516.309720] BUG: unable to handle kernel paging request at ffffffffa0f12560
>  > >> > [  516.309720] IP: netlink_getsockopt (net/netlink/af_netlink.c:2271)
>  > > [..]
>  > >> > [  516.309720] RIP netlink_getsockopt (net/netlink/af_netlink.c:2271)
>  > >> > [  516.309720]  RSP <ffff8803fc85fed8>
>  > >> > [  516.309720] CR2: ffffffffa0f12560
>  > >> > 
>  > >> > They only theory I had so far is that netlink is a module, and has gone away while the code
>  > >> > was executing, but netlink isn't a module on my kernel.
>  > > The RIP - 0xffffffffa0f12560 is in the range (from Documentation/x86/x86_64/mm.txt):
>  > > 
>  > >     ffffffffa0000000 - ffffffffff5fffff (=1525 MB) module mapping space
>  > > 
>  > > So seems it was in a module.
>  > 
>  > Yup, that's why that theory came up, but when I checked my config:
>  > ... 
>  > that theory went away. (also confirmed by not finding a netlink module.)
>  > 
>  > What about the kernel .text overflowing into the modules space? The loader
>  > checks for that, but can something like that happen after everything is
>  > up and running? I'll look into that tomorrow.
> 
> another theory: Trinity can sometimes generate plausible looking module
> addresses and pass those in structs etc.
> 
> I wonder if there's somewhere in that path that isn't checking that the address
> in the optval it got is actually a userspace address before it tries to write to it.

It happened again, and this time I've left the kernel addresses in, and it's quite
interesting:

[   88.837926] Call Trace:
[   88.837926]  [<ffffffff9ff6a792>] __sock_create+0x292/0x3c0
[   88.837926]  [<ffffffff9ff6a610>] ? __sock_create+0x110/0x3c0
[   88.837926]  [<ffffffff9ff6a920>] sock_create+0x30/0x40
[   88.837926]  [<ffffffff9ff6ad4c>] SyS_socket+0x2c/0x70
[   88.837926]  [<ffffffffa0561c30>] ? tracesys+0x7e/0xe6
[   88.837926]  [<ffffffffa0561c93>] tracesys+0xe1/0xe6

tracesys() seems to live inside a module space here?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
