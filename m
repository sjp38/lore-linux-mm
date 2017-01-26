Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 61E3A6B0253
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:33:05 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z67so302599228pgb.0
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 00:33:05 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 3si797570plx.91.2017.01.26.00.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 00:33:04 -0800 (PST)
Subject: Re: ioremap_page_range: remapping of physical RAM ranges
References: <CADY3hbEy+oReL=DePFz5ZNsnvWpm55Q8=mRTxCGivSL64gAMMA@mail.gmail.com>
 <072b4406-16ef-cdf6-e968-711a60ca9a3f@nvidia.com>
 <20170125231529.GA14993@devmasch>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <47fe454a-249d-967b-408f-83c5046615e4@nvidia.com>
Date: Thu, 26 Jan 2017 00:33:02 -0800
MIME-Version: 1.0
In-Reply-To: <20170125231529.GA14993@devmasch>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ahmed Samy <f.fallen45@gmail.com>
Cc: linux-mm@kvack.org, zhongjiang@huawei.com

On 01/25/2017 03:15 PM, Ahmed Samy wrote:
> On Wed, Jan 25, 2017 at 02:27:27PM -0800, John Hubbard wrote:
>>
>> Hi A. Samy,
>>
>> I'm sorry this caught you by surprise, let's try get your use case cover=
ed.
>>
>> My thinking on this was: the exported ioremap* family of functions was
>> clearly intended to provide just what the name says: mapping of IO (non-=
RAM)
>> memory. If normal RAM is to be re-mapped, then it should not be done
>> "casually" in a driver, as a (possibly unintended) side effect of a func=
tion
>> that implies otherwise. Either it should be done within the core mm code=
, or
>> perhaps a new, better-named wrapper could be provided, for cases such as
>> yours.
> Hi John,
>
> I agree.  I assume whoever exported it was also doing it for the same
> purpose as mine[?]
>>
>> After a very quick peek at your github code, it seems that your mm_remap=
()
>> routine already has some code in common with __ioremap_caller(), so I'm
>> thinking that we could basically promote your mm_remap to the in-tree ke=
rnel
>> and EXPORT it, and maybe factor out the common parts (or not--it's small=
,
>> after all). Thoughts? If you like it, I'll put something together here.
> That'd be a good solution, it's actually sometimes useful to remap physic=
al
> ram in general, specifically for memory imaging tools, etc.
>
> How about also exporting walk_system_ram_range()?  It seems to be defined
> conditionally, so I am not sure if that would be a good idea.

That routine has an interesting history. At first glance, I think it used t=
o be=20
exported. And now it is not. And it's ifdef'd out only for powerpc. I'll lo=
ok into=20
the history and intentions of that some more...

> 	[ See also mm_cache_ram_ranges() in mm.c in github =E2=80=93 it's also a=
 hacky
> 	  way to get RAM ranges.  ]

Yes, I see.

>
> How about something like:
>
> 	/* vm_flags incase locking is required, in my case, I need it for VMX
> 	 * root where there is no interrupts.  */
> 	void *remap_ram_range(unsigned long phys, unsigned long size,
> 			      unsigned long vm_flags)
> 	{
> 		struct vm_struct *area;
> 		unsigned long psize;
> 		unsigned long vaddr;
>
> 		psize =3D (size >> PAGE_SHIFT) + (size & (PAGE_SIZE - 1)) !=3D 0;
> 		area =3D get_vm_area_caller(size, VM_IOREMAP | vm_flags,
> 					  __builtin_return_address(0));
> 		if (!area)
> 			return NULL;
>
> 		area->phys_addr =3D phys & ~(PAGE_SIZE - 1);
> 		vaddr =3D (unsigned long)area->addr;
> 		if (remap_page_range(vaddr, vaddr + size, phys, size))

That's ioremap_page_range, I assume (rather than remap_page_range)?

Overall, the remap_ram_range approach looks reasonable to me so far. I'll l=
ook into=20
the details tomorrow.

I'm sure that most people on this list already know this, but...could you s=
ay a few=20
more words about how remapping system ram is used, why it's a good thing an=
d not a=20
bad thing? :)

thanks
john h

> 			goto err_remap;
>
> 		return (void *)vaddr + phys & (PAGE_SIZE - 1);
> err_remap:
> 		free_vm_area(area);
> 		return NULL;
> 	}
>
> Of course you can add protection, etc.
>>
>> thanks
>> john h
>>
> Thanks,
> 	asamy
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
