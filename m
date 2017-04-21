Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 371096B0390
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:29:34 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id v34so131328470iov.22
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:29:34 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q20si10252199pfk.314.2017.04.21.05.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 05:29:33 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v3] mm, swap: Sort swap entries before free
References: <20170407064901.25398-1-ying.huang@intel.com>
	<20170418045909.GA11015@bbox> <87y3uwrez0.fsf@yhuang-dev.intel.com>
	<20170420063834.GB3720@bbox> <874lxjim7m.fsf@yhuang-dev.intel.com>
Date: Fri, 21 Apr 2017 20:29:30 +0800
In-Reply-To: <874lxjim7m.fsf@yhuang-dev.intel.com> (Ying Huang's message of
	"Thu, 20 Apr 2017 15:15:25 +0800")
Message-ID: <87tw5idjv9.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>

"Huang, Ying" <ying.huang@intel.com> writes:

> Minchan Kim <minchan@kernel.org> writes:
>
>> On Wed, Apr 19, 2017 at 04:14:43PM +0800, Huang, Ying wrote:
>>> Minchan Kim <minchan@kernel.org> writes:
>>> 
>>> > Hi Huang,
>>> >
>>> > On Fri, Apr 07, 2017 at 02:49:01PM +0800, Huang, Ying wrote:
>>> >> From: Huang Ying <ying.huang@intel.com>
>>> >> 
>>> >>  void swapcache_free_entries(swp_entry_t *entries, int n)
>>> >>  {
>>> >>  	struct swap_info_struct *p, *prev;
>>> >> @@ -1075,6 +1083,10 @@ void swapcache_free_entries(swp_entry_t *entries, int n)
>>> >>  
>>> >>  	prev = NULL;
>>> >>  	p = NULL;
>>> >> +
>>> >> +	/* Sort swap entries by swap device, so each lock is only taken once. */
>>> >> +	if (nr_swapfiles > 1)
>>> >> +		sort(entries, n, sizeof(entries[0]), swp_entry_cmp, NULL);
>>> >
>>> > Let's think on other cases.
>>> >
>>> > There are two swaps and they are configured by priority so a swap's usage
>>> > would be zero unless other swap used up. In case of that, this sorting
>>> > is pointless.
>>> >
>>> > As well, nr_swapfiles is never decreased so if we enable multiple
>>> > swaps and then disable until a swap is remained, this sorting is
>>> > pointelss, too.
>>> >
>>> > How about lazy sorting approach? IOW, if we found prev != p and,
>>> > then we can sort it.
>>> 
>>> Yes.  That should be better.  I just don't know whether the added
>>> complexity is necessary, given the array is short and sort is fast.
>>
>> Huh?
>>
>> 1. swapon /dev/XXX1
>> 2. swapon /dev/XXX2
>> 3. swapoff /dev/XXX2
>> 4. use only one swap
>> 5. then, always pointless sort.
>
> Yes.  In this situation we will do unnecessary sorting.  What I don't
> know is whether the unnecessary sorting will hurt performance in real
> life.  I can do some measurement.

I tested the patch with 1 swap device and 1 process to eat memory
(remove the "if (nr_swapfiles > 1)" for test).  I think this is the
worse case because there is no lock contention.  The memory freeing time
increased from 1.94s to 2.12s (increase ~9.2%).  So there is some
overhead for some cases.  I change the algorithm to something like
below,

 void swapcache_free_entries(swp_entry_t *entries, int n)
 {
 	struct swap_info_struct *p, *prev;
 	int i;
+	swp_entry_t entry;
+	unsigned int prev_swp_type;
 
 	if (n <= 0)
 		return;
 
+	prev_swp_type = swp_type(entries[0]);
+	for (i = n - 1; i > 0; i--) {
+		if (swp_type(entries[i]) != prev_swp_type)
+			break;
+	}
+
+	/* Sort swap entries by swap device, so each lock is only taken once. */
+	if (i)
+		sort(entries, n, sizeof(entries[0]), swp_entry_cmp, NULL);
 	prev = NULL;
 	p = NULL;
 	for (i = 0; i < n; ++i) {
-		p = swap_info_get_cont(entries[i], prev);
+		entry = entries[i];
+		p = swap_info_get_cont(entry, prev);
 		if (p)
-			swap_entry_free(p, entries[i]);
+			swap_entry_free(p, entry);
 		prev = p;
 	}
 	if (p)

With this patch, the memory freeing time increased from 1.94s to 1.97s.
I think this is good enough.  Do you think so?

I will send out the formal patch soon.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
