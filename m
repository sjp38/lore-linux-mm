Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B11B8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 16:56:03 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id l22so16444560pfb.2
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 13:56:03 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id u7si16599992pfu.270.2018.12.12.13.56.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 13:56:01 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <20181205011519.GV10377@bombadil.infradead.org>
 <20181205014441.GA3045@redhat.com>
 <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com> <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
 <20181212213005.GE5037@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <514cc9e1-dc4d-b979-c6bc-88ac503c098d@nvidia.com>
Date: Wed, 12 Dec 2018 13:56:00 -0800
MIME-Version: 1.0
In-Reply-To: <20181212213005.GE5037@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis  <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe" <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 12/12/18 1:30 PM, Jerome Glisse wrote:
> On Wed, Dec 12, 2018 at 08:27:35AM -0800, Dan Williams wrote:
>> On Wed, Dec 12, 2018 at 7:03 AM Jerome Glisse <jglisse@redhat.com> wrote=
:
>>>
>>> On Mon, Dec 10, 2018 at 11:28:46AM +0100, Jan Kara wrote:
>>>> On Fri 07-12-18 21:24:46, Jerome Glisse wrote:
>>>>> Another crazy idea, why not treating GUP as another mapping of the pa=
ge
>>>>> and caller of GUP would have to provide either a fake anon_vma struct=
 or
>>>>> a fake vma struct (or both for PRIVATE mapping of a file where you ca=
n
>>>>> have a mix of both private and file page thus only if it is a read on=
ly
>>>>> GUP) that would get added to the list of existing mapping.
>>>>>
>>>>> So the flow would be:
>>>>>     somefunction_thatuse_gup()
>>>>>     {
>>>>>         ...
>>>>>         GUP(_fast)(vma, ..., fake_anon, fake_vma);
>>>>>         ...
>>>>>     }
>>>>>
>>>>>     GUP(vma, ..., fake_anon, fake_vma)
>>>>>     {
>>>>>         if (vma->flags =3D=3D ANON) {
>>>>>             // Add the fake anon vma to the anon vma chain as a child
>>>>>             // of current vma
>>>>>         } else {
>>>>>             // Add the fake vma to the mapping tree
>>>>>         }
>>>>>
>>>>>         // The existing GUP except that now it inc mapcount and not
>>>>>         // refcount
>>>>>         GUP_old(..., &nanonymous, &nfiles);
>>>>>
>>>>>         atomic_add(&fake_anon->refcount, nanonymous);
>>>>>         atomic_add(&fake_vma->refcount, nfiles);
>>>>>
>>>>>         return nanonymous + nfiles;
>>>>>     }
>>>>
>>>> Thanks for your idea! This is actually something like I was suggesting=
 back
>>>> at LSF/MM in Deer Valley. There were two downsides to this I remember
>>>> people pointing out:
>>>>
>>>> 1) This cannot really work with __get_user_pages_fast(). You're not al=
lowed
>>>> to get necessary locks to insert new entry into the VMA tree in that
>>>> context. So essentially we'd loose get_user_pages_fast() functionality=
.
>>>>
>>>> 2) The overhead e.g. for direct IO may be noticeable. You need to allo=
cate
>>>> the fake tracking VMA, get VMA interval tree lock, insert into the tre=
e.
>>>> Then on IO completion you need to queue work to unpin the pages again =
as you
>>>> cannot remove the fake VMA directly from interrupt context where the I=
O is
>>>> completed.
>>>>
>>>> You are right that the cost could be amortized if gup() is called for
>>>> multiple consecutive pages however for small IOs there's no help...
>>>>
>>>> So this approach doesn't look like a win to me over using counter in s=
truct
>>>> page and I'd rather try looking into squeezing HMM public page usage o=
f
>>>> struct page so that we can fit that gup counter there as well. I know =
that
>>>> it may be easier said than done...
>>>
>>> So i want back to the drawing board and first i would like to ascertain
>>> that we all agree on what the objectives are:
>>>
>>>     [O1] Avoid write back from a page still being written by either a
>>>          device or some direct I/O or any other existing user of GUP.
>>>          This would avoid possible file system corruption.
>>>
>>>     [O2] Avoid crash when set_page_dirty() is call on a page that is
>>>          considered clean by core mm (buffer head have been remove and
>>>          with some file system this turns into an ugly mess).
>>>
>>>     [O3] DAX and the device block problems, ie with DAX the page map in
>>>          userspace is the same as the block (persistent memory) and no
>>>          filesystem nor block device understand page as block or pinned
>>>          block.
>>>
>>> For [O3] i don't think any pin count would help in anyway. I believe
>>> that the current long term GUP API that does not allow GUP of DAX is
>>> the only sane solution for now.
>>
>> No, that's not a sane solution, it's an emergency hack.
>>
>>> The real fix would be to teach file-
>>> system about DAX/pinned block so that a pinned block is not reuse
>>> by filesystem.
>>
>> We already have taught filesystems about pinned dax pages, see
>> dax_layout_busy_page(). As much as possible I want to eliminate the
>> concept of "dax pages" as a special case that gets sprinkled
>> throughout the mm.
>=20
> So thinking on O3 issues what about leveraging the recent change i
> did to mmu notifier. Add a event for truncate or any other file
> event that need to invalidate the file->page for a range of offset.
>=20
> Add mmu notifier listener to GUP user (except direct I/O) so that
> they invalidate they hardware mapping or switch the hardware mapping
> to use a crappy page. When such event happens what ever user do to
> the page through that driver is broken anyway. So it is better to
> be loud about it then trying to make it pass under the radar.
>=20
> This will put the burden on broken user and allow you to properly
> recycle your DAX page.
>=20
> Think of it as revoke through mmu notifier.
>=20
> So patchset would be:
>     enum mmu_notifier_event {
> +       MMU_NOTIFY_TRUNCATE,
>     };
>=20
> +   Change truncate code path to emit MMU_NOTIFY_TRUNCATE
>=20

That part looks good.

> Then for each user of GUP (except direct I/O or other very short
> term GUP):

but, why is there a difference between how we handle long- and
short-term callers? Aren't we just leaving a harder-to-reproduce race
condition, if we ignore the short-term gup callers?

So, how does activity (including direct IO and other short-term callers)
get quiesced (stopped, and guaranteed not to restart or continue), so=20
that truncate or umount can continue on?


>=20
>     Patch 1: register mmu notifier
>     Patch 2: listen to MMU_NOTIFY_TRUNCATE and MMU_NOTIFY_UNMAP
>              when that happens update the device page table or
>              usage to point to a crappy page and do put_user_page
>              on all previously held page

Minor point, this sequence should be done within a wrapper around existing=
=20
get_user_pages(), such as get_user_pages_revokable() or something.

thanks,
--=20
John Hubbard
NVIDIA

>=20
> So this would solve the revoke side of thing without adding a burden
> on GUP user like direct I/O. Many existing user of GUP already do
> listen to mmu notifier and already behave properly. It is just about
> making every body list to that. Then we can even add the mmu notifier
> pointer as argument to GUP just to make sure no new user of GUP forget
> about registering a notifier (argument as a teaching guide not as a
> something actively use).
>=20
>=20
> So does that sounds like a plan to solve your concern with long term
> GUP user ? This does not depend on DAX or anything it would apply to
> any file back pages.
>=20
>=20
> Cheers,
> J=C3=A9r=C3=B4me
>=20
