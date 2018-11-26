Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A8596B436E
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 14:53:50 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b3so2092204edi.0
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 11:53:50 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y2-v6si462897ejj.125.2018.11.26.11.53.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 11:53:48 -0800 (PST)
Date: Mon, 26 Nov 2018 20:53:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHi v2] mm: put_and_wait_on_page_locked() while page is
 migrated
Message-ID: <20181126195345.GI12455@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils>
 <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com>
 <alpine.LSU.2.11.1811251900300.1278@eggly.anvils>
 <alpine.LSU.2.11.1811261121330.1116@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811261121330.1116@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Herrmann <dh.herrmann@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 26-11-18 11:27:07, Hugh Dickins wrote:
[...]
> @@ -1049,25 +1056,44 @@ static void wake_up_page(struct page *page, int bit)
>  	wake_up_page_bit(page, bit);
>  }
>  
> +/*
> + * A choice of three behaviors for wait_on_page_bit_common():
> + */
> +enum behavior {
> +	EXCLUSIVE,	/* Hold ref to page and take the bit when woken, like
> +			 * __lock_page() waiting on then setting PG_locked.
> +			 */
> +	SHARED,		/* Hold ref to page and check the bit when woken, like
> +			 * wait_on_page_writeback() waiting on PG_writeback.
> +			 */
> +	DROP,		/* Drop ref to page before wait, no check when woken,
> +			 * like put_and_wait_on_page_locked() on PG_locked.
> +			 */
> +};

I like this. It makes to semantic much more clear.

Thanks!
-- 
Michal Hocko
SUSE Labs
