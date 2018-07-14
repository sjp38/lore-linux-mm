Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5BFAB6B0269
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 20:47:00 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id y13-v6so8690964ita.8
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 17:47:00 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u206-v6si5855121itc.35.2018.07.13.17.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 17:46:59 -0700 (PDT)
Subject: Re: Instability in current -git tree
References: <CA+55aFyARQV302+mXNYznrOOjzW+yxbcv+=OkD43dG6G1ktoMQ@mail.gmail.com>
 <alpine.DEB.2.21.1807140031440.2644@nanos.tec.linutronix.de>
 <CA+55aFzBx1haeM2QSFvhaW2t_HVK78Y=bKvsiJmOZztwkZ-y7Q@mail.gmail.com>
 <CA+55aFzVGa57apuzDMBLgWQQRcm3BNBs1UEg-G_2o7YW1i=o2Q@mail.gmail.com>
 <CA+55aFy9NJZeqT7h_rAgbKUZLjzfxvDPwneFQracBjVhY53aQQ@mail.gmail.com>
 <20180713164804.fc2c27ccbac4c02ca2c8b984@linux-foundation.org>
 <CA+55aFxAZr8PHo-raTihr8TKK_D-fVL+k6_tw_UyDLychowFNw@mail.gmail.com>
 <20180713165812.ec391548ffeead96725d044c@linux-foundation.org>
 <9b93d48c-b997-01f7-2fd6-6e35301ef263@oracle.com>
 <CA+55aFxFw2-1BD2UBf_QJ2=faQES_8q==yUjwj4mGJ6Ub4uX7w@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <5edf2d71-f548-98f9-16dd-b7fed29f4869@oracle.com>
Date: Fri, 13 Jul 2018 20:46:31 -0400
MIME-Version: 1.0
In-Reply-To: <CA+55aFxFw2-1BD2UBf_QJ2=faQES_8q==yUjwj4mGJ6Ub4uX7w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@redhat.com>, Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Miller <davem@davemloft.net>, Al Viro <viro@zeniv.linux.org.uk>, Dave Airlie <airlied@gmail.com>, Tejun Heo <tj@kernel.org>, Ted Ts'o <tytso@google.com>, Mike Snitzer <snitzer@redhat.com>, linux-mm <linux-mm@kvack.org>, Daniel Vacek <neelx@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

On 07/13/2018 08:28 PM, Linus Torvalds wrote:
> On Fri, Jul 13, 2018 at 5:20 PM Pavel Tatashin
> <pasha.tatashin@oracle.com> wrote:
>>
>> I'd like to try to reproduce it as well, were you able to reproduce this problem in qemu? What were the qemu arguments if so?
> 
> No, this is actually on raw hardware. I've had a unstable machine for
> the last couple of weeks, and it just hung with no sign of where.
> 
> I finally reproduced it reliably by booting with less memory
> ("mem=6G") and then putting the machine under memory pressure and then
> I could get it on the console when the machine died. Before that it
> was just an occasional hung machine randomly every other day or
> whatever.
> 
> If it reproduces in emulation, that will certainly make it easier to
> see the messages.
> 
> But since I suspect it might be related to having that odd (read: real
> life) e820 table setup, it might not reproduce in emulation. At least
> when I boot up in lkvm-run, I don't see those ACPI tables and ACPI NVS
> sections, which seems to be related to this.
> 
> I'm attaching my kernel-config (this is the non-debug one - it does
> have CONFIG_DEBUG_VM, but none of the other debug options I ran with
> for the last few days in the hope of catching it earlier).
> 
>                 Linus
> 

I will try to reproduce it on bare metal. I believe, the problem was narrowed down to this commit:

124049decbb1 x86/e820: put !E820_TYPE_RAM regions into memblock.reserved

The commit intends to zero memmap (struct pages) for every hole in e820 ranges by marking them reserved in memblock. Later  zero_resv_unavail() walks through memmap ranges and zeroes struct pages for every page that is reserved, but does not have a physical backing known by kernel.

Pavel
