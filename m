Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A11CD6B0158
	for <linux-mm@kvack.org>; Tue, 26 May 2015 07:30:06 -0400 (EDT)
Received: by padbw4 with SMTP id bw4so90779157pad.0
        for <linux-mm@kvack.org>; Tue, 26 May 2015 04:30:06 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id bn12si20533063pdb.202.2015.05.26.04.30.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 04:30:05 -0700 (PDT)
Received: by pdfh10 with SMTP id h10so88791995pdf.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 04:30:05 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] arm64: Implement vmalloc based thread_info allocator
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Jungseok Lee <jungseoklee85@gmail.com>
In-Reply-To: <20150525144045.GE14922@blaptop>
Date: Tue, 26 May 2015 20:29:59 +0900
Content-Transfer-Encoding: quoted-printable
Message-Id: <D5CD4D44-77BC-4817-B9A7-60C0F4AE444F@gmail.com>
References: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com> <20150525144045.GE14922@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, barami97@gmail.com, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On May 25, 2015, at 11:40 PM, Minchan Kim wrote:
> Hello Jungseok,

Hi, Minchan,

> On Mon, May 25, 2015 at 01:02:20AM +0900, Jungseok Lee wrote:
>> Fork-routine sometimes fails to get a physically contiguous region =
for
>> thread_info on 4KB page system although free memory is enough. That =
is,
>> a physically contiguous region, which is currently 16KB, is not =
available
>> since system memory is fragmented.
>=20
> Order less than PAGE_ALLOC_COSTLY_ORDER should not fail in current
> mm implementation. If you saw the order-2,3 high-order allocation fail
> maybe your application received SIGKILL by someone. LMK?

Exactly right. The allocation is failed via the following path.

if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
	goto nopage;

IMHO, a reclaim operation would be not needed in this context if memory =
is
allocated from vmalloc space. It means there is no need to traverse =
shrinker list.=20

>> This patch tries to solve the problem as allocating thread_info =
memory
>> from vmalloc space, not 1:1 mapping one. The downside is one =
additional
>> page allocation in case of vmalloc. However, vmalloc space is large =
enough,
>=20
> The size you want to allocate is 16KB in here but additional 4K?
> It increases 25% memory footprint, which is huge downside.

I agree with the point, and most people who try to use vmalloc might =
know the number.
However, an interoperation on the number depends on a point of view.

Vmalloc is large enough and not fully utilized in case of ARM64.
With the considerations, there is a room to do math as follows.

4KB / 240GB =3D 1.5e-8 (4KB page + 3 level combo)

It would be not a huge downside if fork-routine is not damaged due to =
fragmentation.

However, this is one of reasons to add "RFC" prefix in the patch set. =
How is the
additional 4KB interpreted and considered?

Best Regards
Jungseok Lee=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
