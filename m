Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 41F196B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 16:49:20 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so19545595pac.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:49:19 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id be10si22960302pad.11.2015.07.24.13.49.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 13:49:18 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so19545390pac.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:49:18 -0700 (PDT)
Date: Fri, 24 Jul 2015 13:49:14 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] hugetlb: cond_resched for set_max_huge_pages and
 follow_hugetlb_page
Message-ID: <20150724204914.GE3458@Sligo.logfs.org>
References: <1437688476-3399-1-git-send-email-sbaugh@catern.com>
 <alpine.DEB.2.10.1507231506050.6965@chino.kir.corp.google.com>
 <20150723223651.GH24876@Sligo.logfs.org>
 <alpine.DEB.2.10.1507231550390.7871@chino.kir.corp.google.com>
 <20150723230928.GI24876@Sligo.logfs.org>
 <alpine.DEB.2.10.1507241237420.5215@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1507241237420.5215@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Spencer Baugh <sbaugh@catern.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Mike Kravetz <mike.kravetz@oracle.com>, Luiz Capitulino <lcapitulino@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, Spencer Baugh <Spencer.baugh@purestorage.com>, Joern Engel <joern@logfs.org>

On Fri, Jul 24, 2015 at 12:49:14PM -0700, David Rientjes wrote:
> 
> I don't see the cond_resched() you propose to add, but the need for it is 
> obvious with a large user-written nr_hugepages in the above loop.
> 
> The suggestion is to check the conditional, reschedule if needed (and if 
> so, recheck the conditional), and then allocate.
> 
> Your third option looks fine and the best place to do the cond_resched().  
> I was looking at your second option when I responded and compared it to 
> the first.  We don't want to do cond_resched() immediately before or after 
> the allocation, the net result is the same: we may be pointlessly 
> allocating the hugepage and each hugepage allocation can be very 
> heavyweight.
> 
> So I agree with your third option from the previous email.

All right.  We are talking about the same thing now.  But I previously
argued that the pointless allocation will a) not impact correctness and
b) be so rare as to not impact performance.  The problem with the third
option is that it adds a bit of constant overhead all the time to
compensate for not doing the pointless allocation.

On my systems at least, the pointless allocation will happen, on
average, less than once per boot.  Unless my systems are vastly
unrepresentative, the third option doesn't look appealing to me.

> You may also want to include the actual text of the warning from the 
> kernel log in your commit message.  When people encounter this, then will 
> probably grep in the kernel logs for some keywords to see if it was 
> already fixed and I fear your current commit message may allow it to be 
> missed.

Ack.

I should still have those warning in logfiles somewhere and can hunt
them down.

Jorn

--
Act only according to that maxim whereby you can, at the same time,
will that it should become a universal law.
-- Immanuel Kant

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
