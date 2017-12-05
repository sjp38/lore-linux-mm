Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 74FE36B0268
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 07:41:40 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id f185so839868itc.2
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 04:41:40 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f39si42245iod.135.2017.12.05.04.41.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 04:41:39 -0800 (PST)
Message-Id: <20171205123820.134563117@infradead.org>
Date: Tue, 05 Dec 2017 13:34:50 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 5/9] x86/uv: Use the right tlbflush API
References: <20171205123444.990868007@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-tlb-uv.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Andrew Banman <abanman@hpe.com>, Mike Travis <mike.travis@hpe.com>

Since uv_flush_tlb_others() implements flush_tlb_others() which is
about flushing user mappings, we should use __flush_tlb_single(),
which too is about flushing user mappings.

Cc: Andrew Banman <abanman@hpe.com>
Cc: Mike Travis <mike.travis@hpe.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/platform/uv/tlb_uv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/arch/x86/platform/uv/tlb_uv.c
+++ b/arch/x86/platform/uv/tlb_uv.c
@@ -299,7 +299,7 @@ static void bau_process_message(struct m
 		local_flush_tlb();
 		stat->d_alltlb++;
 	} else {
-		__flush_tlb_one(msg->address);
+		__flush_tlb_single(msg->address);
 		stat->d_onetlb++;
 	}
 	stat->d_requestee++;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
