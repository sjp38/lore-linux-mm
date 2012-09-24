Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id E96D26B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 14:55:55 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 25 Sep 2012 00:25:52 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8OItFtk40108128
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 00:25:15 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8OItE55027462
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 04:55:15 +1000
Message-ID: <5060AC71.2080609@linux.vnet.ibm.com>
Date: Tue, 25 Sep 2012 00:24:41 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: divide error: bdi_dirty_limit+0x5a/0x9e
References: <20120924102324.GA22303@aftab.osrc.amd.com> <50603829.9050904@linux.vnet.ibm.com> <20120924110554.GC22303@aftab.osrc.amd.com> <50604047.7000908@linux.vnet.ibm.com> <20120924113447.GA25182@localhost> <20120924122053.GD22303@aftab.osrc.amd.com> <20120924122900.GA28627@localhost> <20120924125632.GE22303@aftab.osrc.amd.com>
In-Reply-To: <20120924125632.GE22303@aftab.osrc.amd.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Conny Seidel <conny.seidel@amd.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>

On 09/24/2012 06:26 PM, Borislav Petkov wrote:
> On Mon, Sep 24, 2012 at 08:29:00PM +0800, Fengguang Wu wrote:
>> On Mon, Sep 24, 2012 at 02:20:53PM +0200, Borislav Petkov wrote:
>>> On Mon, Sep 24, 2012 at 07:34:47PM +0800, Fengguang Wu wrote:
>>>> Will you test such a line? At least the generic do_div() only uses the
>>>> lower 32bits for division.
>>>>
>>>>         WARN_ON(!(den & 0xffffffff));
>>>
>>> But, but, the asm output says:
>>>
>>>   28:   48 89 c8                mov    %rcx,%rax
>>>   2b:*  48 f7 f7                div    %rdi     <-- trapping instruction
>>>   2e:   31 d2                   xor    %edx,%edx
>>>
>>> and this version of DIV does an unsigned division of RDX:RAX by the
>>> contents of a *64-bit register* ... in our case %rdi.
>>>
>>> Srivatsa's oops  shows the same:
>>>
>>>   28:   48 89 f0                mov    %rsi,%rax
>>>   2b:*  48 f7 f7                div    %rdi     <-- trapping instruction
>>>   2e:   41 8b 94 24 74 02 00    mov    0x274(%r12),%edx
>>>
>>> Right?
>>
>> Right, that's why I said "at least". As for x86, I'm as clueless as you..
> 
> Right, both oopses are on x86 so I don't think it is the bitness of the
> division.
> 
> Another thing those two have in common is that both happen when a CPU
> comes online. Srivatsa's is when CPU9 comes online (oops is detected on
> CPU9) and in our case CPU4 comes online but the oops says CPU0.
> 

I had posted another dump from one of my tests. That one triggers while
offlining a CPU (CPU 9).

https://lkml.org/lkml/2012/9/14/235

> So it has to be hotplug-related.

Regards,
Srivatsa S. Bhat


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
