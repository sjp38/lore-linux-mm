Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 22BDF6B0137
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 03:04:55 -0400 (EDT)
Received: by mail-ea0-f170.google.com with SMTP id a15so1636273eae.29
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 00:04:53 -0700 (PDT)
Date: Sat, 6 Apr 2013 09:04:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 07/10] mbind: add hugepage migration code to mbind()
Message-ID: <20130406070450.GC4501@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-8-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130325134926.GZ2154@dhcp22.suse.cz>
 <515F4ECB.9050105@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515F4ECB.9050105@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Fri 05-04-13 18:23:07, KOSAKI Motohiro wrote:
> >> -	if (!new_hpage)
> >> +	/*
> >> +	 * Getting a new hugepage with alloc_huge_page() (which can happen
> >> +	 * when migration is caused by mbind()) can return ERR_PTR value,
> >> +	 * so we need take care of the case here.
> >> +	 */
> >> +	if (!new_hpage || IS_ERR_VALUE(new_hpage))
> >>  		return -ENOMEM;
> > 
> > Please no. get_new_page returns NULL or a page. You are hooking a wrong
> > callback here. The error value doesn't make any sense here. IMO you
> > should just wrap alloc_huge_page by something that returns NULL or page.
> 
> I suggest just opposite way. new_vma_page() always return ENOMEM, ENOSPC etc instad 
> of NULL. and caller propegate it to userland.
> I guess userland want to distingush why mbind was failed.

Sure, and I wasn't suggesting to change alloc_huge_page. I was just
pointing out that new_page_t used to return page or NULL and hugetlb
unmap_and_move shouldn't be any different in that direction so using
alloc_huge_page is not a good fit here.

> Anyway, If new_vma_page() have a change to return both NULL and
> -ENOMEM. That's a bug.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
