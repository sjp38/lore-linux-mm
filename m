Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 486376B004F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 05:47:03 -0400 (EDT)
Message-ID: <4A4B317F.4050100@redhat.com>
Date: Wed, 01 Jul 2009 12:50:55 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: KSM: current madvise rollup
References: <Pine.LNX.4.64.0906291419440.5078@sister.anvils> <4A49E051.1080400@redhat.com> <Pine.LNX.4.64.0906301518370.967@sister.anvils> <4A4A5C56.5000109@redhat.com> <Pine.LNX.4.64.0907010057320.4255@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0907010057320.4255@sister.anvils>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Tue, 30 Jun 2009, Izik Eidus wrote:
>   
>> Hugh Dickins wrote:
>>     
>>> On Tue, 30 Jun 2009, Izik Eidus wrote:
>>>       
>>>> Hugh Dickins wrote:
>>>>     
>>>>         
>>>>> I've plenty more to do: still haven't really focussed in on mremap
>>>>> move, and races when the vma we expect to be VM_MERGEABLE is actually
>>>>> something else by the time we get mmap_sem for get_user_pages. 
>>>>>       
>>>>>           
>>>> Considering the fact that the madvise run with mmap_sem(write)
>>>> isn't it enough just to check the VM_MERGEABLE flag?
>>>>         
>>> That is most of it, yes: though really we'd want that check down
>>> inside __get_user_pages(), so that it wouldn't proceed any further
>>> if by then the vma is not VM_MERGEABLE.  GUP's VM_IO | VM_PFNMAP check
>>> does already keep it away from the most dangerous areas, but we also
>>> don't want it to touch VM_HUGETLB ones (faulting in huge pages nobody
>>> wants), nor any !VM_MERGEABLE really.
>>>       
>> Ouch, I see what you mean!, previously the check for PageKsm() that was made
>> before cmp_and_merge_page() was protecting us against everything but anonymous
>> pages...
>> I saw that you change the condition, but i forgot about that  protection!
>>     
>
> No, that isn't what I meant, actually.  It's a little worrying that I
> didn't even consider your point when adding the || !rmap_item->stable_tree,
> but on reflection I don't think that changes our protection.
>   

Yes, i have forgot about this: PageAnon() check inside 
try_to_merge_one_page() - we didnt always had it...
(Sorry for all the mess... ;-))

> My point is (well, to be honest, I'm adjusting my view as I reply) that
> "PageKsm(page)" is seductive, but dangerously relative.  Until we are
> sure that we're in a VM_MERGEABLE area (and here we are not sure, just
> know that it was when the recent get_next_rmap_item returned that item),
> it means no more than the condition within that function.  You're clear
> about that in the comments above and within PageKsm() itself, but it's
> easily forgotten in the places where it's used.  Here, I'm afraid, I
> read "PageKsm(page[0])" as saying that page[0] is definitely a KSM page,
> but we don't actually know that much, since we're unsure of VM_MERGEABLE.
>
> Or when you say "I saw that you change the condition", perhaps you don't
> mean my added "|| !rmap_item->stable_tree" below, but my change to PageKsm
> itself, changing it from !PageAnon(page) to page->mapping == NULL?  I
> should explain that actually my testing was with one additional patch
>
> @@ -1433,7 +1433,8 @@ int ksm_madvise(struct vm_area_struct *v
>  			return 0;		/* just ignore the advice */
>  
>  		if (vma->vm_file || vma->vm_ops)
> -			return 0;		/* just ignore the advice */
> +			if (!(vma->vm_flags & VM_CAN_NONLINEAR))
> +				return 0;	/* just ignore the advice */
>  
>  		if (!test_bit(MMF_VM_MERGEABLE, &mm->flags))
>  			if (__ksm_enter(mm) < 0)
>
> which extends KSM from pure anonymous vmas to most private file-backed
> vmas, hence I needed the test to distinguish the KSM pages from nearby
> pages in there too.  I left that line out of the rollup I sent, partly
> to separate the extension, but mainly because I'm a bit uncomfortable
> with using "VM_CAN_NONLINEAR" in that way, for two reasons: though it
> is a way of saying "this is a normal kind of filesystem, not some weird
> device driver", if we're going to use it in that way, then we ought to
> get Nick's agreement and probably rename it VM_REGULAR (but would then
> need to define exactly what a filesystem must provide to qualify: that
> might take a while!); the other reason is, I've noticed in the past
> that btrfs is not yet setting VM_CAN_NONLINEAR, I think that's just
> an oversight (which I did once mention to Chris), but ought to check
> with Nick that I've not forgotten some reason why an ordinary filesystem
> might be unable to support nonlinear.
>   

