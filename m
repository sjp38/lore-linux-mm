Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BC93E6B004F
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 23:48:50 -0400 (EDT)
Received: from mlsv7.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id E379037C88
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 12:48:53 +0900 (JST)
Message-ID: <4A80EA14.4030300@hitachi.com>
Date: Tue, 11 Aug 2009 12:48:36 +0900
From: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for migration
    aware file systems
References: <200908051136.682859934@firstfloor.org>
    <20090805093643.E0C00B15D8@basil.firstfloor.org>
    <4A7FBFD1.2010208@hitachi.com> <20090810070745.GA26533@localhost>
In-Reply-To: <20090810070745.GA26533@localhost>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "tytso@mit.edu" <tytso@mit.edu>, "hch@infradead.org" <hch@infradead.org>, "mfasheh@suse.com" <mfasheh@suse.com>, "aia21@cantab.net" <aia21@cantab.net>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "swhiteho@redhat.com" <swhiteho@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@suse.de" <npiggin@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:

>>However, we have a way to avoid this kind of data corruption at
>>least for ext3.  If we mount an ext3 filesystem with data=ordered
>>and data_err=abort, all I/O errors on file data block belonging to
>>the committing transaction are checked.  When I/O error is found,
>>abort journaling and remount the filesystem with read-only to
>>prevent further updates.  This kind of feature is very important
>>for mission critical systems.
> 
> Agreed. We also set PG_error, which should be enough to trigger such
> remount?

ext3 doesn't check PG_error.  Maybe we need to do:

1. trylock_buffer()
2. if step 1. succeeds, then clear_buffer_dirty(),
   clear_buffer_uptodate(), and set_buffer_write_io_error()

Note that we can't truncate the corrupted page until the error
check is done by kjournald.
 
>>If we merge this patch, we would face the data corruption problem
>>again.
>>
>>I think there are three options,
>>
>>(1) drop this patch
>>(2) merge this patch with new panic_on_dirty_page_cache_corruption
>>    sysctl
>>(3) implement a more sophisticated error_remove_page function
> 
> In fact we proposed a patch for preventing the re-corruption case, see
> 
>         http://lkml.org/lkml/2009/6/11/294
> 
> However it is hard to answer the (policy) question "How sticky should
> the EIO bit remain?".

It's a good approach!  This approach may also solve my concern,
the re-corruption issue caused by transient IO errors.

But I also think it needs a bit more consideration.  For example,
if the application has the valid data in the user space buffer,
it would try to re-write it after detecting an IO error from the
previous write.  In this case, we should clear the sticky error flag.
 
Thanks,
-- 
Hidehiro Kawai
Hitachi, Systems Development Laboratory
Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
