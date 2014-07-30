Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id ADBB56B0035
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 19:54:43 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so2339709pdj.2
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 16:54:43 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id pb6si1973685pdb.83.2014.07.30.16.54.41
        for <linux-mm@kvack.org>;
        Wed, 30 Jul 2014 16:54:42 -0700 (PDT)
Message-ID: <53D985C0.3070300@lge.com>
Date: Thu, 31 Jul 2014 08:54:40 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] new API to allocate buffer-cache for superblock in
 non-movable area
References: <53CDF437.4090306@lge.com> <20140722073005.GT3935@laptop> <20140722093838.GA22331@quack.suse.cz> <53D8A258.7010904@lge.com> <20140730101143.GB19205@quack.suse.cz>
In-Reply-To: <20140730101143.GB19205@quack.suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>



2014-07-30 i??i?? 7:11, Jan Kara i?' e,?:
> On Wed 30-07-14 16:44:24, Gioh Kim wrote:
>> 2014-07-22 i??i?? 6:38, Jan Kara i?' e,?:
>>> On Tue 22-07-14 09:30:05, Peter Zijlstra wrote:
>>>> On Tue, Jul 22, 2014 at 02:18:47PM +0900, Gioh Kim wrote:
>>>>> Hello,
>>>>>
>>>>> This patch try to solve problem that a long-lasting page cache of
>>>>> ext4 superblock disturbs page migration.
>>>>>
>>>>> I've been testing CMA feature on my ARM-based platform
>>>>> and found some pages for page caches cannot be migrated.
>>>>> Some of them are page caches of superblock of ext4 filesystem.
>>>>>
>>>>> Current ext4 reads superblock with sb_bread(). sb_bread() allocates page
>>>> >from movable area. But the problem is that ext4 hold the page until
>>>>> it is unmounted. If root filesystem is ext4 the page cannot be migrated forever.
>>>>>
>>>>> I introduce a new API for allocating page from non-movable area.
>>>>> It is useful for ext4 and others that want to hold page cache for a long time.
>>>>
>>>> There's no word on why you can't teach ext4 to still migrate that page.
>>>> For all I know it might be impossible, but at least mention why.
>>
>> I am very sorry for lacking of details.
>>
>> In ext4_fill_super() the buffer-head of superblock is stored in sbi->s_sbh.
>> The page belongs to the buffer-head is allocated from movable area.
>> To migrate the page the buffer-head should be released via brelse().
>> But brelse() is not called until unmount.
>    Hum, I don't see where in the code do we check buffer_head use count. Can
> you please point me? Thanks.

Filesystem code does not check buffer_head use count.
sb_bread() returns the buffer_head that is included in bh_lru and has non-zero use count.
You can see the bh_lru code in buffer.c: __find_get_clock() and lookup_bh_lru().
bh_lru_install() inserts the buffer_head into the bh_lru().
It first calls get_bh() to increase the use count and insert bh into the lru array.

The buffer_head use count is non-zero until brelse() is called.

>
>>>    It doesn't seem to be worth the effort to make that page movable to me
>>> (it's reasonably doable since superblock buffer isn't accessed in *that*
>>> many places but single movable page doesn't seem like a good tradeoff for
>>> the complexity).
>>>
>>> But this made me look into the migration code and it isn't completely clear
>>> to me what makes the migration code decide that sb buffer isn't movable? We
>>> seem to be locking the buffers before moving the underlying page but we
>>> don't do any reference or state checks on the buffers... That seems to be
>>> assuming that noone looks at bh->b_data without holding buffer lock. That
>>> is likely true for ordinary data but definitely not true for metadata
>>> buffers (i.e., buffers for pages from block device mappings).
>>
>> The sb buffer is not movable because it is not released.
>> sb_bread increase the reference counter of buffer-head so that
>> the page of the buffer-head cannot be movable.
>>
>> sb_bread allocates page from movable area but it is not movable until the
>> reference counter of the buffer-head becomes zero.
>> There is no lock for the buffer but the reference counter acts like lock.
>    OK, but why do you care about a single page (of at most handful if you
> have more filesystems) which isn't movable? That shouldn't make a big
> difference to compaction...

Even a single page can make CMA migration fail.

>
>> Actually it is strange that ext4 keeps buffer-head in superblock
>> structure until unmount (it can be long time) I thinks the buffer-head
>> should be released immediately like fat_fill_super() did.  I believe
>> there is a reason to keep buffer-head so that I suggest this patch.
>    We don't copy some data from the superblock to other structure so from
> time to time we need to look e.g. at feature bits within superblock buffer.
> Historically we were updating numbers of free blocks and inodes in the
> superblock with each allocation but we don't do that anymore because it
> scales poorly. So there is no fundamental reason for keeping sb buffer
> pinned anymore. Just someone would have to rewrite the code to copy some
> pieces of data from the buffer to some other structure and use it there.

I hope so.

>
> 								Honza
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
