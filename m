Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id CA6A36B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 06:02:31 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so89769920pdr.2
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 03:02:31 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id og9si26922902pbc.66.2015.07.13.03.02.29
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 03:02:30 -0700 (PDT)
Message-ID: <55A38CB4.5050806@lge.com>
Date: Mon, 13 Jul 2015 19:02:28 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] enable migration of driver pages
References: <1436776519-17337-1-git-send-email-gioh.kim@lge.com> <CALYGNiPZtJqcYW5Ob6TbRMGrJHP6zV7cKfbesBxprVQjqVmUSw@mail.gmail.com>
In-Reply-To: <CALYGNiPZtJqcYW5Ob6TbRMGrJHP6zV7cKfbesBxprVQjqVmUSw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, Bruce Fields <bfields@fieldses.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Al Viro <viro@zeniv.linux.org.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, virtualization@lists.linux-foundation.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, dri-devel <dri-devel@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, Gioh Kim <gurugio@hanmail.net>



2015-07-13 i??i?? 6:24i?? Konstantin Khlebnikov i?'(e??) i?' e,?:
> On Mon, Jul 13, 2015 at 11:35 AM, Gioh Kim <gioh.kim@lge.com> wrote:
>> From: Gioh Kim <gurugio@hanmail.net>
>>
>> Hello,
>>
>> This series try to enable migration of non-LRU pages, such as driver's page.
>>
>> My ARM-based platform occured severe fragmentation problem after long-term
>> (several days) test. Sometimes even order-3 page allocation failed. It has
>> memory size 512MB ~ 1024MB. 30% ~ 40% memory is consumed for graphic processing
>> and 20~30 memory is reserved for zram.
>>
>> I found that many pages of GPU driver and zram are non-movable pages. So I
>> reported Minchan Kim, the maintainer of zram, and he made the internal
>> compaction logic of zram. And I made the internal compaction of GPU driver.
>>
>> They reduced some fragmentation but they are not enough effective.
>> They are activated by its own interface, /sys, so they are not cooperative
>> with kernel compaction. If there is too much fragmentation and kernel starts
>> to compaction, zram and GPU driver cannot work with the kernel compaction.
>>
>> So I thought there needs a interface to combine driver and kernel compaction.
>> This patch adds a generic isolate/migrate/putback callbacks for page
>> address-space and a new interface to create anon-inode to manage
>> address_space_operation. The zram and GPU, and any other modules can create
>> anon_inode and register its own migration method. The kernel compaction can
>> call the registered migration when it does compaction.
>>
>> My GPU driver source is not in-kernel driver so that I apply the interface
>> into balloon driver. The balloon driver is already merged
>> into the kernel compaction as a corner-case. This patch have the balloon
>> driver migration be called by the generic interface.
>>
>>
>> This patch set combines 4 patches.
>>
>> 1. patch 1/4: get inode from anon_inodes
>> This patch adds new interface to create inode from anon_inodes.
>>
>> 2. patch 2/4: framework to isolate/migrate/putback page
>> Add isolatepage, putbackpage into address_space_operations
>> and wrapper function to call them.
>>
>> 3. patch 3/4: apply the framework into balloon driver
>> The balloon driver is applied into the framework. It gets a inode
>> from anon_inodes and register operations in the inode.
>> The kernel compaction calls generic interfaces, not balloon
>> driver interfaces.
>> Any other drivers can register operations via inode like this
>> to migrate it's pages.
>>
>> 4. patch 4/4: remove direct calling of migration of driver pages
>> Non-lru pages are also migrated with lru pages by move_to_new_page().
>
> The whole patchset looks good.
>
> Reviewed-by: Konstantin Khlebnikov <koct9i@gmail.com>
>
>>
>> This patch set is tested:
>> - turn on Ubuntu 14.04 with 1G memory on qemu.
>> - do kernel building
>> - after several seconds check more than 512MB is used with free command
>> - command "balloon 512" in qemu monitor
>> - check hundreds MB of pages are migrated
>
> Another simple test is several instances of
> tools/testing/selftests/vm/transhuge-stress.c
> runnng in parallel with balloon inflating/deflating.
> (transparent huge pages must be enabled of course)
> That catched a lot of races in ballooning code.
>

Great!
I'll do it and inform you the result in this week.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
