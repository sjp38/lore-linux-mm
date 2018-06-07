Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3EBD06B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 16:33:30 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id g6-v6so6012193plq.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 13:33:30 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id q8-v6si1269916pfa.272.2018.06.07.13.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 13:33:29 -0700 (PDT)
Message-ID: <1528403417.5265.35.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 07 Jun 2018 13:30:17 -0700
In-Reply-To: <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <20180607143807.3611-7-yu-cheng.yu@intel.com>
	 <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, 2018-06-07 at 11:48 -0700, Andy Lutomirski wrote:
> On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> >
> > The following operations are provided.
> >
> > ARCH_CET_STATUS:
> >         return the current CET status
> >
> > ARCH_CET_DISABLE:
> >         disable CET features
> >
> > ARCH_CET_LOCK:
> >         lock out CET features
> >
> > ARCH_CET_EXEC:
> >         set CET features for exec()
> >
> > ARCH_CET_ALLOC_SHSTK:
> >         allocate a new shadow stack
> >
> > ARCH_CET_PUSH_SHSTK:
> >         put a return address on shadow stack
> >
> > ARCH_CET_ALLOC_SHSTK and ARCH_CET_PUSH_SHSTK are intended only for
> > the implementation of GLIBC ucontext related APIs.
> 
> Please document exactly what these all do and why.  I don't understand
> what purpose ARCH_CET_LOCK and ARCH_CET_EXEC serve.  CET is opt in for
> each ELF program, so I think there should be no need for a magic
> override.

CET is initially enabled if the loader has CET capability.  Then the
loader decides if the application can run with CET.  If the application
cannot run with CET (e.g. a dependent library does not have CET), then
the loader turns off CET before passing to the application.  When the
loader is done, it locks out CET and the feature cannot be turned off
anymore until the next exec() call.  When the next exec() is called, CET
feature is turned on/off based on the values set by ARCH_CET_EXEC.

I will put more details in Documentation/x86/intel_cet.txt.
 
