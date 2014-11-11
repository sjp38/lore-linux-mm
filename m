Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id E4CE36B012B
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 15:15:43 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id n3so2921818wiv.0
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 12:15:43 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5si36985892wjs.63.2014.11.11.12.15.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 12:15:42 -0800 (PST)
Date: Tue, 11 Nov 2014 21:15:39 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [BUG] mm/page-writeback.c: divide by zero in pos_ratio_polynom
 not fixed
Message-ID: <20141111201539.GA12333@quack.suse.cz>
References: <20141101082325.7be0463f@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141101082325.7be0463f@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Sat 01-11-14 08:23:25, Steven Rostedt wrote:
> 
> My tests hit this bug:
> 
> divide error: 0000 [#1] SMP 
> Modules linked in: nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables ipv6 ppdev parport_pc parport microcode r8169
> CPU: 1 PID: 3379 Comm: trace-cmd Tainted: P               3.18.0-rc1-test+ #26
> Hardware name: MSI MS-7823/CSM-H87M-G43 (MS-7823), BIOS V1.6 02/22/2014
> task: ef4a2bc0 ti: efad4000 task.ti: efad4000
> EIP: 0060:[<c06979a9>] EFLAGS: 00010246 CPU: 1
> EIP is at div_u64_rem+0x11/0x24
> EAX: 00000000 EBX: 00000000 ECX: 00000000 EDX: 00000000
> ESI: 00ef57e4 EDI: 00000000 EBP: efad5ca0 ESP: efad5c98
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> CR0: 80050033 CR2: b77495dc CR3: 2fee1000 CR4: 001407f0
> Stack:
>  00000000 0000061a efad5ccc c0697c48 efad5cbc c04ec9d5 0000304e 00ef57e4^M
>  00000000 00000000 00000000 0000061a 00000000 efad5d08 c04ecbc5 00000000
>  00000000 00000000 00000575 f0d84210 0000387b 387b0000 00000000 00000aeb
> Call Trace:
>  [<c0697c48>] div64_u64+0x2f/0xd7
>  [<c04ec9d5>] ? pos_ratio_polynom+0x42/0xb2
>  [<c04ecbc5>] bdi_position_ratio+0x180/0x1d4
>  [<c04eddb2>] balance_dirty_pages_ratelimited+0x2a3/0x549
>  [<c04c274e>] ? __buffer_unlock_commit+0x10/0x12
>  [<c04c2a5a>] ? trace_function+0x6b/0x73
>  [<c04e5993>] ? generic_perform_write+0x110/0x17f^M
>  [<c05001c5>] ? iov_iter_advance+0x9/0xf0
>  [<c04e59bf>] generic_perform_write+0x13c/0x17f
>  [<c04e746b>] __generic_file_write_iter+0x1a6/0x1db^M
>  [<c058aeee>] ? ext4_file_write_iter+0x146/0x489
>  [<c058b176>] ext4_file_write_iter+0x3ce/0x489
>  [<c04bcbed>] ? ring_buffer_unlock_commit+0x25/0x73
>  [<c04c274e>] ? __buffer_unlock_commit+0x10/0x12
>  [<c04c8459>] ? function_trace_call+0xc9/0xf6^M
>  [<c0c7753a>] ? ftrace_call+0x5/0xb
>  [<c054242f>] iter_file_splice_write+0x21f/0x30e
>  [<c0542210>] ? splice_direct_to_actor+0x178/0x178
>  [<c0543921>] SyS_splice+0x3b0/0x4cd
>  [<c0c76982>] syscall_call+0x7/0x7
> Code: 55 89 e5 5d 01 d0 c3 b9 0a 00 00 00 31 d2 f7 f1 55 89 e5 5d c1 e0 04 01 d0 c3 55 89 e5 56 89 c6 53 31 db 39 ca 72 08 89 d0 31 d2 <f7> f1 89 c3 89 f0 f7 f1 8b 4d 08 89 11 89 da 5b 5e 5d c3 55 89
> EIP: [<c06979a9>] div_u64_rem+0x11/0x24 SS:ESP 0068:efad5c98
> ---[ end trace 04e65e2c8b607f3d ]---
> 
> Where the ip of the code points here:
> 
> 	/*
> 	 * Use span=(8*write_bw) in single bdi case as indicated by
> 	 * (thresh - bdi_thresh ~= 0) and transit to bdi_thresh in JBOD case.
> 	 *
> 	 *        bdi_thresh                    thresh - bdi_thresh
> 	 * span = ---------- * (8 * write_bw) + ------------------- * bdi_thresh
> 	 *          thresh                            thresh
> 	 */
> 	span = (thresh - bdi_thresh + 8 * write_bw) * (u64)x >> 16;
> 	x_intercept = bdi_setpoint + span;
> 
> 	if (bdi_dirty < x_intercept - span / 4) {
> 		pos_ratio = div64_u64(pos_ratio * (x_intercept - bdi_dirty),  <---- bug
> 				    x_intercept - bdi_setpoint + 1);
> 	} else
> 		pos_ratio /= 4;
> 
> 
> Now my kernel contains d5c9fde3dae75 "mm/page-writeback.c: fix divide by
> zero in pos_ratio_polynom", which is suppose to fix a divide by zero by
> changing div_u64 to div64_u64(), which changes the divisor parameter
> from 32bit to 64bit. But the x_intercept and bdi_setpoint are still
> just unsigned longs, which on 32bit systems are 32 bits. Just using
> div64_u64() isn't enough, the value passed in must also be 64 bit
> otherwise the "x_intercept - bdi_setpoint + 1" will still be truncated
> before it gets passed into div64_u64(). I don't see how d5c9fde3dae75
> could have fixed anything.
> 
> I'd write a patch to fix this, but my wife has me doing other chores.
  So I was looking into this but I have to say I don't understand where is
the problem. The registers clearly show that x_intercept - bdi_setpoint + 1
== 0 (in 32-bit arithmetics). Given:
   x_intercept = bdi_setpoint + span

We have that span + 1 == 0 and that means that:
((thresh - bdi_thresh + 8 * write_bw) * (u64)x >> 16) == -1 (again in
32-bit arithmetics). But I don't see how that can realistically happen...

Is this reproducible at all?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
