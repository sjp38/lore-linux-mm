Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7736B0035
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 05:20:41 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id y13so1894507pdi.10
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 02:20:41 -0800 (PST)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id e8si6695197pac.53.2014.01.10.02.20.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 02:20:40 -0800 (PST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Fri, 10 Jan 2014 20:20:36 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 4EB6B2BB0053
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 21:20:34 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0AA1YXI2490824
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 21:01:36 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0AAKV9s004727
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 21:20:31 +1100
Message-ID: <52CFCB2D.7080104@linux.vnet.ibm.com>
Date: Fri, 10 Jan 2014 15:57:57 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V4] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
References: <1389295490-28707-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140110083656.GC26378@quack.suse.cz> <20140110095222.GE26378@quack.suse.cz>
In-Reply-To: <20140110095222.GE26378@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus <torvalds@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/10/2014 03:22 PM, Jan Kara wrote:
> On Fri 10-01-14 09:36:56, Jan Kara wrote:
>> On Fri 10-01-14 00:54:50, Raghavendra K T wrote:
>>> We limit the number of readahead pages to 4k.
>>>
>>> max_sane_readahead returns zero on the cpu having no local memory
>>> node. Fix that by returning a sanitized number of pages viz.,
>>> minimum of (requested pages, 4k, number of local free pages)
>>>
>>> Result:
>>> fadvise experiment with FADV_WILLNEED on a x240 machine with 1GB testfile
>>> 32GB* 4G RAM  numa machine ( 12 iterations) yielded
>>>
>>> kernel       Avg        Stddev
>>> base         7.264      0.56%
>>> patched      7.285      1.14%
>>    OK, looks good to me. You can add:
>> Reviewed-by: Jan Kara <jack@suse.cz>
>    Hum, while doing some other work I've realized there may be still a
> problem hiding with the 16 MB limitation. E.g. the dynamic linker is
> doing MADV_WILLNEED on the shared libraries. If the library (or executable)
> is larger than 16 MB, then it may cause performance problems since access
> is random in nature and we don't really know which part of the file do we
> need first.
>
> I'm not sure what others think about this but I'm now more inclined to a
> bit more careful and introduce the 16 MB limit only for the NUMA case. I.e.
> something like:

Your suggestion makes sense. I do not have any strong preference.
may be we shall wait for Linus/Andrew's comments (if any) since Linus
suggested the 16MB idea.

>
> 	unsigned long local_free_page;
> 	int nid;
>
> 	nid = numa_node_id();
> 	if (node_present_pages(nid)) {
> 		/*
> 		 * We sanitize readahead size depending on free memory in
> 		 * the local node.
> 		 */
> 		local_free_page = node_page_state(nid, NR_INACTIVE_FILE)
> 				  + node_page_state(nid, NR_FREE_PAGES);
> 		return min(nr, local_free_page / 2);
> 	}
> 	/*
> 	 * Readahead onto remote memory is better than no readahead when local
> 	 * numa node does not have memory. We limit the readahead to 4k
> 	 * pages though to avoid trashing page cache.
> 	 */
> 	return min(nr, MAX_REMOTE_READAHEAD);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
