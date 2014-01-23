Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B5E726B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 21:19:20 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so1215234pab.19
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 18:19:20 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id xa2si11990487pab.258.2014.01.22.18.19.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 18:19:19 -0800 (PST)
Message-ID: <52E07B31.8070104@oracle.com>
Date: Wed, 22 Jan 2014 21:15:13 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG: Bad rss-counter state
References: <52E06B6F.90808@oracle.com> <alpine.DEB.2.02.1401221735450.26172@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1401221735450.26172@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: khlebnikov@openvz.org, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 01/22/2014 08:39 PM, David Rientjes wrote:
> On Wed, 22 Jan 2014, Sasha Levin wrote:
>
>> Hi all,
>>
>> While fuzzing with trinity running inside a KVM tools guest using latest -next
>> kernel,
>> I've stumbled on a "mm: BUG: Bad rss-counter state" error which was pretty
>> non-obvious
>> in the mix of the kernel spew (why?).
>>
>
> It's not a fatal condition and there's only a few possible stack traces
> that could be emitted during the exit() path.  I don't see how we could
> make it more visible other than its log-level which is already KERN_ALERT.

Would it make sense to add a VM_BUG_ON() to make it more obvious when we have
CONFIG_VM_DEBUG enabled? Many of the VM_BUG_ON test cases are non-fatal either,
and it would make it easier spotting this issue.

>> I've added a small BUG() after the printk() in check_mm(), and here's the full
>> output:
>>
>
> Worst place to add it :)  At line 562 of kernel/fork.c in linux-next
> you're going to hit BUG() when there may be other counters that are also
> bad and they don't get printed.

I gave the condition before curly braces :)

                 if (unlikely(x)) {
                         printk(KERN_ALERT "BUG: Bad rss-counter state "
                                           "mm:%p idx:%d val:%ld\n", mm, i, x);
                         BUG();
                 }

>> [  318.334905] BUG: Bad rss-counter state mm:ffff8801e6dec000 idx:0 val:1
>
> So our mm has a non-zero MM_FILEPAGES count, but there's nothing that was
> cited that would tell us what that is so there's not much to go on, unless
> someone already recognizes this as another issue.  Is this reproducible on
> 3.13 or only on linux-next?

Yup, I see it in v3.13 too, which is odd.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
