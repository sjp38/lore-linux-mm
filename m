Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9V2ejtO012157
	for <linux-mm@kvack.org>; Thu, 30 Oct 2008 20:40:45 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9V2fQPe123706
	for <linux-mm@kvack.org>; Thu, 30 Oct 2008 20:41:26 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9V2eupe008521
	for <linux-mm@kvack.org>; Thu, 30 Oct 2008 20:40:57 -0600
Date: Thu, 30 Oct 2008 21:41:24 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v8][PATCH 11/12] External checkpoint of a task other than
	ourself
Message-ID: <20081031024124.GA7885@us.ibm.com>
References: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu> <1225374675-22850-12-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1225374675-22850-12-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

Quoting Oren Laadan (orenl@cs.columbia.edu):
> Now we can do "external" checkpoint, i.e. act on another task.
> 
> sys_checkpoint() now looks up the target pid (in our namespace) and
> checkpoints that corresponding task. That task should be the root of
> a container.
> 
> sys_restart() remains the same, as the restart is always done in the
> context of the restarting task.
> 
> Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>

Ok, I'm at a loss right now, and I'm not sure who to blame - Oren,
Daniel, Matt, or someone else.

In one terminal I do:

	lxc-execute -n nonet sleep 100

then in another terminal do
	
	lxc-checkpoint -s -n nonet > /tmp/o

or
	lxc-checkpoint -n nonet > /tmp/o
followed by ctrl-c in the lxc-execute terminal.

Without fail, the second time I do this (if not the first), I get
a BUG (see below).  It really does look like it should have
nothing to do with the c/r patches, but I can't reproduce this
any other way.  I've tried doing

	lxc-freeze -n nonet; lxc-unfreeze -n nonet; lxc-stop -n nonet

I've tried manually doing freeze, checkpoint, unfreeze of containers
hand-crafted to look like what lxc-execute creates (two tasks in private
namespaces with private /proc mount, kill container inits of populated
containers (bc it really looks like another task-exit-vs-container-cleanup
race).

I can't find any other way to reproduce this.

(This is using Oren's patchset with freezer on top, and using
a freshly pulled liblxc from cvs)

-serge

login: ------------[ cut here ]------------
kernel BUG at fs/dcache.c:666!
invalid opcode: 0000 [#1] SMP
Modules linked in:

Pid: 2963, comm: [vinit] Not tainted (2.6.27-rc9-00020-g2265283-dirty #344)
EIP: 0060:[<c0188b5a>] EFLAGS: 00010292 CPU: 1
EIP is at shrink_dcache_for_umount_subtree+0x14b/0x1fe
EAX: 0000004e EBX: c04d22a7 ECX: 00000001 EDX: de6b5160
ESI: df4040a0 EDI: ffffffff EBP: de779d7c ESP: de779d4c
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process [vinit] (pid: 2963, ti=de778000 task=de6b5160 task.ti=de778000)
Stack: c04d1eb2 df4040a0 00000001 df404118 ffffffff c04d22a7 df830698 df404118
       00000004 df830400 c041e788 00000020 de779d88 c0188c3a df830400 de779d98
       c017b521 00000001 c054faf0 de779da4 c017b60b df830400 de779db0 c017b64d
Call Trace:
 [<c0188c3a>] ? shrink_dcache_for_umount+0x2d/0x3a
 [<c017b521>] ? generic_shutdown_super+0x15/0xd3
 [<c017b60b>] ? kill_anon_super+0xc/0x35
 [<c017b64d>] ? kill_litter_super+0x19/0x1c
 [<c017b6a3>] ? deactivate_super+0x53/0x6b
 [<c018d422>] ? mntput_no_expire+0xc3/0xe7
 [<c018d4b1>] ? release_mounts+0x6b/0x7a
 [<c018d522>] ? __put_mnt_ns+0x62/0x70
 [<c0134cad>] ? free_nsproxy+0x25/0x80
 [<c0134d4c>] ? switch_task_namespaces+0x44/0x49
 [<c0134d5b>] ? exit_task_namespaces+0xa/0xc
 [<c012403a>] ? do_exit+0x55f/0x6c9
 [<c0124202>] ? do_group_exit+0x5e/0x85
 [<c012c243>] ? get_signal_to_deliver+0x2ea/0x303
 [<c010232c>] ? do_notify_resume+0x6b/0x715
 [<c013bcfe>] ? lock_release_holdtime+0x1a/0x153
 [<c013da7e>] ? trace_hardirqs_on+0xb/0xd
 [<c013da7e>] ? trace_hardirqs_on+0xb/0xd
 [<c0131aa5>] ? remove_wait_queue+0x30/0x34
 [<c0123903>] ? do_wait+0x1d6/0x284
 [<c0152ecb>] ? audit_syscall_exit+0x2b1/0x2cc
 [<c013da52>] ? trace_hardirqs_on_caller+0xe1/0x102
 [<c01031a6>] ? work_notifysig+0x13/0x19
 =======================
Code: 1c 8b 18 8b 46 40 89 45 ec 8b 46 28 85 c0 74 03 8b 50 20 8d 81 98 02 00 00 50 53 57 ff 75 ec 52 56 68 b2 1e 4d c0 e8 9a 04 28 00 <0f> 0b 83 c4 1c eb fe 8b 7e 34 39 f7 75 04 31 ff eb 03 f0 ff 0f
EIP: [<c0188b5a>] shrink_dcache_for_umount_subtree+0x14b/0x1fe SS:ESP 0068:de779d4c
---[ end trace 218551429ab07a44 ]---
Fixing recursive fault but reboot is needed!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
