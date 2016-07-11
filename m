Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 58B5E6B025E
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 09:30:54 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id c52so136415757qte.2
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 06:30:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z6si1731895qtb.68.2016.07.11.06.30.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 06:30:53 -0700 (PDT)
Date: Mon, 11 Jul 2016 09:30:51 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: [4.7.0rc6] Page Allocation Failures with dm-crypt
Message-ID: <20160711133051.GA28308@redhat.com>
References: <28dc911645dce0b5741c369dd7650099@mail.ud19.udmedia.de>
 <e7af885e08e1ced4f75313bfdfda166d@mail.ud19.udmedia.de>
 <20160711131818.GA28102@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160711131818.GA28102@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Cc: linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org

Inlining reply below after thinking further.

On Mon, Jul 11 2016 at  9:18am -0400,
Mike Snitzer <snitzer@redhat.com> wrote:

> On Mon, Jul 11 2016 at  4:31am -0400,
> Matthias Dahl <ml_linux-kernel@binary-island.eu> wrote:
> 
> > Hello,
> > 
> > I made a few more tests and here my observations:
> > 
> > - kernels 4.4.8 and 4.5.5 show the same behavior
> > 
> > - the moment dd starts, memory usage spikes rapidly and within a just
> >   a few seconds has filled up all 32 GiB of RAM

But that is expected given you're doing an unbounded buffered write to
the device.  What isn't expected, to me anyway, is that the mm subsystem
(or the default knobs for buffered writeback) would be so aggressive
about delaying writeback.

> > - dd w/ direct i/o works just fine

Given that directio works the unbounded buffered IO write you're doing
with dd certainly speaks to that specific area of the mm subsystem.

Why are you doing this test anyway?  Such a large buffered write doesn't
seem to accurately model any application I'm aware of (but obviously it
should still "work").

> > - mkfs.ext4 unfortunately shows the same behavior as dd w/o direct i/o
> >   and such makes creation of an ext4 fs on dm-crypt a game of luck
> > 
> >   (much more exposed so with e2fsprogs 1.43.1)

Now that is weird.  Are you (or the distro you're using) setting any mm
subsystem tunables to really broken values?

> > I am kind of puzzled that this bug has seemingly gone so long unnoticed
> > since it is rather severe and makes dm-crypt unusable to a certain
> > degree
> > for fs encryption (or at least the initial creation of the fs). Am I
> > missing something here or doing something terribly stupid?
> 
> Not clear.  Certainly haven't had any reports of memory leaks with
> dm-crypt.  Something must explain the execessive nature of your leak but
> it isn't a known issue.
> 
> Have you tried running with kmemleak enabled?

I'm now doubting this is a leak...

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
