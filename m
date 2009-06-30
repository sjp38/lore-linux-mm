Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B999C6B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 14:37:54 -0400 (EDT)
Message-ID: <4A4A5C56.5000109@redhat.com>
Date: Tue, 30 Jun 2009 21:41:26 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: KSM: current madvise rollup
References: <Pine.LNX.4.64.0906291419440.5078@sister.anvils> <4A49E051.1080400@redhat.com> <Pine.LNX.4.64.0906301518370.967@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0906301518370.967@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> Many thanks for your speedy and generous response: I'm glad you like it.
>
> On Tue, 30 Jun 2009, Izik Eidus wrote:
>   
>> Hugh Dickins wrote:
>>
>>     
>>> I've plenty more to do: still haven't really focussed in on mremap
>>> move, and races when the vma we expect to be VM_MERGEABLE is actually
>>> something else by the time we get mmap_sem for get_user_pages. 
>>>       
>> Considering the fact that the madvise run with mmap_sem(write)
>> isn't it enough just to check the VM_MERGEABLE flag?
>>     
>
> That is most of it, yes: though really we'd want that check down
> inside __get_user_pages(), so that it wouldn't proceed any further
> if by then the vma is not VM_MERGEABLE.  GUP's VM_IO | VM_PFNMAP check
> does already keep it away from the most dangerous areas, but we also
> don't want it to touch VM_HUGETLB ones (faulting in huge pages nobody
> wants), nor any !VM_MERGEABLE really.
>   

Ouch, I see what you mean!, previously the check for PageKsm() that was 
made before cmp_and_merge_page() was protecting us against everything 
but anonymous pages...
I saw that you change the condition, but i forgot about that  protection!

Looking again this line you do:
                if (!PageKsm(page[0]) ||
                    !rmap_item->stable_tree)
                    cmp_and_merge_page(page[0], rmap_item);

How would we get into situation where rmap_item->stable_tree would be 
NULL, and page[0] would be not anonymous page and we would like to enter 
to cmp_and_merge_page()?

Can you expline more this line please? (I have looked on it before, but 
i thought i saw reasonable case for it, But now looking again I cant 
remember)


