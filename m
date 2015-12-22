Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id BF0866B0266
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 13:19:41 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id 78so37222074pfw.2
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 10:19:41 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id h65si2275639pfd.162.2015.12.22.10.19.41
        for <linux-mm@kvack.org>;
        Tue, 22 Dec 2015 10:19:41 -0800 (PST)
Subject: Re: [kernel-hardening] [RFC][PATCH 6/7] mm: Add Kconfig option for
 slab sanitization
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
 <1450755641-7856-7-git-send-email-laura@labbott.name>
 <567964F3.2020402@intel.com>
 <alpine.DEB.2.20.1512221023550.2748@east.gentwo.org>
 <567986E7.50107@intel.com>
 <alpine.DEB.2.20.1512221124230.14335@east.gentwo.org>
 <56798851.60906@intel.com>
 <alpine.DEB.2.20.1512221207230.14406@east.gentwo.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5679943C.1050604@intel.com>
Date: Tue, 22 Dec 2015 10:19:40 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1512221207230.14406@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <laura@labbott.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On 12/22/2015 10:08 AM, Christoph Lameter wrote:
> On Tue, 22 Dec 2015, Dave Hansen wrote:
>>> Why would you use zeros? The point is just to clear the information right?
>>> The regular poisoning does that.
>>
>> It then allows you to avoid the zeroing at allocation time.
> 
> Well much of the code is expecting a zeroed object from the allocator and
> its zeroed at that time. Zeroing makes the object cache hot which is an
> important performance aspect.

Yes, modifying this behavior has a performance impact.  It absolutely
needs to be evaluated, and I wouldn't want to speculate too much on how
good or bad any of the choices are.

Just to reiterate, I think we have 3 real choices here:

1. Zero at alloc, only when __GFP_ZERO
   (behavior today)
2. Poison at free, also Zero at alloc (when __GFP_ZERO)
   (this patch's proposed behavior, also what current poisoning does,
    doubles writes)
3. Zero at free, *don't* Zero at alloc (when __GFP_ZERO)
   (what I'm suggesting, possibly less perf impact vs. #2)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
