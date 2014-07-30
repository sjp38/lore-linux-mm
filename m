Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id EB5AA6B0036
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 03:44:28 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so1009432pdb.41
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 00:44:28 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id vl8si1448613pbc.51.2014.07.30.00.44.26
        for <linux-mm@kvack.org>;
        Wed, 30 Jul 2014 00:44:27 -0700 (PDT)
Message-ID: <53D8A258.7010904@lge.com>
Date: Wed, 30 Jul 2014 16:44:24 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] new API to allocate buffer-cache for superblock in
 non-movable area
References: <53CDF437.4090306@lge.com> <20140722073005.GT3935@laptop> <20140722093838.GA22331@quack.suse.cz>
In-Reply-To: <20140722093838.GA22331@quack.suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Peter Zijlstra <peterz@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>



2014-07-22 i??i?? 6:38, Jan Kara i?' e,?:
> On Tue 22-07-14 09:30:05, Peter Zijlstra wrote:
>> On Tue, Jul 22, 2014 at 02:18:47PM +0900, Gioh Kim wrote:
>>> Hello,
>>>
>>> This patch try to solve problem that a long-lasting page cache of
>>> ext4 superblock disturbs page migration.
>>>
>>> I've been testing CMA feature on my ARM-based platform
>>> and found some pages for page caches cannot be migrated.
>>> Some of them are page caches of superblock of ext4 filesystem.
>>>
>>> Current ext4 reads superblock with sb_bread(). sb_bread() allocates page
>>> from movable area. But the problem is that ext4 hold the page until
>>> it is unmounted. If root filesystem is ext4 the page cannot be migrated forever.
>>>
>>> I introduce a new API for allocating page from non-movable area.
>>> It is useful for ext4 and others that want to hold page cache for a long time.
>>
>> There's no word on why you can't teach ext4 to still migrate that page.
>> For all I know it might be impossible, but at least mention why.

I am very sorry for lacking of details.

In ext4_fill_super() the buffer-head of superblock is stored in sbi->s_sbh.
The page belongs to the buffer-head is allocated from movable area.
To migrate the page the buffer-head should be released via brelse().
But brelse() is not called until unmount.

For example, fat_fill_super() reads superblock via sb_bread()
and release it via brelse() immediately. Therefore the page that stores superblock can be migrated.



>    It doesn't seem to be worth the effort to make that page movable to me
> (it's reasonably doable since superblock buffer isn't accessed in *that*
> many places but single movable page doesn't seem like a good tradeoff for
> the complexity).
>
> But this made me look into the migration code and it isn't completely clear
> to me what makes the migration code decide that sb buffer isn't movable? We
> seem to be locking the buffers before moving the underlying page but we
> don't do any reference or state checks on the buffers... That seems to be
> assuming that noone looks at bh->b_data without holding buffer lock. That
> is likely true for ordinary data but definitely not true for metadata
> buffers (i.e., buffers for pages from block device mappings).

The sb buffer is not movable because it is not released.
sb_bread increase the reference counter of buffer-head so that
the page of the buffer-head cannot be movable.

sb_bread allocates page from movable area but it is not movable until the
reference counter of the buffer-head becomes zero.
There is no lock for the buffer but the reference counter acts like lock.

Actually it is strange that ext4 keeps buffer-head in superblock structure until unmount (it can be long time)
I thinks the buffer-head should be released immediately like fat_fill_super() did.
I believe there is a reason to keep buffer-head so that I suggest this patch.



>
> Added linux-mm to CC to enlighten me a bit ;)
>
> 								Honza
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
