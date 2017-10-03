Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9A616B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 10:57:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b1so8046547pge.3
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 07:57:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v18si4128970pfk.139.2017.10.03.07.57.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 07:57:35 -0700 (PDT)
Date: Tue, 3 Oct 2017 07:57:32 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 4/5] cramfs: add mmap support
Message-ID: <20171003145732.GA8890@infradead.org>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org>
 <20170927233224.31676-5-nicolas.pitre@linaro.org>
 <20171001083052.GB17116@infradead.org>
 <nycvar.YSQ.7.76.1710011805070.5407@knanqh.ubzr>
 <CAFLxGvzfQrvU-8w7F26mez6fCQD+iS_qRJpLSU+2DniEGouEfA@mail.gmail.com>
 <nycvar.YSQ.7.76.1710021931270.5407@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1710021931270.5407@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Richard Weinberger <richard.weinberger@gmail.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Chris Brandt <Chris.Brandt@renesas.com>

On Mon, Oct 02, 2017 at 07:33:29PM -0400, Nicolas Pitre wrote:
> On Tue, 3 Oct 2017, Richard Weinberger wrote:
> 
> > On Mon, Oct 2, 2017 at 12:29 AM, Nicolas Pitre <nicolas.pitre@linaro.org> wrote:
> > > On Sun, 1 Oct 2017, Christoph Hellwig wrote:
> > >
> > >> up_read(&mm->mmap_sem) in the fault path is a still a complete
> > >> no-go,
> > >>
> > >> NAK
> > >
> > > Care to elaborate?
> > >
> > > What about mm/filemap.c:__lock_page_or_retry() then?
> > 
> > As soon you up_read() in the page fault path other tasks will race
> > with you before
> > you're able to grab the write lock.
> 
> But I _know_ that.
> 
> Could you highlight an area in my code where this is not accounted for?

Existing users of lock_page_or_retry return VM_FAULT_RETRY right after
up()ing mmap_sem, and they must already have a reference to the page
which is the only thing touched until then.

Your patch instead goes for an exclusive mmap_sem if it can, and
even if there is nothing that breaks with that scheme right now
there s nothing documenting that this actually safe, and we are
way down in the complex page fault path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
