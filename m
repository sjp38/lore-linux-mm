Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 15C776B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 19:02:35 -0400 (EDT)
Date: Thu, 1 Apr 2010 01:00:32 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH -mm] proc: don't take ->siglock for /proc/pid/oom_adj
Message-ID: <20100331230032.GB4025@redhat.com>
References: <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330163909.GA16884@redhat.com> <20100330174337.GA21663@redhat.com> <alpine.DEB.2.00.1003301329420.5234@chino.kir.corp.google.com> <20100331185950.GB11635@redhat.com> <alpine.DEB.2.00.1003311408520.31252@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003311408520.31252@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 03/31, David Rientjes wrote:
>
> On Wed, 31 Mar 2010, Oleg Nesterov wrote:
>
> > David, I just can't understand why
> > 	oom-badness-heuristic-rewrite.patch
> > duplicates the related code in fs/proc/base.c and why it preserves
> > the deprecated signal->oom_adj.
>
> You could combine the two write functions together and then two read
> functions together if you'd like.

Yes,

> > 	static ssize_t oom_any_adj_write(struct file *file, const char __user *buf,
> > 						size_t count, bool deprecated_mode)
> > 	{
> >
> > 		if (depraceted_mode) {
> > 			 if (oom_score_adj == OOM_ADJUST_MAX)
> > 				oom_score_adj = OOM_SCORE_ADJ_MAX;
>
> ???

What?

> > 			 else
> > 				oom_score_adj = (oom_score_adj * OOM_SCORE_ADJ_MAX) /
> > 						-OOM_DISABLE;
> > 		}
> >
> > 		if (oom_score_adj < OOM_SCORE_ADJ_MIN ||
> > 				oom_score_adj > OOM_SCORE_ADJ_MAX)
>
> That doesn't work for depraceted_mode (sic), you'd need to test for
> OOM_ADJUST_MIN and OOM_ADJUST_MAX in that case.

Yes, probably "if (depraceted_mode)" should do more checks, I didn't try
to verify that MIN/MAX are correctly converted. I showed this code to explain
what I mean.

> There have been efforts to reuse as much of this code as possible for
> other sysctl handlers as well, you might be better off looking for

David, sorry ;) Right now I'd better try to stop the overloading of
->siglock. And, I'd like to shrink struct_signal if possible, but this
is minor.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
