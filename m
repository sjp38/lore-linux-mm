From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] migration_entry_wait fix.
Date: Wed, 18 Jun 2008 15:35:57 +1000
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org> <20080618101349.db4d5205.kamezawa.hiroyu@jp.fujitsu.com> <20080618105435.de10d6bc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080618105435.de10d6bc.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806181535.58036.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 18 June 2008 11:54, KAMEZAWA Hiroyuki wrote:
> On Wed, 18 Jun 2008 10:13:49 +0900
>
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > +	if (!page_cache_get_speculative())
> > +		goto out;
>
> This is obviously buggy....sorry..quilt refresh miss..
>
> ==
> In speculative page cache lookup protocol, page_count(page) is set to 0
> while radix-tree modification is going on, truncation, migration, etc...

These tend to all happen while the page is locked, and in particular
while the page does not have any references other than the current
code path and the pagecache. So no page tables should point to it.

So migration_entry_wait should not find pages with a refcount of zero.


> While page migration, a page fault to page under migration should wait
> unlock_page() and migration_entry_wait() waits for the page from its
> pte entry. It does get_page() -> wait_on_page_locked() -> put_page() now.
>
> In page migration, page_freeze_refs() -> page_unfreeze_refs() is called.
>
> Here, page_unfreeze_refs() expects page_count(page) == 0 and panics
> if page_count(page) != 0. To avoid this, we shouldn't touch page_count()
> if it is zero. This patch uses page_cache_get_speculative() to avoid
> the panic.

At any rate, page_cache_get_speculative() should not be used for this
purpose, but for when we _really_ don't have any references to a page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
