Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C4EAC6B012B
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 10:28:54 -0500 (EST)
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering
 writeback
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20101117125756.GA5576@amd>
References: <1289996638-21439-1-git-send-email-walken@google.com>
	 <1289996638-21439-4-git-send-email-walken@google.com>
	 <20101117125756.GA5576@amd>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 17 Nov 2010 16:28:54 +0100
Message-ID: <1290007734.2109.941.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-17 at 23:57 +1100, Nick Piggin wrote:
> On Wed, Nov 17, 2010 at 04:23:58AM -0800, Michel Lespinasse wrote:
> > When faulting in pages for mlock(), we want to break COW for anonymous
> > or file pages within VM_WRITABLE, non-VM_SHARED vmas. However, there is
> > no need to write-fault into VM_SHARED vmas since shared file pages can
> > be mlocked first and dirtied later, when/if they actually get written t=
o.
> > Skipping the write fault is desirable, as we don't want to unnecessaril=
y
> > cause these pages to be dirtied and queued for writeback.
>=20
> It's not just to break COW, but to do block allocation and such
> (filesystem's page_mkwrite op). That needs to at least be explained
> in the changelog.

Agreed, the 0/3 description actually does mention this.

> Filesystem doesn't have a good way to fully pin required things
> according to mlock, but page_mkwrite provides some reasonable things
> (like block allocation / reservation).

Right, but marking all pages dirty isn't really sane. I can imagine
making the reservation but not marking things dirty solution, although
it might be lots harder to implement, esp since some filesystems don't
actually have a page_mkwrite() implementation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
