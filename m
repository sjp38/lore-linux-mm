Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 60C4F6B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 11:53:52 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id a108so7784959qge.36
        for <linux-mm@kvack.org>; Mon, 12 May 2014 08:53:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v6si6213725qas.68.2014.05.12.08.53.51
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 08:53:51 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm, compaction: properly signal and act upon lock and need_sched() contention
Date: Mon, 12 May 2014 11:53:39 -0400
Message-Id: <5370ee8f.0683e00a.58c7.fffff04fSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <5370EC9B.5020106@suse.cz>
References: <20140508051747.GA9161@js1304-P5Q-DELUXE> <1399904111-23520-1-git-send-email-vbabka@suse.cz> <1399908847-ouuxeneo@n-horiguchi@ah.jp.nec.com> <5370EC9B.5020106@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, Mel Gorman <mgorman@suse.de>, b.zolnierkie@samsung.com, mina86@mina86.com, cl@linux.com, Rik van Riel <riel@redhat.com>

On Mon, May 12, 2014 at 05:45:31PM +0200, Vlastimil Babka wrote:
...
> >>+/*
> >>+ * Similar to compact_checklock_irqsave() (see its comment) for places where
> >>+ * a zone lock is not concerned.
> >>+ *
> >>+ * Returns false when compaction should abort.
> >>+ */
> >>+static inline bool compact_check_resched(struct compact_control *cc)
> >>+{
> >>+	/* async compaction aborts if contended */
> >>+	if (need_resched()) {
> >>+		if (cc->mode == MIGRATE_ASYNC) {
> >>+			cc->contended = true;
> >
> >This changes the meaning of contended in struct compact_control (not just
> >indicating lock contention,) so please update the comment in mm/internal.h too.
> 
> It doesn't change it, since compact_checklock_irqsave() already has
> this semantic:
> if (should_release_lock(lock) && cc->mode == MIGRATE_ASYNC)
> 	cc->contended = true;
> 
> and should_release_lock() is:
> 	need_resched() || spin_is_contended(lock)
> 
> So the comment was already outdated, I will update it in v2.

Ah OK. Sorry for falsely blaming you :)

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
