Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2365E6B0039
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 15:21:54 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id u56so1251327wes.18
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 12:21:53 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id hx1si8862736wjb.129.2014.09.12.12.21.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 12:21:52 -0700 (PDT)
Date: Fri, 12 Sep 2014 21:21:39 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 00/10] Intel MPX support
In-Reply-To: <54124379.5090502@intel.com>
Message-ID: <alpine.DEB.2.10.1409121543090.4178@nanos>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <54124379.5090502@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 11 Sep 2014, Dave Hansen wrote:

> On 09/11/2014 01:46 AM, Qiaowei Ren wrote:
> > MPX kernel code, namely this patchset, has mainly the 2 responsibilities:
> > provide handlers for bounds faults (#BR), and manage bounds memory.
> 
> Qiaowei, We probably need to mention here what "bounds memory" is, and
> why it has to be managed, and who is responsible for the different pieces.
> 
> Who allocates the memory?
> Who fills the memory?
> When is it freed?
> 
> Thomas, do you have any other suggestions for things you'd like to see
> clarified?

Yes, the most important question is WHY must the kernel handle the
bound table memory allocation in the first place. The "documentation"
patch completely fails to tell that.

> +3. Tips
> +=======
> +
> +1) Users are not allowed to create bounds tables and point the bounds
> +directory at them in the userspace. In fact, it is not also necessary
> +for users to create bounds tables in the userspace.

This misses to explain why. I studied the manual carefully and I have
no idea why you think this is a requirement.

MPX can be handled completely from user space. See below before you
answer.

> +When #BR fault is produced due to invalid entry, bounds table will be
> +created in kernel on demand and kernel will not transfer this fault to
> +userspace. So usersapce can't receive #BR fault for invalid entry, and
> +it is not also necessary for users to create bounds tables by themselves.
> +
> +Certainly users can allocate bounds tables and forcibly point the bounds
> +directory at them through XSAVE instruction, and then set valid bit
> +of bounds entry to have this entry valid. But we have no way to track
> +the memory usage of these user-created bounds tables. In regard to this,
> +this behaviour is outlawed here.

So what's the point of declaring it outlawed? Nothing as far as I can
see simply because you cannot enforce it. This is possible and people
simply will do it.

> +2) We will not support the case that multiple bounds directory entries
> +are pointed at the same bounds table.
> +
> +Users can be allowed to take multiple bounds directory entries and point
> +them at the same bounds table. See more information "Intel(R) Architecture
> +Instruction Set Extensions Programming Reference" (9.3.4).
> +
> +If userspace did this, it will be possible for kernel to unmap an in-use
> +bounds table since it does not recognize sharing. So this behavior is
> +also outlawed here.

Again, this is nothing you can enforce and just saying its outlawed
does not prevent user space from doing it and then sending hard to
decode bug reports where it complains about mappings silently
vanishing under it.

So all you can do here is to write up a rule set how well behaving
user space is supposed to use this facility and the kernel side of it. 

Now back to the original question WHY:

The only kind of "argument" you provided in the whole blurb is "if
user space handles the allocation we have no way to track the memory
usage of these tables".

So if the only value of this whole allocation endavour is that we have
a separate "name" entry in proc/$PID/maps then this definitely does
not justify the mess it creates. You'd be better off with creating a
syscall which allows putting a name tag on a anonymous
mapping. Seriously, that would be handy for other purposes than MPX as
well.

But after staring into the manual and the code trainwreck for a day, I
certainly know WHY you want to handle it in kernel space.

If user space wants to handle it, it needs to preallocate all the
Bound Table mappings simply because it cannot do so from the signal
handler which gets invoked on the #BR 'Invalid BD entry'. mmap is not
on the list of safe async handler functions and even if mmap would
work it still requires locking or nasty tricks to keep track of the
allocation state there.

Preallocation is simply not feasible, because user space does not know
about the requirements of libraries etc. So letting the kernel help
out here is the right approach.

All that information is completely missing in the "doc" and all
over the patch series. 

Thanks,

	tglx





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
