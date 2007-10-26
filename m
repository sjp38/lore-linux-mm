Date: Fri, 26 Oct 2007 14:02:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: OOM notifications
Message-Id: <20071026140201.ae52757c.akpm@linux-foundation.org>
In-Reply-To: <20071018201531.GA5938@dmt>
References: <20071018201531.GA5938@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: linux-kernel@vger.kernel.org, drepper@redhat.com, riel@redhat.com, Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Oct 2007 16:15:31 -0400
Marcelo Tosatti <marcelo@kvack.org> wrote:

> Hi,
> 
> AIX contains the SIGDANGER signal to notify applications to free up some
> unused cached memory:
> 
> http://www.ussg.iu.edu/hypermail/linux/kernel/0007.0/0901.html
> 
> There have been a few discussions on implementing such an idea on Linux,
> but nothing concrete has been achieved.
> 
> On the kernel side Rik suggested two notification points: "about to
> swap" (for desktop scenarios) and "about to OOM" (for embedded-like
> scenarios).
> 
> With that assumption in mind it would be necessary to either have two
> special devices for notification, or somehow indicate both events
> through the same file descriptor.
> 
> Comments are more than welcome.

Martin was talking about some mad scheme wherin you'd create a bunch of
pseudo files (say, /proc/foo/0, /proc/foo/1, ..., /proc/foo/9) and each one
would become "ready" when the MM scanning priority reaches 10%, 20%, ... 
100%.

Obviously there would need to be a lot of abstraction to unhook a permanent
userspace feature from a transient kernel implementation, but the basic
idea is that a process which wants to know when the VM is getting into the
orange zone would select() on the file "7" and a process which wants to
know when the VM is getting into the red zone would select on file "9".

It get more complicated with NUMA memory nodes and cgroup memory
controllers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
