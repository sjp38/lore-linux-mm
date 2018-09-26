Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id E224E8E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 01:00:51 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id 203-v6so11470205ybf.19
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 22:00:51 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id z192-v6si1107091ywg.502.2018.09.25.22.00.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 22:00:47 -0700 (PDT)
Subject: Re: [BUG] mm: direct I/O (using GUP) can write to COW anonymous pages
References: <CAG48ez17Of=dnymzm8GAN_CNG1okMg1KTeMtBQhXGP2dyB5uJw@mail.gmail.com>
 <alpine.LSU.2.11.1809171628190.2225@eggly.anvils>
 <CAG48ez1hk5evqQpyvticPzLFOcESfo2NoWnqrLZk6N4PXwdsOw@mail.gmail.com>
 <20180918095822.GH10257@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <4a17705b-5ca9-296b-b24e-d2d9f10b4c06@nvidia.com>
Date: Tue, 25 Sep 2018 22:00:45 -0700
MIME-Version: 1.0
In-Reply-To: <20180918095822.GH10257@quack2.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Jann Horn <jannh@google.com>
Cc: Hugh Dickins <hughd@google.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, sqazi@google.com, "Michael S. Tsirkin" <mst@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Miklos Szeredi <miklos@szeredi.hu>, john.hubbard@gmail.com

On 9/18/18 2:58 AM, Jan Kara wrote:
> On Tue 18-09-18 02:35:43, Jann Horn wrote:
>> On Tue, Sep 18, 2018 at 2:05 AM Hugh Dickins <hughd@google.com> wrote:
> 
> Thanks for CC Hugh.
> 
>>> On Mon, 17 Sep 2018, Jann Horn wrote:
>>>
>>
>> Makes sense, I guess.
>>
>> I wonder whether there's a concise way to express this in the fork.2
>> manpage, or something like that. Maybe I'll take a stab at writing
>> something. The biggest issue I see with documenting this edgecase is
>> that, as an application developer, if you don't know whether some file
>> might be coming from a FUSE filesystem that has opted out of using the
>> disk cache, the "don't do that" essentially becomes "don't read() into
>> heap buffers while fork()ing in another thread", since with FUSE,
>> direct I/O can happen even if you don't open files as O_DIRECT as long
>> as the filesystem requests direct I/O, and get_user_pages_fast() will
>> AFAIU be used for non-page-aligned buffers, meaning that an adjacent
>> heap memory access could trigger CoW page duplication. But then, FUSE
>> filesystems that opt out of the disk cache are probably so rare that
>> it's not a concern in practice...
> 
> So at least for shared file mappings we do need to fix this issue as it's
> currently userspace triggerable Oops if you try hard enough. And with RDMA
> you don't even have to try that hard. Properly dealing with private
> mappings should not be that hard once the infrastructure is there I hope
> but I didn't seriously look into that. I've added Miklos and John to CC as
> they are interested as well. John was working on fixing this problem -
> https://lkml.org/lkml/2018/7/9/158 - but I didn't hear from him for quite a
> while so I'm not sure whether it died off or what's the current situation.
> 

Hi,

Sorry for missing this even though I was CC'd, I only just now noticed it, while
trying to get caught up again.

Anyway, I've been sidetracked for a...while (since July!), but am jumping back 
in and working on this now. And I've got time allocated for it. So here goes.

thanks,
-- 
John Hubbard
NVIDIA
