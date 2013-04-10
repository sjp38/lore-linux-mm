Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id E98586B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 21:54:16 -0400 (EDT)
Received: by mail-oa0-f52.google.com with SMTP id k14so8237644oag.11
        for <linux-mm@kvack.org>; Tue, 09 Apr 2013 18:54:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1365544834-c6v2jpoo-mutt-n-horiguchi@ah.jp.nec.com>
References: <1365014138-19589-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1365014138-19589-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <515F1F1F.6060900@gmail.com> <1365449252-9pc7knd5-mutt-n-horiguchi@ah.jp.nec.com>
 <CAHGf_=ruv9itn7fhcL=Ar7z_6wQ5Ga_4kj7Ui3EfDUe_cV7D0w@mail.gmail.com> <1365544834-c6v2jpoo-mutt-n-horiguchi@ah.jp.nec.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 9 Apr 2013 21:53:55 -0400
Message-ID: <CAHGf_=pDuFb4s3hg4M+AKphthgkCgFWMPKb9od7opcvDop4haQ@mail.gmail.com>
Subject: Re: [PATCH v3 3/3] hugetlbfs: add swap entry check in follow_hugetlb_page()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> I rewrite the comment here, how about this?
>
> -               if (absent ||
> +               /*
> +                * We need call hugetlb_fault for both hugepages under migration
> +                * (in which case hugetlb_fault waits for the migration,) and
> +                * hwpoisoned hugepages (in which case we need to prevent the
> +                * caller from accessing to them.) In order to do this, we use
> +                * here is_swap_pte instead of is_hugetlb_entry_migration and
> +                * is_hugetlb_entry_hwpoisoned. This is because it simply covers
> +                * both cases, and because we can't follow correct pages directly
> +                * from any kind of swap entries.
> +                */
> +               if (absent || is_swap_pte(huge_ptep_get(pte)) ||
>                     ((flags & FOLL_WRITE) && !pte_write(huge_ptep_get(pte)))) {
>                         int ret;

Looks ok to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
