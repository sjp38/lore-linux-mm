Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 05ECB6B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 13:36:28 -0500 (EST)
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 8 Feb 2012 13:36:27 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 7176438C807C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 13:28:49 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q18ISnoQ160880
	for <linux-mm@kvack.org>; Wed, 8 Feb 2012 13:28:49 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q18ISnso017879
	for <linux-mm@kvack.org>; Wed, 8 Feb 2012 13:28:49 -0500
Message-ID: <4F32BEDC.6030502@linux.vnet.ibm.com>
Date: Wed, 08 Feb 2012 10:28:44 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation library
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com> <1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com> <4F21A5AF.6010605@linux.vnet.ibm.com> <4F300D41.5050105@linux.vnet.ibm.com> <4F32A55E.8010401@linux.vnet.ibm.com> <4F32B6A4.8030702@vflare.org>
In-Reply-To: <4F32B6A4.8030702@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>, Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 02/08/2012 09:53 AM, Nitin Gupta wrote:
> vmap() is not just slower but also does memory allocations at various
> places. Under memory pressure, this may cause failure in reading a
> stored object just because we failed to map it. Also, it allocates VA
> region each time its called which is a real big waste when we can simply
> pre-allocate 2 * PAGE_SIZE'ed VA regions (per-cpu).

Yeah, vmap() is a bit heavy-handed.  I'm just loathe to go mucking
around in the low-level pagetables too much.  Just seems like there'll
be a ton of pitfalls, like arch-specific TLB flushing, and it _seems_
like one of the existing kernel mechanisms should work.

I guess if you've exhaustively explored all of the existing kernel
mapping mechanisms and found none of them to work, and none of them to
be in any way suitably adaptable to your use, you should go ahead and
roll your own.  I guess you do at least use alloc_vm_area().  What made
map_vm_area() unsuitable for your needs?  If you're remapping, you
should at least be guaranteed not to have to allocate pte pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
