Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB2EA6B0253
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 17:16:58 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so41940036wmf.3
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 14:16:58 -0800 (PST)
Received: from mail-wj0-x232.google.com (mail-wj0-x232.google.com. [2a00:1450:400c:c01::232])
        by mx.google.com with ESMTPS id z3si26316130wjt.212.2016.12.07.14.16.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 14:16:57 -0800 (PST)
Received: by mail-wj0-x232.google.com with SMTP id tg4so118505197wjb.1
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 14:16:57 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [RFC PATCH v3] mm: use READ_ONCE in page_cpupid_xchg_last()
References: <584523E4.9030600@huawei.com> <58461A0A.3070504@huawei.com>
	<20161207084305.GA20350@dhcp22.suse.cz>
	<7b74a021-e472-a21e-7936-6741e07906b5@suse.cz>
	<20161207085809.GD17136@dhcp22.suse.cz>
	<b3c3cff5-5d47-7a32-9def-9f42640c9211@suse.cz>
	<ceb6c990-6d88-dc79-b494-432ed838f3c9@de.ibm.com>
	<20161207095943.GF17136@dhcp22.suse.cz>
	<5d4accd3-e26b-d23f-5417-debe9ad7148a@de.ibm.com>
Date: Wed, 07 Dec 2016 23:16:55 +0100
In-Reply-To: <5d4accd3-e26b-d23f-5417-debe9ad7148a@de.ibm.com> (Christian
	Borntraeger's message of "Wed, 7 Dec 2016 11:03:29 +0100")
Message-ID: <877f7bqt9k.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>

On Wed, Dec 07 2016, Christian Borntraeger <borntraeger@de.ibm.com> wrote:

> On 12/07/2016 10:59 AM, Michal Hocko wrote:
>> On Wed 07-12-16 10:40:47, Christian Borntraeger wrote:
>>> On 12/07/2016 10:29 AM, Vlastimil Babka wrote:
>>>> On 12/07/2016 09:58 AM, Michal Hocko wrote:
>>>>> On Wed 07-12-16 09:48:52, Vlastimil Babka wrote:
>>>>> Anyway, this could be addressed easily by
>>>>
>>>> Yes, that way there should be no doubt.
>>>
>>> That change would make it clearer, but the code is correct anyway,
>>> as assignments in C are done from right to left, so 
>>> old_flags = flags = READ_ONCE(page->flags);
>>>
>>> is equivalent to 
>>>
>>> flags = READ_ONCE(page->flags);
>>> old_flags = flags;
>> 
>> OK, I guess you are right. For some reason I thought that the compiler
>> is free to bypass flags and split an assignment
>> a = b = c; into b = c; a = c
>> which would still follow from right to left rule. I guess I am over
>> speculating here though, so sorry for the noise.
>
> Hmmm, just rereading C, I am no longer sure...
> I cannot find anything right now, that adds a sequence point in here.
> Still looking...

C99 6.5.16.3: ... An assignment expression has the value of the left
operand after the assignment, ....

So if the expression c can have side effects or is for any reason
(e.g. volatile) not guaranteed to produce the same value if it's
evaluated again, there's no way the compiler would be allowed to change
a=b=c; into b=c; a=c;. (Also, this means that in "int a, c = 256;
char b; a=b=c;", a ends up with the value 0.)

Somewhat related: https://lwn.net/Articles/233902/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
