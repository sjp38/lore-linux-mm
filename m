Date: Sun, 25 Feb 2007 04:06:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/3] mm: fix PageUptodate memorder
Message-Id: <20070225040657.eb4fc159.akpm@linux-foundation.org>
In-Reply-To: <20070215051851.7443.65811.sendpatchset@linux.site>
References: <20070215051822.7443.30110.sendpatchset@linux.site>
	<20070215051851.7443.65811.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

What an unpleasing patchset.  I really really hope we really have a bug in
there, and that all this crap isn't pointless uglification.

We _do_ need a flush_dcaceh_page() in all cases which you're concerned
about.  Perhaps we should stick the appropriate barriers in there.

> On Thu, 15 Feb 2007 08:31:31 +0100 (CET) Nick Piggin <npiggin@suse.de> wrote:
> +static inline void SetNewPageUptodate(struct page *page)
> +{
> +	/*
> +	 * S390 sets page dirty bit on IO operations, which is why it is
> +	 * cleared in SetPageUptodate. This is not an issue for newly
> +	 * allocated pages that are brought uptodate by zeroing memory.
> +	 */
> +	smp_wmb();
> +	__set_bit(PG_uptodate, &(page)->flags);
> +}

__SetPageUptodate() might be more conventional.

Boy we'd better get the callers of this little handgrenade right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
