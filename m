Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 344476B00B4
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 13:02:58 -0400 (EDT)
Received: by mail-ve0-f178.google.com with SMTP id ox1so2130092veb.9
        for <linux-mm@kvack.org>; Wed, 07 Aug 2013 10:02:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130807134058.GC12843@quack.suse.cz>
References: <cover.1375729665.git.luto@amacapital.net> <20130807134058.GC12843@quack.suse.cz>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 7 Aug 2013 10:02:36 -0700
Message-ID: <CALCETrVT=pmA06VRjmLRZZnWA5PUjcRP_Lwo7f1ze5Lj9FWJeQ@mail.gmail.com>
Subject: Re: [RFC 0/3] Add madvise(..., MADV_WILLWRITE)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Aug 7, 2013 at 6:40 AM, Jan Kara <jack@suse.cz> wrote:
> On Mon 05-08-13 12:43:58, Andy Lutomirski wrote:
>> My application fallocates and mmaps (shared, writable) a lot (several
>> GB) of data at startup.  Those mappings are mlocked, and they live on
>> ext4.  The first write to any given page is slow because
>> ext4_da_get_block_prep can block.  This means that, to get decent
>> performance, I need to write something to all of these pages at
>> startup.  This, in turn, causes a giant IO storm as several GB of
>> zeros get pointlessly written to disk.
>>
>> This series is an attempt to add madvise(..., MADV_WILLWRITE) to
>> signal to the kernel that I will eventually write to the referenced
>> pages.  It should cause any expensive operations that happen on the
>> first write to happen immediately, but it should not result in
>> dirtying the pages.
>>
>> madvice(addr, len, MADV_WILLWRITE) returns the number of bytes that
>> the operation succeeded on or a negative error code if there was an
>> actual failure.  A return value of zero signifies that the kernel
>> doesn't know how to "willwrite" the range and that userspace should
>> implement a fallback.
>>
>> For now, it only works on shared writable ext4 mappings.  Eventually
>> it should support other filesystems as well as private pages (it
>> should COW the pages but not cause swap IO) and anonymous pages (it
>> should COW the zero page if applicable).
>>
>> The implementation leaves much to be desired.  In particular, it
>> generates dirty buffer heads on a clean page, and this scares me.
>>
>> Thoughts?
>   One question before I look at the patches: Why don't you use fallocate()
> in your application? The functionality you require seems to be pretty
> similar to it - writing to an already allocated block is usually quick.

I do use fallocate, and, IIRC, the problem was worse before I added
the fallocate call.

This could be argued to be a filesystem problem -- perhaps
page_mkwrite should never block.  I don't expect that to be fixed any
time soon (if ever).

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
