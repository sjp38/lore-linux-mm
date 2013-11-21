Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7F36B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 17:34:09 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id y10so407523wgg.14
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 14:34:09 -0800 (PST)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id x19si1574664wie.11.2013.11.21.14.34.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 14:34:09 -0800 (PST)
Received: by mail-wi0-f177.google.com with SMTP id cc10so415973wib.10
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 14:34:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAL1ERfNNAZCS58K9mT85wxQfH8B3AyR4aLE8r745me1dJRmPfg@mail.gmail.com>
References: <1384976824-32624-1-git-send-email-ddstreet@ieee.org> <CAL1ERfNNAZCS58K9mT85wxQfH8B3AyR4aLE8r745me1dJRmPfg@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 21 Nov 2013 17:33:49 -0500
Message-ID: <CALZtOND62CZTM-SHNrD3-wwZ=XZz4AAMg9GtrbW1gD6i7LqA-w@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: remove unneeded zswap_rb_erase calls
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Wed, Nov 20, 2013 at 9:52 PM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
> Hello Dan
>
> On Thu, Nov 21, 2013 at 3:47 AM, Dan Streetman <ddstreet@ieee.org> wrote:
>> Since zswap_rb_erase was added to the final (when refcount == 0)
>> zswap_put_entry, there is no need to call zswap_rb_erase before
>> calling zswap_put_entry.
>>
>> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
>> ---
>>  mm/zswap.c | 5 -----
>>  1 file changed, 5 deletions(-)
>>
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index e154f1e..f4fbbd5 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -711,8 +711,6 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>>                 ret = zswap_rb_insert(&tree->rbroot, entry, &dupentry);
>>                 if (ret == -EEXIST) {
>>                         zswap_duplicate_entry++;
>> -                       /* remove from rbtree */
>> -                       zswap_rb_erase(&tree->rbroot, dupentry);
>>                         zswap_entry_put(tree, dupentry);
>>                 }
>>         } while (ret == -EEXIST);
>
> If remove zswap_rb_erase, it would loop until free this dupentry. This
> would cause 2 proplems:

I need to get more familiar with when it's possible to hit a duplicate
entry, it seems strange to me that higher level swap code would be
trying to store a page with an already used offset.

> 1.  zswap_duplicate_entry counter is not correct
> 2. trigger BUG_ON in zswap_entry_put when this dupentry is being writeback,
>    because zswap_writeback_entry will call zswap_entry_put either.
>
> So, I don't think it is a good idea to remove zswap_rb_erase call.
>
>> @@ -787,9 +785,6 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
>>                 return;
>>         }
>>
>> -       /* remove from rbtree */
>> -       zswap_rb_erase(&tree->rbroot, entry);
>> -
>>         /* drop the initial reference from entry creation */
>>         zswap_entry_put(tree, entry);
>
> I think it is better not to remove the zswap_rb_erase call.
>
> From frontswap interface view, if invalidate is called, the page(and
> entry) should never visible to upper.
> If remove the zswap_rb_erase call, it is not fit this semantic.
>
> Consider the following scenario:
> 1. thread 0: entry A is being writeback
> 2. thread 1: invalidate entry A, as refcount != 0, it will still exist
> on rbtree.
> 3. thread 1: reuse  entry A 's swp_entry_t, do a frontswap_store
>    it will conflict with the  entry A on the rbtree, it is not a
> normal duplicate store.
>
> If we place the zswap_rb_erase call in zswap_frontswap_invalidate_page,
> we can avoid the above scenario.
>
> So, I don't think it is a good idea to remove zswap_rb_erase call.

It seems to me that zswap_rb_erase shouldn't have been folded into
zswap_entry_put; if it was removed now, the only place it would need
to be added back is into the success path of writeback, i.e.:

  if (entry == zswap_rb_search(&tree->rbroot, offset)) {
   zswap_rb_erase(&tree->rbroot, entry);
   zswap_entry_put(tree, entry);
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
