Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 08DDF6B1F9E
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 04:52:59 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id d11so2132207wrw.4
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 01:52:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f124sor3343096wme.8.2018.11.20.01.52.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 01:52:57 -0800 (PST)
Date: Tue, 20 Nov 2018 10:52:53 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH v6 01/26] Documentation/x86: Add CET description
Message-ID: <20181120095253.GA119911@gmail.com>
References: <20181119214809.6086-1-yu-cheng.yu@intel.com>
 <20181119214809.6086-2-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181119214809.6086-2-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>


* Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:

> +X86 Documentation
> +=======================
> +
> +Control-flow Enforcement
> +========================
> +
> +.. toctree::
> +   :maxdepth: 1
> +
> +   intel_cet
> diff --git a/Documentation/x86/intel_cet.rst b/Documentation/x86/intel_cet.rst
> new file mode 100644
> index 000000000000..dac83bbf8a24
> --- /dev/null
> +++ b/Documentation/x86/intel_cet.rst
> @@ -0,0 +1,268 @@
> +.. SPDX-License-Identifier: GPL-2.0
> +
> +=========================================
> +Control-flow Enforcement Technology (CET)
> +=========================================
> +
> +[1] Overview
> +============
> +
> +Control-flow Enforcement Technology (CET) provides protection against
> +return/jump-oriented programming (ROP) attacks.  It can be setup to
> +protect both the kernel and applications.  In the first phase,
> +only the user-mode protection is implemented in 64-bit mode; 32-bit
> +applications are supported in compatibility mode.
> +
> +CET introduces shadow stack (SHSTK) and indirect branch tracking
> +(IBT).  SHSTK is a secondary stack allocated from memory and cannot
> +be directly modified by applications.  When executing a CALL, the
> +processor pushes a copy of the return address to SHSTK.  Upon
> +function return, the processor pops the SHSTK copy and compares it
> +to the one from the program stack.  If the two copies differ, the
> +processor raises a control-protection exception.  IBT verifies all
> +indirect CALL/JMP targets are intended as marked by the compiler
> +with 'ENDBR' opcodes (see CET instructions below).
> +
> +There are two kernel configuration options:
> +
> +    INTEL_X86_SHADOW_STACK_USER, and
> +    INTEL_X86_BRANCH_TRACKING_USER.
> +
> +To build a CET-enabled kernel, Binutils v2.31 and GCC v8.1 or later
> +are required.  To build a CET-enabled application, GLIBC v2.28 or
> +later is also required.
> +
> +There are two command-line options for disabling CET features:
> +
> +    no_cet_shstk - disables SHSTK, and
> +    no_cet_ibt - disables IBT.
> +
> +At run time, /proc/cpuinfo shows the availability of SHSTK and IBT.

What is the rough expected performance impact of CET on average function 
call frequency user applications and the kernel itself?

Thanks,

	Ingo
