Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <51109A38.7050605@cn.fujitsu.com>
Date: Tue, 05 Feb 2013 13:35:52 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] fs/aio.c: use get_user_pages_non_movable() to pin
 ring pages when support memory hotremove
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com> <1359972248-8722-3-git-send-email-linfeng@cn.fujitsu.com> <x49ehgw85w4.fsf@segfault.boston.devel.redhat.com> <20130204230209.GK14246@lenny.home.zabbo.net>
In-Reply-To: <20130204230209.GK14246@lenny.home.zabbo.net>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zach Brown <zab@redhat.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Tang chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>

Hi Zach,

On 02/05/2013 07:02 AM, Zach Brown wrote:
>>> index 71f613c..0e9b30a 100644
>>> --- a/fs/aio.c
>>> +++ b/fs/aio.c
>>> @@ -138,9 +138,15 @@ static int aio_setup_ring(struct kioctx *ctx)
>>>  	}
>>>  
>>>  	dprintk("mmap address: 0x%08lx\n", info->mmap_base);
>>> +#ifdef CONFIG_MEMORY_HOTREMOVE
>>> +	info->nr_pages = get_user_pages_non_movable(current, ctx->mm,
>>> +					info->mmap_base, nr_pages,
>>> +					1, 0, info->ring_pages, NULL);
>>> +#else
>>>  	info->nr_pages = get_user_pages(current, ctx->mm,
>>>  					info->mmap_base, nr_pages, 
>>>  					1, 0, info->ring_pages, NULL);
>>> +#endif
>>
>> Can't you hide this in your 1/1 patch, by providing this function as
>> just a static inline wrapper around get_user_pages when
>> CONFIG_MEMORY_HOTREMOVE is not enabled?
> 
> Yes, please.  Having callers duplicate the call site for a single
> optional boolean input is unacceptable.
I will deal with it in next version :)

> 
> But do we want another input argument as a name?  Should aio have been
> using get_user_pages_fast()? (and so now _fast_non_movable?)
> 
> I wonder if it's time to offer the booleans as a _flags() variant, much
> like the current internal flags for __get_user_pages().  The write and
> force arguments are already booleans, we have a different fast api, and
> now we're adding non-movable.  The NON_MOVABLE flag would be 0 without
> MEMORY_HOTREMOVE, easy peasy.
As my next reply-mail mentioned, IIUC in GUP case additional flags seems doesn't work,
 I abstract here:

As I debuged the get_user_pages(), I found that some pages is already there and may be
allocated before we call get_user_pages(). __get_user_pages() have following logic to
handle such case.
1786                         while (!(page = follow_page(vma, start, foll_flags))) {
1787                                 int ret;
To such case an additional alloc-flag or such doesn't work, it's difficult to keep GUP
as smart as we want  , so I worked out the migration approach to get around and 
avoid messing up the current code.

And even worse we have already got *8* arguments...Maybe we have to rework the boolean 
arguments into bit flags... It seems not a little work :(
> 
> Turning current callers' mysterious '1, 1' in to 'WRITE|FORCE' might
> also be nice :).
Agree, maybe we could handle them later :)

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
