Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id BCBB66B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 07:20:00 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so5992447pde.6
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 04:20:00 -0800 (PST)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id gj4si15200252pac.234.2014.02.10.04.19.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 04:19:52 -0800 (PST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Mon, 10 Feb 2014 22:19:47 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 05F193578052
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 23:19:44 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1AC09cx459074
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 23:00:09 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1ACJhGg012441
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 23:19:43 +1100
Message-ID: <52F8C556.6090006@linux.vnet.ibm.com>
Date: Mon, 10 Feb 2014 17:55:58 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org> <alpine.DEB.2.02.1402061456290.31828@chino.kir.corp.google.com> <20140206152219.45c2039e5092c8ea1c31fd38@linux-foundation.org> <alpine.DEB.2.02.1402061537180.3441@chino.kir.corp.google.com> <alpine.DEB.2.02.1402061557210.5061@chino.kir.corp.google.com> <52F4B8A4.70405@linux.vnet.ibm.com> <alpine.DEB.2.02.1402071239301.4212@chino.kir.corp.google.com> <52F88C16.70204@linux.vnet.ibm.com> <alpine.DEB.2.02.1402100200420.30650@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1402100200420.30650@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/10/2014 03:35 PM, David Rientjes wrote:
> On Mon, 10 Feb 2014, Raghavendra K T wrote:
>
>> As you rightly pointed , I 'll drop remote memory term and use
>> something like  :
>>
>> "* Ensure readahead success on a memoryless node cpu. But we limit
>>   * the readahead to 4k pages to avoid trashing page cache." ..
>>
>
> I don't know how to proceed here after pointing it out twice, I'm afraid.
>
> numa_mem_id() is local memory for a memoryless node.  node_present_pages()
> has no place in your patch.

Hi David,  I am happy to see your pointer reg. numa_mem_id(). I did not
meant to be ignoring/offensive .. sorry if conversation thought to be so.

So I understood that you are suggesting implementations like below

1) I do not have problem with the below approach, I could post this in
next version.
( But this did not include 4k limit Linus mentioned to apply)

unsigned long max_sane_readahead(unsigned long nr)
{
         unsigned long local_free_page;
         int nid;

         nid = numa_mem_id();

         /*
          * We sanitize readahead size depending on free memory in
          * the local node.
          */
         local_free_page = node_page_state(nid, NR_INACTIVE_FILE)
                           + node_page_state(nid, NR_FREE_PAGES);
         return min(nr, local_free_page / 2);
}

2) I did not go for below because Honza (Jan Kara) had some
concerns for 4k limit for normal case, and since I am not
the expert, I was waiting for opinions.

unsigned long max_sane_readahead(unsigned long nr)
{
         unsigned long local_free_page, sane_nr;
         int nid;

         nid = numa_mem_id();
	/* limit the max readahead to 4k pages */
	sane_nr = min(nr, MAX_REMOTE_READAHEAD);

         /*
          * We sanitize readahead size depending on free memory in
          * the local node.
          */
         local_free_page = node_page_state(nid, NR_INACTIVE_FILE)
                           + node_page_state(nid, NR_FREE_PAGES);
         return min(sane_nr, local_free_page / 2);
}

>
>> Regarding ACCESS_ONCE, since we will have to add
>> inside the function and still there is nothing that could prevent us
>> getting run on different cpu with a different node (as Andrew ponted), I have
>> not included in current patch that I am posting.
>> Moreover this case is hopefully not fatal since it is just a hint for
>> readahead we can do.
>>
>
> I have no idea why you think the ACCESS_ONCE() is a problem.  It's relying
> on gcc's implementation to ensure that the equation is done only for one
> node.  It has absolutely nothing to do with the fact that the process may
> be moved to another cpu upon returning or even immediately after the
> calculation is done.  Is it possible that node0 has 80% of memory free and
> node1 has 80% of memory inactive?  Well, then your equation doesn't work
> quite so well if the process moves.
>
> There is no downside whatsoever to using it, I have no idea why you think
> it's better without it.

I have no problem introducing ACESSS_ONCE too. But I skipped only
after I got the below error.

mm/readahead.c: In function ?max_sane_readahead?:
mm/readahead.c:246: error: lvalue required as unary ?&? operand

>
>> So there are many possible implementation:
>> (1) use numa_mem_id(), apply freepage limit  and use 4k page limit for all
>> case
>> (Jan had reservation about this case)
>>
>> (2)for normal case:    use free memory calculation and do not apply 4k
>>      limit (no change).
>>     for memoryless cpu case:  use numa_mem_id for more accurate
>>      calculation of limit and also apply 4k limit.
>>
>> (3) for normal case:   use free memory calculation and do not apply 4k
>>      limit (no change).
>>      for memoryless case: apply 4k page limit
>>
>> (4) use numa_mem_id() and apply only free page limit..
>>
>> So, I ll be resending the patch with changelog and comment changes
>> based on your and Andrew's feedback (type (3) implementation).
>>
>
> It's frustrating to have to say something three times.  Ask yourself what
> happens if ALL NODES WITH CPUS DO NOT HAVE MEMORY?
>

True, this is the reason why we could go for implementation (1) I posted
above. It was just that I did not want to float a new version without
knowing whether Andrew was expecting new patch or change log updates.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
