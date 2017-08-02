Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E54AE280300
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 03:44:58 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u89so5044356wrc.1
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 00:44:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d36si27280720wrd.455.2017.08.02.00.44.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 00:44:57 -0700 (PDT)
Subject: Re: [PATCHv2 08/10] x86/mm: Replace compile-time checks for 5-level
 with runtime-time
References: <20170718141517.52202-1-kirill.shutemov@linux.intel.com>
 <20170718141517.52202-9-kirill.shutemov@linux.intel.com>
 <6841c4f3-6794-f0ac-9af9-0ceb56e49653@suse.com>
 <20170725090538.26sbgb4npkztsqj3@black.fi.intel.com>
 <39cb1e36-f94e-32ea-c94a-2daddcbf3408@suse.com>
 <20170726164335.xaajz5ltzhncju26@node.shutemov.name>
 <c450949e-bd79-c9c9-797e-be6b2c7b1e5f@suse.com>
 <20170801144414.rd67k2g2cz46nlow@black.fi.intel.com>
 <d7d46a3c-1a01-1f35-99ed-6c1587275433@suse.com>
 <20170801191144.k333twdie52arpwt@black.fi.intel.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <2c425437-f887-8a7e-9bce-36338c0979d0@suse.com>
Date: Wed, 2 Aug 2017 09:44:54 +0200
MIME-Version: 1.0
In-Reply-To: <20170801191144.k333twdie52arpwt@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/08/17 21:11, Kirill A. Shutemov wrote:
> On Tue, Aug 01, 2017 at 07:14:57PM +0200, Juergen Gross wrote:
>> On 01/08/17 16:44, Kirill A. Shutemov wrote:
>>> On Tue, Aug 01, 2017 at 09:46:56AM +0200, Juergen Gross wrote:
>>>> On 26/07/17 18:43, Kirill A. Shutemov wrote:
>>>>> On Wed, Jul 26, 2017 at 09:28:16AM +0200, Juergen Gross wrote:
>>>>>> On 25/07/17 11:05, Kirill A. Shutemov wrote:
>>>>>>> On Tue, Jul 18, 2017 at 04:24:06PM +0200, Juergen Gross wrote:
>>>>>>>> Xen PV guests will never run with 5-level-paging enabled. So I guess you
>>>>>>>> can drop the complete if (IS_ENABLED(CONFIG_X86_5LEVEL)) {} block.
>>>>>>>
>>>>>>> There is more code to drop from mmu_pv.c.
>>>>>>>
>>>>>>> But while there, I thought if with boot-time 5-level paging switching we
>>>>>>> can allow kernel to compile with XEN_PV and XEN_PVH, so the kernel image
>>>>>>> can be used in these XEN modes with 4-level paging.
>>>>>>>
>>>>>>> Could you check if with the patch below we can boot in XEN_PV and XEN_PVH
>>>>>>> modes?
>>>>>>
>>>>>> We can't. I have used your branch:
>>>>>>
>>>>>> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git
>>>>>> la57/boot-switching/v2
>>>>>>
>>>>>> with this patch applied on top.
>>>>>>
>>>>>> Doesn't boot PV guest with X86_5LEVEL configured (very early crash).
>>>>>
>>>>> Hm. Okay.
>>>>>
>>>>> Have you tried PVH?
>>>>>
>>>>>> Doesn't build with X86_5LEVEL not configured:
>>>>>>
>>>>>>   AS      arch/x86/kernel/head_64.o
>>>>>
>>>>> I've fixed the patch and split the patch into two parts: cleanup and
>>>>> re-enabling XEN_PV and XEN_PVH for X86_5LEVEL.
>>>>>
>>>>> There's chance that I screw somthing up in clenaup part. Could you check
>>>>> that?
>>>>
>>>> Build is working with and without X86_5LEVEL configured.
>>>>
>>>> PV domU boots without X86_5LEVEL configured.
>>>>
>>>> PV domU crashes with X86_5LEVEL configured:
>>>>
>>>> xen_start_kernel()
>>>>   x86_64_start_reservations()
>>>>     start_kernel()
>>>>       setup_arch()
>>>>         early_ioremap_init()
>>>>           early_ioremap_pmd()
>>>>
>>>> In early_ioremap_pmd() there seems to be a call to p4d_val() which is an
>>>> uninitialized paravirt operation in the Xen pv case.
>>>
>>> Thanks for testing.
>>>
>>> Could you check if patch below makes a difference?
>>
>> A little bit better. I get a panic message with backtrace now:
> 
> Are you running with 512m of ram or so?

Yes. :-)

> There's known issue with sparse mem: it still allocate data structures as
> if there's 52-bit phys address space even for p4d_folded case.
> 
> I'm looking this.
> 
> Try to bump memory size to 2g or so for now.

That did the trick!

PV domU is coming up now with a 5-level paging enabled kernel.


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
