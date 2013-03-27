Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 3B85D6B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 15:29:06 -0400 (EDT)
Date: Wed, 27 Mar 2013 15:28:54 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1364412534-t9czjtag-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <87620e9xow.fsf@linux.vnet.ibm.com>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-10-git-send-email-n-horiguchi@ah.jp.nec.com>
 <87620e9xow.fsf@linux.vnet.ibm.com>
Subject: Re: [PATCH 09/10] memory-hotplug: enable memory hotplug to handle
 hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org

On Tue, Mar 26, 2013 at 05:31:51PM +0530, Aneesh Kumar K.V wrote:
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> 
> > +/* Returns true for head pages of in-use hugepages, otherwise returns false. */
> > +bool is_hugepage_movable(struct page *hpage)
> > +{
> > +	struct page *page;
> > +	struct hstate *h;
> > +	bool ret = false;
> > +
> > +	VM_BUG_ON(!PageHuge(hpage));
> > +	/*
> > +	 * This function can be called for a tail page because memory hotplug
> > +	 * scans movability of pages by pfn range of a memory block.
> > +	 * Larger hugepages (1GB for x86_64) are larger than memory block, so
> > +	 * the scan can start at the tail page of larger hugepages.
> > +	 * 1GB hugepage is not movable now, so we return with false for now.
> > +	 */
> > +	if (PageTail(hpage))
> > +		return false;
> > +	h = page_hstate(hpage);
> > +	spin_lock(&hugetlb_lock);
> > +	list_for_each_entry(page, &h->hugepage_activelist, lru)
> > +		if (page == hpage) {
> > +			ret = true;
> > +			break;
> > +		}
> > +	spin_unlock(&hugetlb_lock);
> > +	return ret;
> > +}
> > +
> 
> May be is_hugepage_active() ?

Yes, it would be nice.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
