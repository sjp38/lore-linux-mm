Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 68B3A6B0083
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 11:02:35 -0400 (EDT)
Date: Mon, 16 Apr 2012 16:02:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] s390: mm: rmap: Transfer storage key to struct page
 under the page lock
Message-ID: <20120416150231.GE2359@suse.de>
References: <20120416141423.GD2359@suse.de>
 <4F8C3253.9030208@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F8C3253.9030208@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, Linux-S390 <linux-s390@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 16, 2012 at 10:53:07AM -0400, Rik van Riel wrote:
> On 04/16/2012 10:14 AM, Mel Gorman wrote:
> >This patch is horribly ugly and there has to be a better way of doing
> >it. I'm looking for suggestions on what s390 can do here that is not
> >painful or broken.
> 
> I'm hoping the S390 arch maintainers have an idea.
> 
> Ugly or not, we'll need something to fix the bug.
> 

Indeed.

> >+ * When the late PTE has gone, s390 must transfer the dirty flag from the
> >+ * storage key to struct page. We can usually skip this if the page is anon,
> >+ * so about to be freed; but perhaps not if it's in swapcache - there might
> >+ * be another pte slot containing the swap entry, but page not yet written to
> >+ * swap.
> >   *
> >- * The caller needs to hold the pte lock.
> >+ * set_page_dirty() is called while the page_mapcount is still postive and
> >+ * under the page lock to avoid races with the mapping being invalidated.
> >   */
> >-void page_remove_rmap(struct page *page)
> >+static void propogate_storage_key(struct page *page, bool lock_required)
> 
> Do you mean "propAgate" ?
> 

Yes.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
