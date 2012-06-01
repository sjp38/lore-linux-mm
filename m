Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 849436B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 04:51:38 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so1258666qcs.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 01:51:37 -0700 (PDT)
Message-ID: <4FC88299.1040707@gmail.com>
Date: Fri, 01 Jun 2012 04:51:37 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
References: <20120530163317.GA13189@redhat.com> <20120531005739.GA4532@redhat.com> <20120601023107.GA19445@redhat.com> <alpine.LSU.2.00.1206010030050.8462@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1206010030050.8462@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@gmail.com

>   	mlock_migrate_page(newpage, page);
> --- 3.4.0+/mm/page-writeback.c	2012-05-29 08:09:58.304806782 -0700
> +++ linux/mm/page-writeback.c	2012-06-01 00:23:43.984116973 -0700
> @@ -1987,7 +1987,10 @@ int __set_page_dirty_nobuffers(struct pa
>   		mapping2 = page_mapping(page);
>   		if (mapping2) { /* Race with truncate? */
>   			BUG_ON(mapping2 != mapping);
> -			WARN_ON_ONCE(!PagePrivate(page)&&  !PageUptodate(page));
> +			if (WARN_ON(!PagePrivate(page)&&  !PageUptodate(page)))
> +				print_symbol(KERN_WARNING
> +				    "mapping->a_ops->writepage: %s\n",
> +				    (unsigned long)mapping->a_ops->writepage);

type mismatch? I guess you want %pf or %pF.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
