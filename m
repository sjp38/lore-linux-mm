Received: by ti-out-0910.google.com with SMTP id j3so1033653tid.8
        for <linux-mm@kvack.org>; Mon, 19 May 2008 19:32:19 -0700 (PDT)
Message-ID: <44c63dc40805191932t6a386cb7r389b6e5d3d3bf095@mail.gmail.com>
Date: Tue, 20 May 2008 11:32:19 +0900
From: "MinChan Kim" <barrioskmc@gmail.com>
Subject: Re: [PATCH] Fix to return wrong pointer in slob
In-Reply-To: <1211218837.18026.116.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <48317CA8.1080700@gmail.com> <1211218837.18026.116.camel@calx>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: MinChan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, May 20, 2008 at 2:40 AM, Matt Mackall <mpm@selenic.com> wrote:
>
> On Mon, 2008-05-19 at 22:12 +0900, MinChan Kim wrote:
>> Although slob_alloc return NULL, __kmalloc_node returns NULL + align.
>> Because align always can be changed, it is very hard for debugging
>> problem of no page if it don't return NULL.
>>
>> We have to return NULL in case of no page.
>>
>> Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
>> ---
>>  mm/slob.c |    9 ++++++---
>>  1 files changed, 6 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/slob.c b/mm/slob.c
>> index 6038cba..258d76d 100644
>> --- a/mm/slob.c
>> +++ b/mm/slob.c
>> @@ -469,9 +469,12 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
>>                       return ZERO_SIZE_PTR;
>>
>>               m = slob_alloc(size + align, gfp, align, node);
>> -             if (m)
>> -                     *m = size;
>> -             return (void *)m + align;
>> +             if (!m)
>> +                     return NULL;
>> +             else {
>> +                     *m = size;
>> +                     return (void *)m + align;
>> +             }
>
> This looks good, but I would remove the 'else {' and '}' here. It's nice
> to have the 'normal path' minimally indented.

I agree
Thanks, Matt :)


-- 
Thanks,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
