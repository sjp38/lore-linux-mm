Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 89989280442
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 12:05:18 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id f138so10115646oih.1
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 09:05:18 -0700 (PDT)
Received: from sender-pp-091.zoho.com (sender-pp-091.zoho.com. [135.84.80.236])
        by mx.google.com with ESMTPS id o62si88792oif.352.2017.09.06.09.05.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Sep 2017 09:05:17 -0700 (PDT)
Subject: Re: [PATCH 1/1] workqueue: use type int instead of bool to index
 array
References: <59AF6CB6.4090609@zoho.com>
 <20170906143320.GK1774378@devbig577.frc2.facebook.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <c795e42f-8355-b79b-3239-15c4ea8fede7@zoho.com>
Date: Thu, 7 Sep 2017 00:04:59 +0800
MIME-Version: 1.0
In-Reply-To: <20170906143320.GK1774378@devbig577.frc2.facebook.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, jiangshanlai@gmail.com

On 2017/9/6 22:33, Tejun Heo wrote:
> Hello,
> 
> On Wed, Sep 06, 2017 at 11:34:14AM +0800, zijun_hu wrote:
>> From: zijun_hu <zijun_hu@htc.com>
>>
>> type bool is used to index three arrays in alloc_and_link_pwqs()
>> it doesn't look like conventional.
>>
>> it is fixed by using type int to index the relevant arrays.
> 
> bool is a uint type which can be either 0 or 1.  I don't see what the
> benefit of this patch is.q
> 
bool is NOT a uint type now, it is a new type introduced by gcc, it is
rather different with "typedef int bool" historically
see following code segments for more info about type bool
	bool v = 0x10;
	printf("v = %d\n", v);
the output is v = 1.

it maybe cause a invalid array index if bool is represented as uint
bool highpri = wq->flags & WQ_HIGHPRI; WQ_HIGHPRI = 1 << 4,
@highpri maybe 16, but the number of array elements is 2.

bool is a logic value, the valid value is true or false. 
indexing array by type bool is not a good program custom

it is more extendable to use type int, type bool maybe is improper if the number of
array elements is extended to more than 2 in future

besides, the relevant array is indexed by type int in many other places of the
same source file. this patch can keep consistency
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
