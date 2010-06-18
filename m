Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7F66B01B9
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 05:11:07 -0400 (EDT)
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100618060901.GA6590@dastard>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
	 <20100618060901.GA6590@dastard>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 18 Jun 2010 11:11:00 +0200
Message-ID: <1276852260.27822.1598.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Fri, 2010-06-18 at 16:09 +1000, Dave Chinner wrote:
> > +             bdi->wb_written_head =3D bdi_stat(bdi, BDI_WRITTEN) + wc-=
>written;
>=20
> The resolution of the percpu counters is an issue here, I think.
> percpu counters update in batches of 32 counts per CPU. wc->written
> is going to have a value of roughly 8 or 32 depending on whether
> bdi->dirty_exceeded is set or not. I note that you take this into
> account when checking dirty threshold limits, but it doesn't appear
> to be taken in to here.=20

The BDI stuff uses a custom batch-size, see bdi_stat_error() and
related. The total error is in the order of O(n log n) where n is the
number of CPUs.

But yeah, the whole dirty_exceeded thing makes life more interesting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
