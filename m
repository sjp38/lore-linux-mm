Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 27F966B008A
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 01:26:36 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id k48so1461919wev.6
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 22:26:35 -0700 (PDT)
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
        by mx.google.com with ESMTPS id s8si4831175wjq.101.2014.06.12.22.26.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 22:26:34 -0700 (PDT)
Received: by mail-we0-f171.google.com with SMTP id q58so2217471wes.2
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 22:26:34 -0700 (PDT)
Date: Fri, 13 Jun 2014 08:26:30 +0300
From: Dan Aloni <dan@kernelim.com>
Subject: Re: mm/sched/net: BUG when running simple code
Message-ID: <20140613052630.GA23945@gmail.com>
References: <539A6850.4090408@oracle.com>
 <20140613032754.GA20729@gmail.com>
 <539A77A1.60700@oracle.com>
 <20140613045555.GB20729@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140613045555.GB20729@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Fri, Jun 13, 2014 at 07:55:55AM +0300, Dan Aloni wrote:
> > that theory went away. (also confirmed by not finding a netlink module.)
> > 
> > What about the kernel .text overflowing into the modules space? The loader
> > checks for that, but can something like that happen after everything is
> > up and running? I'll look into that tomorrow.
> 
> The kernel .text needs to be more than 512MB for the overlap to happen. 
> 
>     ffffffff80000000 - ffffffffa0000000 (=512 MB)  kernel text mapping, from phys 0
> 
> Also, it is bizarre that symbol resolution resolved ffffffffa0f12560 to 
> a symbol that is in module space where af_netlink.o is surely not because of 
> "obj-y := af_netlink.o" in the Makefile. 
> 
> What does your /proc/kallsyms show when sorted with regards to the symbols
> in question?
> 
> Also curious are the addresses you have on the stack:
> 
> > [  516.309720] Stack:
> > [  516.309720]  ffff8803fc85ff18 ffff8803fc85ff18 ffff8803fc85fef8 8900200549908020
> > [  516.309720]  ffff8803fc85ff18 ffffffff9ff66470 ffff8803fc85ff18 0000000000000037
> > [  516.309720]  ffff8803fc85ff78 ffffffff9ff69d26 0000000000000037 0000000000000004
>[..]

Oh, just figured about the new kASLR feature that got enabled
recently, it explains the addresses, but there was supposed to be a
line for it in the Oops, so I'm puzzled.

-- 
Dan Aloni

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
