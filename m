Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id BC8ED6B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 05:39:10 -0400 (EDT)
Received: by iec9 with SMTP id 9so5630692iec.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 02:39:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLEb7qCo4uZUJtNDkYMFLE9aGT1fV9Wyw+Jpu2-kSqhX2g@mail.gmail.com>
References: <1344955130-29478-1-git-send-email-elezegarcia@gmail.com>
	<CAOJsxLEb7qCo4uZUJtNDkYMFLE9aGT1fV9Wyw+Jpu2-kSqhX2g@mail.gmail.com>
Date: Tue, 4 Sep 2012 06:39:09 -0300
Message-ID: <CALF0-+V0JQ08vURjdqhT7FemSt=+TYOW-Q-7D4KoLGwVsHB8iA@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm, slob: Prevent false positive trace upon
 allocation failure
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>

Hi Pekka,

On Tue, Sep 4, 2012 at 4:32 AM, Pekka Enberg <penberg@kernel.org> wrote:
> Hi Ezequiel,
>
> On Tue, Aug 14, 2012 at 5:38 PM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
>> This patch changes the __kmalloc_node() logic to return NULL
>> if alloc_pages() fails to return valid pages.
>> This is done to avoid to trace a false positive kmalloc event.
>>
>> Cc: Pekka Enberg <penberg@kernel.org>
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: Glauber Costa <glommer@parallels.com>
>> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
>> ---
>>  mm/slob.c |   11 ++++++-----
>>  1 files changed, 6 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/slob.c b/mm/slob.c
>> index 45d4ca7..686e98b 100644
>> --- a/mm/slob.c
>> +++ b/mm/slob.c
>> @@ -450,15 +450,16 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
>>                                    size, size + align, gfp, node);
>>         } else {
>>                 unsigned int order = get_order(size);
>> +               struct page *page;
>>
>>                 if (likely(order))
>>                         gfp |= __GFP_COMP;
>>                 ret = slob_new_pages(gfp, order, node);
>> -               if (ret) {
>> -                       struct page *page;
>> -                       page = virt_to_page(ret);
>> -                       page->private = size;
>> -               }
>> +               if (!ret)
>> +                       return NULL;
>> +
>> +               page = virt_to_page(ret);
>> +               page->private = size;
>>
>>                 trace_kmalloc_node(_RET_IP_, ret,
>>                                    size, PAGE_SIZE << order, gfp, node);
>
> As mentioned earlier, I think it's valuable for the userspace to be
> able to trace allocation failures as well. So I'm not applying this
> patch.

Yes, you're right. I have a few patches for that.

Thanks!
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
