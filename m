Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 63CC16B0258
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 10:35:58 -0500 (EST)
Received: by pfu207 with SMTP id 207so31700048pfu.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 07:35:58 -0800 (PST)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.4])
        by mx.google.com with ESMTPS id yw7si13353997pac.32.2015.12.09.07.35.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 07:35:57 -0800 (PST)
Message-ID: <56684A59.7030605@sigmadesigns.com>
Date: Wed, 9 Dec 2015 16:35:53 +0100
From: Sebastian Frias <sebastian_frias@sigmadesigns.com>
MIME-Version: 1.0
Subject: Re: m(un)map kmalloc buffers to userspace
References: <5667128B.3080704@sigmadesigns.com> <20151209135544.GE30907@dhcp22.suse.cz> <566835B6.9010605@sigmadesigns.com> <20151209143207.GF30907@dhcp22.suse.cz> <56684062.9090505@sigmadesigns.com> <20151209151254.GH30907@dhcp22.suse.cz>
In-Reply-To: <20151209151254.GH30907@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2015 04:12 PM, Michal Hocko wrote:
> On Wed 09-12-15 15:53:22, Sebastian Frias wrote:
> [...]
>> 2) Now that VM_RESERVED was removed, is there another recommended flag to
>> replace it for the purposes above?
>
> VM_IO + potentially others depending on your usecase.
>
>> 3) Since it was working before, we suppose that something that was
>> previously done by default on the kernel it is not done anymore, could that
>> be a remap_pfn_range during mmap or kmalloc?
>
> VM_RESERVED removal was a cleanup which has removed the flag because it
> was not needed and the same effect could be implied from either VM_IO or
> VM_DONTEXPAND | VM_DONTDUMP. See 314e51b9851b ("mm: kill vma flag
> VM_RESERVED and mm->reserved_vm counter") for more detailed information.
>
>> 4) We tried using remap_pfn_range inside mmap and while it seems to work, we
>> still get occasional crashes due to corrupted memory (in this case the
>> behaviour is the same between 4.1 and 3.4 when using the same modified
>> driver), are we missing something?
>
> This is hard to tell without knowing your driver. I would just encourage
> you to look at other drivers which map kernel memory to userspace via
> mmap. There are many of them. Maybe you can find a pattern which suites
> your usecase.
>

Ok, thanks.
We've seen that drivers/media/pci/zoran/zoran_driver.c for example seems 
to be doing as us kmalloc+remap_pfn_range, is there any guarantee (or at 
least an advised heuristic) to determine if a driver is "current" (ie: 
uses the latest APIs and works)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
