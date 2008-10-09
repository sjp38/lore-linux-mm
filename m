Date: Thu, 9 Oct 2008 14:46:58 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
Message-ID: <20081009124658.GE2952@elte.hu>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, MinChan Kim <minchan.kim@gmail.com>, arnd@arndb.de, jeremy@goop.org
List-ID: <linux-mm.kvack.org>

* Oren Laadan <orenl@cs.columbia.edu> wrote:

> These patches implement basic checkpoint-restart [CR]. This version 
> (v6) supports basic tasks with simple private memory, and open files 
> (regular files and directories only). Changes mainly cleanups. See 
> original announcements below.

i'm wondering about the following productization aspect: it would be 
very useful to applications and users if they knew whether it is safe to 
checkpoint a given app. I.e. whether that app has any state that cannot 
be stored/restored yet.

Once we can do that, if the kernel can reliably tell whether it can 
safely checkpoint an application, we could start adding a kernel driven 
self-test of sorts: a self-propelled kernel feature that would 
transparently try to checkpoint various applications as it goes, and 
restore them immediately.

When such a test-kernel is booted then all that should be visible is an 
occasional slowdown due to the random save/restore cycles of various 
processes - but no actual application breakage should ever occur, and 
the kernel must not crash either. This would work a bit like 
CONFIG_RCUTORTURE: a constant test that should be transparent in terms 
of functionality.

Also, the ability to tell whether a process can be safely checkpointed 
would allow apps to rely on it - they cannot accidentally use some 
kernel feature that is not saved/restored and then lose state across a 
CR cycle.

Plus, as a bonus, the inability to CR a given application would sure 
spur the development of proper checkpointing of that given kernel state. 
We could print some once-per-boot debug warning about exactly what bit 
cannot be checkpointed yet. This would create proper pressure from 
actual users of CR.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
