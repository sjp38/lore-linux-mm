Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7696B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 20:13:53 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p5I0Dmcl011340
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 17:13:51 -0700
Received: from pve37 (pve37.prod.google.com [10.241.210.37])
	by hpaq12.eem.corp.google.com with ESMTP id p5I0Cqq6028907
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 17:13:47 -0700
Received: by pve37 with SMTP id 37so1189327pve.21
        for <linux-mm@kvack.org>; Fri, 17 Jun 2011 17:13:46 -0700 (PDT)
Date: Fri, 17 Jun 2011 17:13:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/12] radix_tree: exceptional entries and indices
In-Reply-To: <20110617163854.49225203.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1106171702150.1345@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils> <alpine.LSU.2.00.1106140341070.29206@sister.anvils> <20110617163854.49225203.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 17 Jun 2011, Andrew Morton wrote:
> On Tue, 14 Jun 2011 03:42:27 -0700 (PDT)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > The low bit of a radix_tree entry is already used to denote an indirect
> > pointer, for internal use, and the unlikely radix_tree_deref_retry() case.
> > Define the next bit as denoting an exceptional entry, and supply inline
> > functions radix_tree_exception() to return non-0 in either unlikely case,
> > and radix_tree_exceptional_entry() to return non-0 in the second case.
> 
> Yes, the RADIX_TREE_INDIRECT_PTR hack is internal-use-only, and doesn't
> operate on (and hence doesn't corrupt) client-provided items.
> 
> This patch uses bit 1 and uses it against client items, so for
> practical purpoese it can only be used when the client is storing
> addresses.  And it needs new APIs to access that flag.
> 
> All a bit ugly.  Why not just add another tag for this?  Or reuse an
> existing tag if the current tags aren't all used for these types of
> pages?

I couldn't see how to use tags without losing the "lockless" lookups:
because the tag is a separate bit from the entry itself, unless you're
under tree_lock, there would be races when changing from page pointer
to swap entry or back, when slot was updated but tag not or vice versa.

Perhaps solvable, like seqlocks, by having two tag bits, the combination
saying come back and look again in a moment.  Hah, that can/is already
done with the low bit, the deref_retry.  So, yes, we could use one tag
bit: but it would be messier (could no longer use the slow-path-slightly-
modified find_get_page() etc).  I thought, while we've got a nearby bit
available, let's put it to use.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
