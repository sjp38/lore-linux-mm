Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id F3C576B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 15:14:28 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id td3so48090340pab.2
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 12:14:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l80si8137594pfj.31.2016.03.10.12.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 12:14:27 -0800 (PST)
Date: Thu, 10 Mar 2016 12:14:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 7/7] mm: kasan: Initial memory quarantine
 implementation
Message-Id: <20160310121426.b667420195a19ee17503ae2d@linux-foundation.org>
In-Reply-To: <CAG_fn=UkgkHw5Ed72hPkYYzhXcH5gy5ubTeS8SvggvzZDxFdJw@mail.gmail.com>
References: <cover.1457519440.git.glider@google.com>
	<bdd59cc00ee49b7849ad60a11c6a4704c3e4856b.1457519440.git.glider@google.com>
	<20160309122148.1250854b862349399591dabf@linux-foundation.org>
	<CAG_fn=UkgkHw5Ed72hPkYYzhXcH5gy5ubTeS8SvggvzZDxFdJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 10 Mar 2016 14:50:56 +0100 Alexander Potapenko <glider@google.com> wrote:

> On Wed, Mar 9, 2016 at 9:21 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Wed,  9 Mar 2016 12:05:48 +0100 Alexander Potapenko <glider@google.com> wrote:
> >
> >> Quarantine isolates freed objects in a separate queue. The objects are
> >> returned to the allocator later, which helps to detect use-after-free
> >> errors.
> >
> > I'd like to see some more details on precisely *how* the parking of
> > objects in the qlists helps "detect use-after-free"?
> When the object is freed, its state changes from KASAN_STATE_ALLOC to
> KASAN_STATE_QUARANTINE. The object is poisoned and put into quarantine
> instead of being returned to the allocator, therefore every subsequent
> access to that object triggers a KASAN error, and the error handler is
> able to say where the object has been allocated and deallocated.
> When it's time for the object to leave quarantine, its state becomes
> KASAN_STATE_FREE and it's returned to the allocator. From now on the
> allocator may reuse it for another allocation.
> Before that happens, it's still possible to detect a use-after free on
> that object (it retains the allocation/deallocation stacks).
> When the allocator reuses this object, the shadow is unpoisoned and
> old allocation/deallocation stacks are wiped. Therefore a use of this
> object, even an incorrect one, won't trigger ASan warning.
> Without the quarantine, it's not guaranteed that the objects aren't
> reused immediately, that's why the probability of catching a
> use-after-free is lower than with quarantine in place.

I see, thanks.  I'll slurp that into the changelog for posterity.

> >> +}
> >
> > We could avoid th4ese ifdefs in the usual way: an empty version of
> > quarantine_remove_cache() if CONFIG_SLAB=n.
> Yes, agreed.
> I am sorry, I don't fully understand the review process now, when
> you've pulled the patches into mm-tree.
> Shall I send the new patch series version, as before, or is anything
> else needs to be done?
> Do I need to rebase against mm- or linux-next? Thanks in advance.

I like to queue a delta patch so I and others can see what changed and
also to keep track of who fixed what and why.  It's a bit harsh on the
reviewers to send them a slightly altered version of a 500 line patch
which they've already read through.

Before sending the patch up to Linus I'll clump everything into a
single patch and a lot of that history is somewhat lost.

Sending a replacement patch is often more convenient for the originator
so that's fine - I'll turn the replacement into a delta locally and
will review then queue that delta.  Also a new revision of a patch has
an altered changelog so I'll manually move that into the older original
patch's changelog immediately.

IOW: either a new patch or a delta is fine.

Your patch is in linux-next now so a diff against -next will work OK.

Probably the easiest thing for you to do is to just alter the patch you
have in-place and send out the new one.  A "[v2" in the Subject: helps
people keep track of things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
