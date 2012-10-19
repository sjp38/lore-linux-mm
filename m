Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id F00966B005A
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 13:54:40 -0400 (EDT)
Message-ID: <1350669236.2768.66.camel@twins>
Subject: Re: question on NUMA page migration
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 19 Oct 2012 19:53:56 +0200
In-Reply-To: <50818A41.7030909@redhat.com>
References: <5081777A.8050104@redhat.com> <1350664742.2768.40.camel@twins>
	 <50818A41.7030909@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, 2012-10-19 at 13:13 -0400, Rik van Riel wrote:

> Would it make sense to have the normal page migration code always
> work with the extra refcount, so we do not have to introduce a new
> MIGRATE_FAULT migration mode?
>=20
> On the other hand, compaction does not take the extra reference...

Right, it appears to not do this, it gets pages from the pfn and
zone->lock and the isolate_lru_page() call is the first reference.

> Another alternative might be to do the put_page inside
> do_prot_none_numa().  That would be analogous to do_wp_page
> disposing of the old page for the caller.

It'd have to be inside migrate_misplaced_page(), can't do before
isolate_lru_page() or the page might disappear. Doing it after is
(obviously) too late.

> I am not real happy about NUMA migration introducing its own
> migration mode...

You didn't seem to mind too much earlier, but I can remove it if you
want.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
