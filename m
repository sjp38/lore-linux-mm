Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D59948D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 04:14:15 -0500 (EST)
Date: Thu, 10 Feb 2011 10:14:08 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC][PATCH v2] Controlling kexec behaviour when hardware
 error happened.
Message-ID: <20110210091408.GA10553@liondog.tnic>
References: <5C4C569E8A4B9B42A84A977CF070A35B2C1494DBE0@USINDEVS01.corp.hds.com>
 <4D53A3AA.5050908@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4D53A3AA.5050908@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Seiji Aguchi <seiji.aguchi@hds.com>, "hpa@zytor.com" <hpa@zytor.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "gregkh@suse.de" <gregkh@suse.de>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, "amwang@redhat.com" <amwang@redhat.com>, Satoru Moriya <satoru.moriya@hds.com>

On Thu, Feb 10, 2011 at 05:36:58PM +0900, Hidetoshi Seto wrote:
> (2011/02/10 1:35), Seiji Aguchi wrote:

[..]

> > diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
> > index d916183..e76b47b 100644
> > --- a/arch/x86/kernel/cpu/mcheck/mce.c
> > +++ b/arch/x86/kernel/cpu/mcheck/mce.c
> > @@ -944,6 +944,8 @@ void do_machine_check(struct pt_regs *regs, long error_code)
> >  
> >  	percpu_inc(mce_exception_count);
> >  
> > +	hwerr_flag = 1;
> > +
> >  	if (notify_die(DIE_NMI, "machine check", regs, error_code,
> >  			   18, SIGKILL) == NOTIFY_STOP)
> >  		goto out;
> 
> Now x86 supports some recoverable machine check, so setting
> flag here will prevent running kexec on systems that have
> encountered such recoverable machine check and recovered.
> 
> I think mce_panic() is proper place to set this flag "hwerr_flag".

I agree, in that case it is unsafe to run kexec only after the error
cannot be recovered by software.

Also, hwerr_flag is really a bad naming choice, how about
"hwerr_unrecoverable" or "hw_compromised" or "recovery_futile" or
"hw_incurable" or simply say what happened: "pcc" = processor context
corrupt (and a reliable restarting might not be possible). This could be
used by others too, besides kexec.

[..]

> > diff --git a/mm/memory-failure.c b/mm/memory-failure.c index 0207c2f..0178f47 100644
> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -994,6 +994,8 @@ int __memory_failure(unsigned long pfn, int trapno, int flags)
> >  	int res;
> >  	unsigned int nr_pages;
> >  
> > +	hwerr_flag = 1;
> > +
> >  	if (!sysctl_memory_failure_recovery)
> >  		panic("Memory failure from trap %d on page %lx", trapno, pfn);
> >  
> 
> For similar reason, setting flag here is not good for
> systems working after isolating some poisoned memory page.
> 
> Why not:
>  if (!sysctl_memory_failure_recovery) {
>  	hwerr_flag = 1;
>  	panic("Memory failure from trap %d on page %lx", trapno, pfn);
>  }

Why do we need that in memory-failure.c at all? I mean, when we consume
the UC, we'll end up in mce_panic() anyway.

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
