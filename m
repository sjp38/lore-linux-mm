Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 58D368E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 09:27:47 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u6-v6so6384465pgn.10
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 06:27:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p16-v6si15265719pgb.38.2018.09.17.06.27.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:27:45 -0700 (PDT)
Date: Mon, 17 Sep 2018 06:27:25 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Message-ID: <20180917132725.GA3633@infradead.org>
References: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
 <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
 <ciirm8zhwyiqh4.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <ciirm8efdy916l.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <CADLDEKsxx=MSFu=4_4JLX1afUMr3GVjNxSQ-726NrbLn8KQaQg@mail.gmail.com>
 <ciirm8r2hs30kh.fsf@u54ee758033e858cfa736.ant.amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ciirm8r2hs30kh.fsf@u54ee758033e858cfa736.ant.amazon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Stecklina <jsteckli@amazon.de>
Cc: Juerg Haefliger <juergh@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, Khalid Aziz <khalid.aziz@oracle.com>, kanth.ghatraju@oracle.com, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

On Mon, Sep 17, 2018 at 12:01:02PM +0200, Julian Stecklina wrote:
> Juerg Haefliger <juergh@gmail.com> writes:
> 
> >> I've updated my XPFO branch[1] to make some of the debugging optional
> >> and also integrated the XPFO bookkeeping with struct page, instead of
> >> requiring CONFIG_PAGE_EXTENSION, which removes some checks in the hot
> >> path.
> >
> > FWIW, that was my original design but there was some resistance to
> > adding more to the page struct and page extension was suggested
> > instead.
> 
> >From looking at both versions, I have to say that having the metadata in
> struct page makes the code easier to understand and removes some special
> cases and bookkeeping.

Btw, can xpfo_lock be replaced with a bit spinlock in the page?
Growing struct page too much might cause performance issues.  Then again
going beyong the 64 byte cache line might already cause that, and even
then it propbably is still way better than the page extensions.

OTOH if you keep the spinlock it might be worth to use
atomic_dec_and_lock on the count.  Maybe the answer is an hash of
spinlock, as we obviously can't take all that many of them at the same
time anyway.

Also for your trasitions froms zero it might be worth at looking at
atomic_inc_unless_zero.
