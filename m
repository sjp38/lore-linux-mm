Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC046004A4
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 17:48:54 -0500 (EST)
Message-ID: <4B62141E.4050107@zytor.com>
Date: Thu, 28 Jan 2010 14:47:58 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [Security] DoS on x86_64
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org> <4B61B00D.7070202@zytor.com> <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, security@kernel.org, "Luck, Tony" <tony.luck@intel.com>, James Morris <jmorris@namei.org>, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Mathias Krause <minipli@googlemail.com>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On 01/28/2010 02:33 PM, Linus Torvalds wrote:
> 
> 
> On Thu, 28 Jan 2010, H. Peter Anvin wrote:
>>
>> - The actual point of no return in the case of binfmt_elf.c is inside
>> the subroutine flush_old_exec() [which makes sense - the actual process
>> switch shouldn't be dependent on the binfmt] which isn't subject to
>> compat-level macro munging.
> 
> Why worry about it? We already do that additional
> 
> 	SET_PERSONALITY(loc->elf_ex);
> 
> _after_ the flush_old_exec() call anyway in fs/binfmt_elf.c.
> 
> So why not just simply remove the whole early SET_PERSONALITY thing, and 
> only keep that later one? The comment about "lookup of the interpreter" is 
> known to be irrelevant these days, so why don't we just remove it all?
> 
> I have _not_ tested any of this, and maybe there is some crazy reason why 
> this won't work, but I'm not seeing it.
> 
> I think we do have to do that "task_size" thing (which flush_old_exec() 
> also does), because it depends on the personality exactly the same way 
> STACK_TOP does. But why isn't the following patch "obviously correct"?
> 

I was worrying about the use of TASK_SIZE, but I don't see any obvious
uses of it downstream in flush_old_exec() before we return.

So this patch, *plus* removing any delayed side effects from
SET_PERSONALITY() [e.g. the TIF_ABI_PENDING stuff in x86-64 which is
intended to have a forward action from SET_PERSONALITY() to
flush_thread()] might just work.  I will try it out.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
