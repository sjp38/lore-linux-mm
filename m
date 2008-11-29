Subject: Re: [PATCH/RFC] - support inheritance of mlocks across fork/exec
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20081126172913.3CB8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <1227561707.6937.61.camel@lts-notebook>
	 <20081126172913.3CB8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Sat, 29 Nov 2008 17:38:39 -0500
Message-Id: <1227998319.7489.30.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-11-26 at 17:37 +0900, KOSAKI Motohiro wrote:
> only one nit.
> 
> > @@ -599,7 +602,8 @@ asmlinkage long sys_mlockall(int flags)
> >  	unsigned long lock_limit;
> >  	int ret = -EINVAL;
> >  
> > -	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE)))
> > +	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE |
> > +				 MCL_INHERIT | MCL_RECURSIVE)))
> >  		goto out;
> 
> from patch description, I think mlockall(MCL_INHERIT) and 
> mlockall(MCL_RECURSIVE) are incorrect. right?
> 
> if so, I think following likes error check is needed.
> 
> if (!(flags & (MCL_CURRENT | MCL_FUTURE)))
> 	goto out;
> 
> if ((flags & (MCL_INHERIT | MECL_RECURSIVE)) == MCL_RECURSIVE)
> 	goto out;
> 

Hello, Kosaki-san:

Thanks for looking at this.  I think you mean that:

1) don't allow MCL_INHERIT | MCL_RECURSIVE without either MCL_CURRENT or
MCL_FUTURE, and

2) MCL_RECURSIVE without MCL_INHERIT does not make sense, either.

Is this correct?

I guess I agree with you.  As is stands, my patch would allow
MCL_INHERIT[|MCL_RECURSIVE] to sneak through with neither MCL_CURRENT
nor MCL_FUTURE set.  Looks like this would result in mlock_fixup() being
called with a newflags that does not containing VM_LOCKED.  This would
be treated as munlockall().   Not good.  Your first check would catch
this.

The second condition would be a no-op, I think.  We only look at look
for MCL_RECURSIVE in mm->mcl_inherit when mcl_inherit is non-zero; and
we only set mcl_inherit when MCL_INHERIT is specified.  But, if the
caller specified MCL_RECURSIVE, they probably intended something to
happen, and since it won't, best to return an error.

I'll fix this up and send it out to the wider distribution that Andrew
requested.

Thanks, again.
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
