Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 08C1E9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 13:20:55 -0400 (EDT)
Date: Tue, 26 Apr 2011 13:19:54 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 00/12] IO-less dirty throttling v7
Message-ID: <20110426171954.GD9414@redhat.com>
References: <20110416132546.765212221@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110416132546.765212221@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Sat, Apr 16, 2011 at 09:25:46PM +0800, Wu Fengguang wrote:
> Andrew,
> 
> This revision undergoes a number of simplifications, cleanups and fixes.
> Independent patches are separated out. The core patches (07, 08) now have
> easier to understand changelog. Detailed rationals can be found in patch 08.
> 
> In response to the complexity complaints, an introduction document is
> written explaining the rationals, algorithm and visual case studies:
> 
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/slides/smooth-dirty-throttling.pdf
> 

Hi Fenguang,

I went quickly browsed through above document and am trying to understand
the meaning of following lines and see how does it fit into the framework
of existing IO conroller.

- task IO controller endogenous
- cgroup IO controller well integrated
- proportional IO controller endogenous

You had sent me a link where you had prepared a patch to control the
async IO completely. So because this code is all about measuring the
bdi writeback rate and then coming up task ratelimit accoridingly, it
will never know about other IO going on in the cgroup. READS and direct
IO.

So IIUC, to make use of above logic for cgroup throttling, one shall have
to come up with explicity notion of async bandwidth per cgroup which does
not control other writes. Currently we have following when it comes to
throttling.

blkio.throttle_read_bps
blkio.throttle_write_bps

The intention is to be able to control the WRITE bandwidth of cgroup and
it could be any kind of WRITE (be it buffered WRITE or direct WRITES). 
Currently we control only direct WRITES and question of how to also
control buffered writes is still on the table.

Because your patch does not know about other WRITES happening in the
system, one needs to create a way so that buffered WRITES and direct
WRITES can be accounted together against a group and throttled
accordingly.

What does "proportional IO controller endogenous" mean? Currently we do
all proportional IO division in CFQ. So are you proposing that for 
buffered WRITES we come up with a different policy altogether in writeback
layer or somehow it is integrating with CFQ mechanism?

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
