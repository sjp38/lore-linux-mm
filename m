Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE14D6B0337
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 09:43:49 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t87so231322412pfk.4
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 06:43:49 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00110.outbound.protection.outlook.com. [40.107.0.110])
        by mx.google.com with ESMTPS id a12si1874346plt.291.2017.03.22.06.43.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Mar 2017 06:43:49 -0700 (PDT)
Subject: Re: [PATCHv3] x86/mm: set x32 syscall bit in SET_PERSONALITY()
References: <20170321174711.29880-1-dsafonov@virtuozzo.com>
 <alpine.DEB.2.20.1703212319440.3776@nanos>
 <26CDE83A-CDBE-4F23-91F6-05B07B461BDD@zytor.com>
 <alpine.DEB.2.20.1703212327170.3776@nanos>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <1cf1ef57-94b5-68d2-4a44-0247f49d6990@virtuozzo.com>
Date: Wed, 22 Mar 2017 16:40:08 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1703212327170.3776@nanos>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, hpa@zytor.com
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Adam Borowski <kilobyte@angband.pl>, linux-mm@kvack.org, Andrei Vagin <avagin@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill
 A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>

On 03/22/2017 01:34 AM, Thomas Gleixner wrote:
> On Tue, 21 Mar 2017, hpa@zytor.com wrote:
>
>> On March 21, 2017 3:21:13 PM PDT, Thomas Gleixner <tglx@linutronix.de> wrote:
>>> On Tue, 21 Mar 2017, Dmitry Safonov wrote:
>>>> v3:
>>>> - clear x32 syscall flag during x32 -> x86-64 exec() (thanks, HPA).
>>>
>>> For correctness sake, this wants to be cleared in the IA32 path as
>>> well. It's not causing any harm, but ....
>>>
>>> I'll amend the patch.

Indeed, thanks!

>> Since the i386 syscall namespace is totally separate (and different),
>> should we simply change the system call number to the appropriate
>> sys_execve number?
>
> That should work as well and would be more intuitive.

Not sure that I got the idea correctly, something like this?
I haven't find any easy way to get compat syscall nr like
__NR_compat_execve, so I defined it there.
I'll resend v4 with the fixup if that's what was expected.

--->8---
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index b03f186369eb..c58ac0bff2f1 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -507,6 +507,8 @@ void set_personality_64bit(void)
  	current->personality &= ~READ_IMPLIES_EXEC;
  }

+#define __NR_ia32_execve	11
+
  void set_personality_ia32(bool x32)
  {
  	/* inherit personality from parent */
@@ -537,6 +539,7 @@ void set_personality_ia32(bool x32)
  			current->mm->context.ia32_compat = TIF_IA32;
  		current->personality |= force_personality32;
  		/* Prepare the first "return" to user space */
+		task_pt_regs(current)->orig_ax = __NR_ia32_execve;
  		current->thread.status |= TS_COMPAT;
  	}
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
