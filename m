Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 153BD6B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 08:22:31 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id i13so13778173qae.34
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 05:22:30 -0700 (PDT)
Received: from mail-qa0-x230.google.com (mail-qa0-x230.google.com [2607:f8b0:400d:c00::230])
        by mx.google.com with ESMTPS id d2si3468724qar.118.2014.08.26.05.22.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Aug 2014 05:22:30 -0700 (PDT)
Received: by mail-qa0-f48.google.com with SMTP id m5so13612668qaj.21
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 05:22:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140826075511.GI11319@bbox>
References: <1408925156-11733-1-git-send-email-minchan@kernel.org>
	<1408925156-11733-4-git-send-email-minchan@kernel.org>
	<20140826073730.GA1975@js1304-P5Q-DELUXE>
	<20140826075511.GI11319@bbox>
Date: Tue, 26 Aug 2014 08:22:29 -0400
Message-ID: <CAFdhcLQce05qi2LGP85N=aaQiKz1ArC3Kn+W-s86R58BkjMr3w@mail.gmail.com>
Subject: Re: [PATCH v5 3/4] zram: zram memory size limitation
From: David Horner <ds2horner@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>

On Tue, Aug 26, 2014 at 3:55 AM, Minchan Kim <minchan@kernel.org> wrote:
> Hey Joonsoo,
>
> On Tue, Aug 26, 2014 at 04:37:30PM +0900, Joonsoo Kim wrote:
>> On Mon, Aug 25, 2014 at 09:05:55AM +0900, Minchan Kim wrote:
>> > @@ -513,6 +540,14 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>> >             ret = -ENOMEM;
>> >             goto out;
>> >     }
>> > +
>> > +   if (zram->limit_pages &&
>> > +           zs_get_total_pages(meta->mem_pool) > zram->limit_pages) {
>> > +           zs_free(meta->mem_pool, handle);
>> > +           ret = -ENOMEM;
>> > +           goto out;
>> > +   }
>> > +
>> >     cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
>>
>> Hello,
>>
>> I don't follow up previous discussion, so I could be wrong.
>> Why this enforcement should be here?
>>
>> I think that this has two problems.
>> 1) alloc/free happens unnecessarilly if we have used memory over the
>> limitation.
>
> True but firstly, I implemented the logic in zsmalloc, not zram but
> as I described in cover-letter, it's not a requirement of zsmalloc
> but zram so it should be in there. If every user want it in future,
> then we could move the function into zsmalloc. That's what we
> concluded in previous discussion.
>
> Another idea is we could call zs_get_total_pages right before zs_malloc
> but the problem is we cannot know how many of pages are allocated
> by zsmalloc in advance.
> IOW, zram should be blind on zsmalloc's internal.
>

We did however suggest that we could check before hand to see if
max was already exceeded as an optimization.
(possibly with a guess on usage but at least using the minimum of 1 page)
In the contested case, the max may already be exceeded transiently and
therefore we know this one _could_ fail (it could also pass, but odds
aren't good).
As Minchan mentions this was discussed before - but not into great detail.
Testing should be done to determine possible benefit. And as he also
mentions, the better place for it may be in zsmalloc, but that
requires an ABI change.

Certainly a detailed suggestion could happen on this thread and I'm
also interested
in your thoughts, but this patchset should be able to go in as is.
Memory exhaustion avoidance probably trumps the possible thrashing at
threshold.

> About alloc/free cost once if it is over the limit,
> I don't think it's important to consider.
> Do you have any scenario in your mind to consider alloc/free cost
> when the limit is over?
>
>> 2) Even if this request doesn't do new allocation, it could be failed
>> due to other's allocation. There is time gap between allocation and
>> free, so legimate user who want to use preallocated zsmalloc memory
>> could also see this condition true and then he will be failed.
>
> Yeb, we already discussed that. :)
> Such false positive shouldn't be a severe problem if we can keep a
> promise that zram user cannot exceed mem_limit.
>

And we cannot avoid the race, nor can we avoid in a low overhead competitive
concurrent process transient inconsistent states.
Different views for different observers.
 They are a consequence of the theory of "Special Computational Relativity".
 I am working on a String Unification Theory of Quantum and General CR in LISP.
 ;-)



>>
>> Thanks.
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
