Message-ID: <464A501A.3080209@yahoo.com.au>
Date: Wed, 16 May 2007 10:28:10 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] resolve duplicate flag no for PG_lazyfree
References: <379110250.28666@ustc.edu.cn>	<20070513224630.3cd0cb54.akpm@linux-foundation.org>	<20070514180618.GB9399@thunk.org> <20070514134606.695f087a.akpm@linux-foundation.org>
In-Reply-To: <20070514134606.695f087a.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Theodore Tso <tytso@mit.edu>, Fengguang Wu <fengguang.wu@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 14 May 2007 14:06:19 -0400
> Theodore Tso <tytso@mit.edu> wrote:
> 
> 
>>On Sun, May 13, 2007 at 10:46:30PM -0700, Andrew Morton wrote:
>>
>>>otoh, the intersection between pages which are PageBooked() and pages which
>>>are PageLazyFree() should be zreo, so it'd be good to actually formalise
>>>this reuse within the ext4 patches.
>>>
>>>otoh2, PageLazyFree() could have reused PG_owner_priv_1.
>>>
>>>Rik, Ted: any thoughts?  We do need to scrimp on page flags: when we
>>>finally run out, we're screwed.
>>
>>It makes sense to me.  PG_lazyfree is currently only in -mm, right?
> 
> 
> Ah, yes, I got confused, sorry.
> 
> 
>> I
>>don't see it in my git tree.  It would probably would be a good idea
>>to make sure that we check to add some sanity checking code if it
>>isn't there already that PG_lazyfree isn't already set when try to set
>>PG_lazyfree (just in case there is a bug in the future which causes
>>the should-never-happen case of trying lazy free a PageBooked page).
>>
> 
> 
> Actually, I think the current status of
> lazy-freeing-of-memory-through-madv_free.patch is "might not be needed".  I
> _think_ we've determined that 0a27a14a62921b438bb6f33772690d345a089be6
> sufficiently fixed the perfomance problems we had in there?

I think so far we've found that it fixes the MySQL scalability problem,
yes. I couldn't see any statistically significant difference with MySQL
in my tests with MADV_FREE (versus MADV_DONTNEED).

ebizzy is improved a bit at low concurrency but drops off slightly at
higher concurrency.

But basically, I don't think we've found a good reason to use a page
flag and introduce the potential performance regressions that the
MADV_FREE patch has.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
