Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id AD9656B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 04:00:24 -0500 (EST)
Message-ID: <4F211607.10403@panasas.com>
Date: Thu, 26 Jan 2012 10:59:51 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [dm-devel]  [LSF/MM TOPIC] a few storage topics
References: <20120124203936.GC20650@quack.suse.cz> <20120125032932.GA7150@localhost> <F6F2DEB8-F096-4A3B-89E3-3A132033BC76@dilger.ca> <1327502034.2720.23.camel@menhir> <D3F292ADF945FB49B35E96C94C2061B915A638A6@nsmail.netscout.com> <1327509623.2720.52.camel@menhir> <1327512727.2776.52.camel@dabdike.int.hansenpartnership.com> <D3F292ADF945FB49B35E96C94C2061B915A63A30@nsmail.netscout.com> <1327516668.7168.7.camel@dabdike.int.hansenpartnership.com> <20120125200613.GH15866@shiny> <20120125224614.GM30782@redhat.com>
In-Reply-To: <20120125224614.GM30782@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Chris Mason <chris.mason@oracle.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Loke, Chetan" <Chetan.Loke@netscout.com>, Steven Whitehouse <swhiteho@redhat.com>, Andreas Dilger <adilger@dilger.ca>, Jan Kara <jack@suse.cz>, Mike Snitzer <snitzer@redhat.com>, linux-scsi@vger.kernel.org, neilb@suse.de, dm-devel@redhat.com, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Wu Fengguang <fengguang.wu@gmail.com>, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, "Darrick J.Wong" <djwong@us.ibm.com>

On 01/26/2012 12:46 AM, Andrea Arcangeli wrote:
> On Wed, Jan 25, 2012 at 03:06:13PM -0500, Chris Mason wrote:
>> We can talk about scaling up how big the RA windows get on their own,
>> but if userland asks for 1MB, we don't have to worry about futile RA, we
>> just have to make sure we don't oom the box trying to honor 1MB reads
>> from 5000 different procs.
> 
> :) that's for sure if read has a 1M buffer as destination. However
> even cp /dev/sda reads/writes through a 32kb buffer, so it's not so
> common to read in 1m buffers.
> 

That's not so true. cp is a bad example because it's brain dead and
someone should fix it. cp performance is terrible. Even KDE's GUI
copy is better.

But applications (and dd users) that do care about read performance
do use large buffers and want the Kernel to not ignore that.

What a better hint for Kernel is the read() destination buffer size.

> But I also would prefer to stay on the simple side (on a side note we
> run out of page flags already on 32bit I think as I had to nuke
> PG_buddy already).
> 

So what would be more simple then not ignoring read() request
size from application, which will give applications all the control
they need.

<snip> (I Agree)

> The config option is also ok with me, but I think it'd be nicer to set
> it at boot depending on ram size (one less option to configure
> manually and zero overhead).

If you actually take into account the destination buffer size, you'll see
that the read-ahead size becomes less important for these workloads that
actually care. But Yes some mount time heuristics could be nice, depending
on DEV size and MEM size.

For example in my file-system with self registered BDI I set readhead sizes
according to raid-strip sizes and such so to get good read performance.

And speaking of reads and readhead. What about alignments? both of offset
and length? though in reads it's not so important. One thing some people
have ask for is raid-verify-reads as a mount option.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
