Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 58E516B0122
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 17:11:42 -0400 (EDT)
Received: by mail-qc0-f178.google.com with SMTP id d10so1790864qca.23
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 14:11:41 -0700 (PDT)
Message-ID: <515F3E0C.6080206@gmail.com>
Date: Fri, 05 Apr 2013 17:11:40 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] soft-offline: use migrate_pages() instead of migrate_huge_page()
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1363983835-20184-4-git-send-email-n-horiguchi@ah.jp.nec.com> <20130325123128.GU2154@dhcp22.suse.cz> <1364272480-bmzkqzs6-mutt-n-horiguchi@ah.jp.nec.com> <20130326094950.GM2295@dhcp22.suse.cz> <1364330135-268cmm8x-mutt-n-horiguchi@ah.jp.nec.com> <20130327130018.GH16579@dhcp22.suse.cz>
In-Reply-To: <20130327130018.GH16579@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

(3/27/13 9:00 AM), Michal Hocko wrote:
> On Tue 26-03-13 16:35:35, Naoya Horiguchi wrote:
> [...]
>> The differences is that migrate_huge_page() has one hugepage as an argument,
>> and migrate_pages() has a pagelist with multiple hugepages.
>> I already told this before and I'm not sure it's enough to answer the question,
>> so I explain another point about why this patch do like it.
> 
> OK, I am blind. It is
> +       list_move(&hpage->lru, &pagelist);
> +       ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
> +                               MIGRATE_SYNC, MR_MEMORY_FAILURE);
> 
> which moves it from active_list and so you have to put it back.
> 
>> I think that we must do putback_*pages() for source pages whether migration
>> succeeds or not.
>> But when we call migrate_pages() with a pagelist,
>> the caller can't access to the successfully migrated source pages
>> after migrate_pages() returns, because they are no longer on the pagelist.
>> So putback of the successfully migrated source pages should be done *in*
>> unmap_and_move() and/or unmap_and_move_huge_page().
> 
> If the migration succeeds then the page becomes unused and free after
> its last reference drops. So I do not see any reason to put it back to
> active list and free it right afterwards.
> On the other hand unmap_and_move does the same thing (although page
> reference counting is a bit more complicated in that case) so it would
> be good to keep in sync with regular pages case.

Even if pages are isolated from lists, there are several page count increasing
path. So, putback_pages() close a race when page count != 1.

I'm not sure, but I guess follow_hugepage() can make the same race.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
