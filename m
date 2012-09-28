Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id CF74A6B0072
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:30:19 -0400 (EDT)
Date: Fri, 28 Sep 2012 15:30:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch for-3.6] mm, thp: fix mapped pages avoiding unevictable
 list on mlock
Message-ID: <20120928133005.GA19474@redhat.com>
References: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

Hi David,

On Wed, Sep 19, 2012 at 06:19:27PM -0700, David Rientjes wrote:
> +	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
> +		if (page->mapping && trylock_page(page)) {
> +			lru_add_drain();
> +			if (page->mapping)
> +				mlock_vma_page(page);
> +			unlock_page(page);
> +		}
> +	}

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Without the patch the kernel will be perfectly fine too, this is is
only to show more "uptodate" values in meminfo.

The meminfo would eventually go in sync as the vmscan started walking
lrus and the old behavior will still happen when trylock
fails.

Without the patch the refiling events happen lazily as needed, now
they happen even if they're not needed.

In some ways we could drop this and also the 4k case and we'd overall
improve performance.

But transparent hugepages must behave identical to 4k pages, so unless
we remove it from the 4k case, it's certainly good to apply the above.

The patch can be deferred to 3.7 if needed.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
