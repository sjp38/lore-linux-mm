From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rd: Preserve the dirty bit in init_page_buffers()
References: <200710151028.34407.borntraeger@de.ibm.com>
	<m18x64knqx.fsf@ebiederm.dsl.xmission.com>
	<m14pgsknmd.fsf_-_@ebiederm.dsl.xmission.com>
	<200710161812.01970.nickpiggin@yahoo.com.au>
Date: Tue, 16 Oct 2007 03:35:08 -0600
In-Reply-To: <200710161812.01970.nickpiggin@yahoo.com.au> (Nick Piggin's
	message of "Tue, 16 Oct 2007 18:12:01 +1000")
Message-ID: <m1przfh06r.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

> On Tuesday 16 October 2007 08:40, Eric W. Biederman wrote:
>> The problem:  When we are trying to free buffers try_to_free_buffers()
>> will look at ramdisk pages with clean buffer heads and remove the
>> dirty bit from the page.  Resulting in ramdisk pages with data that get
>> removed from the page cache.  Ouch!
>>
>> Buffer heads appear on ramdisk pages when a filesystem calls
>> __getblk() which through a series of function calls eventually calls
>> init_page_buffers().
>>
>> So to fix the mismatch between buffer head and page state this patch
>> modifies init_page_buffers() to transfer the dirty bit from the page to
>> the buffer heads like we currently do for the uptodate bit.
>>
>> This patch is safe as only __getblk calls init_page_buffers, and
>> there are only two implementations of block devices cached in the
>> page cache.  The generic implementation in block_dev.c and the
>> implementation in rd.c.
>>
>> The generic implementation of block devices always does everything
>> in terms of buffer heads so it always has buffer heads allocated
>> before a page is marked dirty so this change does not affect it.
>
> This is probably a good idea. Was this causing the reiserfs problems?
> If so, I think we should be concentrating on what the real problem
> is with reiserfs... (or at least why this so obviously correct
> looking patch is wrong).

I think it was my cleanup patch that was sitting on top of this,
That caused the problems.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
