Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 662EA828DF
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 09:31:31 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id e32so58629845qgf.3
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 06:31:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j71si7349564qhc.93.2016.01.22.06.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 06:31:30 -0800 (PST)
Date: Fri, 22 Jan 2016 15:31:27 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/3] thp: change deferred_split_count() to return number
 of THP in queue
Message-ID: <20160122143127.GI7119@redhat.com>
References: <20160121012237.GE7119@redhat.com>
 <1453378163-133609-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1453378163-133609-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453378163-133609-3-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 21, 2016 at 03:09:22PM +0300, Kirill A. Shutemov wrote:
> @@ -3511,7 +3506,7 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
>  	list_splice_tail(&list, &pgdata->split_queue);
>  	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
>  
> -	return split * HPAGE_PMD_NR / 2;
> +	return split;
>  }

Looking further at how the caller processes this "split" retval, if
the list has been fully shrunk by the page freeing, between the
split_count and split_scan, the caller seems to ignore a 0 value
returned above and it'll keep calling even if sc->nr_to_scan isn't
decreasing. The caller won't even check sc->nr_to_scan to notice that
it isn't decreasing anymore, it's write-only as far as the caller is
concerned.

It's also weird we can't return the number of freed pages and break
the loop with just one invocation of the split_scan, but that's a
slight inefficiency in the caller interface. The caller also seems to
forget to set total_scan to 0 if SHRINK_STOP was returned but perhaps
that's on purpose, however for our purpose it'd be better off if it
did.

The split_queue.next is going to be hot in the CPU cache anyway, so
unless we change the caller, it should be worth it to add a list_empty
check and return SHRINK_STOP if it was empty. Doing it at the start or
end doesn't make much difference, at the end lockless it'll deal with
the split failures too if any.

	return split ? : list_empty(&pgdat->split_queue) ? SPLIT_STOP : 0;

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
