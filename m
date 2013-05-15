Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 4F8D96B0034
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:56:03 -0400 (EDT)
Date: Wed, 15 May 2013 15:56:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mm: Remove lru parameter from __pagevec_lru_add and
 remove parts of pagevec API
Message-Id: <20130515155601.370bb7c62a02487b422f7613@linux-foundation.org>
In-Reply-To: <1368440482-27909-5-git-send-email-mgorman@suse.de>
References: <1368440482-27909-1-git-send-email-mgorman@suse.de>
	<1368440482-27909-5-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On Mon, 13 May 2013 11:21:22 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Now that the LRU to add a page to is decided at LRU-add time, remove the
> misleading lru parameter from __pagevec_lru_add. A consequence of this is
> that the pagevec_lru_add_file, pagevec_lru_add_anon and similar helpers
> are misleading as the caller no longer has direct control over what LRU
> the page is added to. Unused helpers are removed by this patch and existing
> users of pagevec_lru_add_file() are converted to use lru_cache_add_file()
> directly and use the per-cpu pagevecs instead of creating their own pagevec.

Well maybe.  The `lru' arg to __lru_cache_add is still there and is
rather misleading (I find it maddening ;)).  AIUI, it's just there as
the means by which the __lru_cache_add() caller tells the LRU manager
that the caller wishes this page to start life on the active LRU, yes? 
It doesn't _really_ specify an LRU list at all.

In which case I think it would be a heck of a lot clearer if the
callers were to do

	SetPageActve(page);
	__lru_cache_add(page);

no?  (Or __lru_cache_add_active(page) and
__lru_cache_add_inactive(page) if one prefers).

Ditto lru_cache_add_lru() and probably other things.  Let's have one
way of communicating activeness, not two.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
