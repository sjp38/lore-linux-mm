Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id C9B036B005A
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 04:11:42 -0500 (EST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 18 Jan 2012 02:11:41 -0700
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id C52E03E4004F
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 02:11:37 -0700 (MST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0I9Bain2900182
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 04:11:37 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0I9BUV3014276
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 04:11:36 -0500
Date: Wed, 18 Jan 2012 14:32:32 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v9 3.2 2/9] uprobes: handle breakpoint and signal step
 exception.
Message-ID: <20120118090232.GE15447@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120110114842.17610.27081.sendpatchset@srdronam.in.ibm.com>
 <20120118083906.GA4697@bandura.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120118083906.GA4697@bandura.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Arapov <anton@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Mike Frysinger <vapier@gentoo.org>

> Srikar,
> 
>   Can we use existing SET_IP() instead of set_instruction_pointer() ?
> 

Oleg had already commented about this in one his uprobes reviews.

The GET_IP/SET_IP available in include/asm-generic/ptrace.h doesnt work
on all archs. Atleast it doesnt work on powerpc when I tried it.

Also most archs define instruction_pointer(). So I thought (rather Peter
Zijlstra suggested the name set_instruction_pointer())
set_instruction_pointer was a better bet than SET_IP. I 

Also I dont see any usage for SET_IP/GET_IP.

May be we should have something like this in
include/asm-generic/ptrace.h

#ifdef instruction_pointer
#define GET_IP(regs)		(instruction_pointer(regs))

#define set_instruction_pointer(regs, val) (instruction_pointer(regs) = (val))

#define SET_IP(regs, val)	(set_instruction_pointer(regs,val))

#endif

or should we do away with GET_IP/SET_IP esp since there are no many
users?

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
