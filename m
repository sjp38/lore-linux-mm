Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8EB876B0092
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 09:24:47 -0400 (EDT)
Message-ID: <4CAF1B90.3080703@redhat.com>
Date: Fri, 08 Oct 2010 09:24:32 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] Retry page fault when blocking on disk transfer.
References: <1286265215-9025-1-git-send-email-walken@google.com> <1286265215-9025-3-git-send-email-walken@google.com> <4CAB628D.3030205@redhat.com> <AANLkTimdACZ9Xm01DM2+E64+T5XfLffrkFBhf7CJ286p@mail.gmail.com> <20101008043956.GA25662@google.com>
In-Reply-To: <20101008043956.GA25662@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On 10/08/2010 12:39 AM, Michel Lespinasse wrote:
> On Tue, Oct 05, 2010 at 03:44:22PM -0700, Michel Lespinasse wrote:
>> On Tue, Oct 5, 2010 at 10:38 AM, Rik van Riel<riel@redhat.com>  wrote:
>>> Looks like it should be relatively easy to do something
>>> similar in do_swap_page also.
>>
>> Good idea. We don't make use of swap too much, which is probably why
>> we didn't have that in our kernel, but it seems like a good idea just
>> for uniformity. I'll add this in a follow-on patch.
>
> So here's the patch. Sorry for the delay - it did not take long to write,
> but I couldn't test it before today.
>
> Please have a look - I'd like to add this to the series I sent earlier.
>
> ----------------------------------- 8<  ---------------------------------
>
> Retry page fault when blocking on swap in
>
> This change is the cousin of 'Retry page fault when blocking
> on disk transfer'. The idea here is to reduce mmap_sem hold times
> that are caused by disk transfers when swapping in pages. We drop
> mmap_sem while waiting for the page lock, and return the VM_FAULT_RETRY
> flag. do_page_fault will then re-acquire mmap_sem and retry the
> page fault. It is expected that upon retry the page will now be cached,
> and thus the retry will complete with a low mmap_sem hold time.
>
> Signed-off-by: Michel Lespinasse<walken@google.com>
>
> diff --git a/mm/memory.c b/mm/memory.c
> index b068c68..0ec70b4 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2613,6 +2613,21 @@ int vmtruncate_range(struct inode *inode, loff_t offset, loff_t end)
>   	return 0;
>   }
>
> +static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
> +				     unsigned int flags)
> +{
> +	if (trylock_page(page))
> +		return 1;
> +	if (!(flags&  FAULT_FLAG_ALLOW_RETRY)) {
> +		__lock_page(page);
> +		return 1;
> +	}
> +
> +	up_read(&mm->mmap_sem);
> +	wait_on_page_locked(page);
> +	return 0;
> +}

Wait a moment.  Your other patch 2/3 also has a
lock_page_or_retry function.  That one is in
filemap.c and takes slightly different arguments,
to do essentially the same thing...

+/*
+ * Lock the page, unless this would block and the caller indicated that it
+ * can handle a retry.
+ */
+static int lock_page_or_retry(struct page *page,
+			      struct vm_area_struct *vma, struct vm_fault *vmf)
+{

Is there a way the two functions can be merged
into one?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
