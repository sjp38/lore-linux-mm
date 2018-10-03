Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id A788B6B000D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 01:40:47 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id g126-v6so2371645ywg.20
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 22:40:47 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 3-v6si53075ywc.595.2018.10.02.22.40.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 22:40:46 -0700 (PDT)
Subject: Re: [PATCH 3/4] infiniband/mm: convert to the new put_user_page()
 call
References: <20180928053949.5381-1-jhubbard@nvidia.com>
 <20180928053949.5381-3-jhubbard@nvidia.com> <20180928153922.GA17076@ziepe.ca>
 <36bc65a3-8c2a-87df-44fc-89a1891b86db@nvidia.com>
 <ed9cbf0a-acc9-1b26-a7fc-e8f89f577ce9@intel.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <e5ffa56e-ae51-6e2c-e6a9-efbdf9317ae0@nvidia.com>
Date: Tue, 2 Oct 2018 22:40:43 -0700
MIME-Version: 1.0
In-Reply-To: <ed9cbf0a-acc9-1b26-a7fc-e8f89f577ce9@intel.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Dalessandro <dennis.dalessandro@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>, john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Christian Benvenuti <benve@cisco.com>

On 10/1/18 7:35 AM, Dennis Dalessandro wrote:
> On 9/28/2018 11:12 PM, John Hubbard wrote:
>> On 9/28/18 8:39 AM, Jason Gunthorpe wrote:
>>> On Thu, Sep 27, 2018 at 10:39:47PM -0700, john.hubbard@gmail.com wrote:
>>>> From: John Hubbard <jhubbard@nvidia.com>
>> [...]
>>>>
>>>> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/=
umem.c
>>>> index a41792dbae1f..9430d697cb9f 100644
>>>> +++ b/drivers/infiniband/core/umem.c
>>>> @@ -60,7 +60,7 @@ static void __ib_umem_release(struct ib_device *dev,=
 struct ib_umem *umem, int d
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 page =3D sg_pag=
e(sg);
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (!PageDirty(=
page) && umem->writable && dirty)
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 set_page_dirty_lock(page);
>>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 put_page(page);
>>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 put_user_page(page);
>>>
>>> Would it make sense to have a release/put_user_pages_dirtied to absorb
>>> the set_page_dity pattern too? I notice in this patch there is some
>>> variety here, I wonder what is the right way?
>>>
>>> Also, I'm told this code here is a big performance bottleneck when the
>>> number of pages becomes very long (think >> GB of memory), so having a
>>> future path to use some kind of batching/threading sound great.
>>>
>>
>> Yes. And you asked for this the first time, too. Consistent! :) Sorry fo=
r
>> being slow to pick it up. It looks like there are several patterns, and
>> we have to support both set_page_dirty() and set_page_dirty_lock(). So
>> the best combination looks to be adding a few variations of
>> release_user_pages*(), but leaving put_user_page() alone, because it's
>> the "do it yourself" basic one. Scatter-gather will be stuck with that.
>>
>> Here's a differential patch with that, that shows a nice little cleanup =
in
>> a couple of IB places, and as you point out, it also provides the hooks =
for
>> performance upgrades (via batching) in the future.
>>
>> Does this API look about right?
>=20
> I'm on board with that and the changes to hfi1 and qib.
>=20
> Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>

Hi Dennis, thanks for the review!

I'll add those new routines in and send out a v2 soon, now that it appears,=
 from=20
the recent discussion, that this aspect of the approach is still viable.


thanks,
--=20
John Hubbard
NVIDIA
