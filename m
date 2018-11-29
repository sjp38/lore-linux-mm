Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5787F6B5519
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 18:19:21 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id e89so2900675pfb.17
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 15:19:21 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x5si2693884pga.440.2018.11.29.15.19.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 15:19:20 -0800 (PST)
Date: Fri, 30 Nov 2018 08:19:13 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH 0/2] =?ISO-2022-JP?B?RG9uGyRCIUcbKEJ0?= leave executable
 TLB entries to freed pages
Message-Id: <20181130081913.916a27c8230b125da4bcf2f7@kernel.org>
In-Reply-To: <4cddc2ba36ba3b6d528556207b8d4592209797ea.camel@intel.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
	<20181129230616.f017059a093841dbaa4b82e6@kernel.org>
	<4cddc2ba36ba3b6d528556207b8d4592209797ea.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "ast@kernel.org" <ast@kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jannh@google.com" <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

On Thu, 29 Nov 2018 18:49:26 +0000
"Edgecombe, Rick P" <rick.p.edgecombe@intel.com> wrote:

> On Thu, 2018-11-29 at 23:06 +0900, Masami Hiramatsu wrote:
> > On Tue, 27 Nov 2018 16:07:52 -0800
> > Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:
> > 
> > > Sometimes when memory is freed via the module subsystem, an executable
> > > permissioned TLB entry can remain to a freed page. If the page is re-used to
> > > back an address that will receive data from userspace, it can result in user
> > > data being mapped as executable in the kernel. The root of this behavior is
> > > vfree lazily flushing the TLB, but not lazily freeing the underlying pages. 
> > 
> > Good catch!
> > 
> > > 
> > > There are sort of three categories of this which show up across modules,
> > > bpf,
> > > kprobes and ftrace:
> > 
> > For x86-64 kprobe, it sets the page NX and after that RW, and then release
> > via module_memfree. So I'm not sure it really happens on kprobes. (Of course
> > the default memory allocator is simpler so it may happen on other archs) But
> > interesting fixes.
> Yes, I think you are right, it should not leave an executable TLB entry in this
> case. Ftrace actually does this on x86 as well.
> 
> Is there some other reason for calling set_memory_nx that should apply elsewhere
> for module users? Or could it be removed in the case of this patch to centralize
> the behavior?

According to the commit c93f5cf571e7 ("kprobes/x86: Fix to set RWX bits correctly
before releasing trampoline"), if we release readonly page by module_memfree(),
it causes kernel crash. And at this moment, on x86-64 set the trampoline page
readonly becuase it is an exacutable page. Setting NX bit is for security reason
that should be set before making it writable.
So I think if you centralize setting NX bit, it should be done before setting
writable bit.

Thank you,


-- 
Masami Hiramatsu <mhiramat@kernel.org>
