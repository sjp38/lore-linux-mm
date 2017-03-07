Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C582B6B038E
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 13:44:11 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b2so16844702pgc.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 10:44:11 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id b1si792625plm.61.2017.03.07.10.44.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 10:44:10 -0800 (PST)
Subject: Re: [Xen-devel] [PATCHv4 18/33] x86/xen: convert __xen_pgd_walk() and
 xen_cleanmfnmap() to support p4d
References: <20170306135357.3124-1-kirill.shutemov@linux.intel.com>
 <20170306135357.3124-19-kirill.shutemov@linux.intel.com>
 <ab2868ea-1dd1-d51b-4c5a-921ef5c9a427@oracle.com>
 <20170307130009.GA2154@node>
 <8bd7d5b7-7a22-a0a2-8eff-e909a1c6783e@oracle.com>
 <47f06f4a-ef29-5a77-c48b-43a91a8c9579@citrix.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <c15b7954-2573-5624-7132-1d435e012922@oracle.com>
Date: Tue, 7 Mar 2017 13:45:07 -0500
MIME-Version: 1.0
In-Reply-To: <47f06f4a-ef29-5a77-c48b-43a91a8c9579@citrix.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Cooper <andrew.cooper3@citrix.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Zhang, Xiong Y" <xiong.y.zhang@intel.com>
Cc: linux-arch@vger.kernel.org, Juergen Gross <jgross@suse.com>, Andi Kleen <ak@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, xen-devel <xen-devel@lists.xen.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 03/07/2017 01:26 PM, Andrew Cooper wrote:
> On 07/03/17 18:18, Boris Ostrovsky wrote:
>>>> Don't we need to pass vaddr down to all routines so that they select
>>>> appropriate tables? You seem to always be choosing the first one.
>>> IIUC, we clear whole page table subtree covered by one pgd entry.
>>> So, no, there's no need to pass vaddr down. Just pointer to page table
>>> entry is enough.
>>>
>>> But I know virtually nothing about Xen. Please re-check my reasoning.
>> Yes, we effectively remove the whole page table for vaddr so I guess
>> it's OK.
>>
>>> I would also appreciate help with getting x86 Xen code work with 5-level
>>> paging enabled. For now I make CONFIG_XEN dependent on !CONFIG_X86_5LEVEL.
>> Hmmm... that's a problem since this requires changes in the hypervisor
>> and even if/when these changes are made older version of hypervisor
>> still will not be able to run those guests.
>>
>> This affects only PV guests and there is a series under review that
>> provides clean code separation with CONFIG_XEN_PV but because, for
>> example, dom0 (Xen control domain) is PV this will significantly limit
>> availability of dom0-capable kernels (because I assume distros will want
>> to have CONFIG_X86_5LEVEL).
> Wasn't the plan to be able to automatically detect 4 vs 5 level support,
> and cope either way, so distros didn't have to ship two different builds
> of Linux?
>
> If so, all we need to do git things to compile sensibly, and have the PV
> entry code in Linux configure the rest of the kernel appropriately.

I am not aware of any plans but this would obviously be the preferred route.

-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
