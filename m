Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B8EDE6B0022
	for <linux-mm@kvack.org>; Mon, 16 May 2011 19:04:53 -0400 (EDT)
Subject: Re: [PATCH 3/3] checkpatch.pl: Add check for task comm references
From: Joe Perches <joe@perches.com>
In-Reply-To: <alpine.DEB.2.00.1105161431550.4353@chino.kir.corp.google.com>
References: <1305580757-13175-1-git-send-email-john.stultz@linaro.org>
	 <1305580757-13175-4-git-send-email-john.stultz@linaro.org>
	 <op.vvlfaobx3l0zgt@mnazarewicz-glaptop>
	 <alpine.DEB.2.00.1105161431550.4353@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 16 May 2011 16:04:50 -0700
Message-ID: <1305587090.2503.42.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andy Whitcroft <apw@canonical.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, LKML <linux-kernel@vger.kernel.org>, John Stultz <john.stultz@linaro.org>, Ted Ts'o <tytso@mit.edu>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, 2011-05-16 at 14:34 -0700, David Rientjes wrote:
> On Mon, 16 May 2011, Michal Nazarewicz wrote:
> > > Now that accessing current->comm needs to be protected,
> > > +# check for current->comm usage
> > > +		if ($line =~ /\b(?:current|task|tsk|t)\s*->\s*comm\b/) {
> > Not a checkpatch.pl expert but as far as I'm concerned, that looks reasonable.

I think the only checkpatch expert is Andy Whitcroft.

You don't need (?: just (

curr, chip and object are pretty common (see below)

An option may be to specify another variable
common_comm_vars or something like it

our $common_comm_vars = qr{(?x:
	current|tsk|p|task|curr|chip|t|object|me
)};

and use that variable in your test

Treewide:

$ grep -rPoh --include=*.[ch] "\b\w+\s*\-\>\s*comm\b" * | \
	sort | uniq -c | sort -rn
    319 current->comm
     59 tsk->comm
     32 __entry->comm
     24 p->comm
     23 event->comm
     19 task->comm
     18 thread->comm
     15 self->comm
     14 c->comm
     13 curr->comm
     12 chip->comm
      9 t->comm
      8 object->comm
      8 me->comm
(others not shown)

Perf:

$ grep -rP --include=*.[ch] "\b\w+\s*\-\>\s*comm\b" tools/perf include/trace | \
	sort | uniq -c | sort -rn
     32 __entry->comm
     23 event->comm
     18 thread->comm
     15 self->comm
     14 c->comm
     10 current->comm
      3 tsk->comm
      3 task->comm
      3 p->comm
(others not shown)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
