Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB906B026F
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 18:11:55 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id t77so5055794pfe.10
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 15:11:55 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x4si14346296pln.635.2017.11.22.15.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 15:11:54 -0800 (PST)
Subject: Re: [PATCH 08/30] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193112.6A962D6A@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711201518490.1734@nanos>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <49e4951d-7281-b37a-5359-ba215dcc49f3@linux.intel.com>
Date: Wed, 22 Nov 2017 15:11:51 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711201518490.1734@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 11/20/2017 09:21 AM, Thomas Gleixner wrote:
>> +KAISER logically keeps a "copy" of the page tables which unmap
>> +the kernel while in userspace.  The kernel manages the page
>> +tables as normal, but the "copying" is done with a few tricks
>> +that mean that we do not have to manage two full copies.
>> +The first trick is that for any any new kernel mapping, we
>> +presume that we do not want it mapped to userspace.  That means
>> +we normally have no copying to do.  We only copy the kernel
>> +entries over to the shadow in response to a kaiser_add_*()
>> +call which is rare.
>  When KAISER is enabled the kernel manages two page tables for the kernel
>  mappings. The regular page table which is used while executing in kernel
>  space and a shadow copy which only contains the mapping entries which are
>  required for the kernel-userspace transition. These mappings have to be
>  copied into the shadow page tables explicitely with the kaiser_add_*()
>  functions.

This misses a few important points that I think the original text
touches on.  I gave it another go:

> Page Table Management
> =====================
> 
> When KAISER is enabled, the kernel manages two sets of page
> tables.  The first copy is very similar to what would be present
> for a kernel without KAISER.  This includes a complete mapping of
> userspace that the kernel can use for things like copy_to_user().
> 
> The second (shadow) is used when running userspace and mirrors the
> mapping of userspace present in the kernel copy.  It maps a only
> the kernel data needed to enter and exit the kernel.
> 
> The shadow is populated by the kaiser_add_*() functions.  Only
> kernel data which has been explicity mapped will appear in the
> shadow copy.  These calls are rare at runtime.
> 
> For a new userspace mapping, the kernel makes the entries in its
> page tables like normal.  The only difference is when the kernel
> makes entries in the top (PGD) level.  In addition to setting the
> entry in the main kernel PGD, a copy if the entry is made in the
> shadow PGD.
> 
> For user space mappings the kernel creates an entry in the kernel
> PGD and the same entry in the shadow PGD, so the underlying page
> table to which the PGD entry points is shared down to the PTE
> level.  This leaves a single, shared set of userspace page tables
> to manage.  One PTE to lock, one set set of accessed bits, dirty
> bits, etc...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
