Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 231906B7BB6
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 14:31:39 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 4so927361plc.5
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 11:31:39 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id j5si965277pfg.254.2018.12.06.11.31.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 11:31:38 -0800 (PST)
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
References: <cover.1543903910.git.alison.schofield@intel.com>
 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
 <c610138f-32dd-a24c-dc52-4e0006a21409@intel.com>
 <CALCETrU34U3berTaEQbvNt0rfCdsjwj+xDb8x7bgAMFHEo=eUw@mail.gmail.com>
 <5e97e1bf-536c-ef73-576e-54145eee1ae9@intel.com>
 <CALCETrVPhay-ziRVjL9dDCwJQHhr4HfG5aGJzYh06k6HEMZTiQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7116c946-4e4b-c7cf-e28a-1a2b932f61f2@intel.com>
Date: Thu, 6 Dec 2018 11:31:37 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrVPhay-ziRVjL9dDCwJQHhr4HfG5aGJzYh06k6HEMZTiQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Alison Schofield <alison.schofield@intel.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, David Howells <dhowells@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, James Morris <jmorris@namei.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kai.huang@intel.com, Jun Nakajima <jun.nakajima@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, keyrings@vger.kernel.org, LSM List <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On 12/6/18 11:10 AM, Andy Lutomirski wrote:
>> On Dec 6, 2018, at 7:39 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>>The coherency is "fine" unless you have writeback of an older
>> cacheline that blows away newer data.  CPUs that support MKTME are
>> guaranteed to never do writeback of the lines that could be established
>> speculatively or from prefetching.
> 
> How is that sufficient?  Suppose I have some physical page mapped with
> keys 1 and 2. #1 is logically live and I write to it.  Then I prefetch
> or otherwise populate mapping 2 into the cache (in the S state,
> presumably).  Now I clflush mapping 1 and read 2.  It contains garbage
> in the cache, but the garbage in the cache is inconsistent with the
> garbage in memory.  This can’t be a good thing, even if no writeback
> occurs.
> 
> I suppose the right fix is to clflush the old mapping and then to zero
> the new mapping.

Yep.  Practically, you need to write to the new mapping to give it any
meaning.  Those writes effectively blow away any previously cached,
garbage contents.

I think you're right, though, that the cached data might not be
_consistent_ with what is in memory.  It feels really dirty, but I can't
think of any problems that it actually causes.
