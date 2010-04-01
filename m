Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D0DC26B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 10:31:22 -0400 (EDT)
Date: Thu, 1 Apr 2010 16:27:58 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch -mm] oom: hold tasklist_lock when dumping tasks
Message-ID: <20100401142758.GA14603@redhat.com>
References: <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com> <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com> <alpine.DEB.2.00.1004010157020.29497@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004010157020.29497@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/01, David Rientjes wrote:
>
> dump_header() always requires tasklist_lock to be held because it calls
> dump_tasks() which iterates through the tasklist.  There are a few places
> where this isn't maintained, so make sure tasklist_lock is always held
> whenever calling dump_header().

Looks correct, but I'd suggest you to update the changelog.

Not only dump_tasks() needs tasklist, oom_kill_process() needs it too
for list_for_each_entry(children).

You fixed this:

> @@ -724,8 +719,10 @@ void pagefault_out_of_memory(void)
>
>  	if (try_set_system_oom()) {
>  		constrained_alloc(NULL, 0, NULL, &totalpages);
> +		read_lock(&tasklist_lock);
>  		err = oom_kill_process(current, 0, 0, 0, totalpages, NULL,
>  					"Out of memory (pagefault)");
> +		read_unlock(&tasklist_lock);


Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
