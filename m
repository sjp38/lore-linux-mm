Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 285CF6B0005
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 20:19:49 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id z9-v6so10855600iom.14
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 17:19:49 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id j63-v6si1065952itj.107.2018.07.13.17.19.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 17:19:47 -0700 (PDT)
Subject: Re: Instability in current -git tree
References: <CA+55aFyARQV302+mXNYznrOOjzW+yxbcv+=OkD43dG6G1ktoMQ@mail.gmail.com>
 <alpine.DEB.2.21.1807140031440.2644@nanos.tec.linutronix.de>
 <CA+55aFzBx1haeM2QSFvhaW2t_HVK78Y=bKvsiJmOZztwkZ-y7Q@mail.gmail.com>
 <CA+55aFzVGa57apuzDMBLgWQQRcm3BNBs1UEg-G_2o7YW1i=o2Q@mail.gmail.com>
 <CA+55aFy9NJZeqT7h_rAgbKUZLjzfxvDPwneFQracBjVhY53aQQ@mail.gmail.com>
 <20180713164804.fc2c27ccbac4c02ca2c8b984@linux-foundation.org>
 <CA+55aFxAZr8PHo-raTihr8TKK_D-fVL+k6_tw_UyDLychowFNw@mail.gmail.com>
 <20180713165812.ec391548ffeead96725d044c@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <9b93d48c-b997-01f7-2fd6-6e35301ef263@oracle.com>
Date: Fri, 13 Jul 2018 20:19:17 -0400
MIME-Version: 1.0
In-Reply-To: <20180713165812.ec391548ffeead96725d044c@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@redhat.com>, Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Miller <davem@davemloft.net>, Al Viro <viro@zeniv.linux.org.uk>, Dave Airlie <airlied@gmail.com>, Tejun Heo <tj@kernel.org>, Ted Ts'o <tytso@google.com>, Mike Snitzer <snitzer@redhat.com>, linux-mm <linux-mm@kvack.org>, Daniel Vacek <neelx@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

On 07/13/2018 07:58 PM, Andrew Morton wrote:
> On Fri, 13 Jul 2018 16:51:39 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
>> On Fri, Jul 13, 2018 at 4:48 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>>>
>>> (But it would be interesting to see whether removing the check "fixes" it)
>>
>> I'm building a "replace VM_BUG_ON() with proper printk's instead" right now.

I'd like to try to reproduce it as well, were you able to reproduce this problem in qemu? What were the qemu arguments if so?

>>
>> Honestly, I think VM_BUG_ON() is complete garbage to begin with. We
>> know the code can't depend on it, since it's only enabled for VM
>> developers. And if it ever triggers, it doesn't get logged because the
>> machine is dead (since the VM code almost always holds critical
>> locks). So it's exactly the worst kind of BUG_ON.
>>
>> Can we turn VM_BUG_ON() into "WARN_ON_ONCE()" and be done with it? The
>> VM developers will actually get better reports, and non-vm-developers
>> don't have dead machines.
>>
> 
> OK by me.  I don't recall ever thinking "gee, I wish the machine had
> crashed at this point".

VM_BUG_ON() changing to WARN_ON_ONCE() is OK, because it is enabled only with CONFIG_DEBUG_VM.
Sometimes, however, it is better to crash. Examples include the possibility of user data getting corrupted, and security vulnerabilities. Once, kernel gets into a broken state, such as invalid pagetable entries,  but continues executing data written to disk, nvram, or sent over network is unreliable. Another example include crash dumps that are hard to analyze as the corruption is long passed.

Pavel