Considering the fact that we will try to merge only anonymous pages, and 
considering the fact of our "O_DIRECT check" i think we can allow to 
scan any vma...
the thing is:
If it is evil driver that play with the page, it will have to run 
get_user_pages that will increase the pagecount but not the mapcount, 
and therefore we wont merge it while it is being used by the driver..., 
now if we will merge the page before the evil driver will do 
get_user_pages(), then in case it will really want to play with the 
page, it will have to call get_user_pages(write) that will break the 
COW..., if it will call get_user_pages(read) it wont be able to write to 
it...

Unless the driver would try to do something really tricky, and Do it in 
a buggy way (Like not checking if the page that it recive is anonymous 
or not) we should be safe.

No?

> However, if we go on to use an actual bit to distinguish PageKsm, as
> I think we shall probably have to to support swapping, then we won't
> need the VM_CAN_NONLINEAR-like check at all: so long as KSM sticks to
> merging only PageAnon pages (and I think "so long as" will be forever),
> it would be safe even on most driver areas, the only exceptions being
> /dev/mem and /dev/kmem (or anything like them: mmaps that can include
> anonymous or KSM pages without them being anonymous or KSM pages in
> the context of that mapping), which are for sure
> marked VM_IO | VM_RESERVED | VM_PFNMAP.
>
> I feel I've waved my hands in the air convincingly for several
> paragraphs, and brought in enough confusions to be fairly sure
> of confusing you, without quite getting to address your point.
> I'm not even sure I understood your point.  And whether PageKsm
> means !PageAnon or !page->mapping, for different reasons those
> are both pretty safe, so maybe I've overestimated the danger of
> races here - though I still believe we need to protect against them.
>
>   
>> Looking again this line you do:
>>                if (!PageKsm(page[0]) ||
>>                    !rmap_item->stable_tree)
>>                    cmp_and_merge_page(page[0], rmap_item);
>>
>> How would we get into situation where rmap_item->stable_tree would be NULL,
>> and page[0] would be not anonymous page and we would like to enter to
>> cmp_and_merge_page()?
>>
>> Can you expline more this line please? (I have looked on it before, but i
>> thought i saw reasonable case for it, But now looking again I cant remember)
>>     
>
> We get into that situation through fork().  If a task with a
> VM_MERGEABLE vma (which already contains KSM pages) does fork(),
> then the child's mm will contain KSM pages.  The original ksm.c
> would tend to leak KSM pages that way, the KSM page count would
> get decremented when they vanished from the parent's mm, but they
> could be held indefinitely in the child's mm without being counted
> in or out: I fixed that by fork copying MMF_VM_MERGEABLE and putting
> child on mm_list, and this counting in of the KSM pages.
>
> But thank you for saying "page[0] would be not anonymous page", I was
> going to point out the error of reading PageKsm that way now, when I
> realize I've got it wrong myself - I really ought to have changed that
> !PageKsm(page[0]) over to PageAnon(page[0]), shouldn't I?  Though
> probably saved from serious error by try_to_merge_one_page's later
> PageAnon check, haven't I been wasting a lot of time on passing down
> file pages to cmp_and_merge_page() there?  Ah, and you're pointing
> out that they come down anyway with the ||!stable part of the test.
>
> (Though, aside from races, they're only coming down when VM_MERGEABLE's
> vm_file test is overridden, as in my own testing, but not in the rollup
> I sent.)
>
> I'll check that again in the morning: it really reinforces my point
> above that "PageKsm" is too dangerously deceptive as it stands.
>   

