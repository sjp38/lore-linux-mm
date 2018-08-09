Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id D1B1A6B0007
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 08:25:50 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v4-v6so5467226oix.2
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 05:25:50 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n126-v6sor3902222oif.297.2018.08.09.05.25.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Aug 2018 05:25:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <EA52CBCF76D5E04D95BED55B83577BE7A677C0@MBX50.360buyAD.local>
References: <EA52CBCF76D5E04D95BED55B83577BE7A677C0@MBX50.360buyAD.local>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 9 Aug 2018 14:25:47 +0200
Message-ID: <CAJfpegt4ymM8Zuto8vDX4djP5S-t3DMaaKn0ntwCsG1JaBpExg@mail.gmail.com>
Subject: Re: FUSE: write operations trigger balance_dirty_pages when using
 writeback cache
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?5YiY56GV54S2?= <liushuoran@jd.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, =?UTF-8?B?5YiY5rW36ZSL?= <bjliuhaifeng@jd.com>, =?UTF-8?B?6YOt5Y2r6b6Z?= <guoweilong@jd.com>

On Thu, Aug 9, 2018 at 2:08 PM, =E5=88=98=E7=A1=95=E7=84=B6 <liushuoran@jd.=
com> wrote:
> Thanks for the advice. I tried removing BDI_CAP_STRICTLIMIT, and it works=
. There is no balance_dirty_pages() triggered, and the performance improves=
 a lot.
>
> Tested by libfuse passthrough_ll example and fio:
> ./passthrough_ll -o writeback /mnt/fuse/
> fio --name=3Dtest --ioengine=3Dpsync --directory=3D/mnt/fuse/home/test --=
bs=3D4k --direct=3D0 --size=3D64M --rw=3Dwrite --fallocate=3D0 --numjobs=3D=
1
>
> performance with BDI_CAP_STRICTLIMIT:
> WRITE: bw=3D158MiB/s (165MB/s), 158MiB/s-158MiB/s (165MB/s-165MB/s), io=
=3D64.0MiB (67.1MB), run=3D406-406msec
>
> Performance without BDI_CAP_STRICTLIMIT:
> WRITE: bw=3D1561MiB/s (1637MB/s), 1561MiB/s-1561MiB/s (1637MB/s-1637MB/s)=
, io=3D64.0MiB (67.1MB), run=3D41-41msec
>
> However, I wonder if there are some side-effects to remove it? Since it s=
eems that the original purpose of this feature is to prevent FUSE from cons=
uming too much memory.

Yes.  So if BDI_CAP_STRICTLIMIT is causing a serious performance
bottleneck, then we need to think about solving this without losing
the benefits.  Simply removing it is definitely not a proper solution.

Thanks,
Miklos
