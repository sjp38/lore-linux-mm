Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 126B862001F
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 15:07:09 -0400 (EDT)
Date: Wed, 17 Mar 2010 14:05:53 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 34] Transparent Hugepage support #14
In-Reply-To: <patchbomb.1268839142@v2.random>
Message-ID: <alpine.DEB.2.00.1003171353240.27268@router.home>
References: <patchbomb.1268839142@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>


I am still opposed to this. The patchset results in compound pages be
managed in 4k segments. The approach so far was that a compound
page is simply a page struct referring to a larger linear memory
segment. The compound state is exclusively modified in the first
page struct which allows an easy conversion of code to deal with compound
pages since the concept of handling a single page struct is preserved. The
main difference between the handling of a 4K page and a compound pages
page struct is that the compound flag is set.

Here compound pages have refcounts in each 4k segment. Critical VM path
can no longer rely on the page to stay intact since there is this on the
fly conversion. The on the fly "atomic" conversion requires various forms
of synchronization and modifications to basic VM primitives like pte
management and page refcounting.

I would recommend that the conversion between 2M and 4K page work with
proper synchronization with all those handling references to the page.
Codepaths handling huge pages should not rely on on the fly conversion but
properly handle the various sizes. In most cases size does not matter
since the page state is contained in a single page struct regardless of
size. This patch here will cause future difficulties in making code handle
compound pages.

Transparent huge page support better be introduced gradually starting f.e.
with the support of 2M pages for anonymous pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
