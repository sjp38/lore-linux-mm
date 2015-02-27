Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6626B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 13:34:54 -0500 (EST)
Received: by wiwl15 with SMTP id l15so2226889wiw.5
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 10:34:54 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id df6si8633401wjb.161.2015.02.27.10.34.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 10:34:52 -0800 (PST)
Message-ID: <1425062086.13329.10.camel@stgolabs.net>
Subject: Re: [PATCH] mm: replace mmap_sem for mm->exe_file serialization
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Fri, 27 Feb 2015 10:34:46 -0800
In-Reply-To: <20150227173650.GA18823@redhat.com>
References: <1424979417.10344.14.camel@stgolabs.net>
	 <20150226205145.GH3041@moon> <20150227173650.GA18823@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Davidlohr Bueso <dave.bueso@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2015-02-27 at 18:36 +0100, Oleg Nesterov wrote:
> On 02/26, Cyrill Gorcunov wrote:
> >
> > On Thu, Feb 26, 2015 at 11:36:57AM -0800, Davidlohr Bueso wrote:
> > > We currently use the mmap_sem to serialize the mm exe_file.
> > > This is atrocious and a clear example of the misuses this
> > > lock has all over the place, making any significant changes
> > > to the address space locking that much more complex and tedious.
> > > This also has to do of how we used to check for the vma's vm_file
> > > being VM_EXECUTABLE (much of which was replaced by 2dd8ad81e31).
> > >
> > > This patch, therefore, removes the mmap_sem dependency and
> > > introduces a specific lock for the exe_file (rwlock_t, as it is
> > > read mostly and protects a trivial critical region). As mentioned,
> > > the motivation is to cleanup mmap_sem (as opposed to exe_file
> > > performance).
> 
> Well, I didn't see the patch, can't really comment.
> 
> But I have to admit that this looks as atrocious and a clear example of
> "lets add yet another random lock which we will regret about later" ;)
> 
> rwlock_t in mm_struct just to serialize access to exe_file?

I don't see why this is a random lock nor how would we regret this
later. I regret having to do these kind of patches because people were
lazy and just relied on mmap_sem without thinking beyond their use case.
As mentioned I'm also planning on creating an own sort of
exe_file_struct, which would be an isolated entity (still in the mm
though), with its own locking and prctl bits, that would tidy mm_struct
a bit. RCU was something else I considered, but it doesn't suite well in
all paths and we would still need a spinlock when updating the file
anyway.

If you have a better suggestion please do tell.

> 
> > A nice side effect of this is that we avoid taking
> > > the mmap_sem (shared) in fork paths for the exe_file handling
> > > (note that readers block when the rwsem is taken exclusively by
> > > another thread).
> 
> Yes, this is ugly. Can't we kill this dup_mm_exe_file() and copy change
> dup_mmap() to also dup ->exe_file ?
> 
> > Hi Davidlohr, it would be interesting to know if the cleanup
> > bring some performance benefit?
> 
> To me the main question is whether the patch makes this code simpler
> or uglier ;)

Its much beyond that. As mentioned, for any significant changes to the
mmap_sem locking scheme, this sort of thing needs to be addressed first.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
