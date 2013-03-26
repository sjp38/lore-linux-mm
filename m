Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 2EEA16B00E1
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 08:02:18 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 26 Mar 2013 21:53:42 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 698372BB0050
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 23:02:06 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2QBmvw456361154
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 22:48:57 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2QC25hL017979
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 23:02:06 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 09/10] memory-hotplug: enable memory hotplug to handle hugepage
In-Reply-To: <1363983835-20184-10-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1363983835-20184-10-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Tue, 26 Mar 2013 17:31:51 +0530
Message-ID: <87620e9xow.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> +/* Returns true for head pages of in-use hugepages, otherwise returns false. */
> +bool is_hugepage_movable(struct page *hpage)
> +{
> +	struct page *page;
> +	struct hstate *h;
> +	bool ret = false;
> +
> +	VM_BUG_ON(!PageHuge(hpage));
> +	/*
> +	 * This function can be called for a tail page because memory hotplug
> +	 * scans movability of pages by pfn range of a memory block.
> +	 * Larger hugepages (1GB for x86_64) are larger than memory block, so
> +	 * the scan can start at the tail page of larger hugepages.
> +	 * 1GB hugepage is not movable now, so we return with false for now.
> +	 */
> +	if (PageTail(hpage))
> +		return false;
> +	h = page_hstate(hpage);
> +	spin_lock(&hugetlb_lock);
> +	list_for_each_entry(page, &h->hugepage_activelist, lru)
> +		if (page == hpage) {
> +			ret = true;
> +			break;
> +		}
> +	spin_unlock(&hugetlb_lock);
> +	return ret;
> +}
> +

May be is_hugepage_active() ?


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
