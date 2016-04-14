Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD7216B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 13:45:50 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a125so58262704wmd.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:45:50 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id vm1si27110041wjc.130.2016.04.14.10.45.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 10:45:49 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id u206so136710934wme.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:45:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAC8qmcDHCMCEZ8F+1gEtsgSTzjAH=RETT=WodxkL8RfJpj2dkg@mail.gmail.com>
References: <570F4F5F.6070209@gmail.com>
	<570F5973.40809@suse.cz>
	<CAMJBoFO7bORG-uWmCxjvyue4+kLbWPO1-dYApJnsyzkMUVkoCw@mail.gmail.com>
	<CAC8qmcDHCMCEZ8F+1gEtsgSTzjAH=RETT=WodxkL8RfJpj2dkg@mail.gmail.com>
Date: Thu, 14 Apr 2016 19:45:49 +0200
Message-ID: <CAMJBoFNQtwSRoz12qHnjX=E7evEaJC5CQbYE68cH9qTS2MZqQQ@mail.gmail.com>
Subject: Re: [PATCH] z3fold: the 3-fold allocator for compressed pages
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

On Thu, Apr 14, 2016 at 5:53 PM, Seth Jennings <sjenning@redhat.com> wrote:
> On Thu, Apr 14, 2016 at 4:06 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
>>
>>
>> On Thu, Apr 14, 2016 at 10:48 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>
>>> On 04/14/2016 10:05 AM, Vitaly Wool wrote:
>>>>
>>>> This patch introduces z3fold, a special purpose allocator for storing
>>>> compressed pages. It is designed to store up to three compressed pages
>>>> per
>>>> physical page. It is a ZBUD derivative which allows for higher
>>>> compression
>>>> ratio keeping the simplicity and determinism of its predecessor.
>>>
>>>
>>> So the obvious question is, why a separate allocator and not extend zbud?
>>
>>
>> Well, as far as I recall Seth was very much for keeping zbud as simple as
>> possible. I am fine either way but if we have zpool API, why not have
>> another zpool API user?
>>
>>>
>>> I didn't study the code, nor notice a design/algorithm overview doc, but
>>> it seems z3fold keeps the idea of one compressed page at the beginning, one
>>> at the end of page frame, but it adds another one in the middle? Also how is
>>> the buddy-matching done?
>
> Yes, as soon as you introduce a 3rd object in the page, zpage
> fragmentation becomes an issue.  Having a middle object partitions
> that zpage, blocking allocations that are larger than either
> partition, even though the combined size of the partitions could have
> accommodated the object.

Yes, but this situation is easy to track down and work around by
moving the middle object to either the beginning or the end. In case
of the current implementation it is the beginning.

> This also means that the unbuddied list is broken in this
> implementation.  num_free_chunks() is calculating the _total_ free
> space in the page.  But that is not that the _usable_ free space by a
> single object, if the middle object has partitioned that free space.

Once again, there is the code in z3fold_free() that makes sure the
free space within the page is contiguous so I don't think the
unbuddied list is, or will be, broken.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
