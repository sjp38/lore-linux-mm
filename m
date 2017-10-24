Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C120F6B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 11:15:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h28so18699381pfh.16
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:15:56 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id k8si289456pli.74.2017.10.24.08.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Oct 2017 08:15:36 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, swap: Fix false error message in __swp_swapcount()
References: <20171024024700.23679-1-ying.huang@intel.com>
	<20171024083809.lrw23yumkassclgm@dhcp22.suse.cz>
Date: Tue, 24 Oct 2017 23:15:32 +0800
In-Reply-To: <20171024083809.lrw23yumkassclgm@dhcp22.suse.cz> (Michal Hocko's
	message of "Tue, 24 Oct 2017 10:38:09 +0200")
Message-ID: <87vaj4poff.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@linux.intel.com>, Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>

Hi, Michal,

Michal Hocko <mhocko@kernel.org> writes:

> On Tue 24-10-17 10:47:00, Huang, Ying wrote:
>> From: Ying Huang <ying.huang@intel.com>
>> 
>> __swp_swapcount() is used in __read_swap_cache_async().  Where the
>> invalid swap entry (offset > max) may be supplied during swap
>> readahead.  But __swp_swapcount() will print error message for these
>> expected invalid swap entry as below, which will make the users
>> confusing.
>   ^^
> confused... And I have to admit this changelog has left me confused as
> well. What is an invalid swap entry in the readahead? Ohh, let me
> re-real Fixes: commit. It didn't really help "We can avoid needlessly
> allocating page for swap slots that are not used by anyone.  No pages
> have to be read in for these slots."
>
> Could you be more specific about when and how this happens please?

Sorry for confusing.

When page fault occurs for a swap entry, the original swap readahead
(not new VMA base swap readahead) may readahead several swap entries
after the fault swap entry.  The readahead algorithm calculates some of
the swap entries to readahead via increasing the offset of the fault
swap entry without checking whether they are beyond the end of the swap
device and it rely on the __swp_swapcount() and swapcache_prepare() to
check it.  Although __swp_swapcount() checks for the swap entry passed
in, it will complain with error message for the expected invalid swap
entry.  This makes the end user confusing.

Is this a little clearer.

Best Regards,
Huang, Ying

>>   swap_info_get: Bad swap offset entry 0200f8a7
>> 
>> So the swap entry checking code in __swp_swapcount() is changed to
>> avoid printing error message for it.  To avoid to duplicate code with
>> __swap_duplicate(), a new helper function named
>> __swap_info_get_silence() is added and invoked in both places.
>> 
>> Cc: Tim Chen <tim.c.chen@linux.intel.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: <stable@vger.kernel.org> # 4.11-4.13
>> Reported-by: Christian Kujau <lists@nerdbynature.de>
>> Fixes: e8c26ab60598 ("mm/swap: skip readahead for unreferenced swap slots")
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> ---
>>  mm/swapfile.c | 42 ++++++++++++++++++++++++++++--------------
>>  1 file changed, 28 insertions(+), 14 deletions(-)
>> 
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index 3074b02eaa09..3193aa670c90 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -1107,6 +1107,30 @@ static struct swap_info_struct *swap_info_get_cont(swp_entry_t entry,
>>  	return p;
>>  }
>>  
>> +static struct swap_info_struct *__swap_info_get_silence(swp_entry_t entry)
>> +{
>> +	struct swap_info_struct *p;
>> +	unsigned long offset, type;
>> +
>> +	if (non_swap_entry(entry))
>> +		goto out;
>> +
>> +	type = swp_type(entry);
>> +	if (type >= nr_swapfiles)
>> +		goto bad_file;
>> +	p = swap_info[type];
>> +	offset = swp_offset(entry);
>> +	if (unlikely(offset >= p->max))
>> +		goto out;
>> +
>> +	return p;
>> +
>> +bad_file:
>> +	pr_err("swap_info_get_silence: %s%08lx\n", Bad_file, entry.val);
>> +out:
>> +	return NULL;
>> +}
>> +
>>  static unsigned char __swap_entry_free(struct swap_info_struct *p,
>>  				       swp_entry_t entry, unsigned char usage)
>>  {
>> @@ -1357,7 +1381,7 @@ int __swp_swapcount(swp_entry_t entry)
>>  	int count = 0;
>>  	struct swap_info_struct *si;
>>  
>> -	si = __swap_info_get(entry);
>> +	si = __swap_info_get_silence(entry);
>>  	if (si)
>>  		count = swap_swapcount(si, entry);
>>  	return count;
>> @@ -3356,22 +3380,16 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
>>  {
>>  	struct swap_info_struct *p;
>>  	struct swap_cluster_info *ci;
>> -	unsigned long offset, type;
>> +	unsigned long offset;
>>  	unsigned char count;
>>  	unsigned char has_cache;
>>  	int err = -EINVAL;
>>  
>> -	if (non_swap_entry(entry))
>> +	p = __swap_info_get_silence(entry);
>> +	if (!p)
>>  		goto out;
>>  
>> -	type = swp_type(entry);
>> -	if (type >= nr_swapfiles)
>> -		goto bad_file;
>> -	p = swap_info[type];
>>  	offset = swp_offset(entry);
>> -	if (unlikely(offset >= p->max))
>> -		goto out;
>> -
>>  	ci = lock_cluster_or_swap_info(p, offset);
>>  
>>  	count = p->swap_map[offset];
>> @@ -3418,10 +3436,6 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
>>  	unlock_cluster_or_swap_info(p, ci);
>>  out:
>>  	return err;
>> -
>> -bad_file:
>> -	pr_err("swap_dup: %s%08lx\n", Bad_file, entry.val);
>> -	goto out;
>>  }
>>  
>>  /*
>> -- 
>> 2.14.2
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
