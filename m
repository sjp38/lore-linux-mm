Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 53D9B6B0037
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 02:38:58 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so2390030pab.10
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 23:38:58 -0700 (PDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 27 Sep 2013 16:38:52 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 0E80B2BB0052
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 16:38:44 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8R6Libk3604836
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 16:21:52 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8R6cYqP010018
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 16:38:35 +1000
Message-ID: <524526EF.1080101@linux.vnet.ibm.com>
Date: Fri, 27 Sep 2013 12:04:23 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v4 06/40] mm: Demarcate and maintain pageblocks in
 region-order in the zones' freelists
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <20130925231454.26184.19783.stgit@srivatsabhat.in.ibm.com> <5244B22C.9020503@sr71.net>
In-Reply-To: <5244B22C.9020503@sr71.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "maxime.coquelin@stericsson.com" <maxime.coquelin@stericsson.com>, "loic.pallardy@stericsson.com" <loic.pallardy@stericsson.com>, "thomas.abraham@linaro.org" <thomas.abraham@linaro.org>, "amit.kachhap@linaro.org" <amit.kachhap@linaro.org>

On 09/27/2013 03:46 AM, Dave Hansen wrote:
> On 09/25/2013 04:14 PM, Srivatsa S. Bhat wrote:
>> @@ -605,16 +713,22 @@ static inline void __free_one_page(struct page *page,
>>  		buddy_idx = __find_buddy_index(combined_idx, order + 1);
>>  		higher_buddy = higher_page + (buddy_idx - combined_idx);
>>  		if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
>> -			list_add_tail(&page->lru,
>> -				&zone->free_area[order].free_list[migratetype].list);
>> +
>> +			/*
>> +			 * Implementing an add_to_freelist_tail() won't be
>> +			 * very useful because both of them (almost) add to
>> +			 * the tail within the region. So we could potentially
>> +			 * switch off this entire "is next-higher buddy free?"
>> +			 * logic when memory regions are used.
>> +			 */
>> +			add_to_freelist(page, &area->free_list[migratetype]);
>>  			goto out;
>>  		}
>>  	}
> 
> Commit 6dda9d55b says that this had some discrete performance gains.

I had seen the comments about this but not the patch which made that change.
Thanks for pointing the commit to me! But now that I went through the changelog
carefully, it appears as if there were only some slight benefits in huge page
allocation benchmarks, and the results were either inconclusive or unsubstantial
in most other benchmarks that the author tried.

> It's a bummer that this deoptimizes it, and I think that (expected)
> performance degredation at least needs to be referenced _somewhere_.
>

I'm not so sure about that. Yes, I know that my patchset treats all pages
equally (by adding all of them _far_ _away_ from the head of the list), but
given that the above commit didn't show any significant improvements, I doubt
whether my patchset will lead to any noticeable _degradation_. Perhaps I'll try
out the huge-page allocation benchmark and observe what happens with my patchset.
 
> I also find it very hard to take code seriously which stuff like this:
> 
>> +#ifdef CONFIG_DEBUG_PAGEALLOC
>> +		WARN(region->nr_free == 0, "%s: nr_free messed up\n", __func__);
>> +#endif
> 
> nine times.
> 

Hmm, those debug checks were pretty invaluable for me when testing the code.
I retained them in the patches so that if other people test it and find
problems, they would be able to send bug reports with good amount of info as
to what exactly went wrong. Besides, this patchset adds a ton of new code, and
this list manipulation framework along with the bitmap-based radix tree is one
of the core components. If that goes for a toss, everything from there onwards
will be a train-wreck! So I felt having these checks and balances would be very
useful to validate the correct working of each piece and to debug complex
problems easily.

But please help me understand your point correctly - are you suggesting that
I remove these checks completely or just make them gel well with the other code
so that they don't become such an eyesore as they are at the moment (with all
the #ifdefs sticking out etc)?

If you are suggesting the latter, I completely agree with you. I'll find out
a way to do that, and if you have any suggestions, please let me know!

Thank you!

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
