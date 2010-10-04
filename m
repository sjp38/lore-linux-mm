Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C75D16B004A
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 15:43:37 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o94JhW3R019527
	for <linux-mm@kvack.org>; Mon, 4 Oct 2010 12:43:32 -0700
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by wpaz9.hot.corp.google.com with ESMTP id o94Jgw6p012822
	for <linux-mm@kvack.org>; Mon, 4 Oct 2010 12:43:31 -0700
Received: by pwj1 with SMTP id 1so1376967pwj.20
        for <linux-mm@kvack.org>; Mon, 04 Oct 2010 12:43:30 -0700 (PDT)
Date: Mon, 4 Oct 2010 12:43:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad forfile/email/web
 servers
In-Reply-To: <20101004211112.E8B1.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010041242330.29747@chino.kir.corp.google.com>
References: <20100927110049.6B31.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009270828510.7000@router.home> <20101004211112.E8B1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, Mel Gorman <mel@csn.ul.ie>, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Oct 2010, KOSAKI Motohiro wrote:

> Recently, Robert Mueller reported zone_reclaim_mode doesn't work
> properly on his new NUMA server (Dual Xeon E5520 + Intel S5520UR MB).
> He is using Cyrus IMAPd and it's built on a very traditional
> single-process model.
> 
>   * a master process which reads config files and manages the other
>     process
>   * multiple imapd processes, one per connection
>   * multiple pop3d processes, one per connection
>   * multiple lmtpd processes, one per connection
>   * periodical "cleanup" processes.
> 
> Then, there are thousands of independent processes. The problem is,
> recent Intel motherboard turn on zone_reclaim_mode by default and
> traditional prefork model software don't work fine on it.
> Unfortunatelly, Such model is still typical one even though 21th
> century. We can't ignore them.
> 
> This patch raise zone_reclaim_mode threshold to 30. 30 don't have
> specific meaning. but 20 mean one-hop QPI/Hypertransport and such
> relatively cheap 2-4 socket machine are often used for tradiotional
> server as above. The intention is, their machine don't use
> zone_reclaim_mode.
> 
> Note: ia64 and Power have arch specific RECLAIM_DISTANCE definition.
> then this patch doesn't change such high-end NUMA machine behavior.
> 
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Bron Gondwana <brong@fastmail.fm>
> Cc: Robert Mueller <robm@fastmail.fm>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

We already do this, but I guess it never got pushed to mainline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
