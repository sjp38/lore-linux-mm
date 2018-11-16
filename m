Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A19F6B0A84
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 12:00:05 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id i12so4248512ita.3
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 09:00:05 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id j4si336946itb.137.2018.11.16.09.00.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Nov 2018 09:00:04 -0800 (PST)
Subject: Re: [PATCH 1/9] mm: Introduce new vm_insert_range API
References: <20181115154530.GA27872@jordon-HP-15-Notebook-PC>
 <9655a12e-bd3d-aca2-6155-38924028eb5d@infradead.org>
 <CAFqt6zbLjtDab3Bz67trbnQRQdutvgA=YvAFhoW4bxsg657mGQ@mail.gmail.com>
 <20181116064049.GA5320@bombadil.infradead.org>
 <CAFqt6zbL1tu4VWtZ5Wz-BgbOS+M2GJziMj958_h_ri4Th3n9bQ@mail.gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <b54491c4-c119-6e83-93ae-d0df7fc165a1@infradead.org>
Date: Fri, 16 Nov 2018 08:59:28 -0800
MIME-Version: 1.0
In-Reply-To: <CAFqt6zbL1tu4VWtZ5Wz-BgbOS+M2GJziMj958_h_ri4Th3n9bQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

On 11/16/18 12:15 AM, Souptick Joarder wrote:
> On Fri, Nov 16, 2018 at 12:11 PM Matthew Wilcox <willy@infradead.org> wrote:
>>
>> On Fri, Nov 16, 2018 at 11:00:30AM +0530, Souptick Joarder wrote:
>>> On Thu, Nov 15, 2018 at 11:44 PM Randy Dunlap <rdunlap@infradead.org> wrote:
>>>> On 11/15/18 7:45 AM, Souptick Joarder wrote:
>>>> What is the opposite of vm_insert_range() or even of vm_insert_page()?
>>>> or is there no need for that?
>>>
>>> There is no opposite function of vm_insert_range() / vm_insert_page().
>>> My understanding is, in case of any error, mmap handlers will return the
>>> err to user process and user space will decide the next action. So next
>>> time when mmap handler is getting invoked it will map from the beginning.
>>> Correct me if I am wrong.
>>
>> The opposite function, I suppose, is unmap_region().
>>
>>>> s/no./number/
>>>
>>> I didn't get it ??
>>
>> This is a 'sed' expression.  's' is the 'substitute' command; the /
>> is a separator, 'no.' is what you wrote, and 'number' is what Randy
>> is recommending instead.
> 
> Ok. Will change it in v2.

Thanks.

>>>>> +     for (i = 0; i < page_count; i++) {
>>>>> +             ret = vm_insert_page(vma, uaddr, pages[i]);
>>>>> +             if (ret < 0)
>>>>> +                     return ret;
>>>>
>>>> For a non-trivial value of page_count:
>>>> Is it a problem if vm_insert_page() succeeds for several pages
>>>> and then fails?
>>>
>>> No, it will be considered as total failure and mmap handler will return
>>> the err to user space.
>>
>> I think what Randy means is "What happens to the inserted pages?" and
>> the answer is that mmap_region() jumps to the 'unmap_and_free_vma'
>> label, which is an accurate name.

which says:

	/* Undo any partial mapping done by a device driver. */
	unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end);

and that is what I was missing.  Thanks.

> Sorry for incorrect understanding of the question.

No problem.


-- 
~Randy
