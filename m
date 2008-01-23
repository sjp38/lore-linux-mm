Received: from toip5.srvr.bell.ca ([209.226.175.88])
          by tomts16-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080123215537.ONKS574.tomts16-srv.bellnexxia.net@toip5.srvr.bell.ca>
          for <linux-mm@kvack.org>; Wed, 23 Jan 2008 16:55:37 -0500
Date: Wed, 23 Jan 2008 16:55:37 -0500
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [RFC] Userspace tracing memory mappings
Message-ID: <20080123215537.GC2282@Krystal>
References: <20080123160454.GA15405@Krystal> <y0m3aso9xj3.fsf@ton.toronto.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <y0m3aso9xj3.fsf@ton.toronto.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Frank Ch. Eigler" <fche@redhat.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, mbligh@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Frank Ch. Eigler (fche@redhat.com) wrote:
> Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> writes:
> 
> > [...]  Since memory management is not my speciality, I would like to
> > know if there are some implementation details I should be aware of
> > for my LTTng userspace tracing buffers. Here is what I want to do
> > [...]
> 
> Would you mind offering some justification for requiring a kernel
> extension for user-space tracing?  What can the kernel enable in this
> context that a user-space library (which you already assume will be
> linked in) can't?
> 
> - FChE

The kernel would provide :

- System-wide activation of markers located in userspace code
  example use : libc, NPTL tracing.
- Ability to extract buffers of a crashed process
- Ability to extract userspace tracing buffers upon kernel crash
- Activation of userspace tracing at the same time as the kernel tracing
  activation is done, without requiring messing up with signals.
- Potentially filtering on events coming from userspace, without messing
  up with signals.

Another point is early boot tracing : tracing processes such as init
requires to use syscalls rather than relying on debugfs/dev/proc file
operations. And we can't dump the information to the disk yet, so we
cannot expect the process itself to deal with file opening or socket
opening that soon. Therefore, we have to divide tracing in two distinct
actions : writing to the buffers and dumping the buffers (to disk or
though the network).

Another reason why we don't want to do everything is a single library is
that it would account the disk write time to the traced process. If we
do this from the kernel, we can know how many time it took because we
trace it. Another, better yet, reason for this is that if we want to
extract the data to disk or through the network, and want to get the
last trace bits of a segfaulted process, we have to share the buffers
with another process somehow. However, creating one extra process per
traced process is kind of awkward.

So the code itself would be a library in userspace. However, it would
interact both with the kernel for trace activation and with a daemon to
extract the information to disk or to the network. I start to think that
a userspace library would be sufficient for the userspace part of this
design (no need to modify vDSO).

And system V shared memory has a limit on the number of such memory
mapping one can have in the system that is way too low.

Does it explain the purpose of the kernel interaction better ?

Mathieu

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
