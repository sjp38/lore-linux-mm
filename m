Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id D1B566B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 03:15:35 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so5955898pbc.30
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 00:15:35 -0800 (PST)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id cf2si14401984pad.198.2014.02.10.00.15.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 00:15:34 -0800 (PST)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Mon, 10 Feb 2014 13:45:30 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 76B22E0058
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 13:48:45 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1A8FQLN28115198
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 13:45:27 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1A8FOFM008299
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 13:45:25 +0530
Message-ID: <52F88C16.70204@linux.vnet.ibm.com>
Date: Mon, 10 Feb 2014 13:51:42 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org> <alpine.DEB.2.02.1402061456290.31828@chino.kir.corp.google.com> <20140206152219.45c2039e5092c8ea1c31fd38@linux-foundation.org> <alpine.DEB.2.02.1402061537180.3441@chino.kir.corp.google.com> <alpine.DEB.2.02.1402061557210.5061@chino.kir.corp.google.com> <52F4B8A4.70405@linux.vnet.ibm.com> <alpine.DEB.2.02.1402071239301.4212@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1402071239301.4212@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/08/2014 02:11 AM, David Rientjes wrote:
> On Fri, 7 Feb 2014, Raghavendra K T wrote:
>> 3) Change the "readahead into remote memory" part of the documentation
>> which is misleading.
>>
>> ( I feel no need to add numa_mem_id() since we would specifically limit
>> the readahead with MAX_REMOTE_READAHEAD in memoryless cpu cases).
>>
>
> I don't understand what you're saying, numa_mem_id() is local memory to
> current's cpu.  When a node consists only of cpus and not memory it is not
> true that all memory is then considered remote, you won't find that in any
> specification that defines memory affinity including the ACPI spec.  I can
> trivially define all cpus on my system to be on memoryless nodes and
> having that affect readahead behavior when, in fact, there is affinity
> would be ridiculous.
>
As you rightly pointed , I 'll drop remote memory term and use
something like  :

"* Ensure readahead success on a memoryless node cpu. But we limit
  * the readahead to 4k pages to avoid trashing page cache." ..

Regarding ACCESS_ONCE, since we will have to add
inside the function and still there is nothing that could prevent us
getting run on different cpu with a different node (as Andrew ponted), I 
have not included in current patch that I am posting.
Moreover this case is hopefully not fatal since it is just a hint for 
readahead we can do.

So there are many possible implementation:
(1) use numa_mem_id(), apply freepage limit  and use 4k page limit for 
all case
(Jan had reservation about this case)

(2)for normal case:    use free memory calculation and do not apply 4k
     limit (no change).
    for memoryless cpu case:  use numa_mem_id for more accurate
     calculation of limit and also apply 4k limit.

(3) for normal case:   use free memory calculation and do not apply 4k
     limit (no change).
     for memoryless case: apply 4k page limit

(4) use numa_mem_id() and apply only free page limit..

So, I ll be resending the patch with changelog and comment changes
based on your and Andrew's feedback (type (3) implementation).




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
