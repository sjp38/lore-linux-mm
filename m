Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A8E859000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 04:00:39 -0400 (EDT)
Received: from d06nrmr1507.portsmouth.uk.ibm.com (d06nrmr1507.portsmouth.uk.ibm.com [9.149.38.233])
	by mtagate2.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p8R80aac021029
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 08:00:36 GMT
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by d06nrmr1507.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8R80aoA2596940
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 09:00:36 +0100
Received: from d06av12.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8R80VoE014189
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 02:00:32 -0600
Date: Tue, 27 Sep 2011 08:08:47 +0100
From: Stefan Hajnoczi <stefanha@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 8/26]   x86: analyze instruction and
 determine fixups.
Message-ID: <20110927070847.GA8725@stefanha-thinkpad.localdomain>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120127.25326.71509.sendpatchset@srdronam.in.ibm.com>
 <20110920171310.GC27959@stefanha-thinkpad.localdomain>
 <20110920181225.GA5149@infradead.org>
 <20110923165132.GA23870@stefanha-thinkpad.localdomain>
 <4E80D9B2.3010404@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E80D9B2.3010404@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Stone <jistone@redhat.com>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, SystemTap <systemtap@sourceware.org>

On Mon, Sep 26, 2011 at 12:59:46PM -0700, Josh Stone wrote:
> On 09/23/2011 04:53 AM, Masami Hiramatsu wrote:
> >> Masami looked at this and found that SystemTap sdt.h currently requires
> >> an extra userspace memory store in order to activate probes.  Each probe
> >> has a "semaphore" 16-bit counter which applications may test before
> >> hitting the probe itself.  This is used to avoid overhead in
> >> applications that do expensive argument processing (e.g. creating
> >> strings) for probes.
> > Indeed, originally, those semaphores designed for such use cases.
> > However, some applications *always* use it (e.g. qemu-kvm).
> 
> I found that qemu-kvm generates its tracepoints like this:
> 
>   static inline void trace_$name($args) {
>       if (QEMU_${nameupper}_ENABLED()) {
>           QEMU_${nameupper}($argnames);
>       }
>   }
> 
> In that case, the $args are always computed to call the inline, so
> you'll basically just get a memory read, jump, NOP.  There's no benefit
> from checking ENABLED() here, and removing it would leave only the NOP.
>  Even if you invent an improved mechanism for ENABLED(), that doesn't
> change the fact that it's doing useless work here.
> 
> So in this case, it may be better to patch qemu, assuming my statements
> hold for DTrace's implementation on other platforms too.  The ENABLED()
> guard still does have other genuine uses though, as with the string
> preparation in Python's probes.

I will get qemu fixed.

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
