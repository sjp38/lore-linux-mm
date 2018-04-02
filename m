Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF636B000E
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 16:41:59 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id c2-v6so3091872plo.21
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 13:41:59 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id w33-v6si1105407plb.176.2018.04.02.13.41.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Apr 2018 13:41:58 -0700 (PDT)
Subject: Re: [PATCH 09/11] x86/pti: enable global pages for shared areas
References: <20180402172700.65CAE838@viggo.jf.intel.com>
 <20180402172713.B7D6F0C0@viggo.jf.intel.com>
 <CA+55aFx5GCahkr_-Y0qF5S=USCXhNcvWZ6gr_TxpvUVAh46STA@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <503339cf-7e54-0888-1767-c8ac87ce2130@linux.intel.com>
Date: Mon, 2 Apr 2018 13:41:57 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFx5GCahkr_-Y0qF5S=USCXhNcvWZ6gr_TxpvUVAh46STA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On 04/02/2018 10:56 AM, Linus Torvalds wrote:
> On Mon, Apr 2, 2018 at 10:27 AM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
>> +       /*
>> +        * The cpu_entry_area is shared between the user and kernel
>> +        * page tables.  All of its ptes can safely be global.
>> +        */
>> +       if (boot_cpu_has(X86_FEATURE_PGE))
>> +               pte = pte_set_flags(pte, _PAGE_GLOBAL);
> So this is where the quesion of "why is this conditional" is valid.
> 
> We could set _PAGE_GLOBAL unconditionally, not bothering with testing
> X86_FEATURE_PGE.

I think we should just keep the check for now.  Before this patch set,
on !X86_FEATURE_PGE systems, we cleared _PAGE_GLOBAL in virtually all
places due to masking via __supported_pte_mask.

It is rather harmless either way, but being _consistent_ (by keeping the
check) with all of our PTEs is nice.
