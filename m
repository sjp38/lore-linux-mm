Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 965096B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 15:16:25 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o31JGKrK014934
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 21:16:20 +0200
Received: from pvc7 (pvc7.prod.google.com [10.241.209.135])
	by wpaz37.hot.corp.google.com with ESMTP id o31JFsQc014881
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 12:16:19 -0700
Received: by pvc7 with SMTP id 7so760344pvc.41
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 12:16:19 -0700 (PDT)
Date: Thu, 1 Apr 2010 12:16:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] oom: hold tasklist_lock when dumping tasks
In-Reply-To: <20100401142758.GA14603@redhat.com>
Message-ID: <alpine.DEB.2.00.1004011215000.30661@chino.kir.corp.google.com>
References: <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com>
 <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com> <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com> <alpine.DEB.2.00.1004010157020.29497@chino.kir.corp.google.com>
 <20100401142758.GA14603@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Apr 2010, Oleg Nesterov wrote:

> > dump_header() always requires tasklist_lock to be held because it calls
> > dump_tasks() which iterates through the tasklist.  There are a few places
> > where this isn't maintained, so make sure tasklist_lock is always held
> > whenever calling dump_header().
> 
> Looks correct, but I'd suggest you to update the changelog.
> 
> Not only dump_tasks() needs tasklist, oom_kill_process() needs it too
> for list_for_each_entry(children).
> 
> You fixed this:
> 
> > @@ -724,8 +719,10 @@ void pagefault_out_of_memory(void)
> >
> >  	if (try_set_system_oom()) {
> >  		constrained_alloc(NULL, 0, NULL, &totalpages);
> > +		read_lock(&tasklist_lock);
> >  		err = oom_kill_process(current, 0, 0, 0, totalpages, NULL,
> >  					"Out of memory (pagefault)");
> > +		read_unlock(&tasklist_lock);
> 

It's required for both that and because oom_kill_process() can call 
dump_header() which is mentioned in the changelog, so I don't think any 
update is needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
