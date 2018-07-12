Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 44FD76B0006
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 19:50:18 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id q18-v6so18320874pll.3
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:50:18 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x19-v6si21783288plr.15.2018.07.12.16.50.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 16:50:16 -0700 (PDT)
Subject: Re: [RFC PATCH v2 18/27] x86/cet/shstk: Introduce WRUSS instruction
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-19-yu-cheng.yu@intel.com>
 <bbb487cc-ac1c-f734-eee3-2463a0ba7efc@linux.intel.com>
 <1531436398.2965.18.camel@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <46784af0-6fbb-522d-6acb-c6248e5e0e0d@linux.intel.com>
Date: Thu, 12 Jul 2018 16:49:56 -0700
MIME-Version: 1.0
In-Reply-To: <1531436398.2965.18.camel@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/12/2018 03:59 PM, Yu-cheng Yu wrote:
> On Tue, 2018-07-10 at 16:48 -0700, Dave Hansen wrote:
>>>
>>> +/*
>>> + * WRUSS is a kernel instrcution and but writes to user
>>> + * shadow stack memory.A A When a fault occurs, both
>>> + * X86_PF_USER and X86_PF_SHSTK are set.
>>> + */
>>> +static int is_wruss(struct pt_regs *regs, unsigned long error_code)
>>> +{
>>> +	return (((error_code & (X86_PF_USER | X86_PF_SHSTK)) ==
>>> +		(X86_PF_USER | X86_PF_SHSTK)) && !user_mode(regs));
>>> +}
>> I thought X86_PF_USER was set based on the mode in which the fault
>> occurred.A A Does this mean that the architecture of this bit is different
>> now?
> 
> Yes.
> 
>> That seems like something we need to call out if so.A A It also means we
>> need to update the SDM because some of the text is wrong.
> 
> It needs to mention the WRUSS case.

Ugh.  The documentation for this is not pretty.  But, I guess this is
not fundamentally different from access to U=1 pages when SMAP is in
place and we've set EFLAGS.AC=1.

But, sheesh, we need to call this out really explicitly and make it
crystal clear what is going on.

We need to go through the page fault code very carefully and audit all
the X86_PF_USER spots and make sure there's no impact to those.  SMAP
should mean that we already dealt with these, but we still need an audit.

The docs[1] are clear as mud on this though: "Page entry has user
privilege (U=1) for a supervisor-level shadow-stack-load,
shadow-stack-store-intent or shadow-stack-store access except those that
originate from the WRUSS instruction."

Or, in short:

	"Page has U=1 ... except those that originate from the WRUSS 	
	instruction."

Which is backwards from what you said.  I really wish those docs had
reused the established SDM language instead of reinventing their own way
of saying things.

1.
https://software.intel.com/sites/default/files/managed/4d/2a/control-flow-enforcement-technology-preview.pdf
