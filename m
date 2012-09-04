Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 12CB76B0062
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 12:32:23 -0400 (EDT)
Date: Tue, 4 Sep 2012 12:32:20 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive
	hashtable
Message-ID: <20120904163220.GA31698@Krystal>
References: <20120824212348.GK21325@google.com> <5038074D.300@gmail.com> <20120824230740.GN21325@google.com> <20120825042419.GA27240@Krystal> <503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal> <503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal> <20120828230050.GA3337@Krystal> <1346772948.27919.9.camel@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346772948.27919.9.camel@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Steven Rostedt (rostedt@goodmis.org) wrote:
> On Tue, 2012-08-28 at 19:00 -0400, Mathieu Desnoyers wrote:
> 
> > Looking again at:
> > 
> > +#define hash_for_each_size(name, bits, bkt, node, obj, member)                 \
> > +       for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)                             \
> > +               hlist_for_each_entry(obj, node, &name[bkt], member)
> > 
> > you will notice that a "break" or "continue" in the inner loop will not
> > affect the outer loop, which is certainly not what the programmer would
> > expect!
> > 
> > I advise strongly against creating such error-prone construct.
> > 
> 
> A few existing loop macros do this. But they require a do { } while ()
> approach, and all have a comment.
> 
> It's used by do_each_thread() in sched.h 

Yes. It's worth noting that it is a do_each_thread() /
while_each_thread() pair.


> and ftrace does this as well.
> Look at kernel/trace/ftrace.c at do_for_each_ftrace_rec().

Same here.

> 
> Yes it breaks 'break' but it does not break 'continue' as it would just
> go to the next item that would have been found (like a normal for
> would).

Good point.

So would changing hash_for_each_size() to a

do_each_hash_size()/while_each_hash_size() make it clearer that this
contains a double-loop ? (along with an appropriate comment about
break).

Thanks,

Mathieu

> 
> -- Steve
> 
> 

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
