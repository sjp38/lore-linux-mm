Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 010E76B03BD
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 16:06:02 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id w10-v6so12866581plz.0
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 13:06:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m6-v6si24601628pls.35.2018.11.06.13.06.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 13:06:00 -0800 (PST)
Date: Tue, 6 Nov 2018 13:05:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 4/4] Kselftest for module text allocation
 benchmarking
Message-Id: <20181106130557.11bfeddafe103bb609352aba@linux-foundation.org>
In-Reply-To: <20181102192520.4522-5-rick.p.edgecombe@intel.com>
References: <20181102192520.4522-1-rick.p.edgecombe@intel.com>
	<20181102192520.4522-5-rick.p.edgecombe@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: jeyu@kernel.org, willy@infradead.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org, kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com

On Fri,  2 Nov 2018 12:25:20 -0700 Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:

> This adds a test module in lib/, and a script in kselftest that does
> benchmarking on the allocation of memory in the module space. Performance here
> would have some small impact on kernel module insertions, BPF JIT insertions
> and kprobes. In the case of KASLR features for the module space, this module
> can be used to measure the allocation performance of different configurations.
> This module needs to be compiled into the kernel because module_alloc is not
> exported.

Well, we could export module_alloc().  Would that be helpful at all?

> With some modification to the code, as explained in the comments, it can be
> enabled to measure TLB flushes as well.
> 
> There are two tests in the module. One allocates until failure in order to
> test module capacity and the other times allocating space in the module area.
> They both use module sizes that roughly approximate the distribution of in-tree
> X86_64 modules.
> 
> You can control the number of modules used in the tests like this:
> echo m1000>/dev/mod_alloc_test
> 
> Run the test for module capacity like:
> echo t1>/dev/mod_alloc_test
> 
> The other test will measure the allocation time, and for CONFG_X86_64 and
> CONFIG_RANDOMIZE_BASE, also give data on how often the a??backup area" is used.
> 
> Run the test for allocation time and backup area usage like:
> echo t2>/dev/mod_alloc_test
> The output will be something like this:
> num		all(ns)		last(ns)
> 1000		1083		1099
> Last module in backup count = 0
> Total modules in backup     = 0
> >1 module in backup count   = 0

Are the above usage instructions captured in the kernel code somewhere?
I can't see it, and expecting people to trawl git changelogs isn't
very friendly.
