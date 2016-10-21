Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8F06B0069
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 21:58:44 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n85so40482558pfi.7
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 18:58:44 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id e7si189202pas.335.2016.10.20.18.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 18:58:43 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id 128so7075172pfz.1
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 18:58:43 -0700 (PDT)
Date: Fri, 21 Oct 2016 12:58:28 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 4/6] mm: remove free_unmap_vmap_area_addr
Message-ID: <20161021125828.17b8960e@roar.ozlabs.ibm.com>
In-Reply-To: <CAJWu+oqOw6uMh+Q_78MGjO8WKLxCuh4fmVmKxEJ5aoviXjoMcA@mail.gmail.com>
References: <1476773771-11470-1-git-send-email-hch@lst.de>
	<1476773771-11470-5-git-send-email-hch@lst.de>
	<CAJWu+oqOw6uMh+Q_78MGjO8WKLxCuh4fmVmKxEJ5aoviXjoMcA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Jisheng Zhang <jszhang@marvell.com>, Chris Wilson <chris@chris-wilson.co.uk>, John Dias <joaodias@google.com>, "open
 list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-rt-users@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 20 Oct 2016 17:46:36 -0700
Joel Fernandes <joelaf@google.com> wrote:

> > @@ -1100,10 +1091,14 @@ void vm_unmap_ram(const void *mem, unsigned int count)
> >         debug_check_no_locks_freed(mem, size);
> >         vmap_debug_free_range(addr, addr+size);
> >
> > -       if (likely(count <= VMAP_MAX_ALLOC))
> > +       if (likely(count <= VMAP_MAX_ALLOC)) {
> >                 vb_free(mem, size);
> > -       else
> > -               free_unmap_vmap_area_addr(addr);
> > +               return;
> > +       }
> > +
> > +       va = find_vmap_area(addr);
> > +       BUG_ON(!va);  
> 
> Considering recent objections to BUG_ON [1], lets make this a WARN_ON
> while we're moving the code?

If you lost track of your kernel memory mappings, you are in big trouble
and fail stop is really the best course of action for containing the
problem, which could have security and data corruption implications. This
is covered by Linus' last paragraph in that commit.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
