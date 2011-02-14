Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C29418D0039
	for <linux-mm@kvack.org>; Sun, 13 Feb 2011 20:21:54 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5BB2C3EE0D7
	for <linux-mm@kvack.org>; Mon, 14 Feb 2011 10:21:51 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 388D945DE50
	for <linux-mm@kvack.org>; Mon, 14 Feb 2011 10:21:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1473845DE4D
	for <linux-mm@kvack.org>; Mon, 14 Feb 2011 10:21:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C3C77EF8006
	for <linux-mm@kvack.org>; Mon, 14 Feb 2011 10:21:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A37AEF8001
	for <linux-mm@kvack.org>; Mon, 14 Feb 2011 10:21:50 +0900 (JST)
Message-ID: <4D588379.4050209@jp.fujitsu.com>
Date: Mon, 14 Feb 2011 10:20:57 +0900
From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH v2] Controlling kexec behaviour when hardware error
 happened.
References: <5C4C569E8A4B9B42A84A977CF070A35B2C1494DBE0@USINDEVS01.corp.hds.com> <4D53A3AA.5050908@jp.fujitsu.com> <20110210091408.GA10553@liondog.tnic>
In-Reply-To: <20110210091408.GA10553@liondog.tnic>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Seiji Aguchi <seiji.aguchi@hds.com>, "hpa@zytor.com" <hpa@zytor.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "gregkh@suse.de" <gregkh@suse.de>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, "amwang@redhat.com" <amwang@redhat.com>, Satoru Moriya <satoru.moriya@hds.com>

(2011/02/10 18:14), Borislav Petkov wrote:
> On Thu, Feb 10, 2011 at 05:36:58PM +0900, Hidetoshi Seto wrote:
>> (2011/02/10 1:35), Seiji Aguchi wrote:
> 
> [..]
> 
>>> diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
>>> index d916183..e76b47b 100644
>>> --- a/arch/x86/kernel/cpu/mcheck/mce.c
>>> +++ b/arch/x86/kernel/cpu/mcheck/mce.c
>>> @@ -944,6 +944,8 @@ void do_machine_check(struct pt_regs *regs, long error_code)
>>>  
>>>  	percpu_inc(mce_exception_count);
>>>  
>>> +	hwerr_flag = 1;
>>> +
>>>  	if (notify_die(DIE_NMI, "machine check", regs, error_code,
>>>  			   18, SIGKILL) == NOTIFY_STOP)
>>>  		goto out;
>>
>> Now x86 supports some recoverable machine check, so setting
>> flag here will prevent running kexec on systems that have
>> encountered such recoverable machine check and recovered.
>>
>> I think mce_panic() is proper place to set this flag "hwerr_flag".
> 
> I agree, in that case it is unsafe to run kexec only after the error
> cannot be recovered by software.
> 
> Also, hwerr_flag is really a bad naming choice, how about
> "hwerr_unrecoverable" or "hw_compromised" or "recovery_futile" or
> "hw_incurable" or simply say what happened: "pcc" = processor context
> corrupt (and a reliable restarting might not be possible). This could be
> used by others too, besides kexec.

Or how about something like hwerr_panic() to clear that the panic is
requested due to hardware error.

Anyway, Aguchi-san, please note that we should not turn off kexec before
encountering fatal hardware error and before printing/transmitting
enough hardware error log to out of this system.

> 
> [..]
> 
>>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c index 0207c2f..0178f47 100644
>>> --- a/mm/memory-failure.c
>>> +++ b/mm/memory-failure.c
>>> @@ -994,6 +994,8 @@ int __memory_failure(unsigned long pfn, int trapno, int flags)
>>>  	int res;
>>>  	unsigned int nr_pages;
>>>  
>>> +	hwerr_flag = 1;
>>> +
>>>  	if (!sysctl_memory_failure_recovery)
>>>  		panic("Memory failure from trap %d on page %lx", trapno, pfn);
>>>  
>>
>> For similar reason, setting flag here is not good for
>> systems working after isolating some poisoned memory page.
>>
>> Why not:
>>  if (!sysctl_memory_failure_recovery) {
>>  	hwerr_flag = 1;
>>  	panic("Memory failure from trap %d on page %lx", trapno, pfn);
>>  }
> 
> Why do we need that in memory-failure.c at all? I mean, when we consume
> the UC, we'll end up in mce_panic() anyway.

One possible answer is that memory-failure.c is not x86 specific.


Thanks,
H.Seto

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
