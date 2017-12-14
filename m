Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B81AF6B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 14:44:00 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id g69so10285967ita.9
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 11:44:00 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id g4si3679993ite.50.2017.12.14.11.43.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 11:43:59 -0800 (PST)
Date: Thu, 14 Dec 2017 20:43:34 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 06/17] x86/ldt: Do not install LDT for kernel threads
Message-ID: <20171214194334.GD3326@worktop>
References: <20171214112726.742649793@infradead.org>
 <20171214113851.398563731@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171214113851.398563731@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

On Thu, Dec 14, 2017 at 12:27:32PM +0100, Peter Zijlstra wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
> 
> Kernel threads can use the mm of a user process temporarily via use_mm(),
> but there is no point in installing the LDT which is associated to that mm
> for the kernel thread.

So thinking about this a bit more; I fear its not correct.

Suppose a kthread does use_mm() and we then schedule to a task of that
process, we'll not pass through switch_mm() and we'll not install the
LDT and bad things happen.

Or am I missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
