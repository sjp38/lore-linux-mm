Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F03E6B03A0
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 11:10:08 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 70so13450576its.15
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:10:08 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0095.outbound.protection.outlook.com. [104.47.1.95])
        by mx.google.com with ESMTPS id t199si1472199oit.65.2017.04.19.08.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 19 Apr 2017 08:10:07 -0700 (PDT)
Subject: Re: [PATCH 1/4] fs: fix data invalidation in the cleancache during
 direct IO
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
 <20170414140753.16108-2-aryabinin@virtuozzo.com>
 <20170418193808.GA16667@linux.intel.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <ac3b6a27-4345-53cf-04b5-c1f74e680695@virtuozzo.com>
Date: Wed, 19 Apr 2017 18:11:31 +0300
MIME-Version: 1.0
In-Reply-To: <20170418193808.GA16667@linux.intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Steve French <sfrench@samba.org>, Matthew Wilcox <mawilcox@microsoft.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org

On 04/18/2017 10:38 PM, Ross Zwisler wrote:
> On Fri, Apr 14, 2017 at 05:07:50PM +0300, Andrey Ryabinin wrote:
>> Some direct write fs hooks call invalidate_inode_pages2[_range]()
>> conditionally iff mapping->nrpages is not zero. If page cache is empty,
>> buffered read following after direct IO write would get stale data from
>> the cleancache.
>>
>> Also it doesn't feel right to check only for ->nrpages because
>> invalidate_inode_pages2[_range] invalidates exceptional entries as well.
>>
>> Fix this by calling invalidate_inode_pages2[_range]() regardless of nrpages
>> state.
>>
>> Fixes: c515e1fd361c ("mm/fs: add hooks to support cleancache")
>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> ---
> <>
>> diff --git a/fs/dax.c b/fs/dax.c
>> index 2e382fe..1e8cca0 100644
>> --- a/fs/dax.c
>> +++ b/fs/dax.c
>> @@ -1047,7 +1047,7 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>>  	 * into page tables. We have to tear down these mappings so that data
>>  	 * written by write(2) is visible in mmap.
>>  	 */
>> -	if ((iomap->flags & IOMAP_F_NEW) && inode->i_mapping->nrpages) {
>> +	if ((iomap->flags & IOMAP_F_NEW)) {
>>  		invalidate_inode_pages2_range(inode->i_mapping,
>>  					      pos >> PAGE_SHIFT,
>>  					      (end - 1) >> PAGE_SHIFT);
> 
> tl;dr: I think the old code is correct, and that you don't need this change.
> 
> This should be harmless, but could slow us down a little if we keep
> calling invalidate_inode_pages2_range() without really needing to.  Really for
> DAX I think we need to call invalidate_inode_page2_range() only if we have
> zero pages mapped over the place where we are doing I/O, which is why we check
> nrpages.
> 

Check for ->nrpages only looks strange, because invalidate_inode_pages2_range() also
invalidates exceptional radix tree entries. Is that correct that we invalidate
exceptional entries only if ->nrpages > 0 and skip invalidation otherwise?


> Is DAX even allowed to be used at the same time as cleancache?  From a brief
> look at Documentation/vm/cleancache.txt, it seems like these two features are
> incompatible.  With DAX we already are avoiding the page cache completely.

tl;dr: I think you're right.

cleancache may store any PageUptodate && PageMappedToDisk page evicted from page cache (see __delete_from_page_cache)
DAX deletes hole page via __delete_from_page_cache(), but I don't see we mark such page as Uptodate or MappedToDisk
so it will never go into the cleancache.

Latter cleancache_get_page() (e.g. it's called from mpage_readpages() which is called from blkdev_read_pages())
I assume that DAX doesn't use a_ops->readpages() method so cleancache_get_page() is never called from DAX.


> Anyway, I don't see how this change in DAX can save us from a data corruption
> (which is what you're seeing, right?), and I think it could slow us down, so
> I'd prefer to leave things as they are.
> 

I'll remove this hunk from v2.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
