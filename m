Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id F3D566B0260
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 09:35:15 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a136so27596297wme.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 06:35:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wp4si740211wjb.173.2016.06.02.06.35.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 06:35:15 -0700 (PDT)
Subject: Re: [linux-next-20160602] kernel BUG at mm/rmap.c:1253!
References: <201606022014.GFF87050.FJOLVOMQHFOtSF@I-love.SAKURA.ne.jp>
 <20160602115046.GA2001@dhcp22.suse.cz> <20160602115949.GL1995@dhcp22.suse.cz>
 <20160602131352.GQ1995@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <af861bee-70da-a150-052c-2712511103d7@suse.cz>
Date: Thu, 2 Jun 2016 15:35:12 +0200
MIME-Version: 1.0
In-Reply-To: <20160602131352.GQ1995@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Ebru Akagunduz <ebru.akagunduz@gmail.com>

On 06/02/2016 03:13 PM, Michal Hocko wrote:
> On Thu 02-06-16 13:59:49, Michal Hocko wrote:
>> [CCing Ebru]
>>
>> On Thu 02-06-16 13:50:46, Michal Hocko wrote:
>>> [CCing Andrea and Kirill]
>>
>> Hmm, thinking about it little bit more it might be related to "mm, thp:
>> make swapin readahead under down_read of mmap_sem". I didn't get to look
>> closer at the patch but maybe revalidate after mmap sem is dropped is
>> not sufficient.
>
> so hugepage_vma_revalidate does this:
>
> 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
> 	hend = vma->vm_end & HPAGE_PMD_MASK;
> 	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
> 		return SCAN_ADDRESS_RANGE;
>
> I really do not see why we have to play with hstart and hend.

AFAIU the point of these tests is to see whether the vma is large enough 
to contain the given address within a huge page. And it kind of silently 
assumes that address is already huge-page aligned.

> But
> address + HPAGE_PMD_SIZE > hend part looks suspicious. address
> always have to vm_start <= address && address < vm_end AFAICS.

I think the check is fine after a deeper look. The code itself is also 
quite old, the recent patches just abstracted it to the new function.

> and the above allows address + HPAGE_PMD_MASK == end.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
