Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC1C6B0070
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 07:00:01 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so45888328pdb.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 04:00:01 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id rd3si16928336pbc.77.2015.04.24.03.59.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 04:00:00 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NNB0003X5AP1R90@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Apr 2015 12:01:37 +0100 (BST)
Message-id: <553A2229.5040509@samsung.com>
Date: Fri, 24 Apr 2015 12:59:53 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 0/9 v2] Helper to abstract vma handling in media layer
References: <1426593399-6549-1-git-send-email-jack@suse.cz>
 <20150402150258.GA31277@quack.suse.cz> <551D5F7C.4080400@xs4all.nl>
In-reply-to: <551D5F7C.4080400@xs4all.nl>
Content-type: text/plain; charset=utf-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hans Verkuil <hverkuil@xs4all.nl>, Jan Kara <jack@suse.cz>, linux-media@vger.kernel.org
Cc: Hans Verkuil <hans.verkuil@cisco.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Pawel Osciak <pawel@osciak.com>

Dear All,

On 2015-04-02 17:25, Hans Verkuil wrote:
> On 04/02/2015 05:02 PM, Jan Kara wrote:
>>    Hello,
>>
>> On Tue 17-03-15 12:56:30, Jan Kara wrote:
>>>    After a long pause I'm sending second version of my patch series to abstract
>>> vma handling from the various media drivers. After this patch set drivers have
>>> to know much less details about vmas, their types, and locking. My motivation
>>> for the series is that I want to change get_user_pages() locking and I want to
>>> handle subtle locking details in as few places as possible.
>>>
>>> The core of the series is the new helper get_vaddr_pfns() which is given a
>>> virtual address and it fills in PFNs into provided array. If PFNs correspond to
>>> normal pages it also grabs references to these pages. The difference from
>>> get_user_pages() is that this function can also deal with pfnmap, mixed, and io
>>> mappings which is what the media drivers need.
>>>
>>> I have tested the patches with vivid driver so at least vb2 code got some
>>> exposure. Conversion of other drivers was just compile-tested so I'd like to
>>> ask respective maintainers if they could have a look.  Also I'd like to ask mm
>>> folks to check patch 2/9 implementing the helper. Thanks!
>>    Ping? Any reactions?
> For patch 1/9:
>
> Acked-by: Hans Verkuil <hans.verkuil@cisco.com>
>
> For the other patches I do not feel qualified to give Acks. I've Cc-ed Pawel and
> Marek who have a better understanding of the mm internals than I do. Hopefully
> they can review the code.
>
> It definitely looks like a good idea, and if nobody else will comment on the vb2
> patches in the next 2 weeks, then I'll try to review it myself (for whatever that's
> worth).

I'm really sorry that I didn't manage to find time to review this 
patchset. I really
like the idea of moving pfn lookup from videobuf2/driver to some common 
code in mm
and it is really great that someone managed to provide nice generic code 
for it.

I've applied the whole patchset onto v4.0 and tested it on Odroid U3 
(with some
additional patches). VideoBuf2-dc works still fine with USERPTR gathered 
from other's
device mmaped buffer. You can add my:

Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
Tested-by: Marek Szyprowski <m.szyprowski@samsung.com>

for the patches 1-8. Patch 9/9 doesn't apply anymore, so I've skipped 
it. Patch 2
needs a small fixup - you need to add '#include <linux/vmalloc.h>', 
because otherwise
it doesn't compile. There have been also a minor conflict to be resolved 
in patch 7.

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
