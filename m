Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EF4206B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 13:23:20 -0400 (EDT)
Date: Thu, 1 Apr 2010 19:23:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf10-pc] [LSF/MM TOPIC][ATTEND] How to fix direct-io vs fork
 issue
Message-ID: <20100401172315.GB5825@random.random>
References: <20100401154419.BE4C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100401154419.BE4C.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, lsf10-pc@lists.linuxfoundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 01, 2010 at 04:41:21PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> I would like to ask about one difficult problem about people.
> currently, direct-io implementation has big sick about VM interaction.
> it assume get_user_pages() can pin the target pages in page's mm. but 
> it doesn't. fork and cow might replace the relationship between task's mm
> and pages. therefore cuncurrent directio and fork can corrupt the process's
> data.
> 
> There was two proposal in past day. 1) introduce new page flags 2)
> introduce new lock. unfortunately both proposal got strong complaint
> from other developers. then, we still have this issue.

There were two races forward and backwards, each one needed its own
fix. I still think it needs fixing. Any way we fix it is fine with me
and better than the bug.

Said that I think fixing it outside of gup/fork internals is messy and
much slower as it requires to add locking. If one wants to go down
that route, first thing needed would be to convert all put_page points
that releases any gup pin to a put_gup_page or something like
that. Only _then_ it'd be feasible to fix it that way, and all gup
users requires conversion first. Just adding a spin_unlock before
put_page is a mess, besides the unpinning can happen from
dma-irq-completion handlers so requiring irq locks to be safe, each
user is different. I doubt this is a good way to fix it but still if
someone is interested to identify all put_pages that releases gup pins
(possibly also marking specials the put_page releasing pins from irq
or bh atomic context if there's any), that could be an useful effort
for the long run as it'd allow to improve the gup API somehow in the
future (not for these two bugs).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
