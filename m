Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 68CE58D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:29:20 -0500 (EST)
Received: from [10.10.7.10] by digidescorp.com (Cipher SSLv3:RC4-MD5:128) (MDaemon PRO v10.1.1)
	with ESMTP id md50001483616.msg
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 08:29:15 -0600
Subject: Re: [PATCH][RESEND] nommu: yield CPU periodically while disposing
 large VM
From: "Steven J. Magnani" <steve@digidescorp.com>
Reply-To: steve@digidescorp.com
In-Reply-To: <20101111184059.5744a42f.akpm@linux-foundation.org>
References: <1289507596-17613-1-git-send-email-steve@digidescorp.com>
	 <20101111184059.5744a42f.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 15 Nov 2010 08:29:11 -0600
Message-ID: <1289831351.2524.15.camel@iscandar.digidescorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Ungerer <gerg@snapgear.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-11-11 at 18:40 -0800, Andrew Morton wrote:
> On Thu, 11 Nov 2010 14:33:16 -0600 "Steven J. Magnani" <steve@digidescorp.com> wrote:
> 
> > --- a/mm/nommu.c	2010-10-21 07:42:23.000000000 -0500
> > +++ b/mm/nommu.c	2010-10-21 07:46:50.000000000 -0500
> > @@ -1656,6 +1656,7 @@ SYSCALL_DEFINE2(munmap, unsigned long, a
> >  void exit_mmap(struct mm_struct *mm)
> >  {
> >  	struct vm_area_struct *vma;
> > +	unsigned long next_yield = jiffies + HZ;
> >  
> >  	if (!mm)
> >  		return;
> > @@ -1668,6 +1669,11 @@ void exit_mmap(struct mm_struct *mm)
> >  		mm->mmap = vma->vm_next;
> >  		delete_vma_from_mm(vma);
> >  		delete_vma(mm, vma);
> > +		/* Yield periodically to prevent watchdog timeout */
> > +		if (time_after(jiffies, next_yield)) {
> > +			cond_resched();
> > +			next_yield = jiffies + HZ;
> > +		}
> >  	}
> >  
> >  	kleave("");
> 
[snip]
> cond_resched() is pretty efficient and one second is still
> a very long time.  I suspect you don't need the ratelimiting at all?

Probably not, but the issue was that disposal of "large" VMs can starve
the system. Since these are not the norm (otherwise this would have been
fixed long ago) I was attempting to limit the impact on more
"normal"-sized VMs. Responsiveness is not great with a one-second
ratelimit, and as KOSAKI Motohiro points out this fix won't work on
systems with short watchdog intervals. I assumed that these were not
common.

As efficient as schedule() may be, it still scares me to call it on
reclaim of every block of memory allocated by a terminating process,
particularly on the relatively slow processors that inhabit NOMMU land.
It wasn't obvious to me that it has a quick exit. But since we are
talking about sharing the CPU with other processes perhaps this is only
an issue in an OOM scenario, when fast reclaim might be more important.

I can certainly respin the patch to call cond_resched() unconditionally
if that's the consensus.

Regards,
------------------------------------------------------------------------
 Steven J. Magnani               "I claim this network for MARS!
 www.digidescorp.com              Earthling, return my space modulator!"

 #include <standard.disclaimer>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
