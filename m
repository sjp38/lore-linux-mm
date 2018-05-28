Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 211C36B0005
	for <linux-mm@kvack.org>; Sun, 27 May 2018 21:45:02 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id c137-v6so10051107ith.3
        for <linux-mm@kvack.org>; Sun, 27 May 2018 18:45:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k17-v6sor12813497iob.227.2018.05.27.18.45.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 27 May 2018 18:45:00 -0700 (PDT)
Subject: Re: [RESEND PATCH V5 00/33] block: support multipage bvec
References: <20180525034621.31147-1-ming.lei@redhat.com>
 <20180525045306.GB8740@kmo-pixel>
 <8aa4276d-c0bc-3266-aa53-bf08a2e5ab5c@kernel.dk>
 <20180527072332.GA18240@ming.t460p>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <cc266632-497c-6849-e291-4f042c8d987a@kernel.dk>
Date: Sun, 27 May 2018 19:44:52 -0600
MIME-Version: 1.0
In-Reply-To: <20180527072332.GA18240@ming.t460p>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Kent Overstreet <kent.overstreet@gmail.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>

On 5/27/18 1:23 AM, Ming Lei wrote:
> On Fri, May 25, 2018 at 10:30:46AM -0600, Jens Axboe wrote:
>> On 5/24/18 10:53 PM, Kent Overstreet wrote:
>>> On Fri, May 25, 2018 at 11:45:48AM +0800, Ming Lei wrote:
>>>> Hi,
>>>>
>>>> This patchset brings multipage bvec into block layer:
>>>
>>> patch series looks sane to me. goddamn that's a lot of renaming.
>>
>> Indeed... I actually objected to some of the segment -> page
>> renaming, but it's still in there. The foo2() temporary functions
>> also concern me, we all know there's nothing more permanent than a
>> temporary fixup.
> 
> Jens, I remember I explained the renaming story to you in lsfmm a bit:
> 
> 1) the current naming of segment is actually wrong, since every segment
> only stores one single-page vector
> 
> 2) the most important part is that once multipage bvec is introduced,
> if the old _segment naming is still kept, it can be very confusing,
> especially no good name is left for the helpers of dealing with real
> segment.

Yes, we discussed exactly this, which is why I'm surprised you went
ahead with the same approach. I told you I don't like tree wide renames,
if they can be avoided. I'd rather suffer some pain wrt page vs segments
naming, and then later do a rename (if it bothers us) once the dust has
settled on the interesting part of the changes.

I'm very well away of our current naming and what it signifies.  With
#1, you are really splitting hairs, imho. Find a decent name for
multiple segment. Chunk?

> For the foo2() temporary change, that is only for avoiding tree-wide
> change in one single tree, with this way, we can change sub-system one
> by one, but if you think it is good to do tree-wide conversion in one
> patch, I am fine to do it in next version.

It's still a painful middle step.

>>> Things are going to get interesting when we start sticking compound
>>> pages in the page cache, there'll be some interesting questions of
>>> semantics to deal with then but I think getting this will only help
>>> w.r.t. plumbing that through and not dealing with 4k pages
>>> unnecessarily - but I think even if we were to decide that merging
>>> in bio_add_page() is not the way to go when the upper layers are
>>> passing compound pages around already, this patch series helps
>>> because regardless at some point everything under
>>> generic_make_request() is going to have to deal with segments that
>>> are more than one page, and this patch series makes that happen. So
>>> incremental progress.
>>>
>>> Jens, any objections to getting this in?
>>
>> I like most of it, but I'd much rather get this way earlier in the
>> series.  We're basically just one week away from the merge window, it
>> needs more simmer and testing time than that. On top of that, it
>> hasn't received much review yet.
>>
>> So as far as I'm concerned, we can kick off the 4.19 block branch
>> with iterated versions of this patchset.
> 
> OK, I will post out again once v4.19 is started.

Sounds good.

-- 
Jens Axboe
