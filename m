Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A530E6B01AC
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 08:06:03 -0400 (EDT)
Message-ID: <4BA75D20.2060905@panasas.com>
Date: Mon, 22 Mar 2010 14:05:52 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
Subject: Re: [rfc][patch] mm, fs: warn on missing address space operations
References: <20100322053937.GA17637@laptop> <4BA7359B.2060603@panasas.com> <20100322105442.GH17637@laptop>
In-Reply-To: <20100322105442.GH17637@laptop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 03/22/2010 12:54 PM, Nick Piggin wrote:
> On Mon, Mar 22, 2010 at 11:17:15AM +0200, Boaz Harrosh wrote:
>> ---
>> git diff --stat -p -M fs/exofs/inode.c
>>  fs/exofs/inode.c |    8 ++++++++
>>  1 files changed, 8 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
>> index a17e4b7..85dd847 100644
>> --- a/fs/exofs/inode.c
>> +++ b/fs/exofs/inode.c
>> @@ -754,6 +754,11 @@ static int exofs_write_end(struct file *file, struct address_space *mapping,
>>  	return ret;
>>  }
>>  
>> +static int exofs_releasepage(struct page *page, gfp_t gfp)
>> +{
>> +	return try_to_free_buffers(page);
>> +}
>> +
>>  const struct address_space_operations exofs_aops = {
>>  	.readpage	= exofs_readpage,
>>  	.readpages	= exofs_readpages,
>> @@ -761,6 +766,9 @@ const struct address_space_operations exofs_aops = {
>>  	.writepages	= exofs_writepages,
>>  	.write_begin	= exofs_write_begin_export,
>>  	.write_end	= exofs_write_end,
>> +	.releasepage	= exofs_releasepage,
>> +	.set_page_dirty	= __set_page_dirty_buffers,
>> +	.invalidatepage = block_invalidatepage,
>>  };
> 
> AFAIKS, you aren't using buffer heads at all (except nobh_truncate,
> which will not attach buffers to pages)?
> 
> If so, you should only need __set_page_dirty_nobuffers.
> 

Ho, thanks, that one is much better, yes.

BTW:
The use of nobh_truncate, I hope will go away after your:
	fs: truncate introduce new sequence
with these two helpers you added I can actually get rid of
that as well. (I think. I keep postponing this work ;-))

> Thanks,
> Nick
> 

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
