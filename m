Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 5B1D56B0068
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 00:10:55 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id rl6so8443094pac.29
        for <linux-mm@kvack.org>; Wed, 02 Jan 2013 21:10:54 -0800 (PST)
Date: Wed, 2 Jan 2013 21:10:48 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v7 1/2] KSM: numa awareness sysfs knob
In-Reply-To: <1357030004.1379.4.camel@kernel.cn.ibm.com>
Message-ID: <alpine.LNX.2.00.1301022050450.979@eggly.anvils>
References: <20121224050817.GA25749@kroah.com> <1356658337-12540-1-git-send-email-pholasek@redhat.com> <1357030004.1379.4.camel@kernel.cn.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Tue, 1 Jan 2013, Simon Jeons wrote:
> 
> Hi Petr and Hugh,
> 
> One offline question, thanks for your clarify.

Perhaps not as offline as you intended :)

> 
> How to understand age = (unsigned char)(ksm_scan.seqnr -
> rmap_item->address);? It used for what?

As you can see, remove_rmap_item_from_tree uses it to decide whether
or not it should rb_erase the rmap_item from the unstable_tree.

Every full scan of all the rmap_items, we increment ksm_scan.seqnr,
forget the old unstable_tree (it would just be a waste of processing
to remove every node one by one), and build up the unstable_tree afresh.

That works fine until we need to remove an rmap_item: then we have to be
very sure to remove it from the unstable_tree if it's already been linked
there during this scan, but ignore its rblinkage if that's just left over
from the previous scan.

A single bit would be enough to decide this; but we got it troublesomely
wrong in the early days of KSM (didn't always visit every rmap_item each
scan), so it's convenient to use 8 bits (the low unsigned char, stored
below the FLAGs and below the page-aligned address in the rmap_item -
there's lots of them, best keep them as small as we can) and do a
BUG_ON(age > 1) if we made a mistake.

We haven't hit that BUG_ON in over three years: if we need some more
bits for something, we can cut the age down to one or two bits.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
