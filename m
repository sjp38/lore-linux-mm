Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 7A93E6B0032
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 02:00:02 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 1 Aug 2013 15:53:12 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 91F033578054
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 15:59:46 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r715iCwd31195354
	for <linux-mm@kvack.org>; Thu, 1 Aug 2013 15:44:13 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r715xiIa017673
	for <linux-mm@kvack.org>; Thu, 1 Aug 2013 15:59:45 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 8/8] prepare to remove /proc/sys/vm/hugepages_treat_as_movable
In-Reply-To: <1375302249-scfvftrh-mutt-n-horiguchi@ah.jp.nec.com>
References: <1374728103-17468-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1374728103-17468-9-git-send-email-n-horiguchi@ah.jp.nec.com> <87k3k7q4ox.fsf@linux.vnet.ibm.com> <1375302249-scfvftrh-mutt-n-horiguchi@ah.jp.nec.com>
Date: Thu, 01 Aug 2013 11:29:39 +0530
Message-ID: <87vc3qvtmc.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> On Wed, Jul 31, 2013 at 12:02:30AM +0530, Aneesh Kumar K.V wrote:
>> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
>> 
>> > Now hugepages are definitely movable. So allocating hugepages from
>> > ZONE_MOVABLE is natural and we have no reason to keep this parameter.
>> > In order to allow userspace to prepare for the removal, let's leave
>> > this sysctl handler as noop for a while.
>> 
>> I guess you still need to handle architectures for which pmd_huge is
>> 
>> int pmd_huge(pmd_t pmd)
>> {
>> 	return 0;
>> }
>> 
>> embedded powerpc is one. They don't store pte information at the PMD
>> level. Instead pmd contains a pointer to hugepage directory which
>> contain huge pte.
>
> It seems that this comment is for the whole series, not just for this
> patch, right?
>
> Some users of hugepage migration (mbind, move_pages, migrate_pages)
> walk over page tables to collect hugepages to be migrated, where
> hugepages are just ignored in such architectures due to pmd_huge.
> So no problem for these users.
>
> But the other users (softoffline, memory hotremove) choose hugepages
> to be migrated based on pfn, where they don't check pmd_huge.
> As you wrote, this can be problematic for such architectures.
> So I think of adding pmd_huge() check somewhere (in unmap_and_move_huge_page
> for example) to make it fail for such architectures.

Considering that we have architectures that won't support migrating
explicit hugepages with this patch series, is it ok to use
GFP_HIGHUSER_MOVABLE for hugepage allocation ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
