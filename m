Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id BA25C6B0008
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 16:23:07 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id o2-v6so4059182plk.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 13:23:07 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id w19-v6si1046366plq.250.2018.04.02.13.23.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Apr 2018 13:23:06 -0700 (PDT)
Subject: Re: [PATCH 01/11] x86/mm: factor out pageattr _PAGE_GLOBAL setting
References: <20180402172700.65CAE838@viggo.jf.intel.com>
 <20180402172701.5D4CA7DD@viggo.jf.intel.com>
 <CA+55aFw7mLJrr+VqvEY-T3KqR2-xaYSoyU2Jg7VY1Sb1cu1L-w@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <36637d85-d716-a2d4-189c-10ed209f4827@linux.intel.com>
Date: Mon, 2 Apr 2018 13:23:04 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFw7mLJrr+VqvEY-T3KqR2-xaYSoyU2Jg7VY1Sb1cu1L-w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On 04/02/2018 10:52 AM, Linus Torvalds wrote:
> On Mon, Apr 2, 2018 at 10:27 AM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
>>
>> Aside: _PAGE_GLOBAL is ignored when CR4.PGE=1, so why do we
>> even go to the trouble of filtering it anywhere?
> 
> I'm assuming this is a typo, and you mean "when CR4.PGE=0".

Yes, that is a typo.

> The question you raise may be valid, but within the particular context
> of *this* patch it is not.

I thought it was relevant because I was asking myself: Why is it OK for
the (old) code to be doing this:

> -	if (pgprot_val(req_prot) & _PAGE_PRESENT)
> -		pgprot_val(req_prot) |= _PAGE_PSE | _PAGE_GLOBAL;

When _PAGE_GLOBAL is not supported.  This "Aside" got moved a bit away
from the comment, but I actually mean to refer to the comment that talks
about canon_pgprot():

>> canon_pgprot() will clear it if unsupported,
>> but we *always* set it.

and its use of __supported_pte_mask.

I'll redo the changelog a bit and hopefully capture all this along with
correcting the typo.
