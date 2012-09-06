Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 122256B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 11:11:37 -0400 (EDT)
Message-ID: <1346944293.1680.26.camel@gandalf.local.home>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive
 hashtable
From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 06 Sep 2012 11:11:33 -0400
In-Reply-To: <20120906145545.GA17332@leaf>
References: <503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal>
	 <503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal>
	 <20120828230050.GA3337@Krystal>
	 <1346772948.27919.9.camel@gandalf.local.home> <50462C99.5000007@redhat.com>
	 <50462EE8.1090903@redhat.com> <20120904170138.GB31934@Krystal>
	 <5048AAF6.5090101@gmail.com> <20120906145545.GA17332@leaf>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Pedro Alves <palves@redhat.com>, Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On Thu, 2012-09-06 at 07:55 -0700, Josh Triplett wrote:

> > My solution to making 'break' work in the iterator is:
> > 
> > 	for (bkt = 0, node = NULL; bkt < HASH_SIZE(name) && node == NULL; bkt++)
> > 		hlist_for_each_entry(obj, node, &name[bkt], member)
> > 
> 
> Looks reasonable.  However, it would break (or rather, not break) on
> code like this:
> 
> 	hash_for_each_entry(...) {
> 		if (...) {
> 			foo(node);
> 			node = NULL;
> 			break;
> 		}
> 	}
> 
> Hiding the double loop still seems error-prone.

We've already had this conversation ;-)  A guess a big comment is in
order:

/*
 * NOTE!  Although this is a double loop, 'break' still works because of
 *        the 'node == NULL' condition in the outer loop. On break of
 *        the inner loop, node will be !NULL, and the outer loop will
 *        exit as well.
 */

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
