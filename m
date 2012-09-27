Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 373BE6B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 19:40:36 -0400 (EDT)
Received: by oagk14 with SMTP id k14so3052252oag.14
        for <linux-mm@kvack.org>; Thu, 27 Sep 2012 16:40:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120927215147.A3F935C0050@hpza9.eem.corp.google.com>
References: <20120927215147.A3F935C0050@hpza9.eem.corp.google.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 27 Sep 2012 16:40:13 -0700
Message-ID: <CA+55aFw069v_jCcF7rC-1bkOPYsg3f9wPiWEhNOXEq5D71Lx=g@mail.gmail.com>
Subject: Re: [patch 1/1] thp: avoid VM_BUG_ON page_count(page) false positives
 in __collapse_huge_page_copy
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aarcange@redhat.com, hughd@google.com, jweiner@redhat.com, mgorman@suse.de, pholasek@redhat.com, riel@redhat.com, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>

On Thu, Sep 27, 2012 at 2:51 PM,  <akpm@linux-foundation.org> wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> Subject: thp: avoid VM_BUG_ON page_count(page) false positives in __collapse_huge_page_copy
>
> Some time ago Petr once reproduced a false positive VM_BUG_ON in
> khugepaged while running the autonuma-benchmark on a large 8 node system.
> All production kernels out there have DEBUG_VM=n so it was only noticeable
> on self built kernels.  It's not easily reproducible even on the 8 nodes
> system.
>
> Use page_freeze_refs to prevent speculative pagecache lookups to
> trigger the false positives, so we're still able to check the
> page_count to be exact.

This is too ugly to live. It also fundamentally changes semantics and
actually makes CONFIG_DEBUG_VM result in totally different behavior.

I really don't think it's a good feature to make CONFIG_DEBUG_VM
actually seriously change serialization.

Either do the page_freeze_refs thing *unconditionally*, presumably
replacing the current code that does

                ...
                /* cannot use mapcount: can't collapse if there's a gup pin */
                if (page_count(page) != 1) {

instead, or then just relax the potentially racy VM_BUG_ON() to just
check >= 2. Because debug stuff that changes semantics really is
horribly horribly bad.

Btw, there are two other thp patches (relating to mlock) floating
around. They look much more reasonable than this one, but I was hoping
to see more ack's for them.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
