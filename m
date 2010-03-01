Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6435D6B0078
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 13:00:10 -0500 (EST)
Date: Mon, 1 Mar 2010 18:58:46 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 04 of 32] update futex compound knowledge
Message-ID: <20100301175846.GE17057@random.random>
References: <patchbomb.1264969631@v2.random>
 <57877975a9a72d2fad7e.1264969635@v2.random>
 <1266319998.8404.48.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1266319998.8404.48.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 16, 2010 at 12:33:18PM +0100, Peter Zijlstra wrote:
> OK, so I really don't like this, the futex code is pain enough without
> having all this open-coded gunk in. Is there really no sensible
> vm-helper you can use here?

I also don't like this but there's no vm helper and this is the only
case where this happens. No other place pretends to work on the head
page while calling gup on a tail page! So this requires special care
considering tail page may disappear any time (and head page as well)
if split_huge_page is running.

> Also, that whole local_irq_disable(); __gup_fast(); dance is terribly
> x86 specific, and this is generic core kernel code.

But nothing risks to break at build time, simply any arch with
transparent hugepage support also has to implement
__get_user_pages_fast. Disabling irq and using __get_user_pages_fast
looked the best way to serialize against split_huge_page here (rather
than taking locks).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
