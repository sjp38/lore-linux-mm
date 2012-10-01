Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id C64BE6B005D
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 04:15:06 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so8418885pbb.14
        for <linux-mm@kvack.org>; Mon, 01 Oct 2012 01:15:06 -0700 (PDT)
Date: Mon, 1 Oct 2012 01:14:25 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4] KSM: numa awareness sysfs knob
In-Reply-To: <alpine.LSU.2.00.1209301736560.6304@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1210010053380.6539@eggly.anvils>
References: <1348448166-1995-1-git-send-email-pholasek@redhat.com> <alpine.LSU.2.00.1209301736560.6304@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Sun, 30 Sep 2012, Hugh Dickins wrote:
> Andrea's point about ksm_migrate_page() is an important one, and I've
> answered that against his mail, but here's some other easier points.

There's another point that I completely forgot to make once I got down
to the details of your patch.

Somewhere, I didn't decide exactly where, perhaps near the memcmp_pages()
call in unstable_tree_search_insert(), you do need to check that the page
"in" the unstable tree still belongs to the NUMAnode of the page we're
comparing with.

While that is, of course, the NUMAnode of the unstable tree we're
searching, the unstable tree places no hold on the pages "in" it (it's
actually a tree of rmap_items, not of pages), so they could get migrated
to a different NUMAnode (or faulted out and then faulted back in on a
different NUMAnode) since the rmap_item was placed in that tree.

This is little different from the other instabilities of the unstable
tree, it's not a big deal, and gets corrected (usually) next time around;
but you do want to check, to avoid promoting such a mismatch into the
stable tree.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
