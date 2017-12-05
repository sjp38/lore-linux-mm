Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 438286B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 16:10:06 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x24so1097284pgv.5
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 13:10:06 -0800 (PST)
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com. [15.233.44.26])
        by mx.google.com with ESMTPS id o2si656840pls.171.2017.12.05.13.10.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 13:10:05 -0800 (PST)
Subject: Re: [PATCH 5/9] x86/uv: Use the right tlbflush API
References: <20171205123444.990868007@infradead.org>
 <20171205123820.134563117@infradead.org>
From: Andrew Banman <abanman@hpe.com>
Message-ID: <5aed7d7f-b093-b65c-403e-46bdbcf9bc5a@hpe.com>
Date: Tue, 5 Dec 2017 15:09:48 -0600
MIME-Version: 1.0
In-Reply-To: <20171205123820.134563117@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Mike Travis <mike.travis@hpe.com>

On 12/5/17 6:34 AM, Peter Zijlstra wrote:
> Since uv_flush_tlb_others() implements flush_tlb_others() which is
> about flushing user mappings, we should use __flush_tlb_single(),
> which too is about flushing user mappings.
> 
> Cc: Andrew Banman<abanman@hpe.com>
> Cc: Mike Travis<mike.travis@hpe.com>
> Signed-off-by: Peter Zijlstra (Intel)<peterz@infradead.org>
> ---
>   arch/x86/platform/uv/tlb_uv.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/arch/x86/platform/uv/tlb_uv.c
> +++ b/arch/x86/platform/uv/tlb_uv.c
> @@ -299,7 +299,7 @@ static void bau_process_message(struct m
>   		local_flush_tlb();
>   		stat->d_alltlb++;
>   	} else {
> -		__flush_tlb_one(msg->address);
> +		__flush_tlb_single(msg->address);
>   		stat->d_onetlb++;
>   	}
>   	stat->d_requestee++;

This looks like the right thing to do. We'll be testing it and complain later if
we find any problems, but I'm not expecting any since this patch looks to
maintain our status quo.

Best,

Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
