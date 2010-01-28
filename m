Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D9D656004A4
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 18:15:39 -0500 (EST)
Message-ID: <4B621A6A.6070507@zytor.com>
Date: Thu, 28 Jan 2010 15:14:50 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [Security] DoS on x86_64
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org> <4B61B00D.7070202@zytor.com> <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain> <alpine.LFD.2.00.1001281449220.3846@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.1001281449220.3846@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mathias Krause <minipli@googlemail.com>, security@kernel.org, "Luck, Tony" <tony.luck@intel.com>, James Morris <jmorris@namei.org>, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On 01/28/2010 03:06 PM, Linus Torvalds wrote:
> 
> 
> On Thu, 28 Jan 2010, Linus Torvalds wrote:
>>
>> I have _not_ tested any of this, and maybe there is some crazy reason why 
>> this won't work, but I'm not seeing it.
> 
> Grr. We also do "arch_pick_mmap_layout()" in "flush_old_exec()".
> 
> That whole function is mis-named. It doesn't actually flush the old exec, 
> it also creates the new one.
> 
> However, we then re-do it afterwards in fs/binfmt_elf.c, so again, that 
> doesn't really matter.
> 
> What _does_ matter, however, is the crazy stuff we do in flush_thread() 
> wrt TIF_ABI_PENDING. That's just crazy.
> 
> So no, the trivial patch won't work.
> 
> How about splitting up "flush_old_exec()" into two pieces? We'd have a 
> "flush_old_exec()" and a "setup_new_exec()" piece, and all existing 
> callers of flush_old_exec() would just be changed to call both?
> 

Ah yes.  This really is a lot better than the track which I originally
was thinking about, which was something like adding a callout from
flush_old_exec().

I will try this... plus remove the TIF_ABI_PENDING stuff from x86, and
see how it works.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
