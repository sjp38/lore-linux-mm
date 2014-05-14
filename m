Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 750696B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 18:36:54 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so190013pbc.15
        for <linux-mm@kvack.org>; Wed, 14 May 2014 15:36:54 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id gs4si3255165pac.207.2014.05.14.15.36.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 15:36:53 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so185152pab.31
        for <linux-mm@kvack.org>; Wed, 14 May 2014 15:36:53 -0700 (PDT)
Date: Wed, 14 May 2014 15:35:34 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 0/3] File Sealing & memfd_create()
In-Reply-To: <537396A2.9090609@cybernetics.com>
Message-ID: <alpine.LSU.2.11.1405141456420.2268@eggly.anvils>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com> <alpine.LSU.2.11.1405132118330.4401@eggly.anvils> <537396A2.9090609@cybernetics.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Hugh Dickins <hughd@google.com>, David Herrmann <dh.herrmann@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Kristian Hogsberg <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>

On Wed, 14 May 2014, Tony Battersby wrote:
> Hugh Dickins wrote:
> > Checking page counts in a GB file prior to sealing does not appeal at
> > all: we'd be lucky ever to find them all accounted for.
> 
> Here is a refinement of that idea: during a seal operation, iterate over
> all the pages in the file and check their refcounts.  On any page that
> has an unexpected extra reference, allocate a new page, copy the data
> over to the new page, and then replace the page having the extra
> reference with the newly-allocated page in the file.  That way you still
> get zero-copy on pages that don't have extra references, and you don't
> have to fail the seal operation if some of the pages are still being
> referenced by something else.

That does seem a more promising idea than any that I'd had: thank you.

But whether it can actually be made to work (safely) is not yet clear
to me.

It would be rather like page migration; but whereas page migration
backs off whenever the page count cannot be fully accounted for
(as does KSM), that is precisely when this would have to act.

Taking action in the case of ignorance does not make me feel very
comfortable.  Page lock and radix tree lock would guard against
many surprises, but not necessarily all.

> 
> The downside of course is the extra memory usage and memcpy overhead if
> something is holding extra references to the pages.  So whether this is
> a good approach depends on:
> 
> *) Whether extra page references would happen frequently or infrequently
> under various kernel configurations and usage scenarios.  I don't know
> enough about the mm system to answer this myself.
> 
> *) Whether or not the extra memory usage and memcpy overhead could be
> considered a DoS attack vector by someone who has found a way to add
> extra references to the pages intentionally.

I may just be too naive on such issues, but neither of those worries
me particularly.  If something can already add an extra pin to many
pages, that is already a concern for memory usage.  The sealing case
would double its scale, but I don't see that as a new issue.

The aspect which really worries me is this: the maintenance burden.
This approach would add some peculiar new code, introducing a rare
special case: which we might get right today, but will very easily
forget tomorrow when making some other changes to mm.  If we compile
a list of danger areas in mm, this would surely belong on that list.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
