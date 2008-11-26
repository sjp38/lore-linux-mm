Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAQ8b7Rv008644
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 26 Nov 2008 17:37:07 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CD12645DD7C
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 17:37:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9149345DD78
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 17:37:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D8391DB803B
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 17:37:06 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA4CA1DB8037
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 17:37:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH/RFC] - support inheritance of mlocks across fork/exec
In-Reply-To: <1227561707.6937.61.camel@lts-notebook>
References: <1227561707.6937.61.camel@lts-notebook>
Message-Id: <20081126172913.3CB8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 26 Nov 2008 17:37:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>


only one nit.

> @@ -599,7 +602,8 @@ asmlinkage long sys_mlockall(int flags)
>  	unsigned long lock_limit;
>  	int ret = -EINVAL;
>  
> -	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE)))
> +	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE |
> +				 MCL_INHERIT | MCL_RECURSIVE)))
>  		goto out;

from patch description, I think mlockall(MCL_INHERIT) and 
mlockall(MCL_RECURSIVE) are incorrect. right?

if so, I think following likes error check is needed.

if (!(flags & (MCL_CURRENT | MCL_FUTURE)))
	goto out;

if ((flags & (MCL_INHERIT | MECL_RECURSIVE)) == MCL_RECURSIVE)
	goto out;


otherthings, looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
