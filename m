Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 61D546B0109
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 05:38:30 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p5T9cRou016331
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 02:38:27 -0700
Received: from qwc23 (qwc23.prod.google.com [10.241.193.151])
	by kpbe19.cbf.corp.google.com with ESMTP id p5T9bTdb022902
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 02:38:26 -0700
Received: by qwc23 with SMTP id 23so753888qwc.17
        for <linux-mm@kvack.org>; Wed, 29 Jun 2011 02:38:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110628165302.706740714@goodmis.org>
References: <20110628164750.281686775@goodmis.org>
	<20110628165302.706740714@goodmis.org>
Date: Wed, 29 Jun 2011 02:38:20 -0700
Message-ID: <CANN689E0ckbGBZZfk-BMdyR=_E6eN2oQb5uhij3ARPVCicqGrQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: Remove use of ALLOW_RETRY when RETRY_NOWAIT is set
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Russell King <rmk+kernel@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>

On Tue, Jun 28, 2011 at 9:47 AM, Steven Rostedt <rostedt@goodmis.org> wrote=
:
> From: Steven Rostedt <srostedt@redhat.com>
>
> The only user of FAULT_FLAG_RETRY_NOWAIT also sets the
> FAULT_FLAG_ALLOW_RETRY flag. This makes the check in the
> __lock_page_or_retry redundant as it checks the RETRY_NOWAIT
> just after checking ALLOW_RETRY and then returns if it is
> set. =A0The FAULT_FLAG_ALLOW_RETRY does not make any other
> difference in this path.
>
> Setting both and then ignoring one is quite confusing,
> especially since this code has very subtle locking issues
> when it comes to the mmap_sem.
>
> Only set the RETRY_WAIT flag and have that do the necessary
> work instead of confusing reviewers of this code by setting
> ALLOW_RETRY and not releasing the mmap_sem.
>
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -151,8 +151,8 @@ extern pgprot_t protection_map[16];
> =A0#define FAULT_FLAG_WRITE =A0 =A0 =A0 0x01 =A0 =A0/* Fault was a write =
access */
> =A0#define FAULT_FLAG_NONLINEAR =A0 0x02 =A0 =A0/* Fault was via a nonlin=
ear mapping */
> =A0#define FAULT_FLAG_MKWRITE =A0 =A0 0x04 =A0 =A0/* Fault was mkwrite of=
 existing pte */
> -#define FAULT_FLAG_ALLOW_RETRY 0x08 =A0 =A0/* Retry fault if blocking */
> -#define FAULT_FLAG_RETRY_NOWAIT =A0 =A0 =A0 =A00x10 =A0 =A0/* Don't drop=
 mmap_sem and wait when retrying */
> +#define FAULT_FLAG_ALLOW_RETRY 0x08 =A0 =A0/* Retry fault if blocking (d=
rops mmap_sem) */
> +#define FAULT_FLAG_RETRY_NOWAIT =A0 =A0 =A0 =A00x10 =A0 =A0/* Wait when =
retrying (don't drop mmap_sem) */

You want to say "DONT wait when retrying" here...

Also - you argued higher up that having both flags set at once is
confusing, but I find it equally confusing to pass a flag to specify
you don't want to wait on retry if the flag that allows retry is not
set. I think the confusion comes from the way the nowait semantics got
bolted on the retry code for virtualization, even though (if I
understand the virtualization use case correctly) they dont actually
want to retry there, they just want to give up without blocking.


Would the following proposal make more sense to you ?

FAULT_FLAG_ALLOW_ASYNC: allow returning a VM_FAULT_ASYNC error code if
the page can't be obtained immediately (major fault).
FAULT_FLAG_ASYNC_WAIT: before returning VM_FAULT_ASYNC, drop the
mmap_sem and wait for major fault to complete.

existing uses of FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT
become FAULT_FLAG_ASYNC
existing uses of FAULT_FLAG_ALLOW_RETRY alone become FAULT_FLAG_ASYNC
| FAULT_FLAG_ASYNC_WAIT
existing uses of VM_FAULT_RETRY become VM_FAULT_ASYNC

This may also help your documentation proposal since the flags would
now work together rather than having one be an exception to the other.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
