Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id CDF7E6B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 12:55:39 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id s7so538979qap.32
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 09:55:39 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j4si2574509qge.118.2014.10.01.09.55.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 09:55:38 -0700 (PDT)
Message-ID: <542C31E0.5040909@oracle.com>
Date: Wed, 01 Oct 2014 12:54:56 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] mm: gup: use get_user_pages_fast and get_user_pages_unlocked
References: <1412153797-6667-1-git-send-email-aarcange@redhat.com> <1412153797-6667-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1412153797-6667-4-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

Hi Andrea,

On 10/01/2014 04:56 AM, Andrea Arcangeli wrote:
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 8f5330d..6606c10 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -881,7 +881,7 @@ static int lookup_node(struct mm_struct *mm, unsigned long addr)
>  	struct page *p;
>  	int err;
>  
> -	err = get_user_pages(current, mm, addr & PAGE_MASK, 1, 0, 0, &p, NULL);
> +	err = get_user_pages_fast(addr & PAGE_MASK, 1, 0, &p);
>  	if (err >= 0) {
>  		err = page_to_nid(p);
>  		put_page(p);

This change looks bogus. mmap_sem might get locked in do_get_mempolicy(), and with this
change we'll try locking it again in get_user_pages_fast.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
