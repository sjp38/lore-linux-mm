Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 604DB6B0011
	for <linux-mm@kvack.org>; Tue, 10 May 2011 21:10:58 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4B13nix006984
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:03:49 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4B1Apfi120804
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:10:51 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4AJAOGb005452
	for <linux-mm@kvack.org>; Tue, 10 May 2011 13:10:24 -0600
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
From: John Stultz <john.stultz@linaro.org>
In-Reply-To: <1305075090.19586.189.camel@Joe-Laptop>
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org>
	 <1305073386-4810-3-git-send-email-john.stultz@linaro.org>
	 <1305075090.19586.189.camel@Joe-Laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 10 May 2011 18:10:46 -0700
Message-ID: <1305076246.2939.67.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 2011-05-10 at 17:51 -0700, Joe Perches wrote:
> On Tue, 2011-05-10 at 17:23 -0700, John Stultz wrote:
> > Acessing task->comm requires proper locking. However in the past
> > access to current->comm could be done without locking. This
> > is no longer the case, so all comm access needs to be done
> > while holding the comm_lock.
> > 
> > In my attempt to clean up unprotected comm access, I've noticed
> > most comm access is done for printk output. To simpify correct
> > locking in these cases, I've introduced a new %ptc format,
> > which will safely print the corresponding task's comm.
> 
> Hi John.
> 
> Couple of tyops for Accessing and simplify in your commit message
> and a few comments on the patch.

Ah. Yes. Thanks!

> Could misuse of %ptc (not using current) cause system lockup?

It very well could. Although I don't see other %p options tring to
handle invalid pointers. Any suggestions on how to best handle this?


> > Example use:
> > printk("%ptc: unaligned epc - sending SIGBUS.\n", current);
> 
> 
> > diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> > index bc0ac6b..b9c97b8 100644
> > --- a/lib/vsprintf.c
> > +++ b/lib/vsprintf.c
> > @@ -797,6 +797,26 @@ char *uuid_string(char *buf, char *end, const u8 *addr,
> >  	return string(buf, end, uuid, spec);
> >  }
> >  
> > +static noinline_for_stack
> > +char *task_comm_string(char *buf, char *end, u8 *addr,
> > +			 struct printf_spec spec, const char *fmt)
> 
> addr should be void * not u8 *
> 
> > +{
> > +	struct task_struct *tsk = (struct task_struct *) addr;
> 
> no cast.
> 
> Maybe it'd be better to use current inside this routine and not
> pass the pointer at all.

That sounds reasonable. Most users are current, so forcing the more rare
non-current users to copy it to a buffer first and use the normal %s
would not be of much impact.

Although I'm not sure if there's precedent for a %p value that didn't
take a argument. Thoughts on that? Anyone else have an opinion here?

Thanks so much for the review and feedback!
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