Because we have this AnonPage() check in try_to_merge_one_page() it 
should be safe to allow filebacked pages to go into 
cmp_and_merge_page(), but! I dont think it anything useful..., we cant 
merge this pages... so why burn cpu cycles on them?...

If you feel more comfortable with PageKsm() -> !page->mapping, we can 
add an PageAnon check before cmp_and_merge_page()...


>
> [ re: PageAnon test before dec/inc_mm_counter ]
>
>   
>> See my comment above, I meant that only Anonymous pages should come into this
>> path..., (I missed the fact that the || condition before the
>> cmp_and_merge_page() call change the behavior and allowed file-mapped pages to
>> get merged)
>>     
>
> If file-mapped pages get anywhere near here, it's only a bug.  But I
> do want anonymous COWed pages in private file-mapped areas to be able
> to get here soon.
>
> By this stage, try_to_merge_one_page's
>
> 	if (!PageAnon(oldpage))
> 		goto out;
>
> has already come into play, so your point stands, that the PageAnon
> test around the dec/inc_mm_counter is strictly unnecessary; but as
> I said, I want to keep it for now as a little warning flag to me.
>
> But put this (the funny way pages move from anon to file) together
> with my PageKsm confusions above, and I think we have a clear case
> for adding the PageKsm flag (in page->mapping with PageAnon) already.
>   

You mean to do: PageKsm()-> if !page->mapping && !PageAnon(page) ?

>
> [ re: kpage_outside_tree versus double break_cow ]
>
>   
>>> Surely there's some reason you did it the convoluted way originally?
>>> Perhaps the locking was different at the time the issue first came up,
>>> and you were not free to break_cow() here at that time?  Sadly, I don't
>>> think my testing has gone down this path even once, I hope yours does.
>>>       
>> Well the only reason that i did it was that it looked more optimal - if we
>> already found 2 identical pages and they are both shared....
>>     
>
> Ah, I see, yes, that makes some sense - though I've not fully thought
> it through, and don't have a strong enough grasp on the various reasons
> why stable_tree_insert can fail ...
>   


Honestly - that doesn't make much sense considering the complexity it 
added, I have no idea what i thought to myself when I wrote it!

>> The complexity that it add to the code isnt worth it, plus it might turn on to
>> be less effective, beacuse due to the fact that they will be outside the
>> stable_tree, less pages will be merged with them....
>>     
>
> ... but agree the complexity is not worth it, or not without a stronger
> real life case.  Especially as I never observed it to happen anyway.
> The beauty of the unstable tree is how these temporary failures
> should sort themselves out in due course, without special casing.
>
>
> [ re: list_add_tail ]
>   
>>> Now, I prefer list_add_tail because I just find it easier to think
>>> through the sequence using list_add_tail; but it occurred to me later
>>> that you might have run tests which show list_add head to behave better.
>>>
>>> For example, if you always list_add new mms to the head (and the scan
>>> runs forwards from the head: last night I added an experimental option
>>> to run backwards, but notice no difference), then the unstable tree
>>> will get built up starting with the pages from the new mms, which
>>> might jostle the tree better than always starting with the same old
>>> mms?  So I might be spoiling a careful and subtle decision you made.
>>>       
>> I saw this change, previously the order was made arbitrary - meaning I never
>> thought what should be the right order..
>> So if you feel something is better that way - it is fine (and better than my
>> unopinion for that case)
>>     
>
> Okay, thanks.  I think the fork() potential for time-wasting that I
> comment upon in the code makes a good case for doing list_add_tail
> behind the cursor as it stands.  But we can revisit if someone comes
> up with evidence for doing it differently - I think there's scope
> for academic papers on the behaviour of the unstable tree.
>   

Well there is a big window for optimizations for both the stable and 
unstable tree...
the current code is the naivest implementation of that stable/unstable 
trees...
> Hugh
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
