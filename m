Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A2AC96B0003
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 13:50:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q22so4982064pfh.20
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 10:50:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q4si829195pga.319.2018.03.29.10.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 10:50:35 -0700 (PDT)
Date: Thu, 29 Mar 2018 10:50:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm/vmstat.c: fix vmstat_update() preemption BUG
Message-Id: <20180329105034.5fcc40fd5509ae74877d001e@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.20.1803291126230.27735@nuc-kabylake>
References: <alpine.DEB.2.20.1803291126230.27735@nuc-kabylake>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: "Steven J. Hill" <steven.hill@cavium.com>, linux-mm@kvack.org

On Thu, 29 Mar 2018 11:32:44 -0500 (CDT) Christopher Lameter <cl@linux.com> wrote:

> Just saw
> 
> commit c7f26ccfb2c31eb1bf810ba13d044fcf583232db
> Author: Steven J. Hill <steven.hill@cavium.com>
> Date:   Wed Mar 28 16:01:09 2018 -0700
> 
>     mm/vmstat.c: fix vmstat_update() preemption BUG
> 
>     Attempting to hotplug CPUs with CONFIG_VM_EVENT_COUNTERS enabled can
>     cause vmstat_update() to report a BUG due to preemption not being
>     disabled around smp_processor_id().
> 
> 
> 
> The fix is wrong.
> 
> vmstat_update cannot be moved to a differentprocessor and thus
> preemption should be off.
> 
> vmstat_update repeatedly accesses per cpu information.
> 
> vmstat_update first checks if there are counter to be updated on the
> current cpu and then updates the counters. This cannot happen if the
> process can be moved to a different cpu.
> 
> The patch "switches off" preemption after the check if there are changes
> to the local per cpu counter.
> 
> Lets find out what changed in the callers of vmstat_update() that caused
> the BUG to be triggered.

Yup.  Please see the discussion at
http://lkml.kernel.org/r/1520881552-25659-1-git-send-email-steven.hill@cavium.com
- I'm suspecting that it's a shortcoming in
check_preemption_disabled().  But check_preemption_disabled() does
indeed check to see if the CPU is pinned to a single CPU so that
explanation doesn't fly.  Maybe it's a glitch in the MIPS port - the
fact that it's triggered by CPU hotplugging makes me wonder if some
state got messed up.
