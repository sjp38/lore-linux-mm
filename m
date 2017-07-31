Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 804D66B05E1
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 07:32:39 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l22so103709317qtf.9
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 04:32:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d56si24315090qtf.418.2017.07.31.04.32.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 04:32:38 -0700 (PDT)
Subject: Re: [PATCH v2 2/4] mm: add file_fdatawait_range and
 file_write_and_wait
References: <20170726175538.13885-1-jlayton@kernel.org>
 <20170726175538.13885-3-jlayton@kernel.org>
 <20170727084914.GC21100@quack2.suse.cz> <1501159710.6279.1.camel@redhat.com>
 <1501500421.4663.4.camel@redhat.com>
From: Steven Whitehouse <swhiteho@redhat.com>
Message-ID: <8d46c4c6-76b5-9726-7d85-249cd9a899f1@redhat.com>
Date: Mon, 31 Jul 2017 12:32:31 +0100
MIME-Version: 1.0
In-Reply-To: <1501500421.4663.4.camel@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>, Jan Kara <jack@suse.cz>, Marcelo Tosatti <mtosatti@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

Hi,


On 31/07/17 12:27, Jeff Layton wrote:
> On Thu, 2017-07-27 at 08:48 -0400, Jeff Layton wrote:
>> On Thu, 2017-07-27 at 10:49 +0200, Jan Kara wrote:
>>> On Wed 26-07-17 13:55:36, Jeff Layton wrote:
>>>> +int file_write_and_wait(struct file *file)
>>>> +{
>>>> +	int err = 0, err2;
>>>> +	struct address_space *mapping = file->f_mapping;
>>>> +
>>>> +	if ((!dax_mapping(mapping) && mapping->nrpages) ||
>>>> +	    (dax_mapping(mapping) && mapping->nrexceptional)) {
>>>> +		err = filemap_fdatawrite(mapping);
>>>> +		/* See comment of filemap_write_and_wait() */
>>>> +		if (err != -EIO) {
>>>> +			loff_t i_size = i_size_read(mapping->host);
>>>> +
>>>> +			if (i_size != 0)
>>>> +				__filemap_fdatawait_range(mapping, 0,
>>>> +							  i_size - 1);
>>>> +		}
>>>> +	}
>>> Err, what's the i_size check doing here? I'd just pass ~0 as the end of the
>>> range and ignore i_size. It is much easier than trying to wrap your head
>>> around possible races with file operations modifying i_size.
>>>
>>> 								Honza
>> I'm basically emulating _exactly_ what filemap_write_and_wait does here,
>> as I'm leery of making subtle behavior changes in the actual writeback
>> behavior. For example:
>>
>> -----------------8<----------------
>> static inline int __filemap_fdatawrite(struct address_space *mapping,
>>          int sync_mode)
>> {
>>          return __filemap_fdatawrite_range(mapping, 0, LLONG_MAX, sync_mode);
>> }
>>
>> int filemap_fdatawrite(struct address_space *mapping)
>> {
>>          return __filemap_fdatawrite(mapping, WB_SYNC_ALL);
>> }
>> EXPORT_SYMBOL(filemap_fdatawrite);
>> -----------------8<----------------
>>
>> ...which then sets up the wbc with the right ranges and sync mode and
>> kicks off writepages. But then, it does the i_size_read to figure out
>> what range it should wait on (with the shortcut for the size == 0 case).
>>
>> My assumption was that it was intentionally designed that way, but I'm
>> guessing from your comments that it wasn't? If so, then we can turn
>> file_write_and_wait a static inline wrapper around
>> file_write_and_wait_range.
> FWIW, I did a bit of archaeology in the linux-history tree and found
> this patch from Marcelo in 2004. Is this optimization still helpful? If
> not, then that does simplify the code a bit.
>
> -------------------8<--------------------
>
> [PATCH] small wait_on_page_writeback_range() optimization
>
> filemap_fdatawait() calls wait_on_page_writeback_range() with -1 as "end"
> parameter.  This is not needed since we know the EOF from the inode.  Use
> that instead.
>
> Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>
> Signed-off-by: Linus Torvalds <torvalds@osdl.org>
> ---
>   mm/filemap.c | 8 +++++++-
>   1 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 78e18b7639b6..55fb7b4141e4 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -287,7 +287,13 @@ EXPORT_SYMBOL(sync_page_range);
>    */
>   int filemap_fdatawait(struct address_space *mapping)
>   {
> -	return wait_on_page_writeback_range(mapping, 0, -1);
> +	loff_t i_size = i_size_read(mapping->host);
> +
> +	if (i_size == 0)
> +		return 0;
> +
> +	return wait_on_page_writeback_range(mapping, 0,
> +				(i_size - 1) >> PAGE_CACHE_SHIFT);
>   }
>   EXPORT_SYMBOL(filemap_fdatawait);
>

Does this ever get called in cases where we would not hold fs locks? In 
that case we definitely don't want to be relying on i_size,

Steve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
