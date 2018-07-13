Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED12A6B0269
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:58:15 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t19-v6so20652109plo.9
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:58:15 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d8-v6si16792266pgn.382.2018.07.13.16.58.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 16:58:14 -0700 (PDT)
Date: Fri, 13 Jul 2018 16:58:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Instability in current -git tree
Message-Id: <20180713165812.ec391548ffeead96725d044c@linux-foundation.org>
In-Reply-To: <CA+55aFxAZr8PHo-raTihr8TKK_D-fVL+k6_tw_UyDLychowFNw@mail.gmail.com>
References: <CA+55aFyARQV302+mXNYznrOOjzW+yxbcv+=OkD43dG6G1ktoMQ@mail.gmail.com>
	<alpine.DEB.2.21.1807140031440.2644@nanos.tec.linutronix.de>
	<CA+55aFzBx1haeM2QSFvhaW2t_HVK78Y=bKvsiJmOZztwkZ-y7Q@mail.gmail.com>
	<CA+55aFzVGa57apuzDMBLgWQQRcm3BNBs1UEg-G_2o7YW1i=o2Q@mail.gmail.com>
	<CA+55aFy9NJZeqT7h_rAgbKUZLjzfxvDPwneFQracBjVhY53aQQ@mail.gmail.com>
	<20180713164804.fc2c27ccbac4c02ca2c8b984@linux-foundation.org>
	<CA+55aFxAZr8PHo-raTihr8TKK_D-fVL+k6_tw_UyDLychowFNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@redhat.com>, Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Miller <davem@davemloft.net>, Al Viro <viro@zeniv.linux.org.uk>, Dave Airlie <airlied@gmail.com>, Tejun Heo <tj@kernel.org>, Ted Ts'o <tytso@google.com>, Mike Snitzer <snitzer@redhat.com>, linux-mm <linux-mm@kvack.org>, Daniel Vacek <neelx@redhat.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Mel Gorman <mgorman@techsingularity.net>

On Fri, 13 Jul 2018 16:51:39 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Fri, Jul 13, 2018 at 4:48 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > (But it would be interesting to see whether removing the check "fixes" it)
> 
> I'm building a "replace VM_BUG_ON() with proper printk's instead" right now.
> 
> Honestly, I think VM_BUG_ON() is complete garbage to begin with. We
> know the code can't depend on it, since it's only enabled for VM
> developers. And if it ever triggers, it doesn't get logged because the
> machine is dead (since the VM code almost always holds critical
> locks). So it's exactly the worst kind of BUG_ON.
> 
> Can we turn VM_BUG_ON() into "WARN_ON_ONCE()" and be done with it? The
> VM developers will actually get better reports, and non-vm-developers
> don't have dead machines.
> 

OK by me.  I don't recall ever thinking "gee, I wish the machine had
crashed at this point".

However we shouldn't simply blunder on in the presence of possible
memory corruption so a conversion would need to be done carefully.
