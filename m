Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 45FFD90002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 08:40:44 -0400 (EDT)
Received: by widex7 with SMTP id ex7so11378993wid.1
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 05:40:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q9si5326532wje.174.2015.03.11.05.40.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Mar 2015 05:40:42 -0700 (PDT)
Message-ID: <1426077631.2055.20.camel@stgolabs.net>
Subject: Re: [PATCH] mm: replace mmap_sem for mm->exe_file serialization
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Wed, 11 Mar 2015 05:40:31 -0700
In-Reply-To: <CALYGNiM3oaempavTx=e29fJgUGkgcROL4C1PPSwCDEBod-vcpw@mail.gmail.com>
References: <1424979417.10344.14.camel@stgolabs.net>
	 <20150226205145.GH3041@moon> <20150227173650.GA18823@redhat.com>
	 <1425062086.13329.10.camel@stgolabs.net>
	 <CALYGNiM3oaempavTx=e29fJgUGkgcROL4C1PPSwCDEBod-vcpw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Davidlohr Bueso <dave.bueso@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 2015-03-11 at 15:21 +0300, Konstantin Khlebnikov wrote:
> On Fri, Feb 27, 2015 at 9:34 PM, Davidlohr Bueso <dave@stgolabs.net> wrote:
> > On Fri, 2015-02-27 at 18:36 +0100, Oleg Nesterov wrote:
> >> On 02/26, Cyrill Gorcunov wrote:
> >> >
> >> > On Thu, Feb 26, 2015 at 11:36:57AM -0800, Davidlohr Bueso wrote:
> >> > > We currently use the mmap_sem to serialize the mm exe_file.
> >> > > This is atrocious and a clear example of the misuses this
> >> > > lock has all over the place, making any significant changes
> >> > > to the address space locking that much more complex and tedious.
> >> > > This also has to do of how we used to check for the vma's vm_file
> >> > > being VM_EXECUTABLE (much of which was replaced by 2dd8ad81e31).
> >> > >
> >> > > This patch, therefore, removes the mmap_sem dependency and
> >> > > introduces a specific lock for the exe_file (rwlock_t, as it is
> >> > > read mostly and protects a trivial critical region). As mentioned,
> >> > > the motivation is to cleanup mmap_sem (as opposed to exe_file
> >> > > performance).
> >>
> >> Well, I didn't see the patch, can't really comment.
> >>
> >> But I have to admit that this looks as atrocious and a clear example of
> >> "lets add yet another random lock which we will regret about later" ;)
> >>
> >> rwlock_t in mm_struct just to serialize access to exe_file?
> >
> > I don't see why this is a random lock nor how would we regret this
> > later. I regret having to do these kind of patches because people were
> > lazy and just relied on mmap_sem without thinking beyond their use case.
> 
> That's history: exe_file had direct relation to mm->mmap_sem,
> that was file from first executable vma. After my patch it's less
> related to vmas.

Indeed. Yet I'm not changing the exe_file address space semantics at
all.

> 
> > As mentioned I'm also planning on creating an own sort of
> > exe_file_struct, which would be an isolated entity (still in the mm
> > though), with its own locking and prctl bits, that would tidy mm_struct
> > a bit. RCU was something else I considered, but it doesn't suite well in
> > all paths and we would still need a spinlock when updating the file
> > anyway.
> 
> Please don't. What's wrong with mmap_sem?
> 
> Do you want optimize reading mm->exe_file?

No, I want to get rid of certain things being done under mmap_sem,
that's all. This is not performance motivated, it's to allow future work
on lock breaking. I've just yesterday explained this at lsfmm (and not
only related to exe_file). In any case I've clean up this patch and
added more on top to create a friendlier interface, I'll send that out a
bit later.

> Then you should use rcu for that: struct file is rcu-protected thing.
> See fget(), you could do something like that.

As mentioned, not all exe paths are RCU friendly ;) We'd at least need
srcu, but that's neither here nor there. A rwlock is suficient to get
the job done and we really need not care much about optimizing this
particular file further.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
