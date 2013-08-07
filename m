Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 506F56B0032
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 11:30:43 -0400 (EDT)
Date: Wed, 7 Aug 2013 11:30:30 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: unused swap offset / bad page map.
Message-ID: <20130807153030.GA25515@redhat.com>
References: <20130807055157.GA32278@redhat.com>
 <CAJd=RBCJv7=Qj6dPW2Ha=nq6JctnK3r7wYCAZTm=REVOZUNowg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBCJv7=Qj6dPW2Ha=nq6JctnK3r7wYCAZTm=REVOZUNowg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

On Wed, Aug 07, 2013 at 06:04:20PM +0800, Hillf Danton wrote:
 > > There were a slew of these. same trace, different addr/anon_vma/index.
 > > mapping always null.
 > >
 > Would you please run again with the debug info added?
 > ---
 > --- a/mm/swapfile.c	Wed Aug  7 17:27:22 2013
 > +++ b/mm/swapfile.c	Wed Aug  7 17:57:20 2013
 > @@ -509,6 +509,7 @@ static struct swap_info_struct *swap_inf
 >  {
 >  	struct swap_info_struct *p;
 >  	unsigned long offset, type;
 > +	int race = 0;
 > 
 >  	if (!entry.val)
 >  		goto out;
 > @@ -524,10 +525,17 @@ static struct swap_info_struct *swap_inf
 >  	if (!p->swap_map[offset])
 >  		goto bad_free;
 >  	spin_lock(&p->lock);
 > +	if (!p->swap_map[offset]) {
 > +		race = 1;
 > +		spin_unlock(&p->lock);
 > +		goto bad_free;
 > +	}
 >  	return p;
 > 
 >  bad_free:
 >  	printk(KERN_ERR "swap_free: %s%08lx\n", Unused_offset, entry.val);
 > +	if (race)
 > +		printk(KERN_ERR "but due to race\n");
 >  	goto out;
 >  bad_offset:
 >  	printk(KERN_ERR "swap_free: %s%08lx\n", Bad_offset, entry.val);
 > --

printk didn't trigger.
This time around the oom killer was going off the same time.
I'm wondering if we have some allocations somewhere in the swap code that
don't handle failure correctly.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
