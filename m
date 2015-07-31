Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D34696B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 16:54:21 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so49359460pdj.3
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 13:54:21 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id el7si12743891pdb.190.2015.07.31.13.54.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 13:54:20 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so48225120pdr.2
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 13:54:20 -0700 (PDT)
Date: Fri, 31 Jul 2015 13:54:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/5] mm/memory-failure: unlock_page before put_page
In-Reply-To: <1438325105-10059-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.10.1507311353490.5910@chino.kir.corp.google.com>
References: <1438325105-10059-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1438325105-10059-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 31 Jul 2015, Naoya Horiguchi wrote:

> In "just unpoisoned" path, we do put_page and then unlock_page, which is a
> wrong order and causes "freeing locked page" bug. So let's fix it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/memory-failure.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git v4.2-rc4.orig/mm/memory-failure.c v4.2-rc4/mm/memory-failure.c
> index c53543d89282..04d677048af7 100644
> --- v4.2-rc4.orig/mm/memory-failure.c
> +++ v4.2-rc4/mm/memory-failure.c
> @@ -1209,9 +1209,9 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  	if (!PageHWPoison(p)) {
>  		printk(KERN_ERR "MCE %#lx: just unpoisoned\n", pfn);
>  		atomic_long_sub(nr_pages, &num_poisoned_pages);
> +		unlock_page(hpage);
>  		put_page(hpage);
> -		res = 0;
> -		goto out;
> +		return 0;
>  	}
>  	if (hwpoison_filter(p)) {
>  		if (TestClearPageHWPoison(p))

Looks like you could do the unlock_page() before either the printk or 
atomic_long_sub(), but probably not important.

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
