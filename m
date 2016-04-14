Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4942E6B028B
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 11:53:51 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id fg3so147519371obb.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:53:51 -0700 (PDT)
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com. [209.85.223.182])
        by mx.google.com with ESMTPS id ni16si7805076igb.86.2016.04.14.08.53.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 08:53:50 -0700 (PDT)
Received: by mail-io0-f182.google.com with SMTP id o126so108013205iod.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:53:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMJBoFO7bORG-uWmCxjvyue4+kLbWPO1-dYApJnsyzkMUVkoCw@mail.gmail.com>
References: <570F4F5F.6070209@gmail.com>
	<570F5973.40809@suse.cz>
	<CAMJBoFO7bORG-uWmCxjvyue4+kLbWPO1-dYApJnsyzkMUVkoCw@mail.gmail.com>
Date: Thu, 14 Apr 2016 10:53:50 -0500
Message-ID: <CAC8qmcDHCMCEZ8F+1gEtsgSTzjAH=RETT=WodxkL8RfJpj2dkg@mail.gmail.com>
Subject: Re: [PATCH] z3fold: the 3-fold allocator for compressed pages
From: Seth Jennings <sjenning@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

On Thu, Apr 14, 2016 at 4:06 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
>
>
> On Thu, Apr 14, 2016 at 10:48 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>> On 04/14/2016 10:05 AM, Vitaly Wool wrote:
>>>
>>> This patch introduces z3fold, a special purpose allocator for storing
>>> compressed pages. It is designed to store up to three compressed pages
>>> per
>>> physical page. It is a ZBUD derivative which allows for higher
>>> compression
>>> ratio keeping the simplicity and determinism of its predecessor.
>>
>>
>> So the obvious question is, why a separate allocator and not extend zbud?
>
>
> Well, as far as I recall Seth was very much for keeping zbud as simple as
> possible. I am fine either way but if we have zpool API, why not have
> another zpool API user?
>
>>
>> I didn't study the code, nor notice a design/algorithm overview doc, but
>> it seems z3fold keeps the idea of one compressed page at the beginning, one
>> at the end of page frame, but it adds another one in the middle? Also how is
>> the buddy-matching done?

Yes, as soon as you introduce a 3rd object in the page, zpage
fragmentation becomes an issue.  Having a middle object partitions
that zpage, blocking allocations that are larger than either
partition, even though the combined size of the partitions could have
accommodated the object.

This also means that the unbuddied list is broken in this
implementation.  num_free_chunks() is calculating the _total_ free
space in the page.  But that is not that the _usable_ free space by a
single object, if the middle object has partitioned that free space.

Seth

>
>
> Basically yes. There is 'start_middle' variable which point to the start of
> the middle page, if any. The matching is done basing on the buddy number.
>
> ~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
