Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f173.google.com (mail-vc0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8963E6B0031
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 08:43:14 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id il7so8133913vcb.18
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 05:43:14 -0700 (PDT)
Received: from mail-ve0-x231.google.com (mail-ve0-x231.google.com [2607:f8b0:400c:c01::231])
        by mx.google.com with ESMTPS id sr19si2834935vcb.179.2014.03.31.05.43.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 05:43:13 -0700 (PDT)
Received: by mail-ve0-f177.google.com with SMTP id sa20so8008048veb.36
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 05:43:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtONA=v+3_+6qEvyY0SruT=aGxAfV_N5fsHvLMJKFp4Stnww@mail.gmail.com>
References: <CALZtONDiOdYSSu02Eo78F4UL5OLTsk-9MR1hePc-XnSujRuvfw@mail.gmail.com>
	<20140327222605.GB16495@medulla.variantweb.net>
	<CALZtONDBNzL_S+UUxKgvNjEYu49eM5Fc2yJ37dJ8E+PEK+C7qg@mail.gmail.com>
	<533587FD.7000006@redhat.com>
	<CALZtONA=v+3_+6qEvyY0SruT=aGxAfV_N5fsHvLMJKFp4Stnww@mail.gmail.com>
Date: Mon, 31 Mar 2014 20:43:13 +0800
Message-ID: <CAA_GA1er3d+_LJp67aD8tE0SLMod--FpRFvGBdKmpzU_aQNdUg@mail.gmail.com>
Subject: Re: Adding compression before/above swapcache
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Rik van Riel <riel@redhat.com>, Seth Jennings <sjennings@variantweb.net>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Weijie Yang <weijie.yang@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Mar 28, 2014 at 10:47 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> On Fri, Mar 28, 2014 at 10:32 AM, Rik van Riel <riel@redhat.com> wrote:
>> On 03/28/2014 08:36 AM, Dan Streetman wrote:
>>
>>> Well my general idea was to modify shrink_page_list() so that instead
>>> of calling add_to_swap() and then pageout(), anonymous pages would be
>>> added to a compressed cache.  I haven't worked out all the specific
>>> details, but I am initially thinking that the compressed cache could
>>> simply repurpose incoming pages to use as the compressed cache storage
>>> (using its own page mapping, similar to swap page mapping), and then
>>> add_to_swap() the storage pages when the compressed cache gets to a
>>> certain size.  Pages that don't compress well could just bypass the
>>> compressed cache, and get sent the current route directly to
>>> add_to_swap().
>>
>>
>> That sounds a lot like what zswap does. How is your
>> proposal different?
>
> Two main ways:
> 1) it's above swap, so it would still work without any real swap.

Zswap can also be extended without any real swap device.

> 2) compressed pages could be written to swap disk.
>

Yes, how to handle the write back of zswap is a problem. And I think
your patch making zswap write through is a good start.

> Essentially, the two existing memory compression approaches are both
> tied to swap.  But, AFAIK there's no reason that memory compression
> has to be tied to swap.  So my approach uncouples it.
>

Yes, it's not necessary but swap page is a good candidate and easy to
handle. There are also clean file pages which may suitable for
compression. See http://lwn.net/Articles/545244/.

>>
>> And, is there an easier way to implement that difference? :)
>
> I'm hoping that it wouldn't actually be too complex.  But that's part
> of why I emailed for feedback before digging into a prototype... :-)
>

I'm afraid your idea may not that easy to be implemented and need to
add many tricky code to current mm subsystem, but the benefit is still
uncertain. As Mel pointed out we really need better demonstration
workloads for memory compression before changes.
https://lwn.net/Articles/591961

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
