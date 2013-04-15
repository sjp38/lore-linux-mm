Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 87D586B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 16:58:07 -0400 (EDT)
Date: Mon, 15 Apr 2013 13:58:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: Check more strictly to avoid ULLONG overflow by
 PAGE_ALIGN
Message-Id: <20130415135805.c552511917b0dbe113388acb@linux-foundation.org>
In-Reply-To: <20130412171108.d3ef3e2d66e9c1bfcf69467c@mxp.nes.nec.co.jp>
References: <1365748763-4350-1-git-send-email-handai.szj@taobao.com>
	<20130412171108.d3ef3e2d66e9c1bfcf69467c@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Sha Zhengju <handai.szj@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, jeff.liu@oracle.com, Sha Zhengju <handai.szj@taobao.com>

On Fri, 12 Apr 2013 17:11:08 +0900 Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > --- a/include/linux/res_counter.h
> > +++ b/include/linux/res_counter.h
> > @@ -54,7 +54,7 @@ struct res_counter {
> >  	struct res_counter *parent;
> >  };
> >  
> > -#define RESOURCE_MAX (unsigned long long)LLONG_MAX
> > +#define RESOURCE_MAX (unsigned long long)ULLONG_MAX
> >  
> 
> I don't think it's a good idea to change a user-visible value.

The old value was a mistake, surely.

RESOURCE_MAX shouldn't be in this header file - that is far too general
a name.  I suggest the definition be moved to res_counter.c.  And the
(unsigned long long) cast is surely unneeded if we're to use
ULLONG_MAX.

> >  /**
> >   * Helpers to interact with userspace
> > diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> > index ff55247..6c35310 100644
> > --- a/kernel/res_counter.c
> > +++ b/kernel/res_counter.c
> > @@ -195,6 +195,12 @@ int res_counter_memparse_write_strategy(const char *buf,
> >  	if (*end != '\0')
> >  		return -EINVAL;
> >  
> > -	*res = PAGE_ALIGN(*res);
> > +	/* Since PAGE_ALIGN is aligning up(the next page boundary),
> > +	 * check the left space to avoid overflow to 0. */
> > +	if (RESOURCE_MAX - *res < PAGE_SIZE - 1)
> > +		*res = RESOURCE_MAX;
> > +	else
> > +		*res = PAGE_ALIGN(*res);
> > +
> 
> Current interface seems strange because we can set a bigger value than
> the value which means "unlimited".

I'm not sure what you mean by this?

> So, how about some thing like:
> 
> 	if (*res > RESOURCE_MAX)
> 		return -EINVAL;
> 	if (*res > PAGE_ALIGN(RESOURCE_MAX) - PAGE_SIZE)
> 		*res = RESOURCE_MAX;
> 	else
> 		*res = PAGE_ALIGN(*res);
> 

The first thing I'd do to res_counter_memparse_write_strategy() is to
rename its second arg to `resp' then add a local called `res'.  Because
that function dereferences res far too often.

Then,

-	*res = PAGE_ALIGN(*res);
	if (PAGE_ALIGN(res) >= res)
		res = PAGE_ALIGN(res);
	else
		res = RESOURCE_MAX;	/* PAGE_ALIGN wrapped to zero */

	*resp = res;
	return 0;
	
	

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
