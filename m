Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 9B7FD6B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 00:25:55 -0500 (EST)
Date: Mon, 4 Mar 2013 15:55:39 +1030
From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: OOM triggered with plenty of memory free
Message-ID: <20130304052539.GE31835@marvin.atrad.com.au>
References: <20130213031056.GA32135@marvin.atrad.com.au>
 <alpine.DEB.2.02.1302121917020.11158@chino.kir.corp.google.com>
 <20130213042552.GC32135@marvin.atrad.com.au>
 <511BADEA.3070403@linux.vnet.ibm.com>
 <20130226063916.GM16712@marvin.atrad.com.au>
 <512CD435.30704@linux.vnet.ibm.com>
 <87d2vmkd8v.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87d2vmkd8v.fsf@xmission.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Jonathan Woithe <jwoithe@atrad.com.au>

On Tue, Feb 26, 2013 at 12:54:08PM -0800, Eric W. Biederman wrote:
> Dave Hansen <dave@linux.vnet.ibm.com> writes:
> 
> > On 02/25/2013 10:39 PM, Jonathan Woithe wrote:
> >> On Wed, Feb 13, 2013 at 07:14:50AM -0800, Dave Hansen wrote:
> >>> David's analysis looks spot-on.  The only other thing I'll add is that
> >>> it just looks weird that all three kmalloc() caches are so _even_:
> >>>
> >>>>> kmalloc-128       1234556 1235168    128   32    1 : tunables    0    0    0 : slabdata  38599  38599      0
> >>>>> kmalloc-64        1238117 1238144     64   64    1 : tunables    0    0    0 : slabdata  19346  19346      0
> >>>>> kmalloc-32        1236600 1236608     32  128    1 : tunables    0    0    0 : slabdata   9661   9661      0
> >>>
> >>> It's almost like something goes and does 3 allocations in series and
> >>> leaks them all.
> > ...
> >> Given these observations it seems that 2.6.35.11 was leaking memory,
> >> probably as a result of a bug in the fork() execution path.  At this stage
> >> kmemleak is not showing the same recurring problem under 3.7.9.
> >
> > Your kmemleak data shows that the leaks are always from either 'struct
> > cred', or 'struct pid'.  Those are _generally_ tied to tasks, but you
> > only have a couple thousand task_structs.
> >
> > My suspicion would be that something is allocating those structures, but
> > a refcount got leaked somewhere.  2.6.35.11 is about the same era that
> > this code went in:
> >
> > http://lists.linux-foundation.org/pipermail/containers/2010-June/024720.html
> >
> > and it deals with both creds and 'struct pid'.  Eric, do you recall any
> > bugs like this that got fixed along the way?
> >
> > I do think it's fairly safe to assume that 3.7.9 doesn't have this
> > bug.
> 
> I remember that at one point there was a very subtle leak of I think
> struct pid.  That leak was not associated with the socket code but
> something else.

Thanks for the feedback and assistance with this problem.  Given that 3.7.9
(and the LTS kernels 3.4.34 and 3.0.67) all seem to be free of the leak it
seems the sensible approach here is to push a newer kernel onto the affected
machines.  If time permits I may try a bisect to see what it was and when it
was fixed, but this would be for academic interest only.

Curiously enough, 3.4.34 and 3.7.9 are showing a tendency to miss UDP
packets which we don't see with 3.0.67 or 2.6.35.11.  That's clearly a
separate issue in a different subsystem though - I'm bisecting to see if I
can gain any insight into it.

Thanks again for the information and insights.

Regards
  jonathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
