Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 319B76B0010
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:51:52 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id t23-v6so29410117ioa.9
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:51:52 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r90-v6sor10354006ioi.323.2018.07.13.16.51.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 16:51:51 -0700 (PDT)
MIME-Version: 1.0
References: <CA+55aFyARQV302+mXNYznrOOjzW+yxbcv+=OkD43dG6G1ktoMQ@mail.gmail.com>
 <alpine.DEB.2.21.1807140031440.2644@nanos.tec.linutronix.de>
 <CA+55aFzBx1haeM2QSFvhaW2t_HVK78Y=bKvsiJmOZztwkZ-y7Q@mail.gmail.com>
 <CA+55aFzVGa57apuzDMBLgWQQRcm3BNBs1UEg-G_2o7YW1i=o2Q@mail.gmail.com>
 <CA+55aFy9NJZeqT7h_rAgbKUZLjzfxvDPwneFQracBjVhY53aQQ@mail.gmail.com> <20180713164804.fc2c27ccbac4c02ca2c8b984@linux-foundation.org>
In-Reply-To: <20180713164804.fc2c27ccbac4c02ca2c8b984@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 13 Jul 2018 16:51:39 -0700
Message-ID: <CA+55aFxAZr8PHo-raTihr8TKK_D-fVL+k6_tw_UyDLychowFNw@mail.gmail.com>
Subject: Re: Instability in current -git tree
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@redhat.com>, Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Miller <davem@davemloft.net>, Al Viro <viro@zeniv.linux.org.uk>, Dave Airlie <airlied@gmail.com>, Tejun Heo <tj@kernel.org>, Ted Ts'o <tytso@google.com>, Mike Snitzer <snitzer@redhat.com>, linux-mm <linux-mm@kvack.org>, Daniel Vacek <neelx@redhat.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Mel Gorman <mgorman@techsingularity.net>

On Fri, Jul 13, 2018 at 4:48 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> (But it would be interesting to see whether removing the check "fixes" it)

I'm building a "replace VM_BUG_ON() with proper printk's instead" right now.

Honestly, I think VM_BUG_ON() is complete garbage to begin with. We
know the code can't depend on it, since it's only enabled for VM
developers. And if it ever triggers, it doesn't get logged because the
machine is dead (since the VM code almost always holds critical
locks). So it's exactly the worst kind of BUG_ON.

Can we turn VM_BUG_ON() into "WARN_ON_ONCE()" and be done with it? The
VM developers will actually get better reports, and non-vm-developers
don't have dead machines.

                    Linus
