Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D1BA26B0011
	for <linux-mm@kvack.org>; Tue, 10 May 2011 21:20:52 -0400 (EDT)
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
From: Joe Perches <joe@perches.com>
In-Reply-To: <1305076246.2939.67.camel@work-vm>
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org>
	 <1305073386-4810-3-git-send-email-john.stultz@linaro.org>
	 <1305075090.19586.189.camel@Joe-Laptop>  <1305076246.2939.67.camel@work-vm>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 10 May 2011 18:20:50 -0700
Message-ID: <1305076850.19586.196.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 2011-05-10 at 18:10 -0700, John Stultz wrote:
> On Tue, 2011-05-10 at 17:51 -0700, Joe Perches wrote:
> > On Tue, 2011-05-10 at 17:23 -0700, John Stultz wrote:
> > > Acessing task->comm requires proper locking. However in the past
> > > access to current->comm could be done without locking. This
> > > is no longer the case, so all comm access needs to be done
> > > while holding the comm_lock.
> > Could misuse of %ptc (not using current) cause system lockup?
> It very well could. Although I don't see other %p options tring to
> handle invalid pointers. Any suggestions on how to best handle this?

The only one I know of is ipv6 which copies a 16 byte buffer
in case the pointed to value is unaligned.  I suppose %pI6c
could be a problem or maybe %pS too, but it hasn't been in
practice.  The use of %ptc somehow seemed more error prone.

> Most users are current, so forcing the more rare
> non-current users to copy it to a buffer first and use the normal %s
> would not be of much impact.
> 
> Although I'm not sure if there's precedent for a %p value that didn't
> take a argument. Thoughts on that? Anyone else have an opinion here?

The uses of %ptc must add an argument or else gcc will complain.
I suggest you just ignore the argument value and use current.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
