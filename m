Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id EF7406B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 14:51:43 -0400 (EDT)
Received: by qcbjx9 with SMTP id jx9so7885002qcb.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 11:51:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g64si17492377qkh.1.2015.03.18.11.51.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 11:51:42 -0700 (PDT)
Date: Wed, 18 Mar 2015 19:06:49 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: install_special_mapping && vm_pgoff (Was: vvar, gup &&
	coredump)
Message-ID: <20150318180649.GA853@redhat.com>
References: <20150311200052.GA22654@redhat.com> <20150312143438.GA4338@redhat.com> <CALCETrW5rmAHutzm_OwK2LTd_J0XByV3pvWGyW=AmC=v7rLfhQ@mail.gmail.com> <20150312165423.GA10073@redhat.com> <20150312174653.GA13086@redhat.com> <20150316190154.GA18472@redhat.com> <CALCETrU9pLE2x3+vei1xw6B8uu4B33DOEzP03ue9DeS8sJhYUg@mail.gmail.com> <20150316194446.GA21791@redhat.com> <20150317134309.GA365@redhat.com> <CALCETrVgzCrb6yfb3=MhBDXxtQgRNbsijBER502+Z2rOVKvipQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVgzCrb6yfb3=MhBDXxtQgRNbsijBER502+Z2rOVKvipQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kratochvil <jan.kratochvil@redhat.com>, Sergio Durigan Junior <sergiodj@redhat.com>, GDB Patches <gdb-patches@sourceware.org>, Pedro Alves <palves@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/17, Andy Lutomirski wrote:
>
> On Tue, Mar 17, 2015 at 6:43 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > But at least the bug exposed by the test-case looks clear:
> >
> >         do_linear_fault:
> >
> >                 vmf->pgoff = (((address & PAGE_MASK) - vma->vm_start) >> PAGE_SHIFT)
> >                                 + vma->vm_pgoff;
> >                 ...
> >
> >                 special_mapping_fault:
> >
> >                         pgoff = vmf->pgoff - vma->vm_pgoff;
> >
> >
> > So special_mapping_fault() can only work if this mapping starts from the
> > first page in ->pages[].
> >
> > So perhaps we need _something like_ the (wrong/incomplete) patch below...
> >
> > Or, really, perhaps we can create vdso_mapping ? So that map_vdso() could
> > simply mmap the anon_inode file...
>
> That's slightly tricky, I think, because it could start showing up in
> /proc/PID/map_files or whatever it's called, and I don't think we want
> that.

Hmm. To me this looke liks improvement. And again, with this change
uprobe-in-vdso can work.

OK, this is off-topic right now, lets forget this for the moment.

> Your patch does look like a considerable improvement, though.  Let me
> see if I can find some time to fold it in with the rest of my special
> mapping rework over the next few days.

I'll try to recheck... Perhaps I'll send this (changed) patch for review.
This is a bugfix, even if the bug is minor.

And note that with this change vvar->access() becomes trivial. I think it
makes sense to fix "gup() fails in vvar" too. Gdb developers have enough
other problems with the poor kernel interfaces ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
