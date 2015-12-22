Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id E1EBA82F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 12:51:16 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id u7so63188268pfb.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 09:51:16 -0800 (PST)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id lj14si5382107pab.100.2015.12.22.09.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 09:51:15 -0800 (PST)
Received: by mail-pf0-x236.google.com with SMTP id q63so3642363pfb.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 09:51:15 -0800 (PST)
Subject: Re: [kernel-hardening] [RFC][PATCH 6/7] mm: Add Kconfig option for
 slab sanitization
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
 <1450755641-7856-7-git-send-email-laura@labbott.name>
 <CA+rthh-X2jvGpptE72CCbOx2MdkukJSCu621+9ymMJ_pCQ9t+w@mail.gmail.com>
From: Laura Abbott <laura@labbott.name>
Message-ID: <56798D8F.9090402@labbott.name>
Date: Tue, 22 Dec 2015 09:51:11 -0800
MIME-Version: 1.0
In-Reply-To: <CA+rthh-X2jvGpptE72CCbOx2MdkukJSCu621+9ymMJ_pCQ9t+w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathias Krause <minipli@googlemail.com>, kernel-hardening@lists.openwall.com
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kees Cook <keescook@chromium.org>

On 12/22/15 1:33 AM, Mathias Krause wrote:
> On 22 December 2015 at 04:40, Laura Abbott <laura@labbott.name> wrote:
>>
>> +config SLAB_MEMORY_SANITIZE
>> +       bool "Sanitize all freed memory"
>> +       help
>> +         By saying Y here the kernel will erase slab objects as soon as they
>> +         are freed.  This in turn reduces the lifetime of data
>> +         stored in them, making it less likely that sensitive information such
>> +         as passwords, cryptographic secrets, etc stay in memory for too long.
>> +
>
>> +         This is especially useful for programs whose runtime is short, long
>> +         lived processes and the kernel itself benefit from this as long as
>> +         they ensure timely freeing of memory that may hold sensitive
>> +         information.
>
> This part is not true. The code is handling SLAB objects only, so
> talking about processes in this context is misleading. Freeing memory
> in userland containing secrets cannot be covered by this feature as
> is. It needs a counter-part in the userland memory allocator as well
> as handling page sanitization in the buddy allocator.
>
> I guess you've just copy+pasted that Kconfig description from the PaX
> feature PAX_MEMORY_SANITIZE that also covers the buddy allocator,
> therefore fits that description while this patch set does not. So
> please adapt the text or implement the fully featured version.
>

I was thinking of secrets that may be stored in the slab allocator. While
certainly not as common they would exist. I'll clarify the text though
to make it obvious this is for kernel slab memory only.
  
>> +
>> +         A nice side effect of the sanitization of slab objects is the
>> +         reduction of possible info leaks caused by padding bytes within the
>> +         leaky structures.  Use-after-free bugs for structures containing
>> +         pointers can also be detected as dereferencing the sanitized pointer
>> +         will generate an access violation.
>> +
>> +         The tradeoff is performance impact. The noticible impact can vary
>> +         and you are advised to test this feature on your expected workload
>> +         before deploying it
>> +
>
>> +         The slab sanitization feature excludes a few slab caches per default
>> +         for performance reasons. The level of sanitization can be adjusted
>> +         with the sanitize_slab commandline option:
>> +               sanitize_slab=off: No sanitization will occur
>> +               santiize_slab=slow: Sanitization occurs only on the slow path
>> +               for all but the excluded slabs
>> +               (relevant for SLUB allocator only)
>> +               sanitize_slab=partial: Sanitization occurs on all path for all
>> +               but the excluded slabs
>> +               sanitize_slab=full: All slabs are sanitize
>
> This should probably be moved to Documentation/kernel-parameters.txt,
> as can be found in the PaX patch[1]?
>

Yes, I missed that. I'll fix that.
  
>> +
>> +         If unsure, say Y here.
>
> Really? It has an unknown performance impact, depending on the
> workload, which might make "unsure users" preferably say No, if they
> don't care about info leaks.

This is getting to the argument about security vs. performance and
what should be default. I think this deserves more advice than just
"If unsure, do X" so I'll add some more description about the trade
offs.

>
> Related to this, have you checked that the sanitization doesn't
> interfere with the various slab handling schemes, namely RCU related
> specialties? Not all caches are marked SLAB_DESTROY_BY_RCU, some use
> call_rcu() instead, implicitly relying on the semantics RCU'ed slabs
> permit, namely allowing a "use-after-free" access to be legitimate
> within the RCU grace period. Scrubbing the object during that period
> would break that assumption.

I haven't looked into that. I was working off the assumption that
if the regular SLAB debug poisoning worked so would the sanitization.
The regular debug poisoning only checks for SLAB_DESTROY_BY_RCU so
how does that work then?

>
> Speaking of RCU, do you have a plan to support RCU'ed slabs as well?
>

My only plan was to get the base support in. I didn't have a plan to
support RCU slabs but that's certainly something to be done in the
future.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
