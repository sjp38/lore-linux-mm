Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 572176B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 22:14:55 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so60615618wic.0
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 19:14:54 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id ba4si13496918wjb.106.2015.09.26.19.14.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 19:14:54 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so63660272wic.0
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 19:14:53 -0700 (PDT)
Message-ID: <5607511B.7030808@gmail.com>
Date: Sun, 27 Sep 2015 04:14:51 +0200
From: angelo <angelo70@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix cpu hangs on truncating last page of a 16t sparse
 file
References: <560723F8.3010909@gmail.com> <alpine.LSU.2.11.1509261835360.9917@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1509261835360.9917@eggly.anvils>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hugh,

thanks for the fast reply..

Looks like the XFS file system can support files until 16 Tera
when CONFIG_LBDAF is enabled.

On XFS, 32 bit arch, s_maxbytes is actually set (CONFIG_LBDAF=y) as
17592186044415.

But if s_maxbytes doesn't have to be greater than MAX_LFS_FILESIZE,
i agree the issue should be fixed in layers above.

The fact is that everything still works correct until an index as
17592186044415 - 4096, and there can be users that could already
have so big files in use in their setup.

What do you think ?

Best regards
Angelo Dureghello


On 27/09/2015 03:36, Hugh Dickins wrote:
> Let's Cc linux-fsdevel, who will be more knowledgable.
>
> On Sun, 27 Sep 2015, angelo wrote:
>
>> Hi all,
>>
>> running xfstests, generic 308 on whatever 32bit arch is possible
>> to observe cpu to hang near 100% on unlink.
>> The test removes a sparse file of length 16tera where only the last
>> 4096 bytes block is mapped.
>> At line 265 of truncate.c there is a
>> if (index >= end)
>>      break;
>> But if index is, as in this case, a 4294967295, it match -1 used as
>> eof. Hence the cpu loops 100% just after.
> That's odd.  I've not checked your patch, because I think the problem
> would go beyond truncate, and the root cause lie elsewhere.
>
> My understanding is that the 32-bit
> #define MAX_LFS_FILESIZE (((loff_t)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1)
> makes a page->index of -1 (or any "negative") impossible to reach.
>
> I don't know offhand the rules for mounting a filesystem populated with
> a 64-bit kernel on a 32-bit kernel, what's to happen when a too-large
> file is encountered; but assume that's not the case here - you're
> just running xfstests/tests/generic/308.
>
> Is pwrite missing a check for offset beyond s_maxbytes?
>
> Or is this filesystem-dependent?  Which filesystem?
>
> Hugh
>
>> -------------------
>>
>> On 32bit archs, with CONFIG_LBDAF=y, if truncating last page
>> of a 16tera file, "index" variable is set to 4294967295, and hence
>> matches with -1 used as EOF value. This result in an inifite loop
>> when unlink is executed on this file.
>>
>> Signed-off-by: Angelo Dureghello <angelo@sysam.it>
>> ---
>>   mm/truncate.c | 11 ++++++-----
>>   1 file changed, 6 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/truncate.c b/mm/truncate.c
>> index 76e35ad..3751034 100644
>> --- a/mm/truncate.c
>> +++ b/mm/truncate.c
>> @@ -283,14 +283,15 @@ void truncate_inode_pages_range(struct address_space
>> *mapping,
>>                  pagevec_remove_exceptionals(&pvec);
>>                  pagevec_release(&pvec);
>>                  cond_resched();
>> -               index++;
>> +               if (index < end)
>> +                       index++;
>>          }
>>
>>          if (partial_start) {
>>                  struct page *page = find_lock_page(mapping, start - 1);
>>                  if (page) {
>>                          unsigned int top = PAGE_CACHE_SIZE;
>> -                       if (start > end) {
>> +                       if (start > end && end != -1) {
>>                                  /* Truncation within a single page */
>>                                  top = partial_end;
>>                                  partial_end = 0;
>> @@ -322,7 +323,7 @@ void truncate_inode_pages_range(struct address_space
>> *mapping,
>>           * If the truncation happened within a single page no pages
>>           * will be released, just zeroed, so we can bail out now.
>>           */
>> -       if (start >= end)
>> +       if (start >= end && end != -1)
>>                  return;
>>
>>          index = start;
>> @@ -337,7 +338,7 @@ void truncate_inode_pages_range(struct address_space
>> *mapping,
>>                          index = start;
>>                          continue;
>>                  }
>> -               if (index == start && indices[0] >= end) {
>> +               if (index == start && (indices[0] >= end && end != -1)) {
>>                          /* All gone out of hole to be punched, we're done */
>>                          pagevec_remove_exceptionals(&pvec);
>>                          pagevec_release(&pvec);
>> @@ -348,7 +349,7 @@ void truncate_inode_pages_range(struct address_space
>> *mapping,
>>
>>                          /* We rely upon deletion not changing page->index */
>>                          index = indices[i];
>> -                       if (index >= end) {
>> +                       if (index >= end && (end != -1)) {
>>                                  /* Restart punch to make sure all gone */
>>                                  index = start - 1;
>>                                  break;
>> -- 
>> 2.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
