Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id A8C6B6B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 15:18:18 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 11 Jul 2012 13:18:14 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 2FE381FF004C
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 19:17:24 +0000 (WET)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6BJH6bN042120
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 13:17:17 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6BJH4FH030982
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 13:17:04 -0600
Message-ID: <4FFDD12B.1050909@linux.vnet.ibm.com>
Date: Wed, 11 Jul 2012 14:16:59 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] zsmalloc improvements
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com> <4FFD2524.2050300@kernel.org>
In-Reply-To: <4FFD2524.2050300@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 07/11/2012 02:03 AM, Minchan Kim wrote:
> Today, I tested zsmapbench in my embedded board(ARM).
> tlb-flush is 30% faster than copy-based so it's always not win.
> I think it depends on CPU speed/cache size.

After you pointed this out, I decided to test this on my
Raspberry Pi, the only ARM system I have that is open enough
for me to work with.

I pulled some of the cycle counting stuff out of
arch/arm/kernel/perf_event_v6.c.  I've pushed that code to
the github repo.

git://github.com/spartacus06/zsmapbench.git

My results were in agreement with your findings.  I got 2040
cycles/map for the copy method and 947 cycles/map for the
page-table method.  I think memory speed is playing a big
roll in the difference.

I agree that the page-table method should be restored since
the performance difference is so significant on ARM, a
platform that benefits a lot from memory compression IMHO.

Still, the question remains how to implement the selection
logic, since not all archs that support the page-table
method will necessarily perform better with it.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
