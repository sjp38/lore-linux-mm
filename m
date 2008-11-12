Date: Tue, 11 Nov 2008 18:27:09 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
In-Reply-To: <20081111231722.GR10818@random.random>
Message-ID: <Pine.LNX.4.64.0811111823030.31625@quilx.com>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
 <1226409701-14831-2-git-send-email-ieidus@redhat.com>
 <1226409701-14831-3-git-send-email-ieidus@redhat.com>
 <20081111114555.eb808843.akpm@linux-foundation.org> <20081111210655.GG10818@random.random>
 <Pine.LNX.4.64.0811111522150.27767@quilx.com> <20081111221753.GK10818@random.random>
 <Pine.LNX.4.64.0811111626520.29222@quilx.com> <20081111231722.GR10818@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008, Andrea Arcangeli wrote:

> > O_DIRECT does not take a refcount on the page in order to prevent this?
>
> It definitely does, it's also the only thing it does.

Then page migration will not occur because there is an unresolved
reference.

> The whole point is that O_DIRECT can start the instruction after
> page_count returns as far as I can tell.

But there must still be reference for the bio and whatever may be going on
at the time in order to perform the I/O operation.

> If you check the three emails I linked in answer to Andrew on the
> topic, we agree the o_direct can't start under PT lock (or under
> mmap_sem in write mode but migrate.c rightefully takes the read
> mode). So the fix used in ksm page_wrprotect and in fork() is to check
> page_count vs page_mapcount inside PT lock before doing anything on
> the pte. If you just mark the page wprotect while O_DIRECT is in
> flight, that's enough for fork() to generate data corruption in the
> parent (not the child where the result would be undefined). But in the
> parent the result of the o-direct is defined and it'd never corrupt if
> this was a cached-I/O. The moment the parent pte is marked readonly, a thread
> in the parent could write to the last 512bytes of the page, leading to
> the first 512bytes coming with O_DIRECT from disk being lost (as the
> write will trigger a cow before I/O is complete and the dma will
> complete on the oldpage).

Have you actually seen corruption or this conjecture? AFACT the page
count is elevated while I/O is in progress and thus this is safe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
