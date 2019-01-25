Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CF85E8E00EE
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 16:09:59 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id t26so7107303pgu.18
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 13:09:59 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id d5si5726859pgd.488.2019.01.25.13.09.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 13:09:58 -0800 (PST)
Subject: Re: [PATCH 1/5] mm/resource: return real error codes from walk
 failures
References: <20190124231441.37A4A305@viggo.jf.intel.com>
 <20190124231442.EFD29EE0@viggo.jf.intel.com>
 <CAErSpo7kMjfi-1r8ZyGbheWzo+JCFkDZ1zpVhyNV7VVy8NOV7g@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <4898e064-5298-6a82-83ea-23d16f3dfb3d@intel.com>
Date: Fri, 25 Jan 2019 13:09:57 -0800
MIME-Version: 1.0
In-Reply-To: <CAErSpo7kMjfi-1r8ZyGbheWzo+JCFkDZ1zpVhyNV7VVy8NOV7g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bjorn Helgaas <bhelgaas@google.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, baiyaowei@cmss.chinamobile.com, Takashi Iwai <tiwai@suse.de>, Jerome Glisse <jglisse@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>

On 1/25/19 1:02 PM, Bjorn Helgaas wrote:
>> @@ -453,7 +453,7 @@ int walk_system_ram_range(unsigned long
>>         unsigned long flags;
>>         struct resource res;
>>         unsigned long pfn, end_pfn;
>> -       int ret = -1;
>> +       int ret = -EINVAL;
> Can you either make a similar change to the powerpc version of
> walk_system_ram_range() in arch/powerpc/mm/mem.c or explain why it's
> not needed?  It *seems* like we'd want both versions of
> walk_system_ram_range() to behave similarly in this respect.

Sure.  A quick grep shows powerpc being the only other implementation.
I'll just add this hunk:

> diff -puN arch/powerpc/mm/mem.c~memory-hotplug-walk_system_ram_range-returns-neg-1 arch/powerpc/mm/mem.c
> --- a/arch/powerpc/mm/mem.c~memory-hotplug-walk_system_ram_range-returns-neg-1  2019-01-25 12:57:00.000004446 -0800
> +++ b/arch/powerpc/mm/mem.c     2019-01-25 12:58:13.215004263 -0800 
> @@ -188,7 +188,7 @@ walk_system_ram_range(unsigned long star 
>         struct memblock_region *reg; 
>         unsigned long end_pfn = start_pfn + nr_pages; 
>         unsigned long tstart, tend; 
> -       int ret = -1; 
> +       int ret = -EINVAL; 

I'll also dust off the ol' cross-compiler and make sure I didn't
fat-finger anything.
