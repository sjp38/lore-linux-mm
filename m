Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA526B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 10:54:53 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e63so217416975iod.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 07:54:53 -0700 (PDT)
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com. [209.85.223.182])
        by mx.google.com with ESMTPS id g53si3171499ote.196.2016.04.25.07.54.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 07:54:52 -0700 (PDT)
Received: by mail-io0-f182.google.com with SMTP id d62so82448393iof.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 07:54:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <571DC72F.3030503@suse.cz>
References: <5715FEFD.9010001@gmail.com>
	<20160421162210.f4a50b74bc6ce886ac8c8e4e@linux-foundation.org>
	<571DC72F.3030503@suse.cz>
Date: Mon, 25 Apr 2016 09:54:51 -0500
Message-ID: <CAC8qmcAf-dMz6h0wRj2S5owRkVk68ZYsB9OU6Qq8wYPOrq-MQA@mail.gmail.com>
Subject: Re: [PATCH v2] z3fold: the 3-fold allocator for compressed pages
From: Seth Jennings <sjenning@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vitaly Wool <vitalywool@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>

On Mon, Apr 25, 2016 at 2:28 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 04/22/2016 01:22 AM, Andrew Morton wrote:
>>
>> On Tue, 19 Apr 2016 11:48:45 +0200 Vitaly Wool <vitalywool@gmail.com>
>> wrote:
>>
>>> This patch introduces z3fold, a special purpose allocator for storing
>>> compressed pages. It is designed to store up to three compressed pages
>>> per
>>> physical page. It is a ZBUD derivative which allows for higher
>>> compression
>>> ratio keeping the simplicity and determinism of its predecessor.
>>>
>>> The main differences between z3fold and zbud are:
>>> * unlike zbud, z3fold allows for up to PAGE_SIZE allocations
>>> * z3fold can hold up to 3 compressed pages in its page
>>>
>>> This patch comes as a follow-up to the discussions at the Embedded Linux
>>> Conference in San-Diego related to the talk [1]. The outcome of these
>>> discussions was that it would be good to have a compressed page allocator
>>> as stable and deterministic as zbud with with higher compression ratio.
>>>
>>> To keep the determinism and simplicity, z3fold, just like zbud, always
>>> stores an integral number of compressed pages per page, but it can store
>>> up to 3 pages unlike zbud which can store at most 2. Therefore the
>>> compression ratio goes to around 2.5x while zbud's one is around 1.7x.
>>>
>>> The patch is based on the latest linux.git tree.
>>>
>>> This version of the patch has updates related to various concurrency
>>> fixes
>>> made after intensive testing on SMP/HMP platforms.
>>>
>>>
>>> [1]https://openiotelc2016.sched.org/event/6DAC/swapping-and-embedded-compression-relieves-the-pressure-vitaly-wool-softprise-consulting-ou
>>>
>>
>> So...  why don't we just replace zbud with z3fold?  (Update the changelog
>> to answer this rather obvious question, please!)
>
>
> There was discussion between Seth and Vitaly on v1. Without me knowing the
> details myself, it looked like Seth's objections were addressed, but then
> the thread died. I think there should first be a more clear answer from Seth
> whether z3fold really looks like a clear win (i.e. not workload-dependent)
> over zbud, in which case zbud could be extended?

(sorry for the dup Vlastimil, didn't reply-to-all)

It seems like it could be in the case that most of the pages in your
system compress to 1/3 their original size (on average).  In my
original research, I found that, using lzo, 1/2 a page was more
typical.  However, if you used deflate, you might be able to push the
average down.

IMO I do think we should try to merge zbud and z3fold with zbud being
the default mode (2 object per page) and have an option to enable the
3 objects per page logic.  IIRC that 3rd object logic seemed to be
fairly contained.  Having the separate would duplicate a lot of very
similar code.

However, if Andrew is ok with yet another z- allocator, it can just be
another zpool backend.  I'm fine either way.  Just my two cents.

Seth

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
