Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 21E0D6B0315
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 06:22:37 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c18so114602020qkb.10
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 03:22:37 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id d2si21675823qkh.112.2017.07.05.03.22.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 03:22:36 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id m54so27486428qtb.1
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 03:22:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170705063813.GB10354@dhcp22.suse.cz>
References: <20170703211415.11283-1-jglisse@redhat.com> <20170703211415.11283-5-jglisse@redhat.com>
 <20170704125113.GC14727@dhcp22.suse.cz> <CAKTCnz=zTjYeqeTYZbnOMsT1Ccus4yW=jAws_OgXp3q4xmuSPA@mail.gmail.com>
 <20170705063813.GB10354@dhcp22.suse.cz>
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 5 Jul 2017 20:22:35 +1000
Message-ID: <CAKTCnz=BLs5pteCvmK1ihvdrViTq6kXhoyQzfpRnbh+CgRYynw@mail.gmail.com>
Subject: Re: [PATCH 4/5] mm/memcontrol: allow to uncharge page without using
 page->lru field
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>

On Wed, Jul 5, 2017 at 4:38 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 05-07-17 13:18:18, Balbir Singh wrote:
>> On Tue, Jul 4, 2017 at 10:51 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Mon 03-07-17 17:14:14, J=C3=A9r=C3=B4me Glisse wrote:
>> >> HMM pages (private or public device pages) are ZONE_DEVICE page and
>> >> thus you can not use page->lru fields of those pages. This patch
>> >> re-arrange the uncharge to allow single page to be uncharge without
>> >> modifying the lru field of the struct page.
>> >>
>> >> There is no change to memcontrol logic, it is the same as it was
>> >> before this patch.
>> >
>> > What is the memcg semantic of the memory? Why is it even charged? AFAI=
R
>> > this is not a reclaimable memory. If yes how are we going to deal with
>> > memory limits? What should happen if go OOM? Does killing an process
>> > actually help to release that memory? Isn't it pinned by a device?
>> >
>> > For the patch itself. It is quite ugly but I haven't spotted anything
>> > obviously wrong with it. It is the memcg semantic with this class of
>> > memory which makes me worried.
>> >
>>
>> This is the HMM CDM case. Memory is normally malloc'd and then
>> migrated to ZONE_DEVICE or vice-versa. One of the things we did
>> discuss was seeing ZONE_DEVICE memory in user page tables.
>
> This doesn't answer any of the above questions though.


Jerome is the expert and I am sure he has a better answer, but my understan=
ding
is that this path gets called through release_pages() <-- zap_pte_range().
At first even I pondered about the same thing, but then came across this pa=
th.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
