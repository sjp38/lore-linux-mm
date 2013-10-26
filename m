Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 20D9D6B00DB
	for <linux-mm@kvack.org>; Sat, 26 Oct 2013 05:46:03 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id rd3so4783104pab.19
        for <linux-mm@kvack.org>; Sat, 26 Oct 2013 02:46:02 -0700 (PDT)
Received: from psmtp.com ([74.125.245.172])
        by mx.google.com with SMTP id o4si6820807paa.165.2013.10.26.02.46.01
        for <linux-mm@kvack.org>;
        Sat, 26 Oct 2013 02:46:02 -0700 (PDT)
Received: by mail-ie0-f170.google.com with SMTP id at1so8198105iec.1
        for <linux-mm@kvack.org>; Sat, 26 Oct 2013 02:46:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131025102032.GE6612@gmail.com>
References: <000101ced09e$fed90a10$fc8b1e30$%yang@samsung.com>
	<20131025102032.GE6612@gmail.com>
Date: Sat, 26 Oct 2013 17:46:00 +0800
Message-ID: <CAL1ERfOhhJ12zXwsGJoHWRzkd2destQnJ32nfU25SOACCnzy7Q@mail.gmail.com>
Subject: Re: [PATCH RESEND 2/2] mm/zswap: refoctor the get/put routines
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Weijie Yang <weijie.yang@samsung.com>, akpm@linux-foundation.org, sjennings@variantweb.net, bob.liu@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Fri, Oct 25, 2013 at 6:20 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Thu, Oct 24, 2013 at 05:53:32PM +0800, Weijie Yang wrote:
>> The refcount routine was not fit the kernel get/put semantic exactly,
>> There were too many judgement statements on refcount and it could be minus.
>>
>> This patch does the following:
>>
>> - move refcount judgement to zswap_entry_put() to hide resource free function.
>>
>> - add a new function zswap_entry_find_get(), so that callers can use easily
>> in the following pattern:
>>
>>    zswap_entry_find_get
>>    .../* do something */
>>    zswap_entry_put
>>
>> - to eliminate compile error, move some functions declaration
>>
>> This patch is based on Minchan Kim <minchan@kernel.org> 's idea and suggestion.
>>
>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
>> Cc: Seth Jennings <sjennings@variantweb.net>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Bob Liu <bob.liu@oracle.com>
>
>
> I remember Bob had a idea to remove a look up and I think it's doable.
> Anyway, I don't mind you send it with fix or not.

Thanks for review.

Bob's idea is:
"Then how about  use if (!RB_EMPTY_NODE(&entry->rbnode))  to
 replace rbtree searching?"

I'm afraid not. Because entry could be freed in previous zswap_entry_put,
we cann't reference entry or we would touch a free-and-use issue.

> Thanks for handling this, Weijie!
>
> Acked-by: Minchan Kim <minchan@kernel.org>
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
