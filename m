Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2836E6B0038
	for <linux-mm@kvack.org>; Fri, 12 May 2017 11:11:21 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r63so41608394itc.2
        for <linux-mm@kvack.org>; Fri, 12 May 2017 08:11:21 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id i201si3513782ioa.192.2017.05.12.08.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 May 2017 08:11:20 -0700 (PDT)
Date: Fri, 12 May 2017 10:11:14 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
In-Reply-To: <20170512122704.GA30528@amt.cnet>
Message-ID: <alpine.DEB.2.20.1705121002310.22243@east.gentwo.org>
References: <20170425135717.375295031@redhat.com> <20170425135846.203663532@redhat.com> <20170502102836.4a4d34ba@redhat.com> <20170502165159.GA5457@amt.cnet> <20170502131527.7532fc2e@redhat.com> <alpine.DEB.2.20.1705111035560.2894@east.gentwo.org>
 <20170512122704.GA30528@amt.cnet>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Fri, 12 May 2017, Marcelo Tosatti wrote:

> > A bit confused by this one. The vmstat worker is already disabled if there
> > are no updates. Also the patches by Chris Metcalf on data plane mode add a
> > prctl to quiet the vmstat workers.
> >
> > Why do we need more than this?
>
> If there are vmstat statistic updates on a given CPU, and you don't
> want intervention from the vmstat worker, you change the behaviour of
> stat data collection to directly write to the global structures (which
> disables the performance optimization of collecting data in per-cpu
> counters).

Hmmm.... Ok. That is going to be expensive if you do this for each
individual vmstat update.

> This way you can disable vmstat worker (because it causes undesired
> latencies), while allowing vmstatistics to function properly.

Best then to run the vmstat update mechanism when you leave kernel mode to
get all the updates in one go.


> The prctl from Chris Metcalf patchset allows one to disable vmstat
> worker per CPU? If so, they replace the functionality of the patch
> "[patch 3/3] MM: allow per-cpu vmstat_worker configuration"
> of the -v2 series of my patchset, and we can use it instead.
>
> Is it integrated already?

The data plane mode patches disables vmstat processing  by updating the
vmstats immediately if necessary and switching off the kworker thread.

So the kworker wont be running until the next time statistics are checked
by the shepherd task from a remote cpu. If the counters have been updated
then the shepherd task will reenable the kworker. This is already merged
and has been working for a long time. Data plan mode has not been merged
yet but the infrastructure in vmstat.c is there because NOHZ needs it too.

See linux/vmstat.c:quiet_vmstat()

It would be easy to add a /proc file that allows the quieting of the
vmstat workers for a certain cpu. Just make it call the quiet_vmstat() on
the right cpu.

This will quiet vmstat down. The shepherd task will check the stats in 2
second intervals and will then reenable when necessasry.

Note that we already are updating the global structures directly if the
differential gets too high. Reducing the differential may get you what you
want.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
