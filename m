Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l511E5KE023641
	for <linux-mm@kvack.org>; Thu, 31 May 2007 21:14:05 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l511DxWT261670
	for <linux-mm@kvack.org>; Thu, 31 May 2007 19:14:04 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l511Dxu0028310
	for <linux-mm@kvack.org>; Thu, 31 May 2007 19:13:59 -0600
Subject: Re: [RFC][PATCH] Replacing the /proc/<pid|self>/exe symlink code
From: Matt Helsley <matthltc@us.ibm.com>
In-Reply-To: <20070531060148.GE3390@sequoia.sous-sol.org>
References: <1180486369.11715.69.camel@localhost.localdomain>
	 <20070530180923.GA22345@vino.hallyn.com>
	 <20070531060148.GE3390@sequoia.sous-sol.org>
Content-Type: text/plain
Date: Thu, 31 May 2007 18:13:46 -0700
Message-Id: <1180660426.18419.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wright <chrisw@sous-sol.org>
Cc: "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-30 at 23:01 -0700, Chris Wright wrote:
> * Serge E. Hallyn (serge@hallyn.com) wrote:
> > > ===================================================================
> > > --- linux-2.6.22-rc2-mm1.orig/kernel/exit.c
> > > +++ linux-2.6.22-rc2-mm1/kernel/exit.c
> > > @@ -924,10 +924,12 @@ fastcall void do_exit(long code)
> > >  	if (unlikely(tsk->audit_context))
> > >  		audit_free(tsk);
> > >  
> > >  	taskstats_exit(tsk, group_dead);
> > >  
> > > +	if (tsk->exe_file)
> > > +		fput(tsk->exe_file);
> > 
> > just taking a cursory look so I may be missing something, but doesn't
> > this leave the possibility that right here, with tsk->exe_file being
> > put, another task would try to look at tsk's /proc/tsk->pid/exe?
> 
> And I hit this one, so there's at least one issue.
> 
> [  110.296952] Unable to handle kernel NULL pointer dereference at 0000000000000088 RIP: 
> [  110.299053]  [<ffffffff80293fca>] d_path+0x1a/0x117
> [  110.301861] PGD 6d35a067 PUD 6d35e067 PMD 0 
> [  110.303509] Oops: 0000 [1] SMP 
> [  110.304719] CPU 1 
> [  110.305493] Modules linked in: oprofile
> [  110.306969] Pid: 3983, comm: pidof Not tainted 2.6.22-rc3-g7f397dcd-dirty #183
> [  110.309733] RIP: 0010:[<ffffffff80293fca>]  [<ffffffff80293fca>] d_path+0x1a/0x117
> [  110.312635] RSP: 0018:ffff810142335e38  EFLAGS: 00010292
> [  110.314667] RAX: ffff81006d58a000 RBX: 0000000000000000 RCX: 0000000000001000
> [  110.317397] RDX: ffff81006d58a000 RSI: 0000000000000000 RDI: 0000000000000000
> [  110.320127] RBP: ffff81006d58a000 R08: 00000000fffffff3 R09: 000000000006be8b
> [  110.322857] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000000
> [  110.325588] R13: 0000000000001000 R14: ffff81006d58a000 R15: 00000000000000000
> [  110.328319] FS:  00002b033d578260(0000) GS:ffff81000106e480(0000) knlGS:0000000000000000
> [  110.331415] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  110.333613] CR2: 0000000000000088 CR3: 000000006cf54000 CR4: 00000000000006e0
> [  110.336344] Process pidof (pid: 3983, threadinfo ffff810142334000, task ffff8101421186c0)
> [  110.339472] Stack:  ffff8101422a7268 0000000000000000 ffff81006d58a000 00000000fffffff4
> [  110.342556]  0000000000000000 0000000000001000 0000000000678820 ffffffff802b7a54
> [  110.345404]  0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  110.348180] Call Trace:
> [  110.349188]  [<ffffffff802b7a54>] proc_pid_readlink+0x89/0xff
> [  110.351387]  [<ffffffff80285e55>] sys_readlinkat+0x87/0xa9
> [  110.353487]  [<ffffffff8026d4dc>] remove_vma+0x5d/0x64
> [  110.355455]  [<ffffffff80596acd>] error_exit+0x0/0x84
> [  110.357389]  [<ffffffff8020935e>] system_call+0x7e/0x83
> [  110.359388] 
> [  110.359958] 
> [  110.359958] Code: 48 8b 87 88 00 00 00 48 85 c0 74 20 48 8b 40 30 48 85 c0 74 
> [  110.363381] RIP  [<ffffffff80293fca>] d_path+0x1a/0x117
> [  110.365386]  RSP <ffff810142335e38>
> [  110.366720] CR2: 0000000000000088

Hmm, at first blush this does appear to be related to the bug Serge
pointed out. I'm not certain though, so I'll see if I can spot/produce
any other problems that could explain this.

Thanks for testing my patch!

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
