Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PKL2p0028725
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 16:21:02 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PKL2ae043958
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 14:21:02 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PKL1Hi025066
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 14:21:02 -0600
Subject: Re: RFC/POC Make Page Tables Relocatable
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <d43160c70710251310o7113f1cbo68872365c193e94c@mail.gmail.com>
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
	 <1193330774.4039.136.camel@localhost>
	 <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com>
	 <1193335725.24087.19.camel@localhost>
	 <d43160c70710251144t172cfd1exef99e0d53fb9be73@mail.gmail.com>
	 <1193340182.24087.54.camel@localhost>
	 <d43160c70710251253j2f4e640uc0ccc0432738f55c@mail.gmail.com>
	 <1193342419.24087.71.camel@localhost>
	 <d43160c70710251310o7113f1cbo68872365c193e94c@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 13:20:59 -0700
Message-Id: <1193343659.24087.82.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-mm@kvack.org, Mel Gorman <MELGOR@ie.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 16:10 -0400, Ross Biro wrote:
> On 10/25/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> > How would it get freed?
> 
> The process exists or ummaps the range of memory.  The relocation code
> is likely called on a different cpu in the node and currently has no
> way to pin the data in memory.  Perhaps finding a way to pin the page
> would help the other locking issues, so it might solve lots of
> problems.

Taking a simple reference count on the page will keep it from getting
freed.  It won't keep it from getting _unused_, but it will against
getting actually freed back to the allocator.

But, if you get to this point and you have a page and the only person
with a reference to it is you, it _should_ be completely empty of pte
entries.  They were all cleared at zap_pte_range() time.

You need other mechanisms in place, anyway, to keep ptes from being
instantiated or shot down while you're doing the copy itself.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
