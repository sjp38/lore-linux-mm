Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 22AD36B0002
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 10:58:12 -0400 (EDT)
Date: Sun, 14 Apr 2013 07:58:07 -0700
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: System freezes when RAM is full (64-bit)
Message-ID: <20130414145807.GC6478@dhcp22.suse.cz>
References: <20130404070856.GB29911@dhcp22.suse.cz>
 <515D89BE.2040609@gmail.com>
 <20130404151658.GJ29911@dhcp22.suse.cz>
 <515EA3B7.5030308@gmail.com>
 <20130405115914.GD31132@dhcp22.suse.cz>
 <515F3701.1080504@gmail.com>
 <20130412102020.GA20624@dhcp22.suse.cz>
 <5167E6BA.70909@gmail.com>
 <20130412111113.GC20624@dhcp22.suse.cz>
 <51680028.5050600@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51680028.5050600@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ivan Danov <huhavel@gmail.com>
Cc: Simon Jeons <simon.jeons@gmail.com>, linux-mm@kvack.org, 1162073@bugs.launchpad.net, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 12-04-13 14:38:00, Ivan Danov wrote:
> On 12/04/13 13:11, Michal Hocko wrote:
> >On Fri 12-04-13 12:49:30, Ivan Danov wrote:
> >>$ cat /proc/sys/vm/swappiness
> >>60
> >OK, thanks for confirming this. It is really strange that we do not swap
> >almost at all, then.
> >>I have increased my swap partition from nearly 2GB to around 16GB,
> >>but the problem remains.
> >Increasing the swap partition will not help much as it almost unused
> >with 2G already (at least last data shown that).
> >
> >>Here I attach the logs for the larger swap partition. I use a MATLAB
> >>script to simulate the problem, but it also works in Octave:
> >>X = ones(100000,10000);
> >AFAIU this will create a matrix with 10^9 elements and initialize them
> >to 1. I am not familiar with octave but do you happen to know what is
> >the data type used for the element? 8B? It would be also interesting to
> >know how is the matrix organized and initialized. Does it fit into
> >memory at all?
> Yes, 8B each, so it will be almost 8GB and it should fit into the
> memory.

It won't fit in because kernel and other processes consume some memory
as well. So you have to swap.

> I don't know details how it actually works, but if it cannot
> create the matrix, MATLAB complains about that. Since it starts
> complaining even after 2000 more in the second dimension, maybe it
> needs the RAM to create it all. However on the desktop machine, both
> RAM and swap are being used (quite a lot of them both).

How much you swap depends on vm.swappiness. I would suggest increasing
the value if your workload is really so anononymous memory based.
Otherwise a lot of file pages are reclaimed which can lead to problems
you are seeing.

> >>I have tried to simulate the problem on a desktop installation with
> >>4GB of RAM, 10GB of swap partition, installed Ubuntu Lucid and then
> >>upgraded to 12.04, the problem isn't there, but the input is still
> >>quite choppy during the load. After the script finishes, everything
> >>looks fine. For the desktop installation the hard drive is not an
> >>SSD hard drive.
> >What is the kernel version used here?
> $ uname -a
> Linux ivan 3.2.0-40-generic #64-Ubuntu SMP Mon Mar 25 21:22:10 UTC
> 2013 x86_64 x86_64 x86_64 GNU/Linux

Is there any chance you could test with the latest vanilla kernel and 
Mel's patches from https://lkml.org/lkml/2013/4/11/516 on top?

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
