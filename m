Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2D9BD6B01B1
	for <linux-mm@kvack.org>; Thu, 20 May 2010 19:49:02 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4KNmxob022932
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 21 May 2010 08:48:59 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A698545DE52
	for <linux-mm@kvack.org>; Fri, 21 May 2010 08:48:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C28045DE50
	for <linux-mm@kvack.org>; Fri, 21 May 2010 08:48:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 42152E0800B
	for <linux-mm@kvack.org>; Fri, 21 May 2010 08:48:58 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DA8CBE08005
	for <linux-mm@kvack.org>; Fri, 21 May 2010 08:48:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: RFC: dirty_ratio back to 40%
In-Reply-To: <4BF51B0A.1050901@redhat.com>
References: <4BF51B0A.1050901@redhat.com>
Message-Id: <20100521083408.1E36.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 21 May 2010 08:48:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: lwoodman@redhat.com
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

Hi

CC to Nick and Jan

> We've seen multiple performance regressions linked to the lower(20%)
> dirty_ratio.  When performing enough IO to overwhelm the background  
> flush daemons the percent of dirty pagecache memory quickly climbs 
> to the new/lower dirty_ratio value of 20%.  At that point all writing 
> processes are forced to stop and write dirty pagecache pages back to disk.  
> This causes performance regressions in several benchmarks as well as causing
> a noticeable overall sluggishness.  We all know that the dirty_ratio is
> an integrity vs performance trade-off but the file system journaling
> will cover any devastating effects in the event of a system crash.
> 
> Increasing the dirty_ratio to 40% will regain the performance loss seen
> in several benchmarks.  Whats everyone think about this???

In past, Jan Kara also claim the exactly same thing.

	Subject: [LSF/VM TOPIC] Dynamic sizing of dirty_limit
	Date: Wed, 24 Feb 2010 15:34:42 +0100

	> (*) We ended up increasing dirty_limit in SLES 11 to 40% as it used to be
	> with old kernels because customers running e.g. LDAP (using BerkelyDB
	> heavily) were complaining about performance problems.

So, I'd prefer to restore the default rather than both Redhat and SUSE apply exactly
same distro specific patch. because we can easily imazine other users will face the same
issue in the future.

	Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Nick, Jan, if the above is too old and your distro have been dropped the patch, please
correct me.

My motivation is, distro specific patches should keep minimum as far as possible.
It exactly help I and other MM developers handle MM bug report.

Thanks.


> ------------------------------------------------------------------------
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index ef27e73..645a462 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -78,7 +78,7 @@ int vm_highmem_is_dirtyable;
>  /*
>   * The generator of dirty data starts writeback at this percentage
>   */
> -int vm_dirty_ratio = 20;
> +int vm_dirty_ratio = 40;
>  
>  /*
>   * vm_dirty_bytes starts at 0 (disabled) so that it is a function of
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
