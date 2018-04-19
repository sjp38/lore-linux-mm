Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CAA126B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 12:02:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d13so2988469pfn.21
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 09:02:53 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 1-v6si3806397plo.228.2018.04.19.09.02.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 09:02:50 -0700 (PDT)
Subject: Re: [PATCH 11/11] x86/pti: leave kernel text global for !PCID
References: <20180406205501.24A1A4E7@viggo.jf.intel.com>
 <20180406205518.E3D989EB@viggo.jf.intel.com>
 <CAGXu5jJS-PYS7ONy_neDQCqVGRwrtjg=VdktXALQnzRe1+RNuA@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <db2f91ab-9565-7bda-b3c3-a1cdb61d1587@linux.intel.com>
Date: Thu, 19 Apr 2018 09:02:31 -0700
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJS-PYS7ONy_neDQCqVGRwrtjg=VdktXALQnzRe1+RNuA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, namit@vmware.com

On 04/18/2018 05:11 PM, Kees Cook wrote:
> On Fri, Apr 6, 2018 at 1:55 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
>> +/*
>> + * For some configurations, map all of kernel text into the user page
>> + * tables.  This reduces TLB misses, especially on non-PCID systems.
>> + */
>> +void pti_clone_kernel_text(void)
>> +{
>> +       unsigned long start = PFN_ALIGN(_text);
>> +       unsigned long end = ALIGN((unsigned long)_end, PMD_PAGE_SIZE);
> I think this is too much set global: _end is after data, bss, and brk,
> and all kinds of other stuff that could hold secrets. I think this
> should match what mark_rodata_ro() is doing and use
> __end_rodata_hpage_align. (And on i386, this should be maybe _etext.)

Sounds reasonable to me.  This does assume that there are no secrets
built into the kernel image, right?
