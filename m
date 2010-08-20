Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 90CAF6B02DE
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 04:43:10 -0400 (EDT)
Date: Fri, 20 Aug 2010 16:43:04 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] writeback: Adding pages_dirtied and
 pages_entered_writeback
Message-ID: <20100820084304.GA6051@localhost>
References: <1282251447-16937-1-git-send-email-mrubin@google.com>
 <1282251447-16937-3-git-send-email-mrubin@google.com>
 <20100820025111.GB5502@localhost>
 <AANLkTimKn5BZiCAyr-3XAZuu66Q+ASZgBZ7LDU2Jom1p@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTimKn5BZiCAyr-3XAZuu66Q+ASZgBZ7LDU2Jom1p@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@suse.de" <npiggin@suse.de>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 04:16:09PM +0800, Michael Rubin wrote:
> On Thu, Aug 19, 2010 at 7:51 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > As Rik said, /proc/sys is not a suitable place.
> 
> OK I'm convinced.
> 
> > Frankly speaking I've worked on writeback for years and never felt
> > the need to add these counters. What I often do is:
> >
> > $ vmmon -d 1 nr_writeback nr_dirty nr_unstable
> >
> > A  A  nr_writeback A  A  A  A  nr_dirty A  A  A nr_unstable
> > A  A  A  A  A  A 68738 A  A  A  A  A  A  A  A 0 A  A  A  A  A  A 39568
> > A  A  A  A  A  A 66051 A  A  A  A  A  A  A  A 0 A  A  A  A  A  A 42255
> > A  A  A  A  A  A 63406 A  A  A  A  A  A  A  A 0 A  A  A  A  A  A 44900
> > A  A  A  A  A  A 60643 A  A  A  A  A  A  A  A 0 A  A  A  A  A  A 47663
> > A  A  A  A  A  A 57954 A  A  A  A  A  A  A  A 0 A  A  A  A  A  A 50352
> > A  A  A  A  A  A 55264 A  A  A  A  A  A  A  A 0 A  A  A  A  A  A 53042
> > A  A  A  A  A  A 52592 A  A  A  A  A  A  A  A 0 A  A  A  A  A  A 55715
> > A  A  A  A  A  A 49922 A  A  A  A  A  A  A  A 0 A  A  A  A  A  A 58385
> > That is what I get when copying /dev/zero to NFS.
> >
> > I'm very interested in Google's use case for this patch, and why
> > the simple /proc/vmstat based vmmon tool is not enough.
> 
> So as I understand it from looking at the code vmmon is sampling
> nr_writeback, nr_dirty which are exported versions of
> global_page_state for NR_FILE_DIRTY and NR_WRITEBACK. These states are
> a snapshot of the state of the kernel's pages. Namely how many dpages
> ar ein writeback or dirty at the moment vmmon's acquire routine is
> called.
> 
> vmmon is sampling /proc/vstat and then displaying the difference from
> the last time they sampled.  If I am misunderstanding let me know.

Maybe Andrew's vmmon does that. My vmmon always display the raw values
:) It could be improved to do raw values for nr_dirty and differences
for pgpgin by default.

> This is good for the state of the system but as we compare
> application, mm and io performance over long periods of time we are
> interested in the surges and fluctuations of the rates of the
> producing and consuming of dirty pages also. It can help isolate where
> the problem is and also to compare performance between kernels and/or
> applications.

Yeah the accumulated dirty and writeback page counts could be useful.
For example, for inspecting the dirty and writeback speed over time.
That's not possible for nr_dirty/nr_writeback.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
