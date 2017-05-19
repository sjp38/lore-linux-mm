Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB6FA2806EE
	for <linux-mm@kvack.org>; Fri, 19 May 2017 13:49:40 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id i6so27910127qti.5
        for <linux-mm@kvack.org>; Fri, 19 May 2017 10:49:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e4si9493210qta.328.2017.05.19.10.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 10:49:39 -0700 (PDT)
Date: Fri, 19 May 2017 13:49:34 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and
 vmstat_worker configuration
Message-ID: <20170519134934.0c298882@redhat.com>
In-Reply-To: <alpine.DEB.2.20.1705191205580.19631@east.gentwo.org>
References: <20170502131527.7532fc2e@redhat.com>
	<alpine.DEB.2.20.1705111035560.2894@east.gentwo.org>
	<20170512122704.GA30528@amt.cnet>
	<alpine.DEB.2.20.1705121002310.22243@east.gentwo.org>
	<20170512154026.GA3556@amt.cnet>
	<alpine.DEB.2.20.1705121103120.22831@east.gentwo.org>
	<20170512161915.GA4185@amt.cnet>
	<alpine.DEB.2.20.1705121154240.23503@east.gentwo.org>
	<20170515191531.GA31483@amt.cnet>
	<alpine.DEB.2.20.1705160825480.32761@east.gentwo.org>
	<20170519143407.GA19282@amt.cnet>
	<alpine.DEB.2.20.1705191205580.19631@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Fri, 19 May 2017 12:13:26 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> > So why are you against integrating this simple, isolated patch which
> > does not affect how current logic works?  
> 
> Frankly the argument does not make sense. Vmstat updates occur very
> infrequently (probably even less than you IPIs and the other OS stuff that
> also causes additional latencies that you seem to be willing to tolerate).

Infrequently is not good enough. It only has to happen once to
cause a problem.

Also, IPIs take a few us, usually less. That's not a problem. In our
testing we see the preemption caused by the kworker take 10us or
even more. I've never seeing it take 3us. I'm not saying this is not
true, I'm saying if this is causing a problem to us it will cause
a problem to other people too.

> And you can configure the interval of vmstat updates freely.... Set
> the vmstat_interval to 60 seconds instead of 2 for a try? Is that rare
> enough?

No, we'd have to set it high enough to disable it and this will
affect all CPUs.

Something that crossed my mind was to add a new tunable to set
the vmstat_interval for each CPU, this way we could essentially
disable it to the CPUs where DPDK is running. What's the implications
of doing this besides not getting up to date stats in /proc/vmstat
(which I still have to confirm would be OK)? Can this break anything
in the kernel for example?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
