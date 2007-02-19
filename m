Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l1JAtJiY171718
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 21:55:19 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JAh0on143376
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 21:43:00 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JAdTN8018807
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 21:39:30 +1100
Message-ID: <45D97E5E.7060603@in.ibm.com>
Date: Mon, 19 Feb 2007 16:09:26 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH][0/4] Memory controller (RSS Control)
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop> <20070219005441.7fa0eccc.akpm@linux-foundation.org> <6599ad830702190106m3f391de4x170326fef2e4872@mail.gmail.com>
In-Reply-To: <6599ad830702190106m3f391de4x170326fef2e4872@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, xemul@sw.ru, linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On 2/19/07, Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>> Alas, I fear this might have quite bad worst-case behaviour.  One small
>> container which is under constant memory pressure will churn the
>> system-wide LRUs like mad, and will consume rather a lot of system time.
>> So it's a point at which container A can deleteriously affect things 
>> which
>> are running in other containers, which is exactly what we're supposed to
>> not do.
> 
> I think it's OK for a container to consume lots of system time during
> reclaim, as long as we can account that time to the container involved
> (i.e. if it's done during direct reclaim rather than by something like
> kswapd).
> 
> Churning the LRU could well be bad though, I agree.
> 

I completely agree with you on reclaim consuming time.

Churning the LRU can be avoided by the means I mentioned before

1. Add a container pointer (per page struct), it is also
    useful for the page cache controller
2. Check if the page belongs to a particular container before
    the list_del(&page->lru), so that those pages can be skipped.
3. Use a double LRU list by overloading the lru list_head of
    struct page.

> Paul
> 


-- 
	Warm Regards,
	Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
