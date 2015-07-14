Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1A928024D
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:16:20 -0400 (EDT)
Received: by ieik3 with SMTP id k3so20571125iei.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:16:20 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com. [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id g73si1833163iod.163.2015.07.14.14.16.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 14:16:20 -0700 (PDT)
Received: by ieik3 with SMTP id k3so20571027iei.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:16:20 -0700 (PDT)
Date: Tue, 14 Jul 2015 14:16:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: RE: [patch v3 3/3] mm, oom: do not panic for oom kills triggered
 from sysrq
In-Reply-To: <050601d0bae5$14647770$3d2d6650$@alibaba-inc.com>
Message-ID: <alpine.DEB.2.10.1507141414410.16182@chino.kir.corp.google.com>
References: <02e601d0b9fd$d644ec50$82cec4f0$@alibaba-inc.com> <alpine.DEB.2.10.1507091428340.17177@chino.kir.corp.google.com> <050601d0bae5$14647770$3d2d6650$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, 10 Jul 2015, Hillf Danton wrote:

> > I'm not sure I understand your point.
> > 
> > There are two oom killer panics: when panic_on_oom is enabled and when the
> > oom killer can't find an eligible process.
> > 
> > The change to the panic_on_oom panic is dealt with in check_panic_on_oom()
> > and the no eligible process panic is dealt with here.
> > 
> > If the sysctl is disabled, and there are no eligible processes to kill,
> > the change in behavior here is that we don't panic when triggered from
> > sysrq.  That's the change in the hunk above.
> > 
> When no eligible processes is selected to kill, we are sure that we skip one
> panic in check_panic_on_oom(), and we have no clear reason to panic again.
> 
> But we can simply answer the caller that there is no page, and let her
> decide what to do.
> 
> So I prefer to fold the two panic into one.
> 
> Hillf
> > > > -	if (p != (void *)-1UL) {
> > > > +	if (p && p != (void *)-1UL) {
> > > >  		oom_kill_process(oc, p, points, totalpages, NULL,
> > > >  				 "Out of memory");
> > > >  		killed = 1;
> 

I'm still not sure I understand your point, unfortunately.  The new check:

	if (!p && oc->order != -1) {
		dump_header(oc, NULL, NULL);
		panic("Out of memory and no killable processes...\n");
	}

ensures we never panic when called from sysrq.  This is done because 
userspace can easily race when there is a single eligible process to kill 
that exits or is otherwise killed and the sysrq+f ends up panicking the 
machine unexpectedly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
