Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 24CB06B006C
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 00:14:11 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u56so2073727wes.8
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 21:14:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id yx7si4624600wjc.120.2014.06.12.21.14.08
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 21:14:10 -0700 (PDT)
Date: Fri, 13 Jun 2014 00:13:31 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: mm/sched/net: BUG when running simple code
Message-ID: <20140613041331.GA31688@redhat.com>
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
Cc: Dan Aloni <dan@kernelim.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

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
 > ... 
 > that theory went away. (also confirmed by not finding a netlink module.)
 > 
 > What about the kernel .text overflowing into the modules space? The loader
 > checks for that, but can something like that happen after everything is
 > up and running? I'll look into that tomorrow.

another theory: Trinity can sometimes generate plausible looking module
addresses and pass those in structs etc.

I wonder if there's somewhere in that path that isn't checking that the address
in the optval it got is actually a userspace address before it tries to write to it.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
