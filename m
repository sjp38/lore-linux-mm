Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id DC0766B00E7
	for <linux-mm@kvack.org>; Tue, 22 May 2012 17:01:40 -0400 (EDT)
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 22 May 2012 17:01:35 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2147338C8065
	for <linux-mm@kvack.org>; Tue, 22 May 2012 17:00:01 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4ML00YI141996
	for <linux-mm@kvack.org>; Tue, 22 May 2012 17:00:00 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4MKxvHF030855
	for <linux-mm@kvack.org>; Tue, 22 May 2012 14:59:59 -0600
Message-ID: <4FBBFE49.4070409@linux.vnet.ibm.com>
Date: Tue, 22 May 2012 13:59:53 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] hugetlb: fix resv_map leak in error path
References: <20120521202814.E01F0FE1@kernel> <20120522134558.49255899.akpm@linux-foundation.org>
In-Reply-To: <20120522134558.49255899.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cl@linux.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com, kosaki.motohiro@jp.fujitsu.com, hughd@google.com, rientjes@google.com, adobriyan@gmail.com, mel@csn.ul.ie

On 05/22/2012 01:45 PM, Andrew Morton wrote:
> On Mon, 21 May 2012 13:28:14 -0700
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
>> When called for anonymous (non-shared) mappings,
>> hugetlb_reserve_pages() does a resv_map_alloc().  It depends on
>> code in hugetlbfs's vm_ops->close() to release that allocation.
>>
>> However, in the mmap() failure path, we do a plain unmap_region()
>> without the remove_vma() which actually calls vm_ops->close().
>>
>> This is a decent fix.  This leak could get reintroduced if
>> new code (say, after hugetlb_reserve_pages() in
>> hugetlbfs_file_mmap()) decides to return an error.  But, I think
>> it would have to unroll the reservation anyway.
> 
> How far back does this bug go?  The patch applies to 3.4 but gets
> rejects in 3.3 and earlier.

commit 17c9d12e126cb0de8d535dc1908c4819d712bc68
Date:   Wed Feb 11 16:34:16 2009 +0000

So, ~2.6.30.

I don't think it existed before that.  The code was there, but the
ordering made it OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
