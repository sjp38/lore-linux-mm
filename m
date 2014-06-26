Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 48E3C6B003B
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 05:14:37 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so3267878wgg.13
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 02:14:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2si8867373wje.108.2014.06.26.02.14.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Jun 2014 02:14:35 -0700 (PDT)
Message-ID: <53ABE479.3080508@suse.cz>
Date: Thu, 26 Jun 2014 11:14:33 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: mm: shm: hang in shmem_fallocate
References: <52AE7B10.2080201@oracle.com> <52F6898A.50101@oracle.com> <alpine.LSU.2.11.1402081841160.26825@eggly.anvils> <52F82E62.2010709@oracle.com> <539A0FC8.8090504@oracle.com> <alpine.LSU.2.11.1406151921070.2850@eggly.anvils> <53A9A7D8.2020703@suse.cz> <alpine.LSU.2.11.1406251152450.1580@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1406251152450.1580@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 06/26/2014 12:36 AM, Hugh Dickins wrote:
> On Tue, 24 Jun 2014, Vlastimil Babka wrote:
>> On 06/16/2014 04:29 AM, Hugh Dickins wrote:
>>> On Thu, 12 Jun 2014, Sasha Levin wrote:
>>>> On 02/09/2014 08:41 PM, Sasha Levin wrote:
>>>>> On 02/08/2014 10:25 PM, Hugh Dickins wrote:
>>>>>> Would trinity be likely to have a thread or process repeatedly faulting
>>>>>> in pages from the hole while it is being punched?
>>>>>
>>>>> I can see how trinity would do that, but just to be certain - Cc davej.
>>>>>
>>>>> On 02/08/2014 10:25 PM, Hugh Dickins wrote:
>>>>>> Does this happen with other holepunch filesystems?  If it does not,
>>>>>> I'd suppose it's because the tmpfs fault-in-newly-created-page path
>>>>>> is lighter than a consistent disk-based filesystem's has to be.
>>>>>> But we don't want to make the tmpfs path heavier to match them.
>>>>>
>>>>> No, this is strictly limited to tmpfs, and AFAIK trinity tests hole
>>>>> punching in other filesystems and I make sure to get a bunch of those
>>>>> mounted before starting testing.
>>>>
>>>> Just pinging this one again. I still see hangs in -next where the hang
>>>> location looks same as before:
>>>>
>>>
>>> Please give this patch a try.  It fixes what I can reproduce, but given
>>> your unexplained page_mapped() BUG in this area, we know there's more
>>> yet to be understood, so perhaps this patch won't do enough for you.
>>>
>>
>> Hi,
>
> Sorry for the slow response: I have got confused, learnt more, and
> changed my mind, several times in the course of replying to you.
> I think this reply will be stable... though not final.

Thanks a lot for looking into it!

>>
>> since this got a CVE,
>
> Oh.  CVE-2014-4171.  Couldn't locate that yesterday but see it now.

Sorry, I should have mentioned it explicitly.

> Looks overrated to me

I'd bet it would pass unnoticed if you didn't use the sentence "but 
whether it's a serious matter in the scale of denials of service, I'm 
not so sure" in your first reply to Sasha's report :) I wouldn't be 
surprised if people grep for this.

