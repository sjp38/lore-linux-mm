Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 247EF6B0062
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 12:31:02 -0400 (EDT)
Message-ID: <50462C99.5000007@redhat.com>
Date: Tue, 04 Sep 2012 17:30:17 +0100
From: Pedro Alves <palves@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
References: <20120824203332.GF21325@google.com> <5037E9D9.9000605@gmail.com>  <20120824212348.GK21325@google.com> <5038074D.300@gmail.com>  <20120824230740.GN21325@google.com> <20120825042419.GA27240@Krystal>  <503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal>  <503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal>  <20120828230050.GA3337@Krystal> <1346772948.27919.9.camel@gandalf.local.home>
In-Reply-To: <1346772948.27919.9.camel@gandalf.local.home>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Sasha Levin <levinsasha928@gmail.com>, Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On 09/04/2012 04:35 PM, Steven Rostedt wrote:
> On Tue, 2012-08-28 at 19:00 -0400, Mathieu Desnoyers wrote:
> 
>> Looking again at:
>>
>> +#define hash_for_each_size(name, bits, bkt, node, obj, member)                 \
>> +       for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)                             \
>> +               hlist_for_each_entry(obj, node, &name[bkt], member)
>>
>> you will notice that a "break" or "continue" in the inner loop will not
>> affect the outer loop, which is certainly not what the programmer would
>> expect!
>>
>> I advise strongly against creating such error-prone construct.
>>
> 
> A few existing loop macros do this. But they require a do { } while ()
> approach, and all have a comment.
> 
> It's used by do_each_thread() in sched.h and ftrace does this as well.
> Look at kernel/trace/ftrace.c at do_for_each_ftrace_rec().
> 
> Yes it breaks 'break' but it does not break 'continue' as it would just
> go to the next item that would have been found (like a normal for
> would).

/*
 * This is a double for. Do not use 'break' to break out of the loop,
 * you must use a goto.
 */
#define do_for_each_ftrace_rec(pg, rec)                                 \
        for (pg = ftrace_pages_start; pg; pg = pg->next) {              \
                int _____i;                                             \
                for (_____i = 0; _____i < pg->index; _____i++) {        \
                        rec = &pg->records[_____i];



You can make 'break' also work as expected if you can embed a little knowledge
of the inner loop's condition in the outer loop's condition.  Sometimes it's
trivial, most often when the inner loop's iterator is a pointer that goes
NULL at the end, but other times not so much.  Something like (completely untested):

#define do_for_each_ftrace_rec(pg, rec)                                 \
        for (pg = ftrace_pages_start, rec = &pg->records[pg->index];    \
             pg && rec == &pg->records[pg->index];                      \
             pg = pg->next) {                                           \
                int _____i;                                             \
                for (_____i = 0; _____i < pg->index; _____i++) {        \
                        rec = &pg->records[_____i];

(other variants possible)

IOW, the outer loop only iterates if the inner loop completes.  If there's
a break in the inner loop, then the outer loop breaks too.  Of course, it
all depends on whether the generated code looks sane or hideous, if
the uses of the macro care for it over bug avoidance.

-- 
Pedro Alves

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
