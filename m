Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f50.google.com (mail-oa0-f50.google.com [209.85.219.50])
	by kanga.kvack.org (Postfix) with ESMTP id 318306B0036
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 03:57:24 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id g18so732641oah.9
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 00:57:23 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id rt10si2960895obb.61.2014.07.30.00.57.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Jul 2014 00:57:22 -0700 (PDT)
Received: by mail-oi0-f52.google.com with SMTP id h136so617682oig.25
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 00:57:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53D8A258.7010904@lge.com>
References: <53CDF437.4090306@lge.com>
	<20140722073005.GT3935@laptop>
	<20140722093838.GA22331@quack.suse.cz>
	<53D8A258.7010904@lge.com>
Date: Wed, 30 Jul 2014 16:57:22 +0900
Message-ID: <CAH9JG2XaD3TzFUV51OytmR1Ra_Nt5a2rGm5EE_E4POUyW8fDjA@mail.gmail.com>
Subject: Re: [PATCH 0/2] new API to allocate buffer-cache for superblock in
 non-movable area
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>
Cc: Jan Kara <jack@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>

Adding Marek & Tomasz,


On Wed, Jul 30, 2014 at 4:44 PM, Gioh Kim <gioh.kim@lge.com> wrote:
>
>
> 2014-07-22 =EC=98=A4=ED=9B=84 6:38, Jan Kara =EC=93=B4 =EA=B8=80:
>
>> On Tue 22-07-14 09:30:05, Peter Zijlstra wrote:
>>>
>>> On Tue, Jul 22, 2014 at 02:18:47PM +0900, Gioh Kim wrote:
>>>>
>>>> Hello,
>>>>
>>>> This patch try to solve problem that a long-lasting page cache of
>>>> ext4 superblock disturbs page migration.
>>>>
>>>> I've been testing CMA feature on my ARM-based platform
>>>> and found some pages for page caches cannot be migrated.
>>>> Some of them are page caches of superblock of ext4 filesystem.
>>>>
>>>> Current ext4 reads superblock with sb_bread(). sb_bread() allocates pa=
ge
>>>> from movable area. But the problem is that ext4 hold the page until
>>>> it is unmounted. If root filesystem is ext4 the page cannot be migrate=
d
>>>> forever.
>>>>
>>>> I introduce a new API for allocating page from non-movable area.
>>>> It is useful for ext4 and others that want to hold page cache for a lo=
ng
>>>> time.
>>>
>>>
>>> There's no word on why you can't teach ext4 to still migrate that page.
>>> For all I know it might be impossible, but at least mention why.
>
>
> I am very sorry for lacking of details.
>
> In ext4_fill_super() the buffer-head of superblock is stored in sbi->s_sb=
h.
> The page belongs to the buffer-head is allocated from movable area.
> To migrate the page the buffer-head should be released via brelse().
> But brelse() is not called until unmount.
>
> For example, fat_fill_super() reads superblock via sb_bread()
> and release it via brelse() immediately. Therefore the page that stores
> superblock can be migrated.
>
>
>
>
>>    It doesn't seem to be worth the effort to make that page movable to m=
e
>> (it's reasonably doable since superblock buffer isn't accessed in *that*
>> many places but single movable page doesn't seem like a good tradeoff fo=
r
>> the complexity).
>>
>> But this made me look into the migration code and it isn't completely
>> clear
>> to me what makes the migration code decide that sb buffer isn't movable?
>> We
>> seem to be locking the buffers before moving the underlying page but we
>> don't do any reference or state checks on the buffers... That seems to b=
e
>> assuming that noone looks at bh->b_data without holding buffer lock. Tha=
t
>> is likely true for ordinary data but definitely not true for metadata
>> buffers (i.e., buffers for pages from block device mappings).
>
we got similar issues and add similar work-around codes.

Thank you,
Kyungmin Park
>
> The sb buffer is not movable because it is not released.
> sb_bread increase the reference counter of buffer-head so that
> the page of the buffer-head cannot be movable.
>
> sb_bread allocates page from movable area but it is not movable until the
> reference counter of the buffer-head becomes zero.
> There is no lock for the buffer but the reference counter acts like lock.
>
> Actually it is strange that ext4 keeps buffer-head in superblock structur=
e
> until unmount (it can be long time)
> I thinks the buffer-head should be released immediately like
> fat_fill_super() did.
> I believe there is a reason to keep buffer-head so that I suggest this
> patch.
>
>
>
>
>>
>> Added linux-mm to CC to enlighten me a bit ;)
>>
>>                                                                 Honza
>>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
