Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3566728025A
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:53:21 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 191so2878034pgd.0
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:53:21 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y10si1330495pgq.774.2017.11.01.08.53.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 08:53:20 -0700 (PDT)
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <8ea53aa4-34ee-15ab-c28c-04cf3c2e979b@linux.intel.com>
Date: Wed, 1 Nov 2017 08:53:18 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>

On 10/31/2017 04:27 PM, Linus Torvalds wrote:
>      So even if you don't want to have global pages for normal kernel
> entries, you don't want to just make _PAGE_GLOBAL be defined as zero.
> You'd want to just use _PAGE_GLOBAL conditionally.

I implemented this, then did a quick test with some code that does a
bunch of quick system calls:

> 	https://github.com/antonblanchard/will-it-scale/blob/master/tests/lseek1.c

It helps a wee bit (~3%) with PCIDs, and much more when PCIDs are not in
use (~15%).  Here are the numbers:  ("ge" means "Global Entry"):

no kaiser       : 5.2M
kaiser+  pcid	: 3.0M
kaiser+  pcid+ge: 3.1M
kaiser+nopcid   : 2.2M
kaiser+nopcid+ge: 2.5M

This *does* use Global pages for the process stack (which is not idea),
but it sounds like Andy's entry stack stuff will get rid of the need to
do that in the first place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
