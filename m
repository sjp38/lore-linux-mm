Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 971FE90010B
	for <linux-mm@kvack.org>; Thu, 12 May 2011 18:10:21 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p4CMAGYg009433
	for <linux-mm@kvack.org>; Thu, 12 May 2011 15:10:16 -0700
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by wpaz24.hot.corp.google.com with ESMTP id p4CM9nQO004391
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 15:10:15 -0700
Received: by pzk27 with SMTP id 27so1145963pzk.41
        for <linux-mm@kvack.org>; Thu, 12 May 2011 15:10:15 -0700 (PDT)
Date: Thu, 12 May 2011 15:10:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
In-Reply-To: <1305076246.2939.67.camel@work-vm>
Message-ID: <alpine.DEB.2.00.1105121508030.9130@chino.kir.corp.google.com>
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org> <1305073386-4810-3-git-send-email-john.stultz@linaro.org> <1305075090.19586.189.camel@Joe-Laptop> <1305076246.2939.67.camel@work-vm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Joe Perches <joe@perches.com>, LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 10 May 2011, John Stultz wrote:

> > > diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> > > index bc0ac6b..b9c97b8 100644
> > > --- a/lib/vsprintf.c
> > > +++ b/lib/vsprintf.c
> > > @@ -797,6 +797,26 @@ char *uuid_string(char *buf, char *end, const u8 *addr,
> > >  	return string(buf, end, uuid, spec);
> > >  }
> > >  
> > > +static noinline_for_stack
> > > +char *task_comm_string(char *buf, char *end, u8 *addr,
> > > +			 struct printf_spec spec, const char *fmt)
> > 
> > addr should be void * not u8 *
> > 
> > > +{
> > > +	struct task_struct *tsk = (struct task_struct *) addr;
> > 
> > no cast.
> > 
> > Maybe it'd be better to use current inside this routine and not
> > pass the pointer at all.
> 
> That sounds reasonable. Most users are current, so forcing the more rare
> non-current users to copy it to a buffer first and use the normal %s
> would not be of much impact.
> 

Please still require an argument, otherwise the oom killer (which could 
potentially called right before a stack overflow) would be required to use 
buffers for the commands printed in the tasklist dump.

> Although I'm not sure if there's precedent for a %p value that didn't
> take a argument. Thoughts on that? Anyone else have an opinion here?
> 

After the cleanups are addressed:

	Acked-by: David Rientjes <rientjes@google.com>

It would have been nice if we could force %ptc to expect a 
struct task_struct * rather than a void *, however.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
