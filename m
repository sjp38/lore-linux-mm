Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CD9696B0055
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 17:27:53 -0400 (EDT)
Date: Thu, 25 Jun 2009 14:28:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] memcg: cgroup fix rmdir hang
Message-Id: <20090625142809.ac6b7b85.akpm@linux-foundation.org>
In-Reply-To: <20090623160720.36230fa2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090623160720.36230fa2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jun 2009 16:07:20 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> previous discussion was this => http://marc.info/?t=124478543600001&r=1&w=2
> 
> This patch tries to fix problem as
>   - rmdir can sleep very very long if swap entry is shared between multiple
>     cgroups
> 
> Now, cgroup's rmdir path does following
> 
> ==
> again:
> 	check there are no tasks and children group.
> 	call pre_destroy()
> 	check css's refcnt
> 	if (refcnt > 0) {
> 		sleep until css's refcnt goes down to 0.
> 		goto again
> 	}
> ==
> 
> Unfortunately, memory cgroup does following at charge.
> 
> 	css_get(&memcg->css)
> 	....
> 	charge(memcg) (increase USAGE)
> 	...
> And this "memcg" is not necessary to include the caller, task.
> 
> pre_destroy() tries to reduce memory usage until USAGE goes down to 0.
> Then, there is a race that
> 	- css's refcnt > 0 (and memcg's usage > 0)
> 	- rmdir() caller sleeps until css->refcnt goes down 0.
> 	- But to make css->refcnt be 0, pre_destroy() should be called again.
> 
> This patch tries to fix this in asyhcnrounos way (i.e. without big lock.)
> Any comments are welcome.
> 

Do you believe that these fixes should be backported into 2.6.30.x?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
