Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 564516B02F3
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 12:54:55 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id o20so72134880yba.9
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 09:54:55 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id 132si1486680ywf.64.2017.06.29.09.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 09:54:54 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id w12so11982793qta.2
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 09:54:54 -0700 (PDT)
Subject: Re: [PATCH] cma: fix calculation of aligned offset
References: <20170628170742.2895-1-opendmb@gmail.com>
 <CADtm3G6EWr6O5TEpXr_EUGA6_Fg7yBm12ttfXfC_EtQT7gyXFw@mail.gmail.com>
From: Doug Berger <opendmb@gmail.com>
Message-ID: <06989e55-b062-5312-1b26-f6db39153f7a@gmail.com>
Date: Thu, 29 Jun 2017 09:54:51 -0700
MIME-Version: 1.0
In-Reply-To: <CADtm3G6EWr6O5TEpXr_EUGA6_Fg7yBm12ttfXfC_EtQT7gyXFw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gregory Fong <gregory.0xf0@gmail.com>
Cc: Angus Clark <angus@angusclark.org>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Lucas Stach <l.stach@pengutronix.de>, Catalin Marinas <catalin.marinas@arm.com>, Shiraz Hashim <shashim@codeaurora.org>, Jaewon Kim <jaewon31.kim@samsung.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, Danesh Petigara <dpetigara@broadcom.com>

On 06/28/2017 11:23 PM, Gregory Fong wrote:
> On Wed, Jun 28, 2017 at 10:07 AM, Doug Berger <opendmb@gmail.com> wrote:
>> The align_offset parameter is used by bitmap_find_next_zero_area_off()
>> to represent the offset of map's base from the previous alignment
>> boundary; the function ensures that the returned index, plus the
>> align_offset, honors the specified align_mask.
>>
>> The logic introduced by commit b5be83e308f7 ("mm: cma: align to
>> physical address, not CMA region position") has the cma driver
>> calculate the offset to the *next* alignment boundary.
> 
> Wow, I had that completely backward, nice catch.
Thanks go to Angus for that!

>> In most cases,
>> the base alignment is greater than that specified when making
>> allocations, resulting in a zero offset whether we align up or down.
>> In the example given with the commit, the base alignment (8MB) was
>> half the requested alignment (16MB) so the math also happened to work
>> since the offset is 8MB in both directions.  However, when requesting
>> allocations with an alignment greater than twice that of the base,
>> the returned index would not be correctly aligned.
> 
> It may be worth explaining what impact incorrect alignment has for an
> end user, then considering for inclusion in stable.
It would be difficult to explain in a general way since the end user is
requesting the alignment and only she knows what the consequences would
be for insufficient alignment.

I assume in general with the CMA it is most likely a DMA constraint.
However, in our particular case the problem affected an allocation used
by a co-processor.  The larger CONFIG_CMA_ALIGNMENT is the less likely
users would run into this bug.  We encountered it after reducing our
default CONFIG_CMA_ALIGNMENT.

I agree that it should be considered for stable.

>>
>> Also, the align_order arguments of cma_bitmap_aligned_mask() and
>> cma_bitmap_aligned_offset() should not be negative so the argument
>> type was made unsigned.
>>
>> Fixes: b5be83e308f7 ("mm: cma: align to physical address, not CMA region position")
>> Signed-off-by: Angus Clark <angus@angusclark.org>
>> Signed-off-by: Doug Berger <opendmb@gmail.com>
> 
> Acked-by: Gregory Fong <gregory.0xf0@gmail.com>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
