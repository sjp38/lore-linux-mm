Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 87A846B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 16:08:07 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d3so3764026pgv.23
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 13:08:07 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id d31-v6si23537907pla.27.2018.11.13.13.08.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 13:08:05 -0800 (PST)
Message-ID: <43979cffef0a4b5ea90b3fc41b6f9edd2a4324db.camel@intel.com>
Subject: Re: [PATCH v5 05/27] Documentation/x86: Add CET description
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 13 Nov 2018 13:02:24 -0800
In-Reply-To: <20181113184337.GM10502@zn.tnic>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
	 <20181011151523.27101-6-yu-cheng.yu@intel.com>
	 <20181113184337.GM10502@zn.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, 2018-11-13 at 19:43 +0100, Borislav Petkov wrote:
> On Thu, Oct 11, 2018 at 08:15:01AM -0700, Yu-cheng Yu wrote:
> > Explain how CET works and the no_cet_shstk/no_cet_ibt kernel
> > parameters.
> > 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > ---
> >  .../admin-guide/kernel-parameters.txt         |   6 +
> >  Documentation/index.rst                       |   1 +
> >  Documentation/x86/index.rst                   |  11 +
> >  Documentation/x86/intel_cet.rst               | 266 ++++++++++++++++++
> >  4 files changed, 284 insertions(+)
> >  create mode 100644 Documentation/x86/index.rst
> >  create mode 100644 Documentation/x86/intel_cet.rst
> 
> So this patch should probably come first in the series so that a reader
> can know what to expect...
> 
> > diff --git a/Documentation/admin-guide/kernel-parameters.txt
> > b/Documentation/admin-guide/kernel-parameters.txt
> > index 92eb1f42240d..3854423f7c86 100644
> > --- a/Documentation/admin-guide/kernel-parameters.txt
> > +++ b/Documentation/admin-guide/kernel-parameters.txt
> > @@ -2764,6 +2764,12 @@
> >  			noexec=on: enable non-executable mappings (default)
> >  			noexec=off: disable non-executable mappings
> >  
> > +	no_cet_ibt	[X86-64] Disable indirect branch tracking for
> > user-mode
> > +			applications
> > +
> > +	no_cet_shstk	[X86-64] Disable shadow stack support for user-
> > mode
> > +			applications
> > +
> >  	nosmap		[X86]
> >  			Disable SMAP (Supervisor Mode Access Prevention)
> >  			even if it is supported by processor.
> > diff --git a/Documentation/index.rst b/Documentation/index.rst
> > index 5db7e87c7cb1..1cdc139adb40 100644
> > --- a/Documentation/index.rst
> > +++ b/Documentation/index.rst
> 
> Please integrate scripts/checkpatch.pl into your patch creation
> workflow. Some of the warnings/errors *actually* make sense:
> 
> WARNING: Missing or malformed SPDX-License-Identifier tag in line 1
> #76: FILE: Documentation/x86/index.rst:1:
> +=======================
> 
> WARNING: Missing or malformed SPDX-License-Identifier tag in line 1
> #93: FILE: Documentation/x86/intel_cet.rst:1:
> +=========================================
> 
> > @@ -104,6 +104,7 @@ implementation.
> >     :maxdepth: 2
> >  
> >     sh/index
> > +   x86/index
> >  
> >  Filesystem Documentation
> >  ------------------------
> > diff --git a/Documentation/x86/index.rst b/Documentation/x86/index.rst
> > new file mode 100644
> > index 000000000000..9c34d8cbc8f0
> > --- /dev/null
> > +++ b/Documentation/x86/index.rst
> > @@ -0,0 +1,11 @@
> > +=======================
> > +X86 Documentation
> > +=======================
> > +
> > +Control Flow Enforcement
> > +========================
> > +
> > +.. toctree::
> > +   :maxdepth: 1
> > +
> > +   intel_cet
> > diff --git a/Documentation/x86/intel_cet.rst
> > b/Documentation/x86/intel_cet.rst
> > new file mode 100644
> > index 000000000000..946f4802a51f
> > --- /dev/null
> > +++ b/Documentation/x86/intel_cet.rst
> > @@ -0,0 +1,266 @@
> > +=========================================
> > +Control Flow Enforcement Technology (CET)
> > +=========================================
> > +
> > +[1] Overview
> > +============
> > +
> > +Control Flow Enforcement Technology (CET) provides protection against
> > +return/jump-oriented programming (ROP) attacks.  It can be implemented
> > +to protect both the kernel and applications.  In the first phase,
> > +only the user-mode protection is implemented on the 64-bit kernel.
> 
> s/the//			         is implemented in 64-bit mode.
> 
> > +However, 32-bit applications are supported under the compatibility
> > +mode.
> 
> Drop "However":
> 
> "32-bit applications are, of course, supported in compatibility mode."
> 
> > +
> > +CET includes shadow stack (SHSTK) and indirect branch tracking (IBT).
> 
> "CET introduces two a shadow stack and an indirect branch tracking mechanism."
> 
> > +The SHSTK is a secondary stack allocated from memory.  The processor
> 
> s/The//
> 
> > +automatically pushes/pops a secure copy to the SHSTK every return
> > +address and,
> 
> that reads funny - pls reorganize. Also, what is a "secure copy"?
> 
> You mean a copy of every return address which software cannot access?
> 
> > by comparing the secure copy to the program stack copy,
> > +verifies function returns are as intended. 
> 
> 			 ... have not been corrupted/modified."
> 
> > The IBT verifies all
> > +indirect CALL/JMP targets are intended and marked by the compiler with
> > +'ENDBR' op codes.
> 
> "opcode" - one word. And before you use "ENDBR" you need to explain it
> above what it is.
> 
> /me reads further... encounters ENDBR's definition...
> 
> ah, ok, so you should say something like
> 
> "... and marked by the compiler with the ENDBR opcode (see below)."

I will work on it.  Thanks!

Yu-cheng
