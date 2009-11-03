Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D9E6B6B0062
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 09:33:08 -0500 (EST)
Date: Tue, 3 Nov 2009 12:32:50 -0200
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH 03/11] Handle asynchronous page fault in a PV guest.
Message-ID: <20091103143250.GD10084@amt.cnet>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-4-git-send-email-gleb@redhat.com> <20091103141423.GC10084@amt.cnet> <20091103142533.GN27911@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091103142533.GN27911@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 03, 2009 at 04:25:33PM +0200, Gleb Natapov wrote:
> On Tue, Nov 03, 2009 at 12:14:23PM -0200, Marcelo Tosatti wrote:
> > On Sun, Nov 01, 2009 at 01:56:22PM +0200, Gleb Natapov wrote:
> > > Asynchronous page fault notifies vcpu that page it is trying to access
> > > is swapped out by a host. In response guest puts a task that caused the
> > > fault to sleep until page is swapped in again. When missing page is
> > > brought back into the memory guest is notified and task resumes execution.
> > 
> > Can't you apply this to non-paravirt guests, and continue to deliver
> > interrupts while waiting for the swapin? 
> > 
> > It should allow the guest to schedule a different task.
> But how can I make the guest to not run the task that caused the fault?

Any attempt to access the swapped out data will cause a #PF vmexit,
since the translation is marked as not present. If there's swapin in
progress, you wait for that swapin, otherwise start swapin and wait.

Its not as efficient as paravirt because you have to wait for a timer
interrupt and the guest scheduler to decide to taskswitch, but OTOH its
transparent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
