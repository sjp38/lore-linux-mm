Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 155642802E6
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 22:33:10 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so3437354wic.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 19:33:09 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id z12si11214573wjw.88.2015.07.15.19.33.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 19:33:08 -0700 (PDT)
Date: Thu, 16 Jul 2015 04:33:07 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v1 3/4] mm/memory-failure: give up error handling for
 non-tail-refcounted thp
Message-ID: <20150716023307.GF1747@two.firstfloor.org>
References: <1437010894-10262-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1437010894-10262-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437010894-10262-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

> @@ -909,6 +909,15 @@ int get_hwpoison_page(struct page *page)
>  	 * directly for tail pages.
>  	 */
>  	if (PageTransHuge(head)) {
> +		/*
> +		 * Non anonymous thp exists only in allocation/free time. We
> +		 * can't handle such a case correctly, so let's give it up.
> +		 * This should be better than triggering BUG_ON when kernel
> +		 * tries to touch a "partially handled" page.
> +		 */
> +		if (!PageAnon(head))
> +			return 0;

Please print a message for this case. In the future there will be
likely more non anonymous THP pages from Kirill's large page cache work
(so eventually we'll need it)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
