Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 00589900155
	for <linux-mm@kvack.org>; Sat, 10 Sep 2011 13:27:03 -0400 (EDT)
Subject: Re: 3.0.3 oops. memory related?
From: Steven Rostedt <srostedt@redhat.com>
In-Reply-To: <20110907091339.91160fb5.kamezawa.hiroyu@jp.fujitsu.com>
References: <4E63C846.10606@gmail.com>
	 <20110905094956.186d3830.kamezawa.hiroyu@jp.fujitsu.com>
	 <4E665D51.7050809@gmail.com>
	 <20110907083818.827b0fa1.kamezawa.hiroyu@jp.fujitsu.com>
	 <20110907091339.91160fb5.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 10 Sep 2011 13:26:56 -0400
Message-ID: <1315675617.3537.49.camel@frodo>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Anders <aeriksson2@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>

Note, it's best to email me at my other email rostedt@goodmis.org. As I
do not check this email much while traveling.

On Wed, 2011-09-07 at 09:13 +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 7 Sep 2011 08:38:18 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Tue, 06 Sep 2011 19:50:09 +0200
> > Anders <aeriksson2@gmail.com> wrote:
> > 
> > > On 09/05/11 02:49, KAMEZAWA Hiroyuki wrote:
> > > > On Sun, 04 Sep 2011 20:49:42 +0200
> > > > Anders <aeriksson2@gmail.com> wrote:
> > > >
> > > > > I've got kdump setup to collect oopes. I found this in the log. Not sure
> > > > > what it's related to.
> > > > > 
> > > >
> > > > > <4>[47900.533010]  [<ffffffff810ab79f>] ?
> > > > > mem_cgroup_count_vm_event+0x15/0x67
> > > > > <4>[47900.533010]  [<ffffffff810987e5>] ? handle_mm_fault+0x3b/0x1e8
> > > > > <4>[47900.533010]  [<ffffffff81049bb3>] ? sched_clock_local+0x13/0x76
> > > > > <4>[47900.533010]  [<ffffffff8101bdb0>] ? do_page_fault+0x31a/0x33f
> > > > > <4>[47900.533010]  [<ffffffff81022b80>] ? check_preempt_curr+0x36/0x62
> > > > > <4>[47900.533010]  [<ffffffff8104bb23>] ? ktime_get_ts+0x65/0xa6
> > > > > <4>[47900.533010]  [<ffffffff810bfd2c>] ?
> > > > > poll_select_copy_remaining+0xce/0xed
> > > > > <4>[47900.533010]  [<ffffffff814c4b4f>] ? page_fault+0x1f/0x30
> > > >
> > > > I'll check memcg but...not sure what parts in above log are garbage.
> > > > At quick glance, mem_cgroup_count_vm_event() does enough NULL check
> > > > but faulted address was..
> > > >
> > > > > <0>[47900.533010] CR2: ffffc5217e257cf0
> > > >
> > > > This seems not NULL referencing.
> > > >
> > > > #define VMALLOC_START    _AC(0xffffc90000000000, UL)
> > > > #define VMALLOC_END      _AC(0xffffe8ffffffffff, UL)
> > > >
> > > > This is not vmalloc area...hmm. could you show your disassemble of
> > > > mem_cgroup_count_vm_event() ? and .config ?
> > > >
> > > How do I disassembe it?
> > > 
> > 
> > # make mm/memcontrol.o
> > # objdump -d memcontrol.o > file
> > 
> > please cut out mem_cgroup_count_vm_event() from dumpped file.
> > 
> 
> Sorry, I made mistake ..the log says
> 
> <1>[47900.533010] RIP  [<ffffffff81097d18>] handle_pte_fault+0x24/0x70a
> <4>[47900.533010]  RSP <ffff880024c27db8>
> <0>[47900.533010] CR2: ffffc5217e257cf0
> 
> <4>[47900.533010] RSP: 0000:ffff880024c27db8  EFLAGS: 00010296
> <4>[47900.533010] RAX: 0000000000000cf0 RBX: ffff88006c3b2a68 RCX:
> ffffc5217e257cf0
> <4>[47900.533010] RDX: 000000000059effe RSI: ffff88006c3b2a68 RDI:
> ffff88006d6d2ac0
> <4>[47900.533010] RBP: ffffc5217e257cf0 R08: ffff880024d3b010 R09:
> 0000000000000028
> Hm. CR2==RBP...then accessing RBP caused the fault. But it seems this
> RBP was accessed in this function before reaching EIP.
> 

Since I don't have the full context. What was the IP address of the
actually fault. Too much is removed and out of context for me to really
understand what happened.

> your .config says
> CONFIG_HAVE_FUNCTION_TRACER=y
> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
> CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
> CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
> CONFIG_HAVE_DYNAMIC_FTRACE=y
> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
> CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
> CONFIG_HAVE_C_RECORDMCOUNT=y

Ignore all the "_HAVE_" configs. It is set if the architecture supports
the features, not if the features are actually enabled. But looking at
your objdump, at least CONFIG_FUNCTION_TRACER is. Is dynamic tracing
enabled?

> 
> In my binary,
> 
> ffffffff8113b820 <handle_pte_fault>:
> ffffffff8113b820:       55                      push   %rbp
> ffffffff8113b821:       48 89 e5                mov    %rsp,%rbp
> ffffffff8113b824:       48 81 ec c0 00 00 00    sub    $0xc0,%rsp
> ffffffff8113b82b:       48 89 5d d8             mov    %rbx,-0x28(%rbp)
> ffffffff8113b82f:       4c 89 65 e0             mov    %r12,-0x20(%rbp)
> ffffffff8113b833:       4c 89 6d e8             mov    %r13,-0x18(%rbp)
> ffffffff8113b837:       4c 89 75 f0             mov    %r14,-0x10(%rbp)
> ffffffff8113b83b:       4c 89 7d f8             mov    %r15,-0x8(%rbp)
> ffffffff8113b83f:       e8 fc d4 47 00          callq  ffffffff815b8d40 <mcount>
> ffffffff8113b844:       4c 89 45 b8             mov    %r8,-0x48(%rbp)
> ffffffff8113b848:       4c 8b 29                mov    (%rcx),%r13
> 
> handle_pte_fault + 0x24 is just after mcount. And caused fault by accessing 
> %rbp...returning from a funciton ?

I'm confused? Is the handle_pte_fault what crashed? Or is it the call
path to the page fault handler to handle the crash.


> Hmm...problem with tracing ? I'm sorry if I misunderstand something.
> Anyway, CCing ftrace guys for getting information.

The mcount above should be converted to a nop at boot up. Can you please
send me your .config file and the dmesg too.

Thanks!

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
