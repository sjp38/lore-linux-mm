Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED726B0037
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 18:11:28 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id g10so2639010pdj.10
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 15:11:28 -0800 (PST)
Received: from psmtp.com ([74.125.245.201])
        by mx.google.com with SMTP id sd2si94120pbb.19.2013.11.14.15.11.26
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 15:11:27 -0800 (PST)
Received: by mail-gg0-f180.google.com with SMTP id l12so1140320gge.11
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 15:11:24 -0800 (PST)
Date: Thu, 14 Nov 2013 15:11:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/migrate.c: take returned value of isolate_huge_page()(Re:
 [PATCH 4/9] migrate: add hugepage migration code to move_pages())
In-Reply-To: <1384444050-v86q6ypr-mutt-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.02.1311141509390.30112@chino.kir.corp.google.com>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1376025702-14818-5-git-send-email-n-horiguchi@ah.jp.nec.com> <20130928172602.GA6191@pd.tnic> <1380553263-lqp3ggll-mutt-n-horiguchi@ah.jp.nec.com> <20130930160450.GA20030@pd.tnic>
 <1380557324-v44mpchd-mutt-n-horiguchi@ah.jp.nec.com> <20131112115633.GA16700@pd.tnic> <1384444050-v86q6ypr-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, 14 Nov 2013, Naoya Horiguchi wrote:

> Introduces a cosmetic substitution of the returned value of isolate_huge_page()
> to suppress a build warning when !CONFIG_HUGETLBFS. No behavioral change.
> 
> Reported-by: Borislav Petkov <bp@alien8.de>
> Tested-by: Borislav Petkov <bp@alien8.de>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/migrate.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 4cd63c2..4a26042 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1168,7 +1168,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
>  			goto put_and_set;
>  
>  		if (PageHuge(page)) {
> -			isolate_huge_page(page, &pagelist);
> +			err = isolate_huge_page(page, &pagelist);
>  			goto put_and_set;
>  		}
>  

I think it would be better to just fix hugetlb.h to do

	static inline bool isolate_huge_page(struct page *page, struct list_head *list)
	{
		return false;
	}

for the !CONFIG_HUGETLB_PAGE variant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
