Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC076B02D7
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 04:16:42 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o7K8GUHc004780
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:16:31 -0700
Received: from ywl5 (ywl5.prod.google.com [10.192.12.5])
	by kpbe20.cbf.corp.google.com with ESMTP id o7K8GTWT012060
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:16:29 -0700
Received: by ywl5 with SMTP id 5so1712112ywl.11
        for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:16:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100820025111.GB5502@localhost>
References: <1282251447-16937-1-git-send-email-mrubin@google.com>
 <1282251447-16937-3-git-send-email-mrubin@google.com> <20100820025111.GB5502@localhost>
From: Michael Rubin <mrubin@google.com>
Date: Fri, 20 Aug 2010 01:16:09 -0700
Message-ID: <AANLkTimKn5BZiCAyr-3XAZuu66Q+ASZgBZ7LDU2Jom1p@mail.gmail.com>
Subject: Re: [PATCH 2/3] writeback: Adding pages_dirtied and pages_entered_writeback
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, npiggin@suse.de, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 7:51 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> As Rik said, /proc/sys is not a suitable place.

OK I'm convinced.

> Frankly speaking I've worked on writeback for years and never felt
> the need to add these counters. What I often do is:
>
> $ vmmon -d 1 nr_writeback nr_dirty nr_unstable
>
> =A0 =A0 nr_writeback =A0 =A0 =A0 =A0 nr_dirty =A0 =A0 =A0nr_unstable
> =A0 =A0 =A0 =A0 =A0 =A068738 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0=
 =A0 =A0 =A039568
> =A0 =A0 =A0 =A0 =A0 =A066051 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0=
 =A0 =A0 =A042255
> =A0 =A0 =A0 =A0 =A0 =A063406 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0=
 =A0 =A0 =A044900
> =A0 =A0 =A0 =A0 =A0 =A060643 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0=
 =A0 =A0 =A047663
> =A0 =A0 =A0 =A0 =A0 =A057954 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0=
 =A0 =A0 =A050352
> =A0 =A0 =A0 =A0 =A0 =A055264 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0=
 =A0 =A0 =A053042
> =A0 =A0 =A0 =A0 =A0 =A052592 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0=
 =A0 =A0 =A055715
> =A0 =A0 =A0 =A0 =A0 =A049922 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0=
 =A0 =A0 =A058385
> That is what I get when copying /dev/zero to NFS.
>
> I'm very interested in Google's use case for this patch, and why
> the simple /proc/vmstat based vmmon tool is not enough.

So as I understand it from looking at the code vmmon is sampling
nr_writeback, nr_dirty which are exported versions of
global_page_state for NR_FILE_DIRTY and NR_WRITEBACK. These states are
a snapshot of the state of the kernel's pages. Namely how many dpages
ar ein writeback or dirty at the moment vmmon's acquire routine is
called.

vmmon is sampling /proc/vstat and then displaying the difference from
the last time they sampled.  If I am misunderstanding let me know.

This is good for the state of the system but as we compare
application, mm and io performance over long periods of time we are
interested in the surges and fluctuations of the rates of the
producing and consuming of dirty pages also. It can help isolate where
the problem is and also to compare performance between kernels and/or
applications.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
