Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 93B916B00AA
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 07:58:25 -0500 (EST)
Date: Wed, 17 Nov 2010 23:57:56 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering
 writeback
Message-ID: <20101117125756.GA5576@amd>
References: <1289996638-21439-1-git-send-email-walken@google.com>
 <1289996638-21439-4-git-send-email-walken@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1289996638-21439-4-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 04:23:58AM -0800, Michel Lespinasse wrote:
> When faulting in pages for mlock(), we want to break COW for anonymous
> or file pages within VM_WRITABLE, non-VM_SHARED vmas. However, there is
> no need to write-fault into VM_SHARED vmas since shared file pages can
> be mlocked first and dirtied later, when/if they actually get written to.
> Skipping the write fault is desirable, as we don't want to unnecessarily
> cause these pages to be dirtied and queued for writeback.

It's not just to break COW, but to do block allocation and such
(filesystem's page_mkwrite op). That needs to at least be explained
in the changelog.

Filesystem doesn't have a good way to fully pin required things
according to mlock, but page_mkwrite provides some reasonable things
(like block allocation / reservation).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
