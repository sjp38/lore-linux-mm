Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 979A36B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 00:05:08 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id q18so92040048igr.2
        for <linux-mm@kvack.org>; Sun, 05 Jun 2016 21:05:08 -0700 (PDT)
Received: from mail-oi0-x245.google.com (mail-oi0-x245.google.com. [2607:f8b0:4003:c06::245])
        by mx.google.com with ESMTPS id g33si7994936otg.199.2016.06.05.21.05.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Jun 2016 21:05:07 -0700 (PDT)
Received: by mail-oi0-x245.google.com with SMTP id s139so139609706oie.0
        for <linux-mm@kvack.org>; Sun, 05 Jun 2016 21:05:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5739B60E.1090700@suse.cz>
References: <1462713387-16724-1-git-send-email-anthony.romano@coreos.com>
	<5739B60E.1090700@suse.cz>
Date: Sun, 5 Jun 2016 21:05:07 -0700
Message-ID: <CAEm7Ktz4+caoGn+G0njRR-JtdbO1pKMfjA7XykKMFBzovmgyag@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: don't undo fallocate past its last page
From: Brandon Philips <brandon@ifup.co>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Anthony Romano <anthony.romano@coreos.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Cong Wang <amwang@redhat.com>, Kay Sievers <kay@vrfy.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Garrett <mjg59@srcf.ucam.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 16, 2016 at 4:59 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 05/08/2016 03:16 PM, Anthony Romano wrote:
>>
>> When fallocate is interrupted it will undo a range that extends one byte
>> past its range of allocated pages. This can corrupt an in-use page by
>> zeroing out its first byte. Instead, undo using the inclusive byte range.
>
>
> Huh, good catch. So why is shmem_undo_range() adding +1 to the value in the
> first place? The only other caller is shmem_truncate_range() and all *its*
> callers do subtract 1 to avoid the same issue. So a nicer fix would be to
> remove all this +1/-1 madness. Or is there some subtle corner case I'm
> missing?

Bumping this thread as I don't think this patch has gotten picked up.
And cc'ing folks from 1635f6a74152f1dcd1b888231609d64875f0a81a.

Also, resending because I forgot to remove the HTML mime-type to make
vger happy.

Thank you,

Brandon


>> Signed-off-by: Anthony Romano <anthony.romano@coreos.com>
>
>
> Looks like a stable candidate patch. Can you point out the commit that
> introduced the bug, for the Fixes: tag?
>
> Thanks,
> Vlastimil
>
>
>> ---
>>   mm/shmem.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 719bd6b..f0f9405 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -2238,7 +2238,7 @@ static long shmem_fallocate(struct file *file, int
>> mode, loff_t offset,
>>                         /* Remove the !PageUptodate pages we added */
>>                         shmem_undo_range(inode,
>>                                 (loff_t)start << PAGE_SHIFT,
>> -                               (loff_t)index << PAGE_SHIFT, true);
>> +                               ((loff_t)index << PAGE_SHIFT) - 1, true);
>>                         goto undone;
>>                 }
>>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
