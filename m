Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8C50F6B004A
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 06:06:25 -0400 (EDT)
Received: by gwj21 with SMTP id 21so1151317gwj.14
        for <linux-mm@kvack.org>; Tue, 19 Oct 2010 03:06:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTin3wXWwA-HXhjx6wvzznp3p57Pg6fee8YNkZB79@mail.gmail.com>
References: <20100915091118.3dbdc961@notabene>
	<4C90139A.1080809@redhat.com>
	<20100915122334.3fa7b35f@notabene>
	<20100915082843.GA17252@localhost>
	<20100915184434.18e2d933@notabene>
	<20101018151459.2b443221@notabene>
	<AANLkTimv_zXHdFDGa9ecgXyWmQynOKTDRPC59PZA9mvL@mail.gmail.com>
	<20101019101151.57c6dd56@notabene>
	<AANLkTin3wXWwA-HXhjx6wvzznp3p57Pg6fee8YNkZB79@mail.gmail.com>
Date: Tue, 19 Oct 2010 12:06:21 +0200
Message-ID: <AANLkTimVu+5gTDs8przJVP2EbWC=FX-zWW7aH08BtrHC@mail.gmail.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
From: Torsten Kaiser <just.for.lkml@googlemail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Neil Brown <neilb@suse.de>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 10:43 AM, Torsten Kaiser
<just.for.lkml@googlemail.com> wrote:
> On Tue, Oct 19, 2010 at 1:11 AM, Neil Brown <neilb@suse.de> wrote:
>> Yes, thanks for the report.
>> This is a real bug exactly as you describe.
>>
>> This is how I think I will fix it, though it needs a bit of review and
>> testing before I can be certain.
>> Also I need to check raid10 etc to see if they can suffer too.
>>
>> If you can test it I would really appreciate it.
>
> I did test it, but while it seemed to fix the deadlock, the system
> still got unusable.
> The still running "vmstat 1" showed that the swapout was still
> progressing, but at a rate of ~20k sized bursts every 5 to 20 seconds.
>
> I also tried to additionally add Wu's patch:
> --- linux-next.orig/mm/vmscan.c 2010-10-13 12:35:14.000000000 +0800
> +++ linux-next/mm/vmscan.c =A0 =A0 =A02010-10-19 00:13:04.000000000 +0800
> @@ -1163,6 +1163,13 @@ static int too_many_isolated(struct zone
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 isolated =3D zone_page_state(zone, NR_ISOLATE=
D_ANON);
> =A0 =A0 =A0 }
>
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* GFP_NOIO/GFP_NOFS callers are allowed to isolate more =
pages, so that
> + =A0 =A0 =A0 =A0* they won't get blocked by normal ones and form circula=
r deadlock.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if ((sc->gfp_mask & GFP_IOFS) =3D=3D GFP_IOFS)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 inactive >>=3D 3;
> +
> =A0 =A0 =A0 return isolated > inactive;
>
> Either it did help somewhat, or I was more lucky on my second try, but
> this time I needed ~5 tries instead of only 2 to get the system mostly
> stuck again. On the testrun with Wu's patch the writeout pattern was
> more stable, a burst of ~80kb each 20 seconds. But I would suspect
> that the size of the burst is rather random.
>
> I do have a complete SysRq+T dump from the first run, I can send that
> to anyone how wants it.
> (It's 190k so I don't want not spam it to the list)

Is this call trace from the SysRq+T violation the rule to only
allocate one bio from bio_alloc() until its submitted?

[  549.700038] Call Trace:
[  549.700038]  [<ffffffff81566b54>] schedule_timeout+0x144/0x200
[  549.700038]  [<ffffffff81045cd0>] ? process_timeout+0x0/0x10
[  549.700038]  [<ffffffff81565e22>] io_schedule_timeout+0x42/0x60
[  549.700038]  [<ffffffff81083123>] mempool_alloc+0x163/0x1b0
[  549.700038]  [<ffffffff81053560>] ? autoremove_wake_function+0x0/0x40
[  549.700038]  [<ffffffff810ea2b9>] bio_alloc_bioset+0x39/0xf0
[  549.700038]  [<ffffffff810ea38d>] bio_clone+0x1d/0x50
[  549.700038]  [<ffffffff814318ed>] make_request+0x23d/0x850
[  549.700038]  [<ffffffff81082e20>] ? mempool_alloc_slab+0x10/0x20
[  549.700038]  [<ffffffff81045cd0>] ? process_timeout+0x0/0x10
[  549.700038]  [<ffffffff81436e63>] md_make_request+0xc3/0x220
[  549.700038]  [<ffffffff81083099>] ? mempool_alloc+0xd9/0x1b0
[  549.700038]  [<ffffffff811ec153>] generic_make_request+0x1b3/0x370
[  549.700038]  [<ffffffff810ea2d6>] ? bio_alloc_bioset+0x56/0xf0
[  549.700038]  [<ffffffff811ec36a>] submit_bio+0x5a/0xd0
[  549.700038]  [<ffffffff81080cf5>] ? unlock_page+0x25/0x30
[  549.700038]  [<ffffffff810a871e>] swap_writepage+0x7e/0xc0
[  549.700038]  [<ffffffff81090d99>] shmem_writepage+0x1c9/0x240
[  549.700038]  [<ffffffff8108c9cb>] pageout+0x11b/0x270
[  549.700038]  [<ffffffff8108cd78>] shrink_page_list+0x258/0x4d0
[  549.700038]  [<ffffffff8108d9e7>] shrink_inactive_list+0x187/0x310
[  549.700038]  [<ffffffff8102dcb1>] ? __wake_up_common+0x51/0x80
[  549.700038]  [<ffffffff811fc8b2>] ? cpumask_next_and+0x22/0x40
[  549.700038]  [<ffffffff8108e1c0>] shrink_zone+0x3e0/0x470
[  549.700038]  [<ffffffff8108e797>] try_to_free_pages+0x157/0x410
[  549.700038]  [<ffffffff81087c92>] __alloc_pages_nodemask+0x412/0x760
[  549.700038]  [<ffffffff810b27d6>] alloc_pages_current+0x76/0xe0
[  549.700038]  [<ffffffff810b6dad>] new_slab+0x1fd/0x2a0
[  549.700038]  [<ffffffff81045cd0>] ? process_timeout+0x0/0x10
[  549.700038]  [<ffffffff810b8721>] __slab_alloc+0x111/0x540
[  549.700038]  [<ffffffff81059961>] ? prepare_creds+0x21/0xb0
[  549.700038]  [<ffffffff810b92bb>] kmem_cache_alloc+0x9b/0xa0
[  549.700038]  [<ffffffff81059961>] prepare_creds+0x21/0xb0
[  549.700038]  [<ffffffff8104a919>] sys_setresgid+0x29/0x120
[  549.700038]  [<ffffffff8100242b>] system_call_fastpath+0x16/0x1b
[  549.700038]  ffff88011e125ea8 0000000000000046 ffff88011e125e08
ffffffff81073c59
[  549.700038]  0000000000012780 ffff88011ea905b0 ffff88011ea90808
ffff88011e125fd8
[  549.700038]  ffff88011ea90810 ffff88011e124010 0000000000012780
ffff88011e125fd8

swap_writepage() uses get_swap_bio() which uses bio_alloc() to get one
bio. That bio is the submitted, but the submit path seems to get into
make_request from raid1.c and that allocates a second bio from
bio_alloc() via bio_clone().

I am seeing this pattern (swap_writepage calling
md_make_request/make_request and then getting stuck in mempool_alloc)
more than 5 times in the SysRq+T output...


Torsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
