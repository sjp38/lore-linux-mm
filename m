Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AE3399000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 10:26:17 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8KEBahH005297
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 10:11:36 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KEQD3q175814
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 10:26:14 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KEQ2Hg011902
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 08:26:03 -0600
Date: Tue, 20 Sep 2011 19:42:04 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 0/26]   Uprobes patchset with perf
 probe support
Message-ID: <20110920141204.GC6568@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110920133401.GA28550@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

* Christoph Hellwig <hch@infradead.org> [2011-09-20 09:34:01]:

> On Tue, Sep 20, 2011 at 05:29:38PM +0530, Srikar Dronamraju wrote:
> > - Uses i_mutex instead of uprobes_mutex.
> 
> What for exactly?  I'm pretty strict against introducing even more
> uses for i_mutex, it's already way to overloaded with different
> meanings.
> 


There could be multiple simultaneous requests for adding/removing a
probe for the same location i.e same inode + same offset. These requests
will have to be serialized.

To serialize this we had used uprobes specific mutex (uprobes_mutex) in
the last patchset.  However using uprobes_mutex will mean we will be
serializing requests for unrelated files. I.e if we get a request to
probe libpthread while we are inserting/deleting a probe on libc, 
then we used to make the libpthread request wait unnecessarily.
This also means that I dont need to introduce yet another lock.

After using i_mutex, these two requests can run in parallel.

I had proposed this while answering one of the comments in the last
patchset. Since I didnt hear any complaints, I went ahead and
implemented this.

I could use any other inode/file/mapping based sleepable lock that is of
higher order than mmap_sem. Can you please let me know if we have
alternatives.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
