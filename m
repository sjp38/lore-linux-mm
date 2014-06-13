Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5F30A6B0038
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 11:14:17 -0400 (EDT)
Received: by mail-yk0-f180.google.com with SMTP id 131so2122002ykp.25
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 08:14:17 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a45si6230846yhf.58.2014.06.13.08.14.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 08:14:16 -0700 (PDT)
Message-ID: <539B152A.5030801@oracle.com>
Date: Fri, 13 Jun 2014 11:13:46 -0400
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

This is, the access happened way before touching optval. The only thing that happened
before is reading optlen from userspace, but that happened using get_user() which should
mean that it was safe.

According to that trace, we died when *executing* a piece of code, not when accessing
some other memory. None of the instructions around the instruction we failed on don't
touch memory at all for that matter.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
