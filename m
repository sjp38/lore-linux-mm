Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 743D86B0037
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 16:58:07 -0400 (EDT)
Received: by mail-ob0-f182.google.com with SMTP id ef5so6201795obb.27
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 13:58:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1365449252-9pc7knd5-mutt-n-horiguchi@ah.jp.nec.com>
References: <1365014138-19589-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1365014138-19589-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <515F1F1F.6060900@gmail.com> <1365449252-9pc7knd5-mutt-n-horiguchi@ah.jp.nec.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 8 Apr 2013 16:57:44 -0400
Message-ID: <CAHGf_=ruv9itn7fhcL=Ar7z_6wQ5Ga_4kj7Ui3EfDUe_cV7D0w@mail.gmail.com>
Subject: Re: [PATCH v3 3/3] hugetlbfs: add swap entry check in follow_hugetlb_page()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> -               if (absent ||
> +               /*
> +                * is_swap_pte test covers both is_hugetlb_entry_hwpoisoned
> +                * and hugepages under migration in which case
> +                * hugetlb_fault waits for the migration and bails out
> +                * properly for HWPosined pages.
> +                */
> +               if (absent || is_swap_pte(huge_ptep_get(pte)) ||
>                     ((flags & FOLL_WRITE) && !pte_write(huge_ptep_get(pte)))) {
>                         int ret;

Your comment describe what the code is. However we want the comment describe
why. In migration case, calling hugetlb_fault() is natural. but in
hwpoison case, it is
needed more explanation. Why can't we call is_hugetlb_hwpoisoned() directly?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
