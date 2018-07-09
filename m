Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC206B0331
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 14:59:46 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h14-v6so12286413pfi.19
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 11:59:46 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 11-v6si15428146plb.195.2018.07.09.11.59.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 11:59:45 -0700 (PDT)
Subject: Re: [PATCHv4 18/18] x86: Introduce CONFIG_X86_INTEL_MKTME
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-19-kirill.shutemov@linux.intel.com>
 <20180709183656.GK6873@char.US.ORACLE.com>
 <d9edff3d-64bd-be81-c9fd-52699d7da81e@intel.com>
 <20180709185246.GC17368@char.us.oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7491deb5-c89e-cbd0-6c17-404d26c30aeb@intel.com>
Date: Mon, 9 Jul 2018 11:59:33 -0700
MIME-Version: 1.0
In-Reply-To: <20180709185246.GC17368@char.us.oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/09/2018 11:52 AM, Konrad Rzeszutek Wilk wrote:
> On Mon, Jul 09, 2018 at 11:44:33AM -0700, Dave Hansen wrote:
>> On 07/09/2018 11:36 AM, Konrad Rzeszutek Wilk wrote:
>>> On Tue, Jun 26, 2018 at 05:22:45PM +0300, Kirill A. Shutemov wrote:
>>> Rip out the X86?
>>>> +	bool "Intel Multi-Key Total Memory Encryption"
>>>> +	select DYNAMIC_PHYSICAL_MASK
>>>> +	select PAGE_EXTENSION
>>>
>>> And maybe select 5-page?
>>
>> Why?  It's not a strict dependency.  You *can* build a 4-level kernel
>> and run it on smaller systems.
> 
> Sure, but in one of his commits he mentions that we may run in overlapping
> physical memory if we use 4-level paging. Hence why not just move to 5-level
> paging and simplify this.

I'm not sure it _actually_ simplifies anything.  We still need code to
handle the cases where we bump into the limits because even 5-level
paging systems can hit the *architectural* limits.  We just don't think
we'll bump into those limits any time soon in practice since they're
512x larger on 5-level systems.

But, a future system that needs physical address space or has a bunch
more KeyID bits might bump into the limits.

It's also _possible_ that a processor could come out that supports MKTME
but not 5-level paging, or a hypervisor would expose such a
configuration to a guest.  We've asked our colleagues very nicely that
Intel not make a processor that does this, but it's still possible one
shows up.
