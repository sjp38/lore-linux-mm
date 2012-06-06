Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 3C9906B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 22:57:36 -0400 (EDT)
Date: Tue, 5 Jun 2012 22:57:30 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: write-behind on streaming writes
Message-ID: <20120606025729.GA1197@redhat.com>
References: <20120528114124.GA6813@localhost>
 <CA+55aFxHt8q8+jQDuoaK=hObX+73iSBTa4bBWodCX3s-y4Q1GQ@mail.gmail.com>
 <20120529155759.GA11326@localhost>
 <CA+55aFykFaBhzzEyRYWRS9Qoy_q_R65Cuth7=XvfOZEMqjn6=w@mail.gmail.com>
 <20120530032129.GA7479@localhost>
 <20120605172302.GB28556@redhat.com>
 <20120605174157.GC28556@redhat.com>
 <20120605184853.GD28556@redhat.com>
 <20120605201045.GE28556@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120605201045.GE28556@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>

On Tue, Jun 05, 2012 at 04:10:45PM -0400, Vivek Goyal wrote:
> On Tue, Jun 05, 2012 at 02:48:53PM -0400, Vivek Goyal wrote:
> 
> [..]
> > So sync_file_range() test keeps less in flight requests on on average
> > hence better latencies. It might not produce throughput drop on SATA
> > disks but might have some effect on storage array luns. Will give it
> > a try.
> 
> Well, I ran dd and syn_file_range test on a storage array Lun. Wrote a
> file of size 4G on ext4. Got about 300MB/s write speed. In fact when I
> measured time using "time", sync_file_range test finished little faster.
> 
> Then I started looking at blktrace output. sync_file_range() test
> initially (for about 8 seconds), drives shallow queue depth (about 16),
> but after 8 seconds somehow flusher gets involved and starts submitting
> lots of requests and we start driving much higher queue depth (upto more than
> 100). Not sure why flusher should get involved. Is everything working as
> expected. I thought that as we wait for last 8MB IO to finish before we
> start new one, we should have at max 16MB of IO in flight. Fengguang?

Ok, found it. I am using "int index" which in turn caused signed integer
extension of (i*BUFSIZE). Once "i" crosses 255, integer overflow happens
and 64bit offset is sign extended and offsets are screwed. So after 2G
file size, sync_file_range() effectively stops working leaving dirty
pages which are cleaned up by flusher. So that explains why flusher
was kicking during my tests. Change "int" to "unsigned int" and problem
if fixed.

Now I ran sync_file_range() test and another program which writes 4GB file
and does a fdatasync() at the end and compared total execution time. First
one takes around 12.5 seconds while later one takes around 12.00 seconds.
So sync_file_range() is just little slower on this SAN lun.

I had expected a bigger difference as sync_file_range() is just driving
max queue depth of 32 (total 16MB IO in flight), while flushers are
driving queue depths up to 140 or so. So in this paritcular test, driving
much deeper queue depths is not really helping much. (I have seen higher
throughputs with higher queue depths in the past. Now sure why don't we
see it here).

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
