Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 47DD66B0035
	for <linux-mm@kvack.org>; Wed, 21 May 2014 01:56:56 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id c1so1715073igq.7
        for <linux-mm@kvack.org>; Tue, 20 May 2014 22:56:56 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id it15si25197707icc.8.2014.05.20.22.56.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 May 2014 22:56:55 -0700 (PDT)
Received: by mail-ig0-f181.google.com with SMTP id h3so1715447igd.2
        for <linux-mm@kvack.org>; Tue, 20 May 2014 22:56:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <537c0e29.89cbc20a.4dbb.62eeSMTPIN_ADDED_BROKEN@mx.google.com>
References: <20140226075723.29820.26427.stgit@zurg>
	<537c0e29.89cbc20a.4dbb.62eeSMTPIN_ADDED_BROKEN@mx.google.com>
Date: Wed, 21 May 2014 09:56:55 +0400
Message-ID: <CALYGNiPeZsB0GSgtGOV04iMX8r1DM0anPoiKwFesfE=MBhtS1Q@mail.gmail.com>
Subject: Re: [PATCH] tools/vm/page-types.c: page-cache sniffing feature
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Arnaldo Carvalho de Melo <acme@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>

On Wed, May 21, 2014 at 6:23 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> Hi Konstantin,
>
> This patch is already in upstream, but I have another idea of implementing
> the similar feature. So let me review this now, and I'll post patches to
> complement this patch.
>
> On Wed, Feb 26, 2014 at 11:57:23AM +0400, Konstantin Khlebnikov wrote:
>> After this patch 'page-types' can walk on filesystem mappings and analize
>> populated page cache pages mostly without disturbing its state.
>>
>> It maps chunk of file, marks VMA as MADV_RANDOM to turn off readahead,
>> pokes VMA via mincore() to determine cached pages, triggers page-fault
>> only for them, and finally gathers information via pagemap/kpageflags.
>> Before unmap it marks VMA as MADV_SEQUENTIAL for ignoring reference bits.
>
> I think that with this patch page-types *does* disturb page cache (not only
> of the target file) because it newly populates the pages not faulted in
> when page-types starts, which rotates LRU list and adds memory pressure.
> To minimize the measurement-disturbance, we need some help in the kernel side.

Yes, it racy and sometimes changes state of page-cache, I know that.
Dcache state also under fire.
[ Also it sometimes races with truncate and dies after SIGBUS, I
already have patch for this ]
But, I don't see reason why anyone needs this so badly to require this
massive change in the kernel.

Also I don't quite like interface which you are proposend.
I think ioctl would be better, like FIEMAP/BMAP but for pages.
Hint: If you're inventing new interface at least make it non-racy and
usable for more than one user at once. =)

My code has one huge advantage -- it don't need any changes in the
kernel and works for old kernels.
If you're planning to change here something you should at least keep
old code for backward compatibility.


I've got another Idea. This mught be done in opposite direction: we
could add interface which tells mapping and offset for each page.
Finding all pages of particular mapping isn't big deal. What do you think?

>
>>
>> usage: page-types -f <path>
>>
>> If <path> is directory it will analyse all files in all subdirectories.
>
> I think -f was reserved for "Walk file address space", so doing file tree
> walk looks to me overkill. You can add "directory mode (-d) for this purpose,
> although it seems to me that we can/should do this (for example) by combining
> with find command. I can show you the example in my patch later.

It walks file address space, what's the problem?
Removing recursive walk saves couple lines but either kills
constuction of overall statistics our might hit the limit of argv
size.

>
>> Symlinks are not followed as well as mount points. Hardlinks aren't handled,
>> they'll be dumbed as many times as they are found. Recursive walk brings all
>> dentries into dcache and populates page cache of block-devices aka 'Buffers'.

I hope you have seen this two paraphes below. That was hint for future
hackers =)

