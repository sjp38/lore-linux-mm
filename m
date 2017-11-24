Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB2E66B0069
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 05:23:30 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q7so6980728pgr.10
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 02:23:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t6sor5430083pgr.325.2017.11.24.02.23.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Nov 2017 02:23:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171124095428.5ojzgfd24sy7zvhe@dhcp22.suse.cz>
References: <20171123162835.6prpgrz3qkdexx56@dhcp22.suse.cz>
 <1511347661-38083-1-git-send-email-maninder1.s@samsung.com>
 <CGME20171122105142epcas5p173b7205da12e1fc72e16ec74c49db665@epcms5p3>
 <20171124094108epcms5p396558828a365a876d61205b0fdb501fd@epcms5p3> <20171124095428.5ojzgfd24sy7zvhe@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 24 Nov 2017 11:23:08 +0100
Message-ID: <CACT4Y+bF7TGFS+395kyzdw21M==ECgs+dCjV0e3Whkvm1_piDA@mail.gmail.com>
Subject: Re: [PATCH 1/1] stackdepot: interface to check entries and size of stackdepot.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Maninder Singh <maninder1.s@samsung.com>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "jkosina@suse.cz" <jkosina@suse.cz>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "jpoimboe@redhat.com" <jpoimboe@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "guptap@codeaurora.org" <guptap@codeaurora.org>, "vinmenon@codeaurora.org" <vinmenon@codeaurora.org>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, PANKAJ MISHRA <pankaj.m@samsung.com>, Lalit Mohan Tripathi <lalit.mohan@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vaneet Narang <v.narang@samsung.com>, kasan-dev <kasan-dev@googlegroups.com>

On Fri, Nov 24, 2017 at 10:54 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 24-11-17 09:41:08, Maninder Singh wrote:
>> Hi Michal,
>>
>> > On Wed 22-11-17 16:17:41, Maninder Singh wrote:
>> > > This patch provides interface to check all the stack enteries
>> > > saved in stackdepot so far as well as memory consumed by stackdepot.
>> > >
>> > > 1) Take current depot_index and offset to calculate end address for one
>> > >         iteration of (/sys/kernel/debug/depot_stack/depot_entries).
>> > >
>> > > 2) Fill end marker in every slab to point its end, and then use it while
>> > >         traversing all the slabs of stackdepot.
>> > >
>> > > "debugfs code inspired from page_onwer's way of printing BT"
>> > >
>> > > checked on ARM and x86_64.
>> > > $cat /sys/kernel/debug/depot_stack/depot_size
>> > > Memory consumed by Stackdepot:208 KB
>> > >
>> > > $ cat /sys/kernel/debug/depot_stack/depot_entries
>> > > stack count 1 backtrace
>> > >  init_page_owner+0x1e/0x210
>> > >  start_kernel+0x310/0x3cd
>> > >  secondary_startup_64+0xa5/0xb0
>> > >  0xffffffffffffffff
>> >
>> > Why do we need this? Who is goging to use this information and what for?
>> > I haven't looked at the code but just the diffstat looks like this
>> > should better have a _very_ good justification to be considered for
>> > merging. To be honest with you I have hard time imagine how this can be
>> > useful other than debugging stack depot...
>>
>> This interface can be used for multiple reasons as:
>>
>> 1) For debugging stackdepot for sure.
>> 2) For checking all the unique allocation paths in system.
>> 3) To check if any invalid stack is coming which is increasing
>> stackdepot memory.
>> (https://lkml.org/lkml/2017/10/11/353)
>
> OK, so debugging a debugging facility... I do not think we want to
> introduce a lot of code for something like that.
>
>> Althoutgh this needs to be taken care in ARM as replied by maintainer, but with help
>> of this interface it was quite easy to check and we added workaround for saving memory.
>>
>> 4) At some point of time to check current memory consumed by stackdepot.
>> 5) To check number of entries in stackdepot to decide stackdepot hash size for different systems.
>>    For fewer entries hash table size can be reduced from 4MB.
>
> What are you going to do with that information. It is not like you can
> reduce the memory footprint or somehow optimize anything during the
> runtime.
>
> --
> Michal Hocko
> SUSE Labs

+kasan-dev mailing list

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
