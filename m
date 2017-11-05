Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 461C36B0033
	for <linux-mm@kvack.org>; Sun,  5 Nov 2017 07:54:56 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 15so9271395pgc.16
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 04:54:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t67sor2824349pgb.205.2017.11.05.04.54.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 05 Nov 2017 04:54:55 -0800 (PST)
Date: Sun, 5 Nov 2017 23:54:43 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
Message-ID: <20171105235443.045fb4b7@roar.ozlabs.ibm.com>
In-Reply-To: <919a1cb5-c3b5-ddee-d6a6-0994c282ae84@redhat.com>
References: <f251fc3e-c657-ebe8-acc8-f55ab4caa667@redhat.com>
	<20171105231850.5e313e46@roar.ozlabs.ibm.com>
	<919a1cb5-c3b5-ddee-d6a6-0994c282ae84@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>

On Sun, 5 Nov 2017 13:35:40 +0100
Florian Weimer <fweimer@redhat.com> wrote:

> On 11/05/2017 01:18 PM, Nicholas Piggin wrote:
> 
> > There was a recent change to move to 128TB address space by default,
> > and option for 512TB addresses if explicitly requested.  
> 
> Do you have a commit hash for the introduction of 128TB by default?  Thanks.

I guess this one

f6eedbba7a26 ("powerpc/mm/hash: Increase VA range to 128TB")

> 
> > Your brk request asked for > 128TB which the kernel gave it, but the
> > address limit in the paca that the SLB miss tests against was not
> > updated to reflect the switch to 512TB address space.
> > 
> > Why is your brk starting so high? Are you trying to test the > 128TB
> > case, or maybe something is confused by the 64->128TB change? What's
> > the strace look like if you run on a distro or <= 4.10 kernel?  
> 
> I think it is a consequence of running with an explicit loader 
> invocation.  With that, the heap is placed above ld.so, which can be 
> quite high in the address space.
> 
> I'm attaching two runs of cat, one executing directly as /bin/cat, and 
> one with /lib64/ld64.so.1 /bin/cat.
> 
> Fortunately, this does *not* apply to PIE binaries (also attached). 
> However, explicit loader invocations are sometimes used in test suites 
> (not just for glibc), and these sporadic test failures are quite annoying.
> 
> Do you still need the strace log?  And if yes, of what exactly?

Thanks, that should be quite helpful. I'll spend a bit more time to
study it, I'll let you know if I need any other traces.

> 
> > Something like the following patch may help if you could test.  
> 
> Okay, this will take some time.

It's no rush, there will probably be a revision to come.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
