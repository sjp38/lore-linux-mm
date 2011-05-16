Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AA7076B0022
	for <linux-mm@kvack.org>; Mon, 16 May 2011 19:10:43 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4GMrbGZ017760
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:53:37 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4GNAbhU158004
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:10:37 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4GHAAWq017306
	for <linux-mm@kvack.org>; Mon, 16 May 2011 11:10:10 -0600
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
From: John Stultz <john.stultz@linaro.org>
In-Reply-To: <4DD19D10.3000201@gmail.com>
References: <1305580757-13175-1-git-send-email-john.stultz@linaro.org>
	 <1305580757-13175-3-git-send-email-john.stultz@linaro.org>
	 <4DD19D10.3000201@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 16 May 2011 16:10:32 -0700
Message-ID: <1305587432.2915.57.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, 2011-05-16 at 23:54 +0200, Jiri Slaby wrote:
> On 05/16/2011 11:19 PM, John Stultz wrote:
> > Accessing task->comm requires proper locking. However in the past
> > access to current->comm could be done without locking. This
> > is no longer the case, so all comm access needs to be done
> > while holding the comm_lock.
> > 
> > In my attempt to clean up unprotected comm access, I've noticed
> > most comm access is done for printk output. To simplify correct
> > locking in these cases, I've introduced a new %ptc format,
> > which will print the corresponding task's comm.
> > 
> > Example use:
> > printk("%ptc: unaligned epc - sending SIGBUS.\n", current);
> > 
> > CC: Ted Ts'o <tytso@mit.edu>
> > CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > CC: David Rientjes <rientjes@google.com>
> > CC: Dave Hansen <dave@linux.vnet.ibm.com>
> > CC: Andrew Morton <akpm@linux-foundation.org>
> > CC: linux-mm@kvack.org
> > Signed-off-by: John Stultz <john.stultz@linaro.org>
> > ---
> >  lib/vsprintf.c |   24 ++++++++++++++++++++++++
> >  1 files changed, 24 insertions(+), 0 deletions(-)
> > 
> > diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> > index bc0ac6b..b7a9953 100644
> > --- a/lib/vsprintf.c
> > +++ b/lib/vsprintf.c
> > @@ -797,6 +797,23 @@ char *uuid_string(char *buf, char *end, const u8 *addr,
> >  	return string(buf, end, uuid, spec);
> >  }
> >  
> > +static noinline_for_stack
> 
> Actually, why noinline? Did your previous version have there some
> TASK_COMM_LEN buffer or anything on stack which is not there anymore?

No, I was just following how almost all of the pointer() called
functions were declared.

But with two pointers and a long, I add more then ip6_string() has on
the stack, which uses the same notation.

But I can drop that bit if there's really no need for it.

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
