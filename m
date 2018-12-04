Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5118E6B7090
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 15:32:56 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 82so9111958pfs.20
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:32:56 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id n30si13937140pgb.406.2018.12.04.12.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 12:32:55 -0800 (PST)
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
References: <cover.1543903910.git.alison.schofield@intel.com>
 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
 <CALCETrXM_nQMFHsAfQGqqURL3=B46AXdiG+4p8Mpm6n4cOqXsw@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <fa98a8d6-d592-0b49-c084-c20cca9a801f@intel.com>
Date: Tue, 4 Dec 2018 12:32:54 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrXM_nQMFHsAfQGqqURL3=B46AXdiG+4p8Mpm6n4cOqXsw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: alison.schofield@intel.com, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, David Howells <dhowells@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, James Morris <jmorris@namei.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kai.huang@intel.com, Jun Nakajima <jun.nakajima@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, keyrings@vger.kernel.org, LSM List <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On 12/4/18 12:00 PM, Andy Lutomirski wrote:
> On Tue, Dec 4, 2018 at 11:19 AM Andy Lutomirski <luto@kernel.org> wrote:
>> On Mon, Dec 3, 2018 at 11:37 PM Alison Schofield <alison.schofield@intel.com> wrote:
>> Finally, If you're going to teach the kernel how to have some user
>> pages that aren't in the direct map, you've essentially done XPO,
>> which is nifty but expensive.  And I think that doing this gets you
>> essentially all the benefit of MKTME for the non-pmem use case.  Why
>> exactly would any software want to use anything other than a
>> CPU-managed key for anything other than pmem?
> 
> Let me say this less abstractly.  Here's a somewhat concrete actual
> proposal.  Make a new memfd_create() flag like MEMFD_ISOLATED.  The
> semantics are that the underlying pages are made not-present in the
> direct map when they're allocated (which is hideously slow, but so be
> it), and that anything that tries to get_user_pages() the resulting
> pages fails.  And then make sure we have all the required APIs so that
> QEMU can still map this stuff into a VM.

I think we need get_user_pages().  We want direct I/O to work, *and* we
really want direct device assignment into VMs.

> And maybe we get fancy and encrypt this memory when it's swapped, but
> maybe we should just encrypt everything when it's swapped.

We decided long ago (and this should be in the patches somewhere) that
we wouldn't force memory to be encrypted in swap.  We would just
recommend it in the documentation as a best practice, especially when
using MKTME.

We can walk that back, of course, but that's what we're doing at the moment.
