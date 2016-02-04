Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 289D54403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 08:12:03 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id 128so26335627wmz.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 05:12:03 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id 10si38105089wmd.15.2016.02.04.05.12.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 05:12:02 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id g62so386053wme.2
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 05:12:02 -0800 (PST)
Date: Thu, 4 Feb 2016 15:11:59 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/3] thp: limit number of object to scan on
 deferred_split_scan()
Message-ID: <20160204131159.GA20399@node.shutemov.name>
References: <20160121012237.GE7119@redhat.com>
 <1453378163-133609-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1453378163-133609-4-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453378163-133609-4-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 21, 2016 at 03:09:23PM +0300, Kirill A. Shutemov wrote:
> If we have a lot of pages in queue to be split, deferred_split_scan()
> can spend unreasonable amount of time under spinlock with disabled
> interrupts.
> 
> Let's cap number of pages to split on scan by sc->nr_to_scan.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/huge_memory.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 36f98459f854..298dbc001b07 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -3478,17 +3478,19 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
>  	int split = 0;
>  
>  	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
> -	list_splice_init(&pgdata->split_queue, &list);
> -
>  	/* Take pin on all head pages to avoid freeing them under us */
>  	list_for_each_safe(pos, next, &list) {

Well, that's embarrassing... :-/

I forgot to commit one local change here. Sorry.