> However, rather than adding another flag to get_user_pages(), we
> probably want to craft KSM's own substitute for it instead: a lot
> of what GUP does (find_extend_vma, in_gate_area, follow_hugetlb_page,
> handle_mm_fault) is stuff you actively do NOT want - all you want,
> I think, is find_vma + VM_MERGEABLE check + follow_page.  And you
> might have gone that way already, except follow_page wasn't EXPORTed,
> and you were at that time supporting KSM as a loadable module.
>
> But that isn't the whole of it.  I don't think there's any other way
> to do it, but with mremap move you can move one VM_MERGEABLE area to
> where another VM_MERGEABLE area was a moment ago, placing KSM pages
> belonging to the one area where KSM pages of the other are expected.
> Can't you?  I don't think that would actually cause data corruption,
> but it could badly poison the stable tree (memcmp'ing against a page
> of data which is not what's expected at that point in the tree),
> rendering KSM close to useless thereafter.  I think.
>
> The simplest answer to that is to prohibit mremap move on VM_MERGEABLE
> areas.  We already have atypical prohibitions in mremap e.g. it's not
> allowed to span vmas; and I don't think it would limit anybody's real
> life use of KSM.  However, I don't like that solution because it gets
> in the way of things like my testing with all areas VM_MERGEABLE, or
> your applying mergeability to another process address space: if we
> make some area mergeable, then later the app happens to decide it
> wants to move that area, it would get an unexpected failure where
> none normally occurs.  So, I'll probably want to allow mremap move,
> but add a ksm_mremap interface to rearrange the rmap_items at the
> same time (haven't considered locking yet, that's often the problem).
>
>   
>> About page migration - right now it should fail when trying to migrate
>> ksmpage:
>>
>> /* Establish migration ptes or remove ptes */
>> try_to_unmap(page, 1);
>>
>> if (!page_mapped(page))
>> rc = move_to_new_page(newpage, page);
>>
>>
>> So as I see it, the soultion for this case is the same soultion as for the
>> swapping problem of the ksm pages...:
>> We need something such as extrnal rmap callbacks to make the rmap code be
>> aware of the ksm virtual mappings of the pages - (we can use our data
>> structures information inside ksm such as the stable_tree to track the virtual
>> addresses that point into this page)
>>
>> So about the page migration i think we need to add support to it, when we add
>> support of swapping, probably one release after we first get ksm merged...
>>
>> And about cgroups, again, i think swapping is main issue for this, for now we
>> only have max_kernel_page_alloc to control the number of unswappable pages
>> allocated by ksm.
>>     
>
> Yes, I woke this morning thinking swapping the KSM pages should be a lot
> easier than I thought originally.  Not much more than plumbing in a third
> alternative to try_to_unmap_file and try_to_unmap_anon, one which goes off
> to KSM to run down the appropriate list hanging off the stable tree.
>
> I'd intended it for other use, but I think now we'll likely give you
> PAGE_MAPPING_KSM 2, so you can fit a tree_item pointer and page flag
> into page_mapping there, instead of anon_vma pointer and PageAnon flag.
> Or more likely, in addition to PageAnon flag.
>
> It's very tempting to get into KSM swapping right now,
> but I'll restrain myself.
>   

Thanks you, I really want to go step by step with this..., To much 
changes would scare everyone :(

>   
>> [replace_page ]
>>     
>>> +
>>> +	BUG_ON(PageAnon(newpage));
>>> ...
>>> +
>>> +	page_remove_rmap(oldpage);
>>> +	if (PageAnon(oldpage)) {
>>> +		dec_mm_counter(mm, anon_rss);
>>> +		inc_mm_counter(mm, file_rss);
>>> +	}
>>>   
>>>       
>> So now that replace_page is embedded inside ksm.c, i guess we dont need the if
>> (PageAnon() check...) ?
>>     
>
> The first time I read you, I thought you were suggesting to remove the
> BUG_ON(PageAnon(newpage)) at the head of replace_page: yes, now that's
> static within ksm.c, it's just a waste of space, better removed.
>
> But you're suggesting remove this check around the dec/inc_mm_counter.
> Well, of course, you're absolutely right; but I'd nonetheless actually
> prefer to keep that test for the moment, as a flag of something odd to
> revisit.  Perhaps you'd prefer a comment "/* Something odd to revisit */"
> instead ;)  But if so, let's keep PageAnon in the text of the comment:
> I know I'm going to want to go back to check usages of PageAnon here,
> and this is a block I'll want to think about.
>
> When testing, I got quite confused for a while when /proc/meminfo
> showed my file pages going up and my anon pages going down.  Yes,
> that block is necessary to keep the stats right for unmap and exit;
> but I think, the more so when we move on to swapping, that we'd
> prefer KSM-substituted-pages to remain counted as anon rather than
> as file, in the bulk of the mm which is unaware of KSM pages.
> Something odd to revisit.
>   


See my comment above, I meant that only Anonymous pages should come into 
this path..., (I missed the fact that the || condition before the 
cmp_and_merge_page() call change the behavior and allowed file-mapped 
pages to get merged)

>   
>>> +static void cmp_and_merge_page(struct page *page, struct rmap_item
>>> *rmap_item)
>>> +{
>>> +	struct page *page2[1];
>>> +	struct rmap_item *tree_rmap_item;
>>> +	unsigned int checksum;
>>> +	int ret;
>>> +
>>> +	if (rmap_item->stable_tree)
>>> +		remove_rmap_item_from_tree(rmap_item);
>>> +
>>> +	/* We first start with searching the page inside the stable tree */
>>> +	tree_rmap_item = stable_tree_search(page, page2, rmap_item);
>>> +	if (tree_rmap_item) {
>>> +		BUG_ON(!tree_rmap_item->tree_item);
>>> +
>>> +		if (page == page2[0]) {		/* forked */
>>> +			ksm_pages_shared++;
>>> +			ret = 0;
>>>       
>> So here we increase the ksm_pages_shared, but how would we decrease it?
>> Shouldnt we map the rmap_item to be stable_tree item?, and add this virtual
>> address into the linked list of the stable tree node?
>> (so when remove_rmap_item() will run we will be able to decrease the
>> number...)
>>     
>
> You had me worried, and I wondered how the numbers had worked out
> correctly in testing; and this was a rather recent mod which could
> easily be wrong.  But it's okay, isn't it?  In the very code which
> you included below, there's the insert_to_stable_tree_list which
> does exactly what you want - doesn't it?
>   

You are right, i didnt notice that case.

>   
>>> +		} else
>>> +			ret = try_to_merge_two_pages_noalloc(rmap_item->mm,
>>> +							    page, page2[0],
>>> +
>>> rmap_item->address);
>>> +		put_page(page2[0]);
>>> +
>>> +		if (!ret) {
>>> +			/*
>>> +			 * The page was successfully merged, let's insert its
>>> +			 * rmap_item into the stable tree.
>>> +			 */
>>> +			insert_to_stable_tree_list(rmap_item, tree_rmap_item);
>>> +		}
>>> +		return;
>>> +	}
>>>       
>
>   
>>> +			/*
>>> +			 * If we fail to insert the page into the stable tree,
>>> +			 * we will have 2 virtual addresses that are pointing
>>> +			 * to a KsmPage left outside the stable tree,
>>> +			 * in which case we need to break_cow on both.
>>> +			 */
>>> +			if (stable_tree_insert(page2[0], tree_item,
>>> +					       tree_rmap_item) == 0) {
>>> +				insert_to_stable_tree_list(rmap_item,
>>> +							   tree_rmap_item);
>>> +			} else {
>>> +				free_tree_item(tree_item);
>>> +				tree_rmap_item->tree_item = NULL;
>>> +				break_cow(tree_mm, tree_addr);
>>> +				break_cow(rmap_item->mm, rmap_item->address);
>>> +				ksm_pages_shared -= 2;
>>>   
>>>       
>> Much better handling than my kpage_outside_tree !
>>     
>
> You surprise me!  Although I couldn't see what was wrong with doing
> the break_cow()s there, I made that change pretty much as a provocation,
> to force you to explain patiently why we cannot break_cow() there, but
> have to go through the kpage_outside_tree, nkpage_out_tree (how I hated
> that name!) dance.  I thought perhaps that you'd found in testing that
> fixing it all up there got ksmd into making the same "mistake" again
> and again, so better to introduce a delay; then I was going to suggest
> forcing checksum back to 0 instead, and adding a comment (I removed the
> other, no longer stable, reason for "wait" too: thinking, by all means
> reinstate, but let's have a separate patch and comment to explain it).
>
> Surely there's some reason you did it the convoluted way originally?
> Perhaps the locking was different at the time the issue first came up,
> and you were not free to break_cow() here at that time?  Sadly, I don't
> think my testing has gone down this path even once, I hope yours does.
>   

Well the only reason that i did it was that it looked more optimal - if 
we already found 2 identical pages and they are both shared....
The complexity that it add to the code isnt worth it, plus it might turn 
on to be less effective, beacuse due to the fact that they will be 
outside the stable_tree, less pages will be merged with them....

>   
>> Great / Excllent work Hugh!, I really like the result, no need from you to
>> split it, i just have walked the code again, and i like it.
>> From the perspective of features, i dont think i want to change anything for
>> the merge release, about the migration/cgroup and all friends,
>> I think the swapping work that will be need to be taken for ksm will solve
>> their problems as well, at least from infrastructure point of view.
>>
>> I will run it on my server and will try to heavy load it...
>>     
>
> Great, I'm so pleased, thank you.
>
> Aside from the break_cows change you already noticed above, there
> was one other thing I wanted to check with you, where my __ksm_enter does:
> 	/*
> 	 * Insert just behind the scanning cursor, to let the area settle
> 	 * down a little; when fork is followed by immediate exec, we don't
> 	 * want ksmd to waste time setting up and tearing down an rmap_list.
> 	 */
> 	list_add_tail(&mm_slot->mm_list, &ksm_scan.mm_slot->mm_list);
>
> Seems reasonable enough, but I've replaced the original list_add
> to the head by a list_add_tail to behind the cursor.  And before
> I brought the cursor into it, I had a list_add_tail to the head.
>
> Now, I prefer list_add_tail because I just find it easier to think
> through the sequence using list_add_tail; but it occurred to me later
> that you might have run tests which show list_add head to behave better.
>
> For example, if you always list_add new mms to the head (and the scan
> runs forwards from the head: last night I added an experimental option
> to run backwards, but notice no difference), then the unstable tree
> will get built up starting with the pages from the new mms, which
> might jostle the tree better than always starting with the same old
> mms?  So I might be spoiling a careful and subtle decision you made.
>   

I saw this change, previously the order was made arbitrary - meaning I 
never thought what should be the right order..
So if you feel something is better that way - it is fine (and better 
than my unopinion for that case)

Thanks.

> Hugh
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
