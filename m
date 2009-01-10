Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 93D8B6B0095
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 19:27:13 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id n0A0RADE023830
	for <linux-mm@kvack.org>; Sat, 10 Jan 2009 00:27:10 GMT
Received: from rv-out-0708.google.com (rvfb17.prod.google.com [10.140.179.17])
	by spaceape14.eur.corp.google.com with ESMTP id n0A0Qpmo008043
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 16:27:08 -0800
Received: by rv-out-0708.google.com with SMTP id b17so9347719rvf.48
        for <linux-mm@kvack.org>; Fri, 09 Jan 2009 16:27:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <604427e00901081840pa6dcc41u9a7a5c69302c7b60@mail.gmail.com>
References: <604427e00901051539x52ab85bcua94cd8036e5b619a@mail.gmail.com>
	 <604427e00901081840pa6dcc41u9a7a5c69302c7b60@mail.gmail.com>
Date: Fri, 9 Jan 2009 16:27:07 -0800
Message-ID: <604427e00901091627n7c909abt6aa1f01c181ad65d@mail.gmail.com>
Subject: Re: [PATCH]Fix: 32bit binary has 64bit address of stack vma
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

friendly ping...

On Thu, Jan 8, 2009 at 6:40 PM, Ying Han <yinghan@google.com> wrote:
> On Mon, Jan 5, 2009 at 3:39 PM, Ying Han <yinghan@google.com> wrote:
>> From: Ying Han <yinghan@google.com>
>>
>> Fix 32bit binary get 64bit stack vma offset.
>>
>> 32bit binary running on 64bit system, the /proc/pid/maps shows for the
>> vma represents stack get a 64bit adress:
>> ff96c000-ff981000 rwxp 7ffffffea000 00:00 0 [stack]
>>
>> Signed-off-by:  Ying Han <yinghan@google.com>
>>
>> fs/exec.c                     |    5 +-
>>
>> diff --git a/fs/exec.c b/fs/exec.c
>> index 4e834f1..8c3eff4 100644
>> --- a/fs/exec.c
>> +++ b/fs/exec.c
>> @@ -517,6 +517,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, uns
>>        unsigned long length = old_end - old_start;
>>        unsigned long new_start = old_start - shift;
>>        unsigned long new_end = old_end - shift;
>> +       unsigned long new_pgoff = new_start >> PAGE_SHIFT;
>>        struct mmu_gather *tlb;
>>
>>        BUG_ON(new_start > new_end);
>> @@ -531,7 +532,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, uns
>>        /*
>>         * cover the whole range: [new_start, old_end)
>>         */
>> -       vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL);
>> +       vma_adjust(vma, new_start, old_end, new_pgoff, NULL);
>>
>>        /*
>>         * move the page tables downwards, on failure we rely on
>> @@ -564,7 +565,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, uns
>>        /*
>>         * shrink the vma to just the new range.
>>         */
>> -       vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
>> +       vma_adjust(vma, new_start, new_end, new_pgoff, NULL);
>>
>>        return 0;
>>  }
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
