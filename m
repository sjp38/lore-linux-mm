Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 0B6B96B005D
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 06:39:16 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Mon, 24 Sep 2012 16:09:11 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8OAd5k24194578
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 16:09:06 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8OAd4tI008424
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 20:39:05 +1000
Message-ID: <50603829.9050904@linux.vnet.ibm.com>
Date: Mon, 24 Sep 2012 16:08:33 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: divide error: bdi_dirty_limit+0x5a/0x9e
References: <20120924102324.GA22303@aftab.osrc.amd.com>
In-Reply-To: <20120924102324.GA22303@aftab.osrc.amd.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Conny Seidel <conny.seidel@amd.com>

On 09/24/2012 03:53 PM, Borislav Petkov wrote:
> Hi all,
> 
> we're able to trigger the oops below when doing CPU hotplug tests.
> 

I hit this problem as well, which I reported here, a few days ago:
https://lkml.org/lkml/2012/9/13/222

<snip>

> 	...
> 
> and from looking at the register dump below, the dividend, which should
> be in %rdx:%rax is 0 and the divisor (denominator) we've got from
> bdi_writeout_fraction and is in %rdi is also 0. Which is strange because
> fprop_fraction_percpu guards for division by zero by setting denominator
> to 1 if it were zero but what about the case where den > num? Can that
> even happen?
> 
> And also, what happens if num is 0? Which it kinda is by looking at %rcx
> where there's copy of it.
>

Going by the usage of percpu_counter_read_positive() (which is used to get
both the values of num and den), the least value that num or den can have
is zero. So, the C code to guard against divide-by-zero looks OK to me.
Which unfortunately keeps the mystery unsolved :(

Regards,
Srivatsa S. Bhat
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
