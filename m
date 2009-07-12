Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C080F6B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 04:42:16 -0400 (EDT)
Message-ID: <4A59A517.1080605@panasas.com>
Date: Sun, 12 Jul 2009 11:55:51 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
Subject: Re: [rfc][patch 3/4] fs: new truncate sequence
References: <20090707144823.GE2714@wotan.suse.de> <20090707145820.GA9976@infradead.org> <20090707150257.GG2714@wotan.suse.de> <20090707150758.GA18075@infradead.org> <20090707154809.GH2714@wotan.suse.de> <20090707163042.GA14947@infradead.org> <20090708063225.GL2714@wotan.suse.de> <20090708104701.GA31419@infradead.org> <20090708123412.GQ2714@wotan.suse.de> <4A54C435.1000503@panasas.com> <20090709075100.GU2714@wotan.suse.de>
In-Reply-To: <20090709075100.GU2714@wotan.suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/09/2009 10:51 AM, Nick Piggin wrote:
> On Wed, Jul 08, 2009 at 07:07:17PM +0300, Boaz Harrosh wrote:
>> On 07/08/2009 03:34 PM, Nick Piggin wrote:
>>> On Wed, Jul 08, 2009 at 06:47:01AM -0400, Christoph Hellwig wrote:
>>> Index: linux-2.6/fs/attr.c
>>> ===================================================================
>>> --- linux-2.6.orig/fs/attr.c
>>> +++ linux-2.6/fs/attr.c
>>> @@ -112,7 +112,12 @@ int inode_setattr(struct inode * inode,
>>>  
>>>  	if (ia_valid & ATTR_SIZE &&
>>>  	    attr->ia_size != i_size_read(inode)) {
>>> -		int error = vmtruncate(inode, attr->ia_size);
>>> +		int error;
>>> +
>>> +		if (inode->i_op->new_truncate)
>>> +			error = simple_setsize(inode, attr->ia_size);
>> I don't understand this branch.
>> If a filesystem has been converted to set "i_op->new_truncate=true"
>> then it must have been converted to intersect ->setattr and has set
>> the i_size (And needs to clear ATTR_SIZE, why?)
>>
>> All other cases of systems not converted, or systems that do not have
>> ->truncate will fall to the "else" part.
>>
>> before the removal of i_op->new_truncate you will need to do something
>> with the systems that do not have ->truncate which will be a 
>> .setattr = simple_setattr or something
>>
>> So I don't understand this conditional
> 
> inode_setattr *is* our "simple_setattr".
> 

I wish you would split it.

one - helper to be called by converted file systems
      (Which just ignores the ATTR_SIZE)
second - to be set into .setattr which does the simple_setsize + above.

More clear for FS users like me (and that ugly unmask of ATTR_SIZE)

or it's just me?

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
