Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 252B76B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 10:28:05 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 19 Jun 2012 08:28:02 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id C52853E4006F
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 14:27:44 +0000 (WET)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5JERNWf017462
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 08:27:23 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5JERXGC023068
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 08:27:33 -0600
Message-ID: <4FE08C1A.2020308@linux.vnet.ibm.com>
Date: Tue, 19 Jun 2012 09:26:34 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] zcache: fix preemptable memory allocation in atomic
 context
References: <4FE0392E.3090300@linux.vnet.ibm.com>
In-Reply-To: <4FE0392E.3090300@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 06/19/2012 03:32 AM, Xiao Guangrong wrote:

> zcache_do_preload uses ZCACHE_GFP_MASK to allocate memory that will be sleep,
> but zcache_do_preload is called in zcache_put_page where IRQ is disabled
> 
> Fix it by use GFP_ATOMIC flag


Did you get a might_sleep warning on this?  I haven't seen this being an
issue.

GFP_ATOMIC only modifies the existing mask to allow allocation use the
emergency pool.  It is __GFP_WAIT not being set that prevents sleep.  We
don't want to use the emergency pool since we make large, long lived
allocations with this mask.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
