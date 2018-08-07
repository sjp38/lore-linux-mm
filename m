Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 135B36B0007
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 14:34:51 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v9-v6so11023444pfn.6
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 11:34:51 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 25-v6si1760466pgk.438.2018.08.07.11.34.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 11:34:49 -0700 (PDT)
Subject: Re: [PATCH 2/3] x86/mm/pti: Don't clear permissions in
 pti_clone_pmd()
References: <1533637471-30953-1-git-send-email-joro@8bytes.org>
 <1533637471-30953-3-git-send-email-joro@8bytes.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <feea2aff-91ff-89a6-9d7c-5402a1d6a27f@intel.com>
Date: Tue, 7 Aug 2018 11:34:46 -0700
MIME-Version: 1.0
In-Reply-To: <1533637471-30953-3-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de

On 08/07/2018 03:24 AM, Joerg Roedel wrote:
> The function sets the global-bit on cloned PMD entries,
> which only makes sense when the permissions are identical
> between the user and the kernel page-table.
> 
> Further, only write-permissions are cleared for entry-text
> and kernel-text sections, which are not writeable anyway.

I think this patch is correct, but I'd be curious if Andy remembers why
we chose to clear _PAGE_RW on these things.  It might have been that we
were trying to say that the *entry* code shouldn't write to this stuff,
regardless of whether the normal kernel can.

But, either way, I agree with the logic here that Global pages must
share permissions between both mappings, so feel free to add my Ack.  I
just want to make sure Andy doesn't remember some detail I'm forgetting.
