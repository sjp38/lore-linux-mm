Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 8548D6B003D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 17:42:54 -0400 (EDT)
Date: Mon, 26 Aug 2013 17:42:44 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: unused swap offset / bad page map.
Message-ID: <20130826214244.GA21146@redhat.com>
References: <CAJd=RBBNCf5_V-nHjK0gOqS4OLMszgB7Rg_WMf4DvL-De+ZdHA@mail.gmail.com>
 <20130823032127.GA5098@redhat.com>
 <CAJd=RBArkh3sKVoOJUZBLngXtJubjx4-a3G6s7Tn0N=Pr1gU4g@mail.gmail.com>
 <20130823035344.GB5098@redhat.com>
 <CAJd=RBBtY-nJfo9nzG5gtgcvB2bz+sxpK5kX33o1sLeLhvEU1Q@mail.gmail.com>
 <20130826190757.GB27768@redhat.com>
 <20130826201846.GA23724@moon>
 <20130826203702.GA15407@redhat.com>
 <20130826204203.GB23724@moon>
 <20130826213754.GN3814@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130826213754.GN3814@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Aug 27, 2013 at 01:37:54AM +0400, Cyrill Gorcunov wrote:
 > On Tue, Aug 27, 2013 at 12:42:03AM +0400, Cyrill Gorcunov wrote:
 > > On Mon, Aug 26, 2013 at 04:37:02PM -0400, Dave Jones wrote:
 > > > 
 > > > Try adding the -C64 to the invocation in scripts/test-multi.sh,
 > > > and perhaps up'ing the NR_PROCESSES variable there too.
 > > 
 > > Thanks! I'll ping you if I manage to crash my instance.
 > 
 > So trinity tained kernel, but definitely not in place I'm interested.
 > 
 > [  320.904506] raw_sendmsg: trinity-child14 forgot to set AF_INET. Fix it!
 > [  329.570812] ------------[ cut here ]------------
 > [  329.571650] WARNING: CPU: 0 PID: 1982 at kernel/lockdep.c:3552 check_flags+0x18a/0x1c1()
 > [  329.571650] DEBUG_LOCKS_WARN_ON(current->softirqs_enabled)
 > [  329.571650] Modules linked in:
 > [  329.571650] CPU: 0 PID: 1982 Comm: trinity-child4 Not tainted 3.11.0-rc6-dirty #386
 > [  329.571650] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
 > [  329.571650]  0000000000000009 ffff88001ee03b10 ffffffff8157ac8a 0000000000000006
 > [  329.571650]  ffff88001ee03b60 ffff88001ee03b50 ffffffff81045bb2 ffffffff81583840
 > [  329.571650]  ffffffff81092620 ffff880002b48000 0000000000000046 ffffffff81a2f750
 > [  329.571650] Call Trace:
 > [  329.571650]  <IRQ>  [<ffffffff8157ac8a>] dump_stack+0x4f/0x84
 > [  329.571650]  [<ffffffff81045bb2>] warn_slowpath_common+0x81/0x9b
 > [  329.571650]  [<ffffffff81583840>] ? ftrace_call+0x5/0x2f
 > [  329.571650]  [<ffffffff81092620>] ? check_flags+0x18a/0x1c1
 > [  329.571650]  [<ffffffff81045c6f>] warn_slowpath_fmt+0x46/0x48
 > [  329.571650]  [<ffffffff81045c2e>] ? warn_slowpath_fmt+0x5/0x48
 > [  329.571650]  [<ffffffff81092620>] check_flags+0x18a/0x1c1
 > [  329.571650]  [<ffffffff81093595>] lock_is_held+0x30/0x5f
 > [  329.571650]  [<ffffffff810eb19e>] rcu_read_lock_held+0x36/0x38
 > [  329.571650]  [<ffffffff810f1b92>] perf_tp_event+0x92/0x220
 > [  329.571650]  [<ffffffff810f1d0e>] ? perf_tp_event+0x20e/0x220
 > [  329.571650]  [<ffffffff81049f6c>] ? __local_bh_enable+0x9a/0x9e
 > [  329.571650]  [<ffffffff810712f3>] ? get_parent_ip+0x3f/0x3f
 > [  329.571650]  [<ffffffff81049f6c>] ? __local_bh_enable+0x9a/0x9e
 > [  329.571650]  [<ffffffff810e3af1>] perf_ftrace_function_call+0xce/0xdc

when it rains, it pours.. 
 
 > (since my config pretty similar to yours I tried to run trinity without
 >  kernel recompilation. At first i loaded swap space with crap data
 > 
 > [root@ovz trinity]# free 
 >              total       used       free     shared    buffers     cached
 > Mem:        493228     480188      13040          0       2912      12112
 > -/+ buffers/cache:     465164      28064
 > Swap:      2063356    1741304     322052
 > 
 > then run it as
 > 
 > [root@ovz trinity]# ./trinity -C64 --dangerous)

Yeah, for reproducing this bug, I'd stick to running it as a user, without --dangerous.
you might still hit a few fairly-easy to trigger warn-on/printks. I run with
this applied: http://paste.fedoraproject.org/34960/55323613/raw/ to make things
a little less noisy.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
