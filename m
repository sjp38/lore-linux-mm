Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 42AFD6B0044
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 22:48:36 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
	<m1haw33q35.fsf@fess.ebiederm.org>
	<CA+1xoqfX3hc7FP+8_9sn_mt4_WHkVfqTiPnE79Brs_kAfAFPCQ@mail.gmail.com>
	<1335708011.28106.245.camel@gandalf.stny.rr.com>
	<CA+1xoqfQczszejX8_9hj1ntFS0SpNhErgYSVPL-DxH2WG67JTw@mail.gmail.com>
	<1335729458.28106.247.camel@gandalf.stny.rr.com>
Date: Sun, 29 Apr 2012 19:52:37 -0700
In-Reply-To: <1335729458.28106.247.camel@gandalf.stny.rr.com> (Steven
	Rostedt's message of "Sun, 29 Apr 2012 15:57:38 -0400")
Message-ID: <m1r4v6ylqi.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [PATCH 01/14] sysctl: provide callback for write into ctl_table entry
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, viro@zeniv.linux.org.uk, fweisbec@gmail.com, mingo@redhat.com, a.p.zijlstra@chello.nl, paulus@samba.org, acme@ghostprotocols.net, james.l.morris@oracle.com, akpm@linux-foundation.org, tglx@linutronix.de, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, Eric Paris <eparis@parisplace.org>

Steven Rostedt <rostedt@goodmis.org> writes:

> On Sun, 2012-04-29 at 16:14 +0200, Sasha Levin wrote:
>
>> A fix for that could be having the sysctl modifying a different var,
>> and having ftrace_enabled from that under a lock, but I'm not sure if
>> it's worth the work for the cleanup.
>
> That was my original plan, but it seemed too much of a hassle than it
> was worth, as I needed to make sure the mirrored variable was in sync
> with ftrace_enabled, otherwise it could be confusing when ftrace was not
> working but sysctl showed ftrace set to 1.

I don't see the problem you are trying to solve with your patches.

What I do see is you have ignored one of the biggest problem with the
current sysctl interface in that it is not easy to plug in your own code
in the cases you need to before an update is made. (Locks permission
checks, etc).

You have also bloated struct ctl_table for no apparent reason.

This current crop of patches was just sloppy.  You showed a poor
choice of function names and did not preserve necessary invariants
when changing the code.  It looks like you exchanged something that
was a bit ugly for something that straight out encourages broken
behavior. 

So I respectfully suggest you go back to the drawing board and figure
out a solution that makes this class of function much easier to write
in a bug free manner.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
