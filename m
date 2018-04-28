Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B5B4A6B0003
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 03:15:42 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id i11-v6so2742004wre.16
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 00:15:42 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q131sor718490wmb.11.2018.04.28.00.15.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 28 Apr 2018 00:15:41 -0700 (PDT)
Date: Sat, 28 Apr 2018 09:15:38 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/9] [v3] x86, pkeys: two protection keys bug fixes
Message-ID: <20180428071538.3whanph7r6v56h2a@gmail.com>
References: <20180427174527.0031016C@viggo.jf.intel.com>
 <20180428070553.yjlt22sb6ntcaqnc@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180428070553.yjlt22sb6ntcaqnc@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, akpm@linux-foundation.org, shuah@kernel.org, shakeelb@google.com


* Ingo Molnar <mingo@kernel.org> wrote:

> After I got the GDB backtraces I tried to clean up leftover tasks, but the main 
> thread would not go away:
> 
>  4006 pts/0    00:00:00 protection_keys <defunct>
> 
> neither SIGCONT nor SIGKILL appears to help:

Just seconds after I sent this I found out that this was user error: I forgot 
about a gdb session I still had running, which understandably blocked the task 
from being cleaned up. Once I exited GDB it all got cleaned up properly.

The hang problem is still there, if I run a script like this:

 while :; do date; echo -n "32-bit: "; ./protection_keys_32 >/dev/null; date; echo -n "64-bit: "; ./protection_keys_64 >/dev/null; done

then within a minute one of the testcases hangs reliably.

Out of 4 attempts so far one hang was in the 32-bit testcase, 3 hangs were in the 
64-bit testcase - so 64-bit appears to trigger it more frequently.

Thanks,

	Ingo
