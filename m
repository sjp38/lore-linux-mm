Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EF70B6B0198
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 22:34:49 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2F2Yloo005187
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 15 Mar 2010 11:34:47 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E8FE645DE51
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:34:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C742245DE4E
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:34:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AE2FEE18003
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:34:46 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 628AEE18001
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:34:46 +0900 (JST)
Date: Mon, 15 Mar 2010 11:31:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 5/5] memcg: dirty pages instrumentation
Message-Id: <20100315113104.b208571c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1268609202-15581-6-git-send-email-arighi@develer.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<1268609202-15581-6-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Mar 2010 00:26:42 +0100
Andrea Righi <arighi@develer.com> wrote:

> Apply the cgroup dirty pages accounting and limiting infrastructure to
> the opportune kernel functions.
> 
> [ NOTE: for now do not account WritebackTmp pages (FUSE) and NILFS2
> bounce pages. This depends on charging also bounce pages per cgroup. ]
> 
> As a bonus, make determine_dirtyable_memory() static again: this
> function isn't used anymore outside page writeback.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

A nitpick.

> @@ -660,6 +705,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>  	unsigned long dirty_thresh;
>  
>          for ( ; ; ) {
> +		unsigned long dirty;
> +
>  		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
>  
>                  /*
> @@ -668,10 +715,10 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>                   */
>                  dirty_thresh += dirty_thresh / 10;      /* wheeee... */
>  
> -                if (global_page_state(NR_UNSTABLE_NFS) +
> -			global_page_state(NR_WRITEBACK) <= dirty_thresh)
> -                        	break;
> -                congestion_wait(BLK_RW_ASYNC, HZ/10);
> +		dirty = get_dirty_writeback_pages();
> +		if (dirty <= dirty_thresh)
> +			break;
> +		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		/*
>  		 * The caller might hold locks which can prevent IO completion

"dirty" seems not to be necessary.
	if (get_dirty_writeback_pages() < dirty_thresh) ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
