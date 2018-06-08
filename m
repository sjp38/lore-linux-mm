Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4FD46B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 10:53:12 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j33-v6so12120057qtc.18
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 07:53:12 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v87-v6si9792660qkl.392.2018.06.08.07.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 07:53:11 -0700 (PDT)
Subject: Re: [PATCH 04/10] x86/cet: Handle thread shadow stack
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
 <20180607143807.3611-5-yu-cheng.yu@intel.com>
 <CALCETrUqXvh2FDXe6bveP10TFpzptEyQe2=mdfZFGKU0T+NXsA@mail.gmail.com>
 <3c1bdf85-0c52-39ed-a799-e26ac0e52391@redhat.com>
 <CALCETrWPDXpbVcuFK_1M5DtaCOW_LSf-XHFAD0vpc735oFWLPg@mail.gmail.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <6ee29e8b-4a0a-3459-a1ee-03923ba4e15d@redhat.com>
Date: Fri, 8 Jun 2018 16:53:03 +0200
MIME-Version: 1.0
In-Reply-To: <CALCETrWPDXpbVcuFK_1M5DtaCOW_LSf-XHFAD0vpc735oFWLPg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On 06/07/2018 10:53 PM, Andy Lutomirski wrote:
> On Thu, Jun 7, 2018 at 12:47 PM Florian Weimer <fweimer@redhat.com> wrote:
>>
>> On 06/07/2018 08:21 PM, Andy Lutomirski wrote:
>>> On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>>>>
>>>> When fork() specifies CLONE_VM but not CLONE_VFORK, the child
>>>> needs a separate program stack and a separate shadow stack.
>>>> This patch handles allocation and freeing of the thread shadow
>>>> stack.
>>>
>>> Aha -- you're trying to make this automatic.  I'm not convinced this
>>> is a good idea.  The Linux kernel has a long and storied history of
>>> enabling new hardware features in ways that are almost entirely
>>> useless for userspace.
>>>
>>> Florian, do you have any thoughts on how the user/kernel interaction
>>> for the shadow stack should work?
>>
>> I have not looked at this in detail, have not played with the emulator,
>> and have not been privy to any discussions before these patches have
>> been posted, however a?|
>>
>> I believe that we want as little code in userspace for shadow stack
>> management as possible.  One concern I have is that even with the code
>> we arguably need for various kinds of stack unwinding, we might have
>> unwittingly built a generic trampoline that leads to full CET bypass.
> 
> I was imagining an API like "allocate a shadow stack for the current
> thread, fail if the current thread already has one, and turn on the
> shadow stack".  glibc would call clone and then call this ABI pretty
> much immediately (i.e. before making any calls from which it expects
> to return).

Ahh.  So you propose not to enable shadow stack enforcement on the new 
thread even if it is enabled for the current thread?  For the cases 
where CLONE_VM is involved?

It will still need a new assembler wrapper which sets up the shadow 
stack, and it's probably required to disable signals.

I think it should be reasonable safe and actually implementable.  But 
the benefits are not immediately obvious to me.

> We definitely want strong enough user control that tools like CRIU can
> continue to work.  I haven't looked at the SDM recently enough to
> remember for sure, but I'm reasonably confident that user code can
> learn the address of its own shadow stack.  If nothing else, CRIU
> needs to be able to restore from a context where there's a signal on
> the stack and the signal frame contains a shadow stack pointer.

CRIU also needs the shadow stack *contents*, which shouldn't be directly 
available to the process.  So it needs very special interfaces anyway.

Does CRIU implement MPX support?

Thanks,
Florian
