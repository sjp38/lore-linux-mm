Date: Sat, 18 Aug 2001 20:10:50 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: resend Re: [PATCH] final merging patch -- significant mozilla
 speedup.
In-Reply-To: <20010819012713.N1719@athlon.random>
Message-ID: <Pine.LNX.4.33.0108182005590.3026-100000@touchme.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: torvalds@transmeta.com, alan@redhat.com, linux-mm@kvack.org, Chris Blizzard <blizzard@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 19 Aug 2001, Andrea Arcangeli wrote:

> This below patch besides rewriting the vma lookup engine also covers the
> cases addressed by your patch:

Your patch performs a few odd things like:

+       vma->vm_raend = 0;
+       vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
        lock_vma_mappings(vma);
        spin_lock(&vma->vm_mm->page_table_lock);
-       vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;

which I would argue are incorrect.  Remember that page faults rely on
page_table_lock to protect against the case where the stack is grown and
vm_start is modified.  Aside from that, your patch is a sufficiently large
change so as to be material for 2.5.  Also, have you instrumented the rb
trees to see what kind of an effect it has on performance compared to the
avl tree?

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