> (and amusing to see my pompous words about a
> "range notification mechanism" taken too seriously), but of course
> we do need to address it.
>
>> I've been looking at backport to an older kernel where
>
> Thanks a lot for looking into it.  I didn't think it was worth a
> Cc: stable@vger.kernel.org myself, but admit to being both naive
> and inconsistent about that.
>
>> fallocate(FALLOC_FL_PUNCH_HOLE) is not yet supported, and there's also no
>> range notification mechanism yet. There's just madvise(MADV_REMOVE) and since
>
> Yes, that mechanism could be ported back pre-v3.5,
> but I agree with your preference not to.
>
>> it doesn't guarantee anything, it seems simpler just to give up retrying to
>
> Right, I don't think we have formally documented the instant of "full hole"
> that I strove for there, and it's probably not externally verifiable, nor
> guaranteed by other filesystems.  I just thought it a good QoS aim, but
> it has given us this problem.
>
>> truncate really everything. Then I realized that maybe it would work for
>> current kernel as well, without having to add any checks in the page fault
>> path. The semantics of fallocate(FALLOC_FL_PUNCH_HOLE) might look different
>> from madvise(MADV_REMOVE), but it seems to me that as long as it does discard
>> the old data from the range, it's fine from any information leak point of view.
>> If someone races page faulting, it IMHO doesn't matter if he gets a new zeroed
>> page before the parallel truncate has ended, or right after it has ended.
>
> Yes.  I disagree with your actual patch, for more than one reason,
> but it's in the right area; and I found myself growing to agree with
> you, that's it's better to have one kind of fix for all these releases,
> than one for v3.5..v3.15 and another for v3.1..v3.4.  (The CVE cites
> v3.0 too, I'm sceptical about that, but haven't tried it as yet.)

I was looking at our 3.0 based kernel, but it could be due to backported 
patches on top.

