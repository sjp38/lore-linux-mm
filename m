Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 32B326B0002
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 02:05:31 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id tb18so1254766obb.3
        for <linux-mm@kvack.org>; Fri, 22 Feb 2013 23:05:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1361475708-25991-9-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1361475708-25991-9-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Sat, 23 Feb 2013 15:05:30 +0800
Message-ID: <CAJd=RBDvqFYUgy+d=DJTBZoaafXoDP+QodAh2CzV2XpDMjaw7Q@mail.gmail.com>
Subject: Re: [PATCH 8/9] memory-hotplug: enable memory hotplug to handle hugepage
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>

Hello Naoya

[add Michal in cc list]

On Fri, Feb 22, 2013 at 3:41 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
>
> +/* Returns true for head pages of in-use hugepages, otherwise returns false. */
> +int is_hugepage_movable(struct page *hpage)
s/int/bool/  can we?
> +{
> +       struct page *page;
> +       struct page *tmp;
> +       struct hstate *h = page_hstate(hpage);
Make sense to compute hstate for a tail page?
> +       int ret = 0;
> +
> +       VM_BUG_ON(!PageHuge(hpage));
> +       if (PageTail(hpage))
> +               return 0;
VM_BUG_ON(!PageHuge(hpage) || PageTail(hpage)), can we?
> +       spin_lock(&hugetlb_lock);
> +       list_for_each_entry_safe(page, tmp, &h->hugepage_activelist, lru)
s/_safe//  can we?
> +               if (page == hpage)
> +                       ret = 1;
Can we bail out with ret set to be true?
> +       spin_unlock(&hugetlb_lock);
> +       return ret;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
