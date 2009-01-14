Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 577ED6B005C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 16:05:47 -0500 (EST)
Received: by qyk5 with SMTP id 5so775237qyk.14
        for <linux-mm@kvack.org>; Wed, 14 Jan 2009 13:05:45 -0800 (PST)
Message-ID: <3e8340490901141305x7155cf10ueed386646d6e21ee@mail.gmail.com>
Date: Wed, 14 Jan 2009 16:05:45 -0500
From: "Bryan Donlan" <bdonlan@gmail.com>
Subject: Re: OOPS and panic on 2.6.29-rc1 on xen-x86
In-Reply-To: <20090114025910.GA17395@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20090112172613.GA8746@shion.is.fushizen.net>
	 <3e8340490901122054q4af2b4cm3303c361477defc0@mail.gmail.com>
	 <20090114025910.GA17395@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 13, 2009 at 9:59 PM, Nick Piggin <npiggin@suse.de> wrote:
> On Mon, Jan 12, 2009 at 11:54:32PM -0500, Bryan Donlan wrote:
>> On Mon, Jan 12, 2009 at 12:26 PM, Bryan Donlan <bdonlan@gmail.com> wrote:
>> > [resending with log/config inline as my previous message seems to have
>> >  been eaten by vger's spam filters]
>> >
>> > Hi,
>> >
>> > After testing 2.6.29-rc1 on xen-x86 with a btrfs root filesystem, I
>> > got the OOPS quoted below and a hard freeze shortly after boot.
>> > Boot messages and config are attached.
>> >
>> > This is on a test system, so I'd be happy to test any patches.
>> >
>> > Thanks,
>> >
>> > Bryan Donlan
>>
>> I've bisected the bug in question, and the faulty commit appears to be:
>> commit e97a630eb0f5b8b380fd67504de6cedebb489003
>> Author: Nick Piggin <npiggin@suse.de>
>> Date:   Tue Jan 6 14:39:19 2009 -0800
>>
>>     mm: vmalloc use mutex for purge
>>
>>     The vmalloc purge lock can be a mutex so we can sleep while a purge is
>>     going on (purge involves a global kernel TLB invalidate, so it can take
>>     quite a while).
>>
>>     Signed-off-by: Nick Piggin <npiggin@suse.de>
>>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>>
>> The bug is easily reproducable by a kernel build on -j4 - it will
>> generally OOPS and panic before the build completes.
>> Also, I've tested it with ext3, and it still occurs, so it seems
>> unrelated to btrfs at least :)
>>
>> >
>> > ------------[ cut here ]------------
>> > Kernel BUG at c05ef80d [verbose debug info unavailable]
>> > invalid opcode: 0000 [#1] SMP
>> > last sysfs file: /sys/block/xvdc/size
>> > Modules linked in:
>
> It is bugging in schedule somehow, but you don't have verbose debug
> info compiled in. Can you compile that in and reproduce if you have
> the time?

Sure - which config option would that be? CONFIG_DEBUG_BUGVERBOSE?

> Going bug here might indicate that there is some other problem with
> the Xen and/or vmalloc code, regardless of reverting this patch.
>
> Thanks,
> Nick
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
