Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 8B1276B0109
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 06:29:40 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so8682516obb.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 03:29:39 -0700 (PDT)
Message-ID: <1339410650.4999.38.camel@lappy>
Subject: Re: [PATCH v3 04/10] mm: frontswap: split out
 __frontswap_unuse_pages
From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon, 11 Jun 2012 12:30:50 +0200
In-Reply-To: <4FD5856C.5060708@kernel.org>
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
	 <1339325468-30614-5-git-send-email-levinsasha928@gmail.com>
	 <4FD5856C.5060708@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2012-06-11 at 14:43 +0900, Minchan Kim wrote:
> On 06/10/2012 07:51 PM, Sasha Levin wrote:
> 
> > An attempt at making frontswap_shrink shorter and more readable. This patch
> > splits out walking through the swap list to find an entry with enough
> > pages to unuse.
> > 
> > Also, assert that the internal __frontswap_unuse_pages is called under swap
> > lock, since that part of code was previously directly happen inside the lock.
> > 
> > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> > ---
> >  mm/frontswap.c |   59 +++++++++++++++++++++++++++++++++++++-------------------
> >  1 files changed, 39 insertions(+), 20 deletions(-)
> > 
> > diff --git a/mm/frontswap.c b/mm/frontswap.c
> > index 5faf840..faa43b7 100644
> > --- a/mm/frontswap.c
> > +++ b/mm/frontswap.c
> > @@ -230,6 +230,41 @@ static unsigned long __frontswap_curr_pages(void)
> >  	return totalpages;
> >  }
> >  
> > +static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
> > +					int *swapid)
> 
> 
> Normally, we use "unsigned int type" instead of swapid.
> I admit the naming is rather awkward but that should be another patch.
> So let's keep consistency with swap subsystem.

I was staying consistent with the naming in mm/frontswap.c. I'll add an
extra patch to modify it to be similar to what's being used in the rest
of the swap subsystem.

> > +{
> > +	int ret = -EINVAL;
> > +	struct swap_info_struct *si = NULL;
> > +	int si_frontswap_pages;
> > +	unsigned long total_pages_to_unuse = total;
> > +	unsigned long pages = 0, pages_to_unuse = 0;
> > +	int type;
> > +
> > +	assert_spin_locked(&swap_lock);
> 
> 
> Normally, we should use this assertion when we can't find swap_lock is hold or not easily
> by complicated call depth or unexpected use-case like general function.
> But I expect this function's caller is very limited, not complicated.
> Just comment write down isn't enough?

Is there a reason not to do it though? Debugging a case where this
function is called without a swaplock and causes corruption won't be
easy.

> > +	for (type = swap_list.head; type >= 0; type = si->next) {
> > +		si = swap_info[type];
> > +		si_frontswap_pages = atomic_read(&si->frontswap_pages);
> > +		if (total_pages_to_unuse < si_frontswap_pages) {
> > +			pages = pages_to_unuse = total_pages_to_unuse;
> > +		} else {
> > +			pages = si_frontswap_pages;
> > +			pages_to_unuse = 0; /* unuse all */
> > +		}
> > +		/* ensure there is enough RAM to fetch pages from frontswap */
> > +		if (security_vm_enough_memory_mm(current->mm, pages)) {
> > +			ret = -ENOMEM;
> 
> 
> Nipick:
> I am not sure detailed error returning would be good.
> Caller doesn't matter it now but it can consider it in future.
> Hmm, 

Is there a reason to avoid returning a meaningful error when it's pretty
easy?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
