Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 89C796B007D
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 16:58:44 -0500 (EST)
Date: Fri, 19 Feb 2010 21:58:26 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03/12] mm: Share the anon_vma ref counts between KSM
	and page migration
Message-ID: <20100219215826.GF1445@csn.ul.ie>
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie> <1266516162-14154-4-git-send-email-mel@csn.ul.ie> <4B7F05BA.4080903@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4B7F05BA.4080903@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 19, 2010 at 04:42:18PM -0500, Rik van Riel wrote:
> On 02/18/2010 01:02 PM, Mel Gorman wrote:
>
>>   struct anon_vma {
>>   	spinlock_t lock;	/* Serialize access to vma list */
>> -#ifdef CONFIG_KSM
>> -	atomic_t ksm_refcount;
>> -#endif
>> -#ifdef CONFIG_MIGRATION
>> -	atomic_t migrate_refcount;
>> +#if defined(CONFIG_KSM) || defined(CONFIG_MIGRATION)
>> +
>> +	/*
>> +	 * The refcount is taken by either KSM or page migration
>> +	 * to take a reference to an anon_vma when there is no
>> +	 * guarantee that the vma of page tables will exist for
>> +	 * the duration of the operation. A caller that takes
>> +	 * the reference is responsible for clearing up the
>> +	 * anon_vma if they are the last user on release
>> +	 */
>> +	atomic_t refcount;
>
> Calling it just refcount is probably confusing, since
> the anon_vma is also referenced by being on the chain
> with others.
>
> Maybe "other_refcount" because it is refcounts taken
> by things other than VMAs?  I am sure there is a better
> name possible...
>

external_refcount is about as good as I can think of to explain what's
going on :/

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