> If I'd realized that we were going to have to backport, I'd have spent
> longer looking for a patch like yours originally.  So my inclination
> now is to go your route, make a new patch for v3.16 and backports,
> and revert the f00cdc6df7d7 that has already gone in.
>
>> So I'm posting it here as a RFC. I haven't thought about the
>> i915_gem_object_truncate caller yet. I think that this path wouldn't satisfy
>
> My understanding is that i915_gem_object_truncate() is not a problem,
> that i915's dev->struct_mutex serializes all its relevant transitions,
> plus the object woudn't even be interestingly accessible to the user.
>
>> the new "lstart < inode->i_size" condition, but I don't know if it's "vulnerable"
>> to the problem.
>
> I don't think i915 is vulnerable, but if it is, that condition would
> be fine for it, as would be the patch I'm now thinking of.
>
>>
>> -----8<-----
>> From: Vlastimil Babka <vbabka@suse.cz>
>> Subject: [RFC PATCH] shmem: prevent livelock between page fault and hole punching
>>
>> ---
>>   mm/shmem.c | 19 +++++++++++++++++++
>>   1 file changed, 19 insertions(+)
>>
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index f484c27..6d6005c 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -476,6 +476,25 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
>>   		if (!pvec.nr) {
>>   			if (index == start || unfalloc)
>>   				break;
>> +                        /*
>> +                         * When this condition is true, it means we were
>> +                         * called from fallocate(FALLOC_FL_PUNCH_HOLE).
>> +                         * To prevent a livelock when someone else is faulting
>> +                         * pages back, we are content with single pass and do
>> +                         * not retry with index = start. It's important that
>> +                         * previous page content has been discarded, and
>> +                         * faulter(s) got new zeroed pages.
>> +                         *
>> +                         * The other callsites are shmem_setattr (for
>> +                         * truncation) and shmem_evict_inode, which set i_size
>> +                         * to truncated size or 0, respectively, and then call
>> +                         * us with lstart == inode->i_size. There we do want to
>> +                         * retry, and livelock cannot happen for other reasons.
>> +                         *
>> +                         * XXX what about i915_gem_object_truncate?
>> +                         */
>
> I doubt you have ever faced such a criticism before, but I'm going
> to speak my mind and say that comment is too long!  A comment of that
> length is okay above or just inside or at a natural break in a function,
> but here it distracts too much from what the code is actually doing.

Fair enough. The reasoning should have gone into commit log, not comment.

> In particular, the words "this condition" are so much closer to the
> condition above than the condition below, that it's rather confusing.
>
> /* Single pass when hole-punching to not livelock on racing faults */
> would have been enough (yes, I've cheated, that would be 2 or 4 lines).
>
>> +                        if (lstart < inode->i_size)
>
> For a long time I was going to suggest that you leave i_size out of it,
> and use "lend > 0" instead.  Then suddenly I realized that this is the
> wrong place for the test.

Well my first idea was to just add a flag about how persistent it should 
be. And set it false for the punch hole case. Then I wondered if there's 
already some bit that distinguishes it. But it makes it more subtle.

> And then that it's not your fault, it's mine,
> in v3.1's d0823576bf4b "mm: pincer in truncate_inode_pages_range".
> Wow, that really pessimized the hole-punch case!
>
> When is pvec.nr 0?  When we've reached the end of the file.  Why should
> we go to the end of the file, when punching a hole at the start?  Ughh!

Ah, I see (I think). But I managed to reproduce this problem when there 
was only an extra page between lend and the end of file, so I doubt this 
is the only problem. AFAIU it's enough to try punching a large enough 
hole, then the loop can only do a single pagevec worth of pages per 
iteration, which gives enough time for somebody faulting pages back?

>> +                                break;
>>   			index = start;
>>   			continue;
>>   		}
>> --
>> 1.8.4.5
>
> But there is another problem.  We cannot break out after one pass on
> shmem, because there's a possiblilty that a swap entry in the radix_tree
> got swizzled into a page just as it was about to be removed - your patch
> might then leave that data behind in the hole.

Thanks, I didn't notice that. Do I understand correctly that this could 
mean info leak for the punch hole call, but wouldn't be a problem for 
madvise? (In any case, that means the solution is not general enough for 
all kernels, so I'm asking just to be sure).

> As it happens, Konstantin Khlebnikov suggested a patch for that a few
> weeks ago, before noticing that it's already handled by the endless loop.
> If we make that loop no longer endless, we need to add in Konstantin's
> "if (shmem_free_swap) goto retry" patch.
>
> Right now I'm thinking that my idiocy in d0823576bf4b may actually
> be the whole of Trinity's problem: patch below.  If we waste time
> traversing the radix_tree to end-of-file, no wonder that concurrent
> faults have time to put something in the hole every time.
>
> Sasha, may I trespass on your time, and ask you to revert the previous
> patch from your tree, and give this patch below a try?  I am very
> interested to learn if in fact it fixes it for you (as it did for me).

I will try this, but as I explained above, I doubt that alone will help.

> However, I am wasting your time, in that I think we shall decide that
> it's too unsafe to rely solely upon the patch below (what happens if
> 1024 cpus are all faulting on it while we try to punch a 4MB hole at

My reproducer is 4MB file, where the puncher tries punching everything 
except first and last page. And there are 8 other threads (as I have 8 
logical CPU's) that just repeatedly sweep the same range, reading only 
the first byte of each page.

> end of file? if we care).  I think we shall end up with the optimization
> below (or some such: it can be written in various ways), plus reverting
> d0823576bf4b's "index == start && " pincer, plus Konstantin's
> shmem_free_swap handling, rolled into a single patch; and a similar

So that means no retry in any case (except the swap thing)? All callers 
can handle that? I guess shmem_evict_inode would be ok, as nobody else
can be accessing that inode. But what about shmem_setattr? (i.e. 
straight truncation) As you said earlier, faulters will get a SIGBUS 
(which AFAIU is due to i_size being updated before we enter 
shmem_undo_range). But could possibly a faulter already pass the i_size 
test, and proceed with the fault only when we are already in 
shmem_undo_range and have passed the page in question?

> patch (without the swap part) for several functions in truncate.c.
>
> Hugh
>
> --- 3.16-rc2/mm/shmem.c	2014-06-16 00:28:55.124076531 -0700
> +++ linux/mm/shmem.c	2014-06-25 10:28:47.063967052 -0700
> @@ -470,6 +470,7 @@ static void shmem_undo_range(struct inod
>   	for ( ; ; ) {
>   		cond_resched();
>
> +		index = min(index, end);
>   		pvec.nr = find_get_entries(mapping, index,
>   				min(end - index, (pgoff_t)PAGEVEC_SIZE),
>   				pvec.pages, indices);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
