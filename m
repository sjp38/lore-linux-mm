Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 8C5576B0036
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 07:19:02 -0400 (EDT)
Message-ID: <5215F392.8070305@suse.cz>
Date: Thu, 22 Aug 2013 13:18:42 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 7/7] mm: munlock: manual pte walk in fast path instead
 of follow_page_mask()
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz> <1376915022-12741-8-git-send-email-vbabka@suse.cz> <20130819154754.4a504e2f7f4be455c164615b@linux-foundation.org>
In-Reply-To: <20130819154754.4a504e2f7f4be455c164615b@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On 08/20/2013 12:47 AM, Andrew Morton wrote:
> On Mon, 19 Aug 2013 14:23:42 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> Currently munlock_vma_pages_range() calls follow_page_mask() to obtain each
>> struct page. This entails repeated full page table translations and page table
>> lock taken for each page separately.
>>
>> This patch attempts to avoid the costly follow_page_mask() where possible, by
>> iterating over ptes within single pmd under single page table lock. The first
>> pte is obtained by get_locked_pte() for non-THP page acquired by the initial
>> follow_page_mask(). The latter function is also used as a fallback in case
>> simple pte_present() and vm_normal_page() are not sufficient to obtain the
>> struct page.
> 
> Patch #7 appears to provide significant performance gains, but the
> improvement wasn't individually described here, unlike the other
> patches.

Oops I forgot to mention this here. Can you please add the following to
the comment then? Thanks.

After this patch, a 13% speedup was measured for munlocking a 56GB large
memory area with THP disabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
