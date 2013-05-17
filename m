Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 023E96B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 16:45:07 -0400 (EDT)
Date: Fri, 17 May 2013 16:44:52 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/5] mm: Remove lru parameter from __pagevec_lru_add and
 remove parts of pagevec API
Message-ID: <20130517204452.GC15721@cmpxchg.org>
References: <1368784087-956-1-git-send-email-mgorman@suse.de>
 <1368784087-956-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368784087-956-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On Fri, May 17, 2013 at 10:48:06AM +0100, Mel Gorman wrote:
> Now that the LRU to add a page to is decided at LRU-add time, remove the
> misleading lru parameter from __pagevec_lru_add. A consequence of this is
> that the pagevec_lru_add_file, pagevec_lru_add_anon and similar helpers
> are misleading as the caller no longer has direct control over what LRU
> the page is added to. Unused helpers are removed by this patch and existing
> users of pagevec_lru_add_file() are converted to use lru_cache_add_file()
> directly and use the per-cpu pagevecs instead of creating their own pagevec.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Rik van Riel <riel@redhat.com>

> @@ -452,8 +448,7 @@ int cachefiles_read_or_alloc_page(struct fscache_retrieval *op,
>  	if (block) {
>  		/* submit the apparently valid page to the backing fs to be
>  		 * read from disk */
> -		ret = cachefiles_read_backing_file_one(object, op, page,
> -						       &pagevec);
> +		ret = cachefiles_read_backing_file_one(object, op, page);

Also remove the declaration and pagevec_init a few lines up?  Minor
detail, though.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
