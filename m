Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id D4F186B00E6
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 11:40:26 -0400 (EDT)
Message-ID: <5151C167.2020206@sr71.net>
Date: Tue, 26 Mar 2013 08:40:23 -0700
From: Dave <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 13/30] thp, mm: implement grab_cache_huge_page_write_begin()
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-14-git-send-email-kirill.shutemov@linux.intel.com> <514B4E2B.2010506@sr71.net> <20130326104810.C7F3AE0085@blue.fi.intel.com>
In-Reply-To: <20130326104810.C7F3AE0085@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/26/2013 03:48 AM, Kirill A. Shutemov wrote:
> Dave Hansen wrote:
>>> +repeat:
>>> +	page = find_lock_page(mapping, index);
>>> +	if (page) {
>>> +		if (!PageTransHuge(page)) {
>>> +			unlock_page(page);
>>> +			page_cache_release(page);
>>> +			return NULL;
>>> +		}
>>> +		goto found;
>>> +	}
>>> +
>>> +	page = alloc_pages(gfp_mask & ~gfp_notmask, HPAGE_PMD_ORDER);
>>
>> I alluded to this a second ago, but what's wrong with alloc_hugepage()?
> 
> It's defined only for !CONFIG_NUMA and only inside mm/huge_memory.c.

It's a short function, but you could easily pull it out from under the
#ifdef and export it.  I kinda like the idea of these things being
allocated in as few code paths possible.  But, it's not a big deal.

>>> +found:
>>> +	wait_on_page_writeback(page);
>>> +	return page;
>>> +}
>>> +#endif
>>
>> So, I diffed :
>>
>> -struct page *grab_cache_page_write_begin(struct address_space
>> vs.
>> +struct page *grab_cache_huge_page_write_begin(struct address_space
>>
>> They're just to similar to ignore.  Please consolidate them somehow.
> 
> Will do.
> 
>>> +found:
>>> +	wait_on_page_writeback(page);
>>> +	return page;
>>> +}
>>> +#endif
>>
>> In grab_cache_page_write_begin(), this "wait" is:
>>
>>         wait_for_stable_page(page);
>>
>> Why is it different here?
> 
> It was wait_on_page_writeback() in grab_cache_page_write_begin() when I forked
> it :(
> 
> See 1d1d1a7 mm: only enforce stable page writes if the backing device requires it
> 
> Consolidation will fix this.

Excellent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
