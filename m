Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B187A6B0279
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 20:43:22 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a195so23859753qkb.13
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 17:43:22 -0700 (PDT)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id e34si6325763qtf.222.2017.06.29.17.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 17:43:21 -0700 (PDT)
Received: by mail-qt0-x241.google.com with SMTP id m54so10817197qtb.1
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 17:43:21 -0700 (PDT)
Subject: Re: [PATCH] cma: fix calculation of aligned offset
References: <20170628170742.2895-1-opendmb@gmail.com>
 <20170629134810.3a5b09dbdea001cca72080ce@linux-foundation.org>
From: Doug Berger <opendmb@gmail.com>
Message-ID: <b9185ff5-1468-4605-36c7-c856e830b9e2@gmail.com>
Date: Thu, 29 Jun 2017 17:43:18 -0700
MIME-Version: 1.0
In-Reply-To: <20170629134810.3a5b09dbdea001cca72080ce@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gregory Fong <gregory.0xf0@gmail.com>, Angus Clark <angus@angusclark.org>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Lucas Stach <l.stach@pengutronix.de>, Catalin Marinas <catalin.marinas@arm.com>, Shiraz Hashim <shashim@codeaurora.org>, Jaewon Kim <jaewon31.kim@samsung.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>

On 06/29/2017 01:48 PM, Andrew Morton wrote:
> On Wed, 28 Jun 2017 10:07:41 -0700 Doug Berger <opendmb@gmail.com> wrote:
> 
>> The align_offset parameter is used by bitmap_find_next_zero_area_off()
>> to represent the offset of map's base from the previous alignment
>> boundary; the function ensures that the returned index, plus the
>> align_offset, honors the specified align_mask.
>>
>> The logic introduced by commit b5be83e308f7 ("mm: cma: align to
>> physical address, not CMA region position") has the cma driver
>> calculate the offset to the *next* alignment boundary.  In most cases,
>> the base alignment is greater than that specified when making
>> allocations, resulting in a zero offset whether we align up or down.
>> In the example given with the commit, the base alignment (8MB) was
>> half the requested alignment (16MB) so the math also happened to work
>> since the offset is 8MB in both directions.  However, when requesting
>> allocations with an alignment greater than twice that of the base,
>> the returned index would not be correctly aligned.
>>
>> Also, the align_order arguments of cma_bitmap_aligned_mask() and
>> cma_bitmap_aligned_offset() should not be negative so the argument
>> type was made unsigned.
> 
> The changelog doesn't describe the user-visible effects of the bug.  It
> should do so please, so that others can decide which kernel(s) need the fix.
> 
> Since the bug has been there for three years, I'll assume that -stable
> backporting is not needed.
> 
I'm afraid I'm confused by what you are asking me to do since it appears
that you have already signed-off on this patch.

The direct user-visible effect of the bug is that if the user requests a
CMA allocation that is aligned with a granule that is more than twice
the base alignment of the CMA region she will receive an allocation that
does not have that alignment.

As I indicated to Gregory, the follow-on consequences of the address not
satisfying the required alignment depend on why the alignment was
requested.  In our case it was a system crash, but it could also
manifest as data corruption on a network interface for example.

In general I would expect it to be unusual for anyone to request an
allocation alignment that is larger than the CMA base alignment which is
probably why the bug has been hiding for three years.

Thanks for your support with this and let me know what more you would
like from me.

-Doug

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
