Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id A17F56B0035
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 10:48:00 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id q5so837525wiv.13
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 07:47:59 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id l3si2293165wiz.32.2014.03.28.07.47.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Mar 2014 07:47:59 -0700 (PDT)
Received: by mail-wi0-f170.google.com with SMTP id bs8so826088wib.1
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 07:47:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <533587FD.7000006@redhat.com>
References: <CALZtONDiOdYSSu02Eo78F4UL5OLTsk-9MR1hePc-XnSujRuvfw@mail.gmail.com>
 <20140327222605.GB16495@medulla.variantweb.net> <CALZtONDBNzL_S+UUxKgvNjEYu49eM5Fc2yJ37dJ8E+PEK+C7qg@mail.gmail.com>
 <533587FD.7000006@redhat.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 28 Mar 2014 10:47:38 -0400
Message-ID: <CALZtONA=v+3_+6qEvyY0SruT=aGxAfV_N5fsHvLMJKFp4Stnww@mail.gmail.com>
Subject: Re: Adding compression before/above swapcache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Weijie Yang <weijie.yang@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Mar 28, 2014 at 10:32 AM, Rik van Riel <riel@redhat.com> wrote:
> On 03/28/2014 08:36 AM, Dan Streetman wrote:
>
>> Well my general idea was to modify shrink_page_list() so that instead
>> of calling add_to_swap() and then pageout(), anonymous pages would be
>> added to a compressed cache.  I haven't worked out all the specific
>> details, but I am initially thinking that the compressed cache could
>> simply repurpose incoming pages to use as the compressed cache storage
>> (using its own page mapping, similar to swap page mapping), and then
>> add_to_swap() the storage pages when the compressed cache gets to a
>> certain size.  Pages that don't compress well could just bypass the
>> compressed cache, and get sent the current route directly to
>> add_to_swap().
>
>
> That sounds a lot like what zswap does. How is your
> proposal different?

Two main ways:
1) it's above swap, so it would still work without any real swap.
2) compressed pages could be written to swap disk.

Essentially, the two existing memory compression approaches are both
tied to swap.  But, AFAIK there's no reason that memory compression
has to be tied to swap.  So my approach uncouples it.

>
> And, is there an easier way to implement that difference? :)

I'm hoping that it wouldn't actually be too complex.  But that's part
of why I emailed for feedback before digging into a prototype... :-)


>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
