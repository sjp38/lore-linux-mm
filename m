Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 52C806B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 10:09:49 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a20so20943573wme.5
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 07:09:49 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b197si11007965wmb.95.2016.11.07.07.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 07:09:48 -0800 (PST)
Date: Mon, 7 Nov 2016 16:09:47 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 4/7] mm: defer vmalloc from atomic context
Message-ID: <20161107150947.GA11279@lst.de>
References: <1477149440-12478-1-git-send-email-hch@lst.de> <1477149440-12478-5-git-send-email-hch@lst.de> <25c117ae-6d06-9846-6a88-ae6221ad6bfe@virtuozzo.com> <CAJWu+oppRL5kD9qPcdCbFAbEkE7bN+kmrvTuaueVZnY+WtK_tg@mail.gmail.com> <a40cccff-3a6e-b0be-5d06-bac6cdb0e1e6@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a40cccff-3a6e-b0be-5d06-bac6cdb0e1e6@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Joel Fernandes <joelaf@google.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Jisheng Zhang <jszhang@marvell.com>, Chris Wilson <chris@chris-wilson.co.uk>, John Dias <joaodias@google.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-rt-users@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>

On Mon, Nov 07, 2016 at 06:01:45PM +0300, Andrey Ryabinin wrote:
> > So because in_atomic doesn't work for !CONFIG_PREEMPT kernels, can we
> > always defer the work in these cases?
> > 
> > So for non-preemptible kernels, we always defer:
> > 
> > if (!IS_ENABLED(CONFIG_PREEMPT) || in_atomic()) {
> >   // defer
> > }
> > 
> > Is this fine? Or any other ideas?
> > 
> 
> What's wrong with my idea?
> We can add vfree_in_atomic() and use it to free vmapped stacks
> and for any other places where vfree() used 'in_atomict() && !in_interrupt()' context.

I somehow missed the mail, sorry.  That beeing said always defer is
going to suck badly in terms of performance, so I'm not sure it's an all
that good idea.

vfree_in_atomic sounds good, but I wonder if we'll need to annotate
more callers than just the stacks.  I'm fairly bust this week, do you
want to give that a spin?  Otherwise I'll give it a try towards the
end of this week or next week.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
