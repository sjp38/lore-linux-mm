Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 511506B0263
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 11:22:53 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 20so125261673ioj.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 08:22:53 -0700 (PDT)
Received: from cmta16.telus.net (cmta16.telus.net. [209.171.16.89])
        by mx.google.com with ESMTP id w202si10754253itb.36.2016.09.28.08.22.28
        for <linux-mm@kvack.org>;
        Wed, 28 Sep 2016 08:22:28 -0700 (PDT)
From: "Doug Smythies" <dsmythies@telus.net>
References: <bug-172981-27@https.bugzilla.kernel.org/> <20160927111059.282a35c89266202d3cb2f953@linux-foundation.org> <002a01d21936$5ca792a0$15f6b7e0$@net> <20160928051841.GB22706@js1304-P5Q-DELUXE> p862bY4Wd9akxp868bmekv
In-Reply-To: p862bY4Wd9akxp868bmekv
Subject: RE: [Bug 172981] New: [bisected] SLAB: extreme load averages and over 2000 kworker threads
Date: Wed, 28 Sep 2016 08:22:24 -0700
Message-ID: <000601d2199c$1f01cd10$5d056730$@net>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: en-ca
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Vladimir Davydov' <vdavydov.dev@gmail.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On 2016.09.27 23:20 Joonsoo Kim wrote:
> On Wed, Sep 28, 2016 at 02:18:42PM +0900, Joonsoo Kim wrote:
>> On Tue, Sep 27, 2016 at 08:13:58PM -0700, Doug Smythies wrote:
>>> By the way, I can eliminate the problem by doing this:
>>> (see also: https://bugzilla.kernel.org/show_bug.cgi?id=172991)
>> 
>> I think that Johannes found the root cause of the problem and they
>> (Johannes and Vladimir) will solve the root cause.
>> 
>> However, there is something useful to do in SLAB side.
>> Could you test following patch, please?
>> 
>> Thanks.
>> 
>> ---------->8--------------
>> diff --git a/mm/slab.c b/mm/slab.c
>> index 0eb6691..39e3bf2 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -965,7 +965,7 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
>>          * guaranteed to be valid until irq is re-enabled, because it will be
>>          * freed after synchronize_sched().
>>          */
>> -       if (force_change)
>> +       if (n->shared && force_change)
>>                 synchronize_sched();
>
> Oops...
>
> s/n->shared/old_shared/

Yes, that seems to work fine. After boot everything is good.
Then I tried and tried to get it to mess up, but could not.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
