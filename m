Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id AA1156B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 16:58:15 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 24 Aug 2012 14:58:14 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 056B419D803C
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 14:57:57 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7OKvkPm192356
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 14:57:53 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7OKx83Q026138
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 14:59:08 -0600
Message-ID: <5037EAC8.6080403@linux.vnet.ibm.com>
Date: Fri, 24 Aug 2012 15:57:44 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] revert changes to zcache_do_preload()
References: <1345735991-6995-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120823205648.GA2066@barrios> <5036AA38.6010400@linux.vnet.ibm.com> <20120823232845.GE5369@bbox>
In-Reply-To: <20120823232845.GE5369@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, xiaoguangrong@linux.vnet.ibm.com

On 08/23/2012 06:28 PM, Minchan Kim wrote:
> Okay, then, why do you think the patchsets are culprit?
> I didn't look the cleanup patch series of Xiao at that time
> so I can be wrong but as I just look through patch of
> "zcache: optimize zcache_do_preload", I can't find any fault
> because zcache_put_page checks irq_disable so we don't need
> to disable preemption so it seems that patch is correct to me.
> If the race happens by preemption, BUG_ON in zcache_put_page
> should catch it.
> 
> What do you mean? Do you have any clue in your mind?
> 
>         The commits undermine an assumption made by tmem_put() in
>         the cleancache path that preemption is disabled.

I do not have an explanation right now for why these commits
expose this issue.  The patch looks like it should be fine
to me, hence my Ack at the time.

I understand and agree with you that the zcache shim
functions zcache_put_page(), zcache_get_page(),
zcache_flush_page(), and zcache_flush_object() all disable
interrupts (or make sure that interrupts are already
disabled) which implicitly disables preemption.

I'm still trying to find root cause here.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
