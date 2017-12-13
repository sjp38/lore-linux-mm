Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7096C6B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 16:50:49 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z25so2265825pgu.18
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 13:50:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f11si1840527pgq.352.2017.12.13.13.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 13:50:47 -0800 (PST)
Date: Wed, 13 Dec 2017 13:50:22 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Message-ID: <20171213215022.GA27778@bombadil.infradead.org>
References: <20171212173221.496222173@linutronix.de>
 <20171212173333.669577588@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171212173333.669577588@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

On Tue, Dec 12, 2017 at 06:32:26PM +0100, Thomas Gleixner wrote:
> From: Peter Zijstra <peterz@infradead.org>
> 
> In order to create VMAs that are not accessible to userspace create a new
> VM_NOUSER flag. This can be used in conjunction with
> install_special_mapping() to inject 'kernel' data into the userspace map.

Maybe I misunderstand the intent behind this, but I was recently looking
at something kind of similar.  I was calling it VM_NOTLB and it wouldn't
put TLB entries into the userspace map at all.  The idea was to be able
to use the user address purely as a handle for specific kernel pages,
which were guaranteed to never be mapped into userspace, so we didn't
need to send TLB invalidations when we took those pages away from the user
process again.  But we'd be able to pass the address to read() or write().

So I was going to check the VMA flags in no_page_table() and return the
struct page that was notmapped there.  I didn't get as far as constructing
a prototype yet, and I'm not entirely sure I understand the purpose of
this patch, so perhaps there's no synergy here at all (and perhaps my
idea wouldn't have worked anyway).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
