Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id C385D6B0038
	for <linux-mm@kvack.org>; Sun, 16 Oct 2016 22:01:36 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id e200so347231846oig.4
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 19:01:36 -0700 (PDT)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id 102si10291340ote.180.2016.10.16.19.01.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 16 Oct 2016 19:01:36 -0700 (PDT)
Message-ID: <58042E94.8080405@huawei.com>
Date: Mon, 17 Oct 2016 09:51:16 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] z3fold: remove the unnecessary limit in z3fold_compact_page
References: <1476452125-22059-1-git-send-email-zhongjiang@huawei.com> <CAMJBoFN7VzLYckHL-Zp7onRBvkrx2T-VsVxK3uyqVii3kLpS0A@mail.gmail.com>
In-Reply-To: <CAMJBoFN7VzLYckHL-Zp7onRBvkrx2T-VsVxK3uyqVii3kLpS0A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/10/15 3:25, Vitaly Wool wrote:
> On Fri, Oct 14, 2016 at 3:35 PM, zhongjiang <zhongjiang@huawei.com> wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> z3fold compact page has nothing with the last_chunks. even if
>> last_chunks is not free, compact page will proceed.
>>
>> The patch just remove the limit without functional change.
>>
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  mm/z3fold.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/mm/z3fold.c b/mm/z3fold.c
>> index e8fc216..4668e1c 100644
>> --- a/mm/z3fold.c
>> +++ b/mm/z3fold.c
>> @@ -258,8 +258,7 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
>>
>>
>>         if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private) &&
>> -           zhdr->middle_chunks != 0 &&
>> -           zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
>> +           zhdr->middle_chunks != 0 && zhdr->first_chunks == 0) {
>>                 memmove(beg + ZHDR_SIZE_ALIGNED,
>>                         beg + (zhdr->start_middle << CHUNK_SHIFT),
>>                         zhdr->middle_chunks << CHUNK_SHIFT);
> This check is actually important because if we move the middle chunk
> to the first and leave the last chunk, handles will become invalid and
> there won't be any easy way to fix that.
>
> Best regards,
>    Vitaly
>
> .
>
 Thanks for you reply. you are right. Leave the last chunk to compact will
 lead to the first_num increase. Thus, handle_to_buddy will become invalid.

 Thanks
 zhongjiang
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
