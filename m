Received: from pd2mr3so.prod.shaw.ca
 (pd2mr3so-qfe3.prod.shaw.ca [10.0.141.108]) by l-daemon
 (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0JLW004KWDYXXZ60@l-daemon> for linux-mm@kvack.org; Sat,
 28 Jul 2007 10:32:57 -0600 (MDT)
Received: from pn2ml6so.prod.shaw.ca ([10.0.121.150])
 by pd2mr3so.prod.shaw.ca (Sun Java System Messaging Server 6.2-7.05 (built Sep
 5 2006)) with ESMTP id <0JLW003SXDYU8520@pd2mr3so.prod.shaw.ca> for
 linux-mm@kvack.org; Sat, 28 Jul 2007 10:32:54 -0600 (MDT)
Received: from [192.168.1.113] ([70.64.1.86])
 by l-daemon (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0JLW00GOVDYTEM56@l-daemon> for linux-mm@kvack.org; Sat,
 28 Jul 2007 10:32:53 -0600 (MDT)
Date: Sat, 28 Jul 2007 10:32:47 -0600
From: Robert Hancock <hancockr@shaw.ca>
Subject: Re: How can we make page replacement smarter (was: swap-prefetch)
In-reply-to: <fa.0CL7DLsw6U7akTkW79pdCM5NPRk@ifi.uio.no>
Message-id: <46AB6FAF.5030306@shaw.ca>
MIME-version: 1.0
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7bit
References: <fa.RQO1FPcnWSV7f0LbL9tuLuh/fYY@ifi.uio.no>
 <fa.FI89MRq1q0M+6SmmYNPsXQv2gC8@ifi.uio.no>
 <fa./S2LBynIjozRhHfPsYxB9mQDpKE@ifi.uio.no>
 <fa.0CL7DLsw6U7akTkW79pdCM5NPRk@ifi.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Boldi <a1426z@gawab.com>
Cc: Chris Snook <csnook@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Al Boldi wrote:
> Chris Snook wrote:
>> Al Boldi wrote:
>>> Because it is hard to quantify the expected swap-in speed for random
>>> pages, let's first tackle the swap-in of consecutive pages, which should
>>> be at least as fast as swap-out.  So again, why is swap-in so slow?
>> If I'm writing 20 pages to swap, I can find a suitable chunk of swap and
>> write them all in one place.  If I'm reading 20 pages from swap, they
>> could be anywhere.  Also, writes get buffered at one or more layers of
>> hardware.
> 
> Ok, this explains swap-in of random pages.  Makes sense, but it doesn't 
> explain the awful tmpfs performance degradation of consecutive read-in runs 
> from swap, which should have at least stayed constant
> 
>> At best, reads can be read-ahead and cached, which is why
>> sequential swap-in sucks less.  On-demand reads are as expensive as I/O
>> can get.
> 
> Which means that it should be at least as fast as swap-out, even faster 
> because write to disk is usually slower than read on modern disks.  But 
> linux currently shows a distinct 2x slowdown for sequential swap-in wrt 
> swap-out.  And to prove this point, just try suspend to disk where you can 
> see sequential swap-out being reported at about twice the speed of 
> sequential swap-in on resume.  Why is that?

Depends if swap-in is doing any read-ahead. If it's reading one page at 
a time in from the disk then the performance will definitely suck 
because of all the overhead from the tiny I/O's. With random swap-in you 
then pay the horrible seek penalty for all the reads as well.

-- 
Robert Hancock      Saskatoon, SK, Canada
To email, remove "nospam" from hancockr@nospamshaw.ca
Home Page: http://www.roberthancock.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
