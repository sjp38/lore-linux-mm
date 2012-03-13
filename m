Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 539A16B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 04:32:36 -0400 (EDT)
Message-ID: <4F5F0620.2020404@codeaurora.org>
Date: Tue, 13 Mar 2012 01:32:32 -0700
From: Stephen Boyd <sboyd@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Persist printk buffer across reboots.
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
In-Reply-To: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avery Pennarun <apenwarr@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "David S. Miller" <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Fabio M. Di Nitto" <fdinitto@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Olaf Hering <olaf@aepfle.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Yinghai LU <yinghai@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 3/12/2012 10:36 PM, Avery Pennarun wrote:
> The last patch in this series implements a new CONFIG_PRINTK_PERSIST option
> that, when enabled, puts the printk buffer in a well-defined memory location
> so that we can keep appending to it after a reboot.  The upshot is that,
> even after a kernel panic or non-panic hard lockup, on the next boot
> userspace will be able to grab the kernel messages leading up to it.  It
> could then upload the messages to a server (for example) to keep crash
> statistics.
>
> The preceding patches in the series are mostly just things I fixed up while
> working on that patch.
>
> Some notes:
>
> - I'm not totally sure of the locking or portability issues when calling
>    memblock or bootmem.  This all happens really early, and I *think*
>    interrupts are still disabled at that time, so it's probably okay.
>
> - Tested this version on x86 (kvm) and it works with soft reboot (ie. reboot
>    -f).  Since some BIOSes wipe the memory during boot, you might not have
>    any luck.  It should be great on many embedded systems, though, including
>    the MIPS system I've tested a variant of this patch on.  (Our MIPS build
>    is based on a slightly older kernel so it's not 100% the same, but I think
>    this should behave identically.)
>
> - The way we choose a well-defined memory location is slightly suspicious
>    (we just count down from the top of the address space) but I've tested it
>    pretty carefully, and it seems to be okay.
>
> - In printk.c with CONFIG_PRINTK_PERSIST set, we're #defining words like
>    log_end.  It might be cleaner to replace all instances of log_end with
>    LOG_END to make this more clear.  This is also the reason the struct
>    logbits members start with _: because otherwise they conflict with the
>    macro.  Suggestions welcome.

Android has something similar called ram_console (see 
staging/android/ram_console.c). The console is dumped to a ram buffer 
that is reserved very early in platform setup code. Then when the phone 
reboots you can cat /proc/last_kmsg to get the previous kernel message 
for debugging. Can you use that code?

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
