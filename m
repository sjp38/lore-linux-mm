Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 683BE6B0047
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:47:58 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3UDh0Ic029618
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 07:43:00 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3UDmZN4237662
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 07:48:37 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3UDmP5m011239
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 07:48:26 -0600
Subject: Re: [RFC] Replace the watermark-related union in struct zone with
	a watermark[] array
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090430133524.GC21997@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	 <1240408407-21848-19-git-send-email-mel@csn.ul.ie>
	 <alpine.DEB.2.00.0904221251350.14558@chino.kir.corp.google.com>
	 <20090427170054.GE912@csn.ul.ie>
	 <alpine.DEB.2.00.0904271340320.11972@chino.kir.corp.google.com>
	 <20090427205400.GA23510@csn.ul.ie>
	 <alpine.DEB.2.00.0904271400450.11972@chino.kir.corp.google.com>
	 <20090430133524.GC21997@csn.ul.ie>
Content-Type: text/plain
Date: Thu, 30 Apr 2009 06:48:20 -0700
Message-Id: <1241099300.29485.96.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-04-30 at 14:35 +0100, Mel Gorman wrote:
> I think what you're saying that you'd be ok with
> 
> zone_wmark_min(z)
> zone_wmark_low(z)
> zone_wmark_high(z)
> 
> and z->pages_mark[WMARK_MIN] =
> and z->pages_mark[WMARK_LOW] =
> and z->pages_mark[WMARK_HIGH] =
> 
> ?
> 
> Is that a significant improvement over what the patch currently does? To
> me, it seems more verbose.

Either way, there are _relatively_ few users.  From a quick cscope, it
appears setup_per_zone_pages_min() is really the heaviest user assigning
them.

Personally, I do like having the 'wmark' or something similar in the
function or structure member names.  But, I also like having the units
in there as well.  There's probably not room for both, though.  I'm fine
with the naming you have above.  The only thing I might consider is
removing 'zone_' from the function names since it's implied from the
variable name:

	min_wmark_pages(z)

The 'z->pages_mark[WMARK_*]' form is ugly, but it should be basically
restricted to use in setup_per_zone_pages_min().  I think that means we
don't need set_foo() functions because of a lack of use sites.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
