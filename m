Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7100C9000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 14:23:17 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p93HwsI5029664
	for <linux-mm@kvack.org>; Mon, 3 Oct 2011 13:58:54 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p93IN3EO213406
	for <linux-mm@kvack.org>; Mon, 3 Oct 2011 14:23:04 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p93IMwXj004107
	for <linux-mm@kvack.org>; Mon, 3 Oct 2011 12:22:59 -0600
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4E89F6D1.6000502@vflare.org>
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
	 <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org>
	 <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org>
	 <4E6F7DA7.9000706@linux.vnet.ibm.com> <4E6FC8A1.8070902@vflare.org>
	 <4E72284B.2040907@linux.vnet.ibm.com>
	 <075c4e4c-a22d-47d1-ae98-31839df6e722@default 4E725109.3010609@linux.vnet.ibm.com>
	 <863f8de5-a8e5-427d-a329-e69a5402f88a@default>
	 <1317657556.16137.696.camel@nimitz>  <4E89F6D1.6000502@vflare.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 03 Oct 2011 11:22:34 -0700
Message-ID: <1317666154.16137.727.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

On Mon, 2011-10-03 at 13:54 -0400, Nitin Gupta wrote:
> I think disabling preemption on the local CPU is the cheapest we can get
> to protect PCPU buffers. We may experiment with, say, multiple buffers
> per CPU, so we end up disabling preemption only in highly improbable
> case of getting preempted just too many times exactly within critical
> section.

I guess the problem is two-fold: preempt_disable() and
local_irq_save().  

> static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
>                                 uint32_t index, struct page *page)
> {
>         struct tmem_pool *pool;
>         int ret = -1;
> 
>         BUG_ON(!irqs_disabled());

That tells me "zcache" doesn't work with interrupts on.  It seems like
awfully high-level code to have interrupts disabled.  The core page
allocator has some irq-disabling spinlock calls, but that's only really
because it has to be able to service page allocations from interrupts.
What's the high-level reason for zcache?

I'll save the discussion about preempt for when Seth posts his patch.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
