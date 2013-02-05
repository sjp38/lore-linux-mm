Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <51109352.9070401@cn.fujitsu.com>
Date: Tue, 05 Feb 2013 13:06:26 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] fs/aio.c: use get_user_pages_non_movable() to pin
 ring pages when support memory hotremove
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com> <1359972248-8722-3-git-send-email-linfeng@cn.fujitsu.com> <x49ehgw85w4.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49ehgw85w4.fsf@segfault.boston.devel.redhat.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Tang chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>

Hi Jeff,

On 02/04/2013 11:18 PM, Jeff Moyer wrote:
>> ---
>>  fs/aio.c | 6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/fs/aio.c b/fs/aio.c
>> index 71f613c..0e9b30a 100644
>> --- a/fs/aio.c
>> +++ b/fs/aio.c
>> @@ -138,9 +138,15 @@ static int aio_setup_ring(struct kioctx *ctx)
>>  	}
>>  
>>  	dprintk("mmap address: 0x%08lx\n", info->mmap_base);
>> +#ifdef CONFIG_MEMORY_HOTREMOVE
>> +	info->nr_pages = get_user_pages_non_movable(current, ctx->mm,
>> +					info->mmap_base, nr_pages,
>> +					1, 0, info->ring_pages, NULL);
>> +#else
>>  	info->nr_pages = get_user_pages(current, ctx->mm,
>>  					info->mmap_base, nr_pages, 
>>  					1, 0, info->ring_pages, NULL);
>> +#endif
> 
> Can't you hide this in your 1/1 patch, by providing this function as
> just a static inline wrapper around get_user_pages when
> CONFIG_MEMORY_HOTREMOVE is not enabled?
Good idea, it makes the callers more neatly :)

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
