Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 33F196B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 12:00:10 -0400 (EDT)
Message-ID: <1346947206.1680.36.camel@gandalf.local.home>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive
 hashtable
From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 06 Sep 2012 12:00:06 -0400
In-Reply-To: <5048C615.4070204@gmail.com>
References: <503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal>
	 <503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal>
	 <20120828230050.GA3337@Krystal>
	 <1346772948.27919.9.camel@gandalf.local.home> <50462C99.5000007@redhat.com>
	 <50462EE8.1090903@redhat.com> <20120904170138.GB31934@Krystal>
	 <5048AAF6.5090101@gmail.com> <20120906145545.GA17332@leaf>
	 <5048C615.4070204@gmail.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Josh Triplett <josh@joshtriplett.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Pedro Alves <palves@redhat.com>, Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On Thu, 2012-09-06 at 17:49 +0200, Sasha Levin wrote:
>  
> > Looks reasonable.  However, it would break (or rather, not break) on
> > code like this:
> > 
> > 	hash_for_each_entry(...) {
> > 		if (...) {
> > 			foo(node);
> > 			node = NULL;

ug, I didn't even notice this. Ignore my last email :-p

/me needs to wake-up a bit more.

> > 			break;
> > 		}
> > 	}
> > 
> > Hiding the double loop still seems error-prone.
> 
> I think that that code doesn't make sense. The users of hlist_for_each_* aren't
> supposed to be changing the loop cursor.

I totally agree. Modifying the 'node' pointer is just asking for issues.
Yes that is error prone, but not due to the double loop. It's due to the
modifying of the node pointer that is used internally by the loop
counter. Don't do that :-)


> 
> We have three options here:
> 
>  1. Stuff everything into a single for(). While not too difficult, it will make
> the readability of the code difficult as it will force us to abandon using
> hlist_for_each_* macros.
> 
>  2. Over-complicate everything, and check for 'node == NULL && obj &&
> obj->member.next == NULL' instead. That one will fail only if the user has
> specifically set the object as the last object in the list and the node as NULL.
> 
>  3. Use 2 loops which might not work properly if the user does something odd,
> with a big fat warning above them.
> 
> 
> To sum it up, I'd rather go with 3 and let anyone who does things he shouldn't
> be doing break.

I agree, the double loop itself is not error prone. If you are modifying
'node' you had better know what the hell you are doing.

Actually, it may be something that is legitimate. That is, if you want
to skip to the next bucket, just set node to NULL and do the break (as
Josh had done). This would break if the macro loop changed later on, but
hey, like I said, it's error prone ;-) If you really want to do that,
then hand coding the double loop would be a better bet. IOW, don't use
the macro loop.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
