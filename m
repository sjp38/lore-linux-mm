Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id E0B366B0031
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 10:09:57 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so301016wgg.13
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 07:09:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z2si35607500wjz.98.2014.07.03.07.09.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 07:09:38 -0700 (PDT)
Date: Thu, 3 Jul 2014 16:08:53 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Qemu-devel] [PATCH 00/10] RFC: userfault
Message-ID: <20140703140853.GG21667@redhat.com>
References: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
 <53B55E63.7080309@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53B55E63.7080309@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Covington <cov@codeaurora.org>
Cc: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Robert Love <rlove@google.com>, Dave Hansen <dave@sr71.net>, Jan Kara <jack@suse.cz>, Neil Brown <neilb@suse.de>, Stefan Hajnoczi <stefanha@gmail.com>, Andrew Jones <drjones@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Taras Glek <tglek@mozilla.com>, Juan Quintela <quintela@redhat.com>, Hugh Dickins <hughd@google.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Mel Gorman <mgorman@suse.de>, Android Kernel Team <kernel-team@android.com>, Mel Gorman <mel@csn.ul.ie>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Mike Hommey <mh@glandium.org>, Keith Packard <keithp@keithp.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Minchan Kim <minchan@kernel.org>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, crml <criu@openvz.org>

Hi Christopher,

On Thu, Jul 03, 2014 at 09:45:07AM -0400, Christopher Covington wrote:
> CRIU uses the soft dirty bit in /proc/pid/clear_refs and /proc/pid/pagemap to
> implement its pre-copy memory migration.
> 
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/vm/soft-dirty.txt
> 
> Would it make sense to use a similar interaction model of peeking and poking
> at /proc/pid/ files for post-copy memory migration facilities?

We plan to use the pagemap information to optimize precopy live
migration, but that's orthogonal with postcopy live migration.

We already combine precopy and postcopy live migration.

In addition to the dirty bit tracking with softdirty clear_refs
feature, the pagemap bits can also tell for example which pages are
missing in the source node, instead of the current memcmp(0) that
avoids to transfer zero pages. With pagemap we can skip a superfluous
zero page fault (David suggested this).

Postcopy live migration poses a different problem. And without
postcopy there's no way to migrate 100GByte guests with heavy load
inside them, in fact even the first "optimistic" precopy pass should
only migrate those pages that already got the dirty bit set by the
time we attempt to send them.

With postcopy we can also guarantee that the maximum amount of data
transferred during precopy+postcopy is twice the size of the guest. So
you know exactly the maximum time live migration will take depending
on your network bandwidth and it cannot fail no matter the load or the
size of the guest. Slowing down the guest with autoconverge isn't
needed anymore.

The userfault only happens in the destination node. The problem we
face is that we must start the guest in the destination node despite
significant amount of its memory is still in the source node.

With postcopy migration the pages aren't dirty nor present in the
destination node, they're just holes, and in fact we already exactly
know which are missing without having to check pagemap.

It's up to the guest OS which pages it decides to touch, we cannot
know. We already know where are holes, we don't know if the guest will
touch the holes during its runtime while the memory is still
externalized.

If the guest touches any hole we need to stop the guest somehow and we
must be let know immediately so we transfer the page, fill the hole,
and let it continue ASAP.

pagemap/clear_refs can't stop the guest and let us know immediately
about the fact the guest touched a hole.

It's not just about the guest shadow mmu accesses, it could also be
O_DIRECT from qemu that triggers the fault and in that case GUP stops,
we fill the hole and then GUP and O_DIRECT succeeds without even
noticing it has been stopped by an userfault.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
