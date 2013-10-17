Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id A196B6B008A
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 11:48:27 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so963266pdj.8
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 08:48:27 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id to1so5327049ieb.23
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 08:48:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1310150950100.12358@eggly.anvils>
References: <1381759136-8616-1-git-send-email-k.kozlowski@samsung.com>
	<alpine.LNX.2.00.1310150257030.6194@eggly.anvils>
	<1381836170.18389.13.camel@AMDC1943>
	<alpine.LNX.2.00.1310150950100.12358@eggly.anvils>
Date: Thu, 17 Oct 2013 23:48:24 +0800
Message-ID: <CAL1ERfN8M0BP5kAtX+tvirY6hKXWrn_FeVE_tCr23z+2GtTjnA@mail.gmail.com>
Subject: Re: [PATCH] swap: fix setting PAGE_SIZE blocksize during
 swapoff/swapon race
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>

On Wed, Oct 16, 2013 at 1:19 AM, Hugh Dickins <hughd@google.com> wrote:
> On Tue, 15 Oct 2013, Krzysztof Kozlowski wrote:
>> On Tue, 2013-10-15 at 02:59 -0700, Hugh Dickins wrote:
>> > On Mon, 14 Oct 2013, Krzysztof Kozlowski wrote:
>> >
>> > > Fix race between swapoff and swapon resulting in setting blocksize o=
f
>> > > PAGE_SIZE for block devices during swapoff.
>> > >
>> > > The swapon modifies swap_info->old_block_size before acquiring
>> > > swapon_mutex. It reads block_size of bdev, stores it under
>> > > swap_info->old_block_size and sets new block_size to PAGE_SIZE.
>> > >
>> > > On the other hand the swapoff sets the device's block_size to
>> > > old_block_size after releasing swapon_mutex.
>> > >
>> > > This patch locks the swapon_mutex much earlier during swapon. It als=
o
>> > > releases the swapon_mutex later during swapoff.
>> > >
>> > > The effect of race can be triggered by following scenario:
>> > >  - One block swap device with block size of 512
>> > >  - thread 1: Swapon is called, swap is activated,
>> > >    p->old_block_size =3D block_size(p->bdev); /512/
>> > >    block_size(p->bdev) =3D PAGE_SIZE;
>> > >    Thread ends.
>> > >
>> > >  - thread 2: Swapoff is called and it goes just after releasing the
>> > >    swapon_mutex. The swap is now fully disabled except of setting th=
e
>> > >    block size to old value. The p->bdev->block_size is still equal t=
o
>> > >    PAGE_SIZE.
>> > >
>> > >  - thread 3: New swapon is called. This swap is disabled so without
>> > >    acquiring the swapon_mutex:
>> > >    - p->old_block_size =3D block_size(p->bdev); /PAGE_SIZE (!!!)/
>> > >    - block_size(p->bdev) =3D PAGE_SIZE;
>> > >    Swap is activated and thread ends.
>> > >
>> > >  - thread 2: resumes work and sets blocksize to old value:
>> > >    - set_blocksize(bdev, p->old_block_size)
>> > >    But now the p->old_block_size is equal to PAGE_SIZE.
>> > >
>> > > The patch swap-fix-set_blocksize-race-during-swapon-swapoff does not=
 fix
>> > > this particular issue. It reduces the possibility of races as the sw=
apon
>> > > must overwrite p->old_block_size before acquiring swapon_mutex in
>> > > swapoff.
>> > >
>> > > Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
>> >
>> > Sorry you're being blown back and forth on this, but I say Nack to
>> > this version.  I've not spent the time to check whether it ends up
>> > correct or not; but your original patch was appropriate to the bug,
>> > and this one is just unnecessary churn in my view.
>>
>> Hi,
>>
>> I still think my previous patch does not solve the issue entirely.
>> The call set_blocksize() in swapoff quite often sets PAGE_SIZE instead
>> of valid block size (e.g. 512). I trigger this with:
>
> PAGE_SIZE and 512 are equally valid block sizes,
> it's just hard to support both consistently at the same instant.
>
>> ------
>> for i in `seq 1000`
>> do
>>       swapoff /dev/sdc1 &
>>       swapon /dev/sdc1 &
>>       swapon /dev/sdc1 &
>> done
>> ------
>> 10 seconds run of this script resulted in 50% of set_blocksize(PAGE_SIZE=
).
>> Although effect can only be observed after adding printks (block device =
is
>> released).
>
> But despite PAGE_SIZE being a valid block size,
> I agree that it's odd if you see variation there.
>
> Here's my guess: it looks as if the p->bdev test is inadequate, in the
> decision whether bad_swap should set_blocksize() or not: p->bdev is not
> usually reset when a swap_info_struct is released for reuse.
>
> Please try correcting that, either by resetting p->bdev where necessary,
> or by putting a better test in bad_swap: see if that fixes this oddity.
>
> I still much prefer your original little patch,
> to this extension of the use of swapon_mutex.
>
> However, a bigger question would be, why does swapoff have to set block
> size back to old_block_size anyway?  That was introduced in 2.5.13 by
>
> <viro@math.psu.edu> (02/05/01 1.447.69.1)
>         [PATCH] (1/6) blksize_size[] removal
>
>          - preliminary cleanups: make sure that swapoff restores original=
 block
>            size, kill set_blocksize() (and use of __bread()) in multipath=
.c,
>            reorder opening device and finding its block size in mtdblock.=
c.
>
> Al, not an urgent question, but is this swapoff old_block_size stuff
> still necessary?  And can't swapon just use whatever bd_block_size is
> already in force?  IIUC, it plays no part beyond the initial readpage
> of swap header.
>
> Thanks,
> Hugh

Let me try to explain(and guess):
we have to set_block in swapon. the swap_header is PAGE_SIZE, if device's
blocksize is more than PAGE_SIZE, then the swap entry address on swapfile
would be not PAGE_SIZE aligned. or one swap page can not fill a block.
There maybe a problem for some device.
The set_blocksize() do the judgement work for swapon.
And may be some userland tools assume swap device blocksize is PAGE_SIZE=EF=
=BC=9F

issues here are more than this one:
After swap_info_struct is released for reuse in swapoff.
Its corresponding resources are released later, such as:
- swap_cgroup_swapoff(type);
- blkdev_put
- inode->i_flags &=3D ~S_SWAPFILE;

we need release(or clean) these resources before release swap_info_struct.

to Krzysztof: I think it is better to add this handle to your patch

regards

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
