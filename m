Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 07BCA6B004F
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 14:14:55 -0500 (EST)
Date: Tue, 3 Feb 2009 11:14:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: /proc/sys/vm/drop_caches: add error handling
Message-Id: <20090203111447.41e2022c.akpm@linux-foundation.org>
In-Reply-To: <20090203204456.ECA3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090203113319.GA2022@elf.ucw.cz>
	<20090203204456.ECA3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: pavel@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  3 Feb 2009 20:47:56 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > 
> > Document that drop_caches is unsafe, and add error checking so that it
> > bails out on invalid inputs. [Note that this was triggered by Android
> > trying to use it in production, and incidentally writing invalid
> > value...]
> 
> Yup. good patch.
> 
> > -	return 0;
> > +	int res;
> > +	res = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
> > +	if (res)
> > +		return res;
> > +	if (!write)
> > +		return res;
> > +	if (sysctl_drop_caches & ~3)
> > +		return -EINVAL;
> > +	if (sysctl_drop_caches & 1)
> > +		drop_pagecache();
> > +	if (sysctl_drop_caches & 2)
> > +		drop_slab();
> > +	return res;
> >  }
> 
> I think following is clarify more.
> 
> 	res = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
> 	if (res)
> 		return res;
> 	if (!write)
> 		return 0;
> 	if (sysctl_drop_caches & ~3)
> 		return -EINVAL;
> 	if (sysctl_drop_caches & 1)
> 		drop_pagecache();
> 	if (sysctl_drop_caches & 2)
> 		drop_slab();
> 	return 0;
> 
> 
> otherthings, _very_ looks good to me. :)
> 

For better or for worse, my intent here was to be
future-back-compatible.  So if we later add new flags, and people write
code which uses those new flags, that code won't break on old kernels.

Probably that wasn't a very good idea, and such userspace code isn't
very good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
