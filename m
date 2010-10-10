Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AF7BB6B0071
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 08:41:09 -0400 (EDT)
Message-ID: <4CB1B452.2060707@redhat.com>
Date: Sun, 10 Oct 2010 14:40:50 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 08/12] Handle async PF in a guest.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-9-git-send-email-gleb@redhat.com> <4CADC6C3.3040305@redhat.com> <20101007171418.GA2397@redhat.com> <4CAE00CB.1070400@redhat.com> <20101007180340.GI2397@redhat.com> <4CB0B8EF.3050702@redhat.com> <20101010075625.GM2397@redhat.com>
In-Reply-To: <20101010075625.GM2397@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/10/2010 09:56 AM, Gleb Natapov wrote:
> On Sat, Oct 09, 2010 at 08:48:15PM +0200, Avi Kivity wrote:
> >   On 10/07/2010 08:03 PM, Gleb Natapov wrote:
> >  >>   >>
> >  >>   >Host side keeps track of outstanding apfs and will not send apf for the
> >  >>   >same phys address twice. It will halt vcpu instead.
> >  >>
> >  >>   What about different pages, running the scheduler code?
> >  >>
> >  >We can get couple of nested apfs, just like we can get nested
> >  >interrupts. Since scheduler disables preemption second apf will halt.
> >
> >  How much is a couple?
> >
> >  Consider:
> >
> >  SIGSTOP
> >  Entire process swapped out
> >  SIGCONT
> >
> >  We can get APF's on the current code, the scheduler code, the stack,
> >  any debugging code in between (e.g. ftrace), and the page tables for
> >  all of these.
> >
> Lets count them all. Suppose guest is in a userspace process code and
> guest memory is completely swapped out. Guest starts to run and faults
> in userspace. Apf is queued but can't be delivered due to faults in
> idt and exception stack. All of them will be taken synchronously due
> to event pending check. After apf is delivered any fault in apf code
> will be takes synchronously since interrupt are disabled. Just before
> calling schedule() interrupts are enabled, so next pf that will happen
> during call to schedule() will be taken asynchronously. Which will cause
> another call to schedule() at which point vcpu will be halted since two
> apfs happened at the same address. So I counted two of them.
>

Ok.  Feels weird, but I guess this is fine.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
