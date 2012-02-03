Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 90BCD6B13FB
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 07:38:11 -0500 (EST)
Received: by dadv6 with SMTP id v6so3359772dad.14
        for <linux-mm@kvack.org>; Fri, 03 Feb 2012 04:38:10 -0800 (PST)
Date: Fri, 3 Feb 2012 20:37:53 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: [Lsf-pc] [dm-devel]  [LSF/MM TOPIC] a few storage topics
Message-ID: <20120203123753.GA11042@localhost>
References: <F6F2DEB8-F096-4A3B-89E3-3A132033BC76@dilger.ca>
 <1327502034.2720.23.camel@menhir>
 <D3F292ADF945FB49B35E96C94C2061B915A638A6@nsmail.netscout.com>
 <1327509623.2720.52.camel@menhir>
 <1327512727.2776.52.camel@dabdike.int.hansenpartnership.com>
 <D3F292ADF945FB49B35E96C94C2061B915A63A30@nsmail.netscout.com>
 <1327516668.7168.7.camel@dabdike.int.hansenpartnership.com>
 <20120125200613.GH15866@shiny>
 <20120125224614.GM30782@redhat.com>
 <D3F292ADF945FB49B35E96C94C2061B915A64111@nsmail.netscout.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B915A64111@nsmail.netscout.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Loke, Chetan" <Chetan.Loke@netscout.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Chris Mason <chris.mason@oracle.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Steven Whitehouse <swhiteho@redhat.com>, Andreas Dilger <adilger@dilger.ca>, Jan Kara <jack@suse.cz>, Mike Snitzer <snitzer@redhat.com>, linux-scsi@vger.kernel.org, neilb@suse.de, dm-devel@redhat.com, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Boaz Harrosh <bharrosh@panasas.com>, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, "Darrick J.Wong" <djwong@us.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>

On Thu, Jan 26, 2012 at 11:40:47AM -0500, Loke, Chetan wrote:
> > From: Andrea Arcangeli [mailto:aarcange@redhat.com]
> > Sent: January 25, 2012 5:46 PM
> 
> ....
> 
> > Way more important is to have feedback on the readahead hits and be
> > sure when readahead is raised to the maximum the hit rate is near 100%
> > and fallback to lower readaheads if we don't get that hit rate. But
> > that's not a VM problem and it's a readahead issue only.
> > 
> 
> A quick google showed up - http://kerneltrap.org/node/6642 
> 
> Interesting thread to follow. I haven't looked further as to what was
> merged and what wasn't.
> 
> A quote from the patch - " It works by peeking into the file cache and
> check if there are any history pages present or accessed."
> Now I don't understand anything about this but I would think digging the
> file-cache isn't needed(?). So, yes, a simple RA hit-rate feedback could
> be fine.
> 
> And 'maybe' for adaptive RA just increase the RA-blocks by '1'(or some
> N) over period of time. No more smartness. A simple 10 line function is
> easy to debug/maintain. That is, a scaled-down version of
> ramp-up/ramp-down. Don't go crazy by ramping-up/down after every RA(like
> SCSI LLDD madness). Wait for some event to happen.
> 
> I can see where Andrew Morton's concerns could be(just my
> interpretation). We may not want to end up like a protocol state machine
> code: tcp slow-start, then increase , then congestion, then let's
> back-off. hmmm, slow-start is a problem for my business logic, so let's
> speed-up slow-start ;).

Loke,

Thrashing safe readahead can work as simple as:

        readahead_size = min(nr_history_pages, MAX_READAHEAD_PAGES)

No need for more slow-start or back-off magics.

This is because nr_history_pages is a lower estimation of the threshing
threshold:

   chunk A           chunk B                      chunk C                 head

   l01 l11           l12   l21                    l22
| |-->|-->|       |------>|-->|                |------>|
| +-------+       +-----------+                +-------------+               |
| |   #   |       |       #   |                |       #     |               |
| +-------+       +-----------+                +-------------+               |
| |<==============|<===========================|<============================|
        L0                     L1                            L2

 Let f(l) = L be a map from
     l: the number of pages read by the stream
 to
     L: the number of pages pushed into inactive_list in the mean time
 then
     f(l01) <= L0
     f(l11 + l12) = L1
     f(l21 + l22) = L2
     ...
     f(l01 + l11 + ...) <= Sum(L0 + L1 + ...)
                        <= Length(inactive_list) = f(thrashing-threshold)

So the count of continuous history pages left in inactive_list is always a
lower estimation of the true thrashing-threshold. Given a stable workload,
the readahead size will keep ramping up and then stabilize in range

        (thrashing_threshold/2, thrashing_threshold)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
