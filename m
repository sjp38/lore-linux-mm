Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id A74B76B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 15:47:29 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id d14-v6so10102087qtn.3
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 12:47:29 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d195-v6si11417023qkg.215.2018.06.07.12.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 12:47:28 -0700 (PDT)
Subject: Re: [PATCH 04/10] x86/cet: Handle thread shadow stack
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
 <20180607143807.3611-5-yu-cheng.yu@intel.com>
 <CALCETrUqXvh2FDXe6bveP10TFpzptEyQe2=mdfZFGKU0T+NXsA@mail.gmail.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <3c1bdf85-0c52-39ed-a799-e26ac0e52391@redhat.com>
Date: Thu, 7 Jun 2018 21:47:22 +0200
MIME-Version: 1.0
In-Reply-To: <CALCETrUqXvh2FDXe6bveP10TFpzptEyQe2=mdfZFGKU0T+NXsA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On 06/07/2018 08:21 PM, Andy Lutomirski wrote:
> On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>>
>> When fork() specifies CLONE_VM but not CLONE_VFORK, the child
>> needs a separate program stack and a separate shadow stack.
>> This patch handles allocation and freeing of the thread shadow
>> stack.
> 
> Aha -- you're trying to make this automatic.  I'm not convinced this
> is a good idea.  The Linux kernel has a long and storied history of
> enabling new hardware features in ways that are almost entirely
> useless for userspace.
> 
> Florian, do you have any thoughts on how the user/kernel interaction
> for the shadow stack should work?

I have not looked at this in detail, have not played with the emulator, 
and have not been privy to any discussions before these patches have 
been posted, however a?|

I believe that we want as little code in userspace for shadow stack 
management as possible.  One concern I have is that even with the code 
we arguably need for various kinds of stack unwinding, we might have 
unwittingly built a generic trampoline that leads to full CET bypass.

I also expect that we'd only have donor mappings in userspace anyway, 
and that the memory is not actually accessible from userspace if it is 
used for a shadow stack.

> My intuition would be that all
> shadow stack management should be entirely controlled by userspace --
> newly cloned threads (with CLONE_VM) should have no shadow stack
> initially, and newly started processes should have no shadow stack
> until they ask for one.

If the new thread doesn't have a shadow stack, we need to disable 
signals around clone, and we are very likely forced to rewrite the early 
thread setup in assembler, to avoid spurious calls (including calls to 
thunks to get EIP on i386).  I wouldn't want to do this If we can avoid 
it.  Just using C and hoping to get away with it doesn't sound greater, 
either.  And obviously there is the matter that the initial thread setup 
code ends up being that universal trampoline.

Thanks,
Florian
