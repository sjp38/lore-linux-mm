Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7CFF782F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 14:55:44 -0400 (EDT)
Received: by qgem9 with SMTP id m9so69201701qge.1
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 11:55:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z11si7063512qhd.0.2015.10.30.11.55.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 11:55:43 -0700 (PDT)
Date: Fri, 30 Oct 2015 19:55:40 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/6] ksm: fix rmap_item->anon_vma memory corruption and
 vma user after free
Message-ID: <20151030185540.GN5390@redhat.com>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
 <1444925065-4841-2-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.11.1510251642050.1923@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510251642050.1923@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Petr Holasek <pholasek@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hello,

On Sun, Oct 25, 2015 at 05:12:22PM -0700, Hugh Dickins wrote:
> I was convinced for an hour, though puzzled how this had survived
> six years without being noticed: I'd certainly found the need for
> the special ksm_exit()/ksm_test_exit() stuff when testing originally,
> that wasn't hard, and why would this race be so very much harder?

I was traveling last few days but I could leave the testcase running
to reproduce again by rolling back only this patch and I failed...

I now assume that it was another buggy patch that caused a corruption
consistent with the ksm_exit not taking the mmap_sem for writing.

The patch that may have caused this (not part of this patchset) tried
to synchronously drop the stable nodes, in order to remove the
migrate_nodes loop in scan_get_next_rmap_item.

> Now, after looking again at ksm_exit(), I just don't see the point
> you're making.  As I read it (and I certainly accept that I may be
> wrong on all this), it will do the down_write,up_write on any mm
> that is registered with it, and that has a chain of rmap_items -
> the easy_to_free route is only for those that have no rmap_items
> (and are not being worked on at present); and those that have no
> rmap_items, have no rmap_items in the unstable or the stable tree.

So the safety comes from relying on various implicit memory barriers
that are taken as we change mm_slot during the scan, so that we know
the mm_slot->rmap_list fields of the mm_slots not under scan, are
stable and never zero if we run into a rmap_item that belongs to
them.

> Please explain what I'm missing before I look again harder.  One
> nit below.  It looked very reasonable and nicely implemented to me,
> but I didn't complete checking it before I lost sight of what it's
> fixing.  (And incrementing mm_users always makes me worry a bit
> about what happens under OOM, so I prefer not to do it.)

Well the atomic_inc_not_zero is simpler and OOM shouldn't be a
practical problem because this would do mmput immediately after (it's
not holding it for long like the scan could do). However it adds an
atomic op that the current logic doesn't require, and I wouldn't like
to run an atomic op if there's no need.

So for the time being I agree that 1/6 is a noop and should be
dropped. This only applies to 1/6.

Thanks and sorry for the confusion about the mm_slot->rmap_list.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
