Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4209A6B0102
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 17:58:39 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id f8so54067wiw.4
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 14:58:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id bj10si38759992wjb.133.2014.06.10.14.58.36
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 14:58:37 -0700 (PDT)
Date: Tue, 10 Jun 2014 23:58:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH, RFC 00/10] THP refcounting redesign
Message-ID: <20140610215830.GF19660@redhat.com>
References: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.10.1406101518510.19364@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1406101518510.19364@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 10, 2014 at 03:25:42PM -0500, Christoph Lameter wrote:
> I thought the idea was that we would modify the relevant code and
> that at some point this requirement could go away?

There were places that weren't aware and splitted unnecessarily to
avoid having to make all places aware immediately and keep the initial
patchset small, all the ones in relevant fast paths are gone by now,
but the requirement doesn't go away if munmap partially unmaps a page.

If munmap or mremap splits the THP in the middle, the pmd has to be
splitted reliably and it cannot fail or the syscall cannot return...

And Kirill patchset still provides a reliable split of the pmd of
course. It only relaxes the actual page struct split but without
actually removing the tailpage refcounting.

There are clear downsides in adding a failure -EBUSY case to
split_huge_page related to potential increased memory usage that from
the user prospective will like a memory leak (like real anon RSS
exceeding the virtual size up to 512 times in the worst case, at least
until khugepaged can fix it up and release RAM with an async
split_huge_page), but the current get_page/put_page improvement
doesn't look significant enough.

This is why I think we should check if we can go the extra mile and
get rid of the tail page refcounting as a whole if possible, if that
is achieved this failure case added to split_huge_page will look a
better tradeoff than it looks now. Currently I'm not impressed by the
simplification of get_page/put_page considering the downsides this
brings to memory utilization and potentially having to defer the page
split to khugepaged.

> Huge pages (and other larger order pages) will become increasingly
> difficult to handle if relevant page state has to be maintained in tail
> pages and if it differs significantly from regular pages.

Over the last couple of years there was no increase in difficulty
though, the only relevant change that happened was to move the tail
page refcounting from ->count to ->mapcount (both otherwised unused on
tail pages) because ->count could confuse the speculative pagecache
lookups on tail pages, but that was a strightforward change, the
difficulty stayed the same no matter if the tail pin was in count or
mapcount.

While I don't see an actual increase in difficulty anywhere in this
area, simplification and performance improvement is always welcome :).

Last but not the least while I don't see a showstopper for non-weird
non-malicious apps, we should take in consideration the malicious case
too and the trouble that this would cause to containers (or rlimits)
if apps can lock in 512 times more physical RAM than they're supposed
to if this allows bypassing all kernel accounting so easily. Then
again it depends if people thinks containers should be usable to
protect against non trusted apps too or not (I don't, I prefer docker
on top of KVM especially on public clouds, but others do).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