>>
>> Probably it's worth to add ioctl for dumping file page cache as array of PFNs
>> as a replacement for this hackish juggling with mmap/madvise/mincore/pagemap.
>>
>> Also recursive walk could be replaced with dumping cached inodes via some ioctl
>> or debugfs interface followed by openning them via open_by_handle_at, this
>> would fix hardlinks handling and unneeded population of dcache and buffers.
>> This interface might be used as data source for constructing readahead plans
>> and for background optimizations of actively used files.
>>
>> collateral changes:
>> + fix 64-bit LFS: define _FILE_OFFSET_BITS instead of _LARGEFILE64_SOURCE
>> + replace lseek + read with single pread
>
> Good, thanks.
>
>> + make show_page_range() reusable after flush
>>
>>
>> usage example:
>>
>> ~/src/linux/tools/vm$ sudo ./page-types -L -f page-types
>> foffset       offset  flags
>> page-types    Inode: 2229277  Size: 89065 (22 pages)
>> Modify: Tue Feb 25 12:00:59 2014 (162 seconds ago)
>> Access: Tue Feb 25 12:01:00 2014 (161 seconds ago)
>
> I don't see why page-types needs to show these information.
> We have many other tools to check file info, so this small program should
> focus on page related things.

This tools helps to take snapshot of cached data and analyze why they are here.
Pages appears in cache when someone reads files and becomes dirty when
someone writes to them.
This all about history and time, so when you inversigate what data is
still in cache or
still dirty you need to know how long they are here.
This isn't precisely right, but reasonable enough and don't need any
change in the kernel.

>
> Thanks,
> Naoya Horiguchi
>
>> 0     3cbf3b  __RU_lA____M________________________
>> 1     38946a  __RU_lA____M________________________
>> 2     1a3cec  __RU_lA____M________________________
>> 3     1a8321  __RU_lA____M________________________
>> 4     3af7cc  __RU_lA____M________________________
>> 5     1ed532  __RU_lA_____________________________
>> 6     2e436a  __RU_lA_____________________________
>> 7     29a35e  ___U_lA_____________________________
>> 8     2de86e  ___U_lA_____________________________
>> 9     3bdfb4  ___U_lA_____________________________
>> 10    3cd8a3  ___U_lA_____________________________
>> 11    2afa50  ___U_lA_____________________________
>> 12    2534c2  ___U_lA_____________________________
>> 13    1b7a40  ___U_lA_____________________________
>> 14    17b0be  ___U_lA_____________________________
>> 15    392b0c  ___U_lA_____________________________
>> 16    3ba46a  __RU_lA_____________________________
>> 17    397dc8  ___U_lA_____________________________
>> 18    1f2a36  ___U_lA_____________________________
>> 19    21fd30  __RU_lA_____________________________
>> 20    2c35ba  __RU_l______________________________
>> 21    20f181  __RU_l______________________________
>>
>>
>>              flags    page-count       MB  symbolic-flags                     long-symbolic-flags
>> 0x000000000000002c             2        0  __RU_l______________________________       referenced,uptodate,lru
>> 0x0000000000000068            11        0  ___U_lA_____________________________       uptodate,lru,active
>> 0x000000000000006c             4        0  __RU_lA_____________________________       referenced,uptodate,lru,active
>> 0x000000000000086c             5        0  __RU_lA____M________________________       referenced,uptodate,lru,active,mmap
>>              total            22        0
>>
>>
>>
>> ~/src/linux/tools/vm$ sudo ./page-types -f /
>>              flags    page-count       MB  symbolic-flags                     long-symbolic-flags
>> 0x0000000000000028         21761       85  ___U_l______________________________       uptodate,lru
>> 0x000000000000002c        127279      497  __RU_l______________________________       referenced,uptodate,lru
>> 0x0000000000000068         74160      289  ___U_lA_____________________________       uptodate,lru,active
>> 0x000000000000006c         84469      329  __RU_lA_____________________________       referenced,uptodate,lru,active
>> 0x000000000000007c             1        0  __RUDlA_____________________________       referenced,uptodate,dirty,lru,active
>> 0x0000000000000228           370        1  ___U_l___I__________________________       uptodate,lru,reclaim
>> 0x0000000000000828            49        0  ___U_l_____M________________________       uptodate,lru,mmap
>> 0x000000000000082c           126        0  __RU_l_____M________________________       referenced,uptodate,lru,mmap
>> 0x0000000000000868           137        0  ___U_lA____M________________________       uptodate,lru,active,mmap
>> 0x000000000000086c         12890       50  __RU_lA____M________________________       referenced,uptodate,lru,active,mmap
>>              total        321242     1254
>>
>> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
>> ---
>>  tools/vm/page-types.c |  170 ++++++++++++++++++++++++++++++++++++++++++++-----
>>  1 file changed, 152 insertions(+), 18 deletions(-)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
