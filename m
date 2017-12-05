Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 728D06B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 16:28:00 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g202so3360566ita.4
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 13:28:00 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id x87si682932ioi.163.2017.12.05.13.27.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 13:27:59 -0800 (PST)
Date: Tue, 5 Dec 2017 22:27:27 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 5/9] x86/uv: Use the right tlbflush API
Message-ID: <20171205212727.GU3165@worktop.lehotels.local>
References: <20171205123444.990868007@infradead.org>
 <20171205123820.134563117@infradead.org>
 <5aed7d7f-b093-b65c-403e-46bdbcf9bc5a@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5aed7d7f-b093-b65c-403e-46bdbcf9bc5a@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Banman <abanman@hpe.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Mike Travis <mike.travis@hpe.com>

On Tue, Dec 05, 2017 at 03:09:48PM -0600, Andrew Banman wrote:
> On 12/5/17 6:34 AM, Peter Zijlstra wrote:
> >Since uv_flush_tlb_others() implements flush_tlb_others() which is
> >about flushing user mappings, we should use __flush_tlb_single(),
> >which too is about flushing user mappings.
> >
> >Cc: Andrew Banman<abanman@hpe.com>
> >Cc: Mike Travis<mike.travis@hpe.com>
> >Signed-off-by: Peter Zijlstra (Intel)<peterz@infradead.org>
> >---
> >  arch/x86/platform/uv/tlb_uv.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> >--- a/arch/x86/platform/uv/tlb_uv.c
> >+++ b/arch/x86/platform/uv/tlb_uv.c
> >@@ -299,7 +299,7 @@ static void bau_process_message(struct m
> >  		local_flush_tlb();
> >  		stat->d_alltlb++;
> >  	} else {
> >-		__flush_tlb_one(msg->address);
> >+		__flush_tlb_single(msg->address);
> >  		stat->d_onetlb++;
> >  	}
> >  	stat->d_requestee++;
> 
> This looks like the right thing to do. We'll be testing it and complain later if
> we find any problems, but I'm not expecting any since this patch looks to
> maintain our status quo.

Well, with KPTI (the-patch-set-formerly-known-as-kaiser), there will be
a distinct difference between the two.

With KPTI __flush_tlb_one() would end up invalidating all kernel
mappings while __flush_tlb_single() will end up only invalidating the
user mappings of the current mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
