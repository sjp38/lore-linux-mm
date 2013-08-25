Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id B71A76B0033
	for <linux-mm@kvack.org>; Sun, 25 Aug 2013 08:00:54 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id 9so3353270iec.2
        for <linux-mm@kvack.org>; Sun, 25 Aug 2013 05:00:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130823152859.GB5439@variantweb.net>
References: <CAL1ERfPzB=CvKJ6kAq2YYTkkg-EgSOWRyfSFWkvKp8ZdQkCDxA@mail.gmail.com>
	<20130823152859.GB5439@variantweb.net>
Date: Sun, 25 Aug 2013 20:00:53 +0800
Message-ID: <CAL1ERfPp8p=42+pyLzAeFUrUSt17ocHaDCtOrYNPmS=b+rsqGw@mail.gmail.com>
Subject: Re: [PATCH 1/4] zswap bugfix: memory leaks when re-swapon
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, weijie.yang@samsung.com

2013/8/23 Seth Jennings <sjenning@linux.vnet.ibm.com>:
> On Fri, Aug 23, 2013 at 07:03:37PM +0800, Weijie Yang wrote:
>> zswap_tree is not freed when swapoff, and it got re-kzalloc in swapon,
>> memory leak occurs.
>> Add check statement in zswap_frontswap_init so that zswap_tree is
>> inited only once.
>>
>> ---
>>  mm/zswap.c |    5 +++++
>>  1 files changed, 5 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index deda2b6..1cf1c07 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -826,6 +826,11 @@ static void zswap_frontswap_init(unsigned type)
>>  {
>>       struct zswap_tree *tree;
>>
>> +     if (zswap_trees[type]) {
>> +             BUG_ON(zswap_trees[type]->rbroot != RB_ROOT);  /* invalidate_area set it */
>
> Lets leave this BUG_ON() out.  If we want to make sure that the rbtree has
> been properly emptied out, we should do it in
> zswap_frontswap_invalidate_area() after the while loop and make it a
> WARN_ON() since the problem is not fatal.
>
> Seth
>

ok.

>> +             return;
>> +     }
>> +
>>       tree = kzalloc(sizeof(struct zswap_tree), GFP_KERNEL);
>>       if (!tree)
>>               goto err;
>> --
>> 1.7.0.4
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
