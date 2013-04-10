Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id EF54B6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 04:07:09 -0400 (EDT)
Date: Wed, 10 Apr 2013 10:07:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 3/3] hugetlbfs: add swap entry check in
 follow_hugetlb_page()
Message-ID: <20130410080706.GA20998@dhcp22.suse.cz>
References: <1365014138-19589-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1365014138-19589-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <515F1F1F.6060900@gmail.com>
 <1365449252-9pc7knd5-mutt-n-horiguchi@ah.jp.nec.com>
 <CAHGf_=ruv9itn7fhcL=Ar7z_6wQ5Ga_4kj7Ui3EfDUe_cV7D0w@mail.gmail.com>
 <1365544834-c6v2jpoo-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365544834-c6v2jpoo-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 09-04-13 18:00:34, Naoya Horiguchi wrote:
[...]
> I rewrite the comment here, how about this?
> 
> -		if (absent ||
> +		/*
> +		 * We need call hugetlb_fault for both hugepages under migration
> +		 * (in which case hugetlb_fault waits for the migration,) and
> +		 * hwpoisoned hugepages (in which case we need to prevent the
> +		 * caller from accessing to them.) In order to do this, we use
> +		 * here is_swap_pte instead of is_hugetlb_entry_migration and
> +		 * is_hugetlb_entry_hwpoisoned. This is because it simply covers
> +		 * both cases, and because we can't follow correct pages directly
> +		 * from any kind of swap entries.
> +		 */
> +		if (absent || is_swap_pte(huge_ptep_get(pte)) ||
>  		    ((flags & FOLL_WRITE) && !pte_write(huge_ptep_get(pte)))) {
>  			int ret;

OK, thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
