Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9034E6B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 12:54:25 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 204-v6so1565071itu.6
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 09:54:25 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0077.outbound.protection.outlook.com. [104.47.38.77])
        by mx.google.com with ESMTPS id p69-v6si7456597itc.61.2018.04.06.09.54.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 06 Apr 2018 09:54:24 -0700 (PDT)
Date: Fri, 6 Apr 2018 19:54:02 +0300
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: [PATCH 1/5] arm64: entry: isb in el1_irq
Message-ID: <20180406165402.nq3sabeku2mp3hpb@yury-thinkpad>
References: <20180405171800.5648-1-ynorov@caviumnetworks.com>
 <20180405171800.5648-2-ynorov@caviumnetworks.com>
 <5036b99a-9faa-c220-27dd-e0d73f8b3fc7@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5036b99a-9faa-c220-27dd-e0d73f8b3fc7@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexey Klimov <klimov.linux@gmail.com>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 06, 2018 at 11:02:56AM +0100, James Morse wrote:
> Hi Yury,
> 
> An ISB at the beginning of the vectors? This is odd, taking an IRQ to get in
> here would be a context-synchronization-event too, so the ISB is superfluous.
> 
> The ARM-ARM  has a list of 'Context-Synchronization event's (Glossary on page
> 6480 of DDI0487B.b), paraphrasing:
> * ISB
> * Taking an exception
> * ERET
> * (...loads of debug stuff...)

Hi James, Mark,

I completely forgot that taking an exception is the context synchronization
event. Sorry for your time on reviewing this crap. It means that patches 1,
2 and 3 are not needed except chunk that adds ISB in do_idle() path. 

Also it means that for arm64 we are safe to mask IPI delivering to CPUs that
run any userspace code, not only nohz_full.

In general, kick_all_cpus_sync() is needed to switch contexts. But exit from
userspace is anyway the switch of context. And while in userspace, we cannot
do something wrong on kernel side. For me it means that we can safely drop
IPI for all userspace modes - both normal and nohz_full. 

If it's correct, for v3 I would suggest:
 - in kick_all_cpus_sync() mask all is_idle_task() and user_mode() CPUs;
 - add isb() for arm64 in do_idle() path only - this path doesn't imply
   context switch.

What do you think?

Yury
