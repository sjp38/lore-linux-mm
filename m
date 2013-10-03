Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9528C6B0031
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 18:39:32 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so3311425pab.41
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 15:39:32 -0700 (PDT)
Received: by mail-ye0-f176.google.com with SMTP id m4so781678yen.7
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 15:39:23 -0700 (PDT)
Message-ID: <524DF246.9050309@gmail.com>
Date: Thu, 03 Oct 2013 18:40:06 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 18/26] mm: Convert process_vm_rw_pages() to use get_user_pages_unlocked()
References: <1380724087-13927-1-git-send-email-jack@suse.cz> <1380724087-13927-19-git-send-email-jack@suse.cz> <524C4AA1.7000409@gmail.com> <20131002193631.GB16998@quack.suse.cz>
In-Reply-To: <20131002193631.GB16998@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

(10/2/13 3:36 PM), Jan Kara wrote:
> On Wed 02-10-13 12:32:33, KOSAKI Motohiro wrote:
>> (10/2/13 10:27 AM), Jan Kara wrote:
>>> Signed-off-by: Jan Kara <jack@suse.cz>
>>> ---
>>>    mm/process_vm_access.c | 8 ++------
>>>    1 file changed, 2 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
>>> index fd26d0433509..c1bc47d8ed90 100644
>>> --- a/mm/process_vm_access.c
>>> +++ b/mm/process_vm_access.c
>>> @@ -64,12 +64,8 @@ static int process_vm_rw_pages(struct task_struct *task,
>>>    	*bytes_copied = 0;
>>>
>>>    	/* Get the pages we're interested in */
>>> -	down_read(&mm->mmap_sem);
>>> -	pages_pinned = get_user_pages(task, mm, pa,
>>> -				      nr_pages_to_copy,
>>> -				      vm_write, 0, process_pages, NULL);
>>> -	up_read(&mm->mmap_sem);
>>> -
>>> +	pages_pinned = get_user_pages_unlocked(task, mm, pa, nr_pages_to_copy,
>>> +					       vm_write, 0, process_pages);
>>>    	if (pages_pinned != nr_pages_to_copy) {
>>>    		rc = -EFAULT;
>>>    		goto end;
>>
>> This is wrong because original code is wrong. In this function, page may
>> be pointed to anon pages. Then, you should keep to take mmap_sem until
>> finish to copying. Otherwise concurrent fork() makes nasty COW issue.
>    Hum, can you be more specific? I suppose you are speaking about situation
> when the remote task we are copying data from/to does fork while
> process_vm_rw_pages() runs. If we are copying data from remote task, I
> don't see how COW could cause any problem. If we are copying to remote task
> and fork happens after get_user_pages() but before copy_to_user() then I
> can see we might be having some trouble. copy_to_user() would then copy
> data into both original remote process and its child thus essentially
> bypassing COW. If the child process manages to COW some of the pages before
> copy_to_user() happens, it can even see only some of the pages. Is that what
> you mean?

scenario 1: vm_write==0

Process P1 call get_user_pages(pa, process_pages) in process_vm_rw_pages
P1 unlock mmap_sem.
Process P2 call fork(). and make P3.
P2 write memory pa. now the "process_pages" is owned by P3 (the child process)
P3 write memory pa. and then the content of "process_pages" is changed.
P1 read process_pages as P2's page. but actually, it is P3's data. Then, P1 observe garbage, at least unintended, data was read.


scenario 2: vm_write==1

Process P1 call get_user_pages(pa, process_pages) in process_vm_rw_pages. It makes COW break and any anon page sharing broke.
P1 unlock mmap_sem.
P2 call fork(). and make P3. And, now COW page sharing is restored.
P2 write memory pa. now the "process_pages" is owned by P3.
P3 write memory pa. it mean P3 changes "process_pages".
P1 write process_pages as P2's page. but actually, it is P3's. It override above P3's write and then P3 observe data corruption.



The solution is to keep holding mmap_sem until finishing process_pages access
because mmap_sem prevent fork. and then race never be happen. I mean you cann't use
get_user_pages_unlock() if target address point to anon pages.

I'm not sure these story match your explanation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
