Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA19221
	for <linux-mm@kvack.org>; Fri, 28 Aug 1998 06:25:37 -0400
Date: Fri, 28 Aug 1998 10:35:36 +0100
Message-Id: <199808280935.KAA06221@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] 498+ days uptime
In-Reply-To: <87ww7v73zg.fsf@atlas.CARNet.hr>
References: <199808262153.OAA13651@cesium.transmeta.com>
	<87ww7v73zg.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "H. Peter Anvin" <hpa@transmeta.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On 27 Aug 1998 00:49:55 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
said:

> I thought it was done this way (update running in userspace) so to
> have control how often buffers get flushed. But, I believe bdflush
> program had this functionality, and it is long gone (as you correctly
> noticed).

update(8) _is_ the old bdflush program. :)

There are two entirely separate jobs being done.  One is to flush all
buffers which are beyond their dirty timelimit: that job is done by the
bdflush syscall called by update/bdflush every 5 seconds.  The second
job is to trickle back some dirty buffers to disk if we are getting
short of clean buffer space in memory. 

These are completely different jobs.  They select which buffers and how
many buffers to write based on different criteria, and they are woken up
by different events.  That's why we have two daemons.  The fact that one
spends its wait time in user mode and one spends its time in kernel mode
is irrelevant; even if they were both kernel threads we'd still have two
separate jobs needing done.

> I'm crossposting this mail to linux-mm where some clever MM people can
> be found. Hopefully we can get an explanation why do we still need
> update.

Because kflushd does not do the job which update needs to do.  It does a
different job.

--Stephen 
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
