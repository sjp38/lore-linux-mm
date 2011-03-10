Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3CC1F8D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 07:14:02 -0500 (EST)
Date: Thu, 10 Mar 2011 13:05:19 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
Message-ID: <20110310120519.GA18415@redhat.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309110606.GA16719@redhat.com> <alpine.DEB.2.00.1103091222420.13353@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1103091222420.13353@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On 03/09, David Rientjes wrote:
>
> On Wed, 9 Mar 2011, Oleg Nesterov wrote:
>
> > > Using for_each_process() does not consider threads that have failed to
> > > exit after the oom killed parent and, thus, we select another innocent
> > > task to kill when we're really just waiting for those threads to exit
> >
> > How so? select_bad_process() checks TIF_MEMDIE and returns ERR_PTR()
> > if it is set.
> >
>
> TIF_MEMDIE is quite obviously a per-thread flag

Yes, and this is why I think it should be replaced.

> That leader may exit and leave behind several other
> threads

No, it can't.

More precisely, it can, and it can even exit _before_ this process starts
to use a lot of memory, then later this process can be oom-killed.

But, until all threads disappear, the leader can't go away and
for_each_process() must see it.

IOW. If for_each_process() doesn't see the leader, there are no threads
from its thread group. If it does see, the process is not dead yet. It
may be exiting, and the current check tries to detect this case but it
is not perfect. And btw "if (p != current)" code is wrong.

I told this many times. This was one of the reasons why initial ->mm != NULL
in select_bad_process() were completely wrong. Now we are going to re-introduce
them, although Andrey's patch is not that wrong (but should be dropped anyway
imho).

However,

> > And, exactly because we use for_each_process() we do not need to check
> > other threads. The main thread can't disappear until they all exit.
> >
>
> That's obviously false,

I still can't convince you ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
