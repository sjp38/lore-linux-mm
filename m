Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id F377C6B0070
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 08:07:25 -0400 (EDT)
Date: Fri, 28 Sep 2012 14:07:18 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 1/1] thp: avoid VM_BUG_ON page_count(page) false
 positives in __collapse_huge_page_copy
Message-ID: <20120928120718.GY19474@redhat.com>
References: <20120927215147.A3F935C0050@hpza9.eem.corp.google.com>
 <CA+55aFw069v_jCcF7rC-1bkOPYsg3f9wPiWEhNOXEq5D71Lx=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw069v_jCcF7rC-1bkOPYsg3f9wPiWEhNOXEq5D71Lx=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, hughd@google.com, jweiner@redhat.com, mgorman@suse.de, pholasek@redhat.com, riel@redhat.com, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>

Hi Linus,

On Thu, Sep 27, 2012 at 04:40:13PM -0700, Linus Torvalds wrote:
> On Thu, Sep 27, 2012 at 2:51 PM,  <akpm@linux-foundation.org> wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > Subject: thp: avoid VM_BUG_ON page_count(page) false positives in __collapse_huge_page_copy
> >
> > Some time ago Petr once reproduced a false positive VM_BUG_ON in
> > khugepaged while running the autonuma-benchmark on a large 8 node system.
> > All production kernels out there have DEBUG_VM=n so it was only noticeable
> > on self built kernels.  It's not easily reproducible even on the 8 nodes
> > system.
> >
> > Use page_freeze_refs to prevent speculative pagecache lookups to
> > trigger the false positives, so we're still able to check the
> > page_count to be exact.
> 
> This is too ugly to live. It also fundamentally changes semantics and
> actually makes CONFIG_DEBUG_VM result in totally different behavior.
> 
> I really don't think it's a good feature to make CONFIG_DEBUG_VM
> actually seriously change serialization.
> 
> Either do the page_freeze_refs thing *unconditionally*, presumably
> replacing the current code that does
> 
>                 ...
>                 /* cannot use mapcount: can't collapse if there's a gup pin */
>                 if (page_count(page) != 1) {
> 
> instead, or then just relax the potentially racy VM_BUG_ON() to just
> check >= 2. Because debug stuff that changes semantics really is
> horribly horribly bad.

Agreed. I think we can simply drop that VM_BUG_ON: there's a
putback_lru_page that does a put_page, and then another that does
page_cache_release just after the VM_BUG_ON, so if the count is < 2
we'll notice when the count underflows in free_page_and_swap_cache
(we've a VM_BUG_ON in put_page_testzero for that).

The reason for too ugly to live patch, is that I wanted to take the
opportunity of a workload on a 128 CPU 8 node system that could
reproduce it to verify that it really was the speculative lookup and
not something else (and something else wouldn't have been good :). But
I fully agree with you that after successfully verifying that, it's
good to go with a non-ugly version. Thanks for checking this!

I'll send an updated patch.

> Btw, there are two other thp patches (relating to mlock) floating
> around. They look much more reasonable than this one, but I was hoping
> to see more ack's for them.

Ok! I'll review them too. I read them and they looked all right but I
didn't spend enough time on it yet to be sure and send an ack sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
