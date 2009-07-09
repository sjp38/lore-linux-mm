Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 966FD6B0055
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 00:41:01 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n694spXm005659
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 9 Jul 2009 13:54:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0394545DE4E
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 13:54:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CF1E845DE4D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 13:54:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B84BB1DB803A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 13:54:50 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 644531DB8041
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 13:54:47 +0900 (JST)
Message-ID: <ae515eca783abc9494e251f2be87327c.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <alpine.LFD.2.01.0907082058340.3352@localhost.localdomain>
References: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
    <20090709122801.21806c01.kamezawa.hiroyu@jp.fujitsu.com>
    <alpine.LFD.2.01.0907082058340.3352@localhost.localdomain>
Date: Thu, 9 Jul 2009 13:54:46 +0900 (JST)
Subject: Re: [PATCH 2/2] ZERO PAGE by pte_special
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
>
>
> On Thu, 9 Jul 2009, KAMEZAWA Hiroyuki wrote:
>>
>> +	/* we can ignore zero page */
>> +	page = vm_normal_page(vma, addr, pte, 1);
>
>> -			page = vm_normal_page(vma, addr, ptent);
>> +			page = vm_normal_page(vma, addr, ptent, 1);
>
>> -	page = vm_normal_page(vma, address, pte);
>> +	page = vm_normal_page(vma, address, pte, (flags & FOLL_NOZERO));
>
>> +	int ignore_zero = !!(flags & GUP_FLAGS_IGNORE_ZERO);
>> ...
>> +				page = vm_normal_page(gate_vma, start,
>> +						      *pte, ignore_zero);
>
>> +			if (ignore_zero)
>> +				foll_flags |= FOLL_NOZERO;
>
>> +	/* This returns NULL when we find ZERO page */
>> +	old_page = vm_normal_page(vma, address, orig_pte, 1);
>
>> +		/* we can ignore zero page */
>> +		page = vm_normal_page(vma, addr, pte, 1);
>
>> +		/* we avoid zero page here */
>> +		page = vm_normal_page(vma, addr, *pte, 1);
>
>> +		/*
>> +		 * Because we comes from try_to_unmap_file(), we'll never see
>> +		 * ZERO_PAGE or ANON.
>> +		 */
>> +		page = vm_normal_page(vma, address, *pte, 1);
>
>>  struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long
>> addr,
>> -		pte_t pte);
>> +		pte_t pte, int ignore_zero);
>
> So I'm quoting these different uses, because they show the pattern that
> exists all over this patch: confusion about "no zero" vs "ignore zero" vs
> just plain no explanation at all.
>
> Quite frankly, I hate the "ignore zero page" naming/comments. I can kind
> of see why you named them that way - we'll not consider it a normal page.
> But that's not "ignoring" it. That's very much noticing it, just saying we
> don't want to get the "struct page" for it.
>
> I equally hate the anonymous "1" use, with or without comments. Does "1"
> mean that you want the zero page, does it means you _don't_ want it, what
> does it mean? Yes, I know that it means FOLL_NOZERO, and that when set, we
> don't want the zero page, but regardless, it's just not very readable.
>
> So I would suggest:
>
>  - never pass in "1".
>
>  - never talk about "ignoring" it.
>
>  - always pass in a _flag_, in this case FOLL_NOZERO.
>
> If you follow those rules, you almost don't need commentary. Assuming
> somebody is knowledgeable about the Linux VM, and knows we have a zero
> page, you can just see a line like
>
> 	page = vm_normal_page(vma, address, *pte, FOLL_NOZERO);
>
Ahh, yes. This looks much better. I'll do in this way in v4.



> and you can understand that you don't want to see ZERO_PAGE. There's never
> any question like "what does that '1' mean here?"
>
> In fact, I'd pass in all of "flags", and then inside vm_normal_page() just
> do
>
> 	if (flags & FOLL_NOZERO) {
> 		...
>
> rather than ever have any boolean arguments.
>
> (Again, I think that we should unify all of FOLL_xyz and FAULT_FLAG_xyz
> and GUP_xyz into _one_ namespace - probably all under FAULT_FLAG_xyz - but
> that's still a separate issue from this particular patchset).
>
sure...it's confusing...I'll start some work to clean it up when I have
a chance.


> Anyway, that said, I think the patch looks pretty simple and fairly
> straightforward. Looks very much like 2.6.32 material, assuming people
> will test it heavily and clean it up as per above before the next merge
> window.
>

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
