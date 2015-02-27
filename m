Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id AE0FA6B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 12:38:34 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id n4so13791590qaq.5
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 09:38:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b130si4658607qhc.99.2015.02.27.09.38.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 09:38:33 -0800 (PST)
Date: Fri, 27 Feb 2015 18:36:50 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm: replace mmap_sem for mm->exe_file serialization
Message-ID: <20150227173650.GA18823@redhat.com>
References: <1424979417.10344.14.camel@stgolabs.net> <20150226205145.GH3041@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150226205145.GH3041@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Davidlohr Bueso <dave.bueso@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@stgolabs.net

On 02/26, Cyrill Gorcunov wrote:
>
> On Thu, Feb 26, 2015 at 11:36:57AM -0800, Davidlohr Bueso wrote:
> > We currently use the mmap_sem to serialize the mm exe_file.
> > This is atrocious and a clear example of the misuses this
> > lock has all over the place, making any significant changes
> > to the address space locking that much more complex and tedious.
> > This also has to do of how we used to check for the vma's vm_file
> > being VM_EXECUTABLE (much of which was replaced by 2dd8ad81e31).
> >
> > This patch, therefore, removes the mmap_sem dependency and
> > introduces a specific lock for the exe_file (rwlock_t, as it is
> > read mostly and protects a trivial critical region). As mentioned,
> > the motivation is to cleanup mmap_sem (as opposed to exe_file
> > performance).

Well, I didn't see the patch, can't really comment.

But I have to admit that this looks as atrocious and a clear example of
"lets add yet another random lock which we will regret about later" ;)

rwlock_t in mm_struct just to serialize access to exe_file?

> A nice side effect of this is that we avoid taking
> > the mmap_sem (shared) in fork paths for the exe_file handling
> > (note that readers block when the rwsem is taken exclusively by
> > another thread).

Yes, this is ugly. Can't we kill this dup_mm_exe_file() and copy change
dup_mmap() to also dup ->exe_file ?

> Hi Davidlohr, it would be interesting to know if the cleanup
> bring some performance benefit?

To me the main question is whether the patch makes this code simpler
or uglier ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
