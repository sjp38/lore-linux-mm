Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1061C6B017C
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 14:25:33 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so4922040pab.25
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 11:25:33 -0700 (PDT)
Received: from psmtp.com ([74.125.245.146])
        by mx.google.com with SMTP id mi5si2071525pab.280.2013.10.18.11.25.08
        for <linux-mm@kvack.org>;
        Fri, 18 Oct 2013 11:25:32 -0700 (PDT)
Received: by mail-vc0-f177.google.com with SMTP id ib11so520231vcb.8
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 11:25:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACz4_2cVZBxg88hqzOHpASN4e=hVYMTTQkXHssDjfXpcqACONw@mail.gmail.com>
References: <20131015001826.GL3432@hippobay.mtv.corp.google.com>
 <20131015110905.085B1E0090@blue.fi.intel.com> <CACz4_2cVZBxg88hqzOHpASN4e=hVYMTTQkXHssDjfXpcqACONw@mail.gmail.com>
From: Ning Qu <quning@google.com>
Date: Fri, 18 Oct 2013 11:24:46 -0700
Message-ID: <CACz4_2c0vvM2HwotMZbz9WWGZbCBmWCD=LrFRAK7uxcGXH+smQ@mail.gmail.com>
Subject: Re: [PATCH 11/12] mm, thp, tmpfs: enable thp page cache in tmpfs
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

I guess this is the last review I have for this around, but not sure
what's the best solution right now.

Kirill, do you think it's OK to just split the huge page when it will
be moved. Will look into how thp anon handle this situation.

Then after this, I probably will post v2.

Thanks!
Best wishes,
--=20
Ning Qu (=C7=FA=C4=FE) | Software Engineer | quning@google.com | +1-408-418=
-6066


On Tue, Oct 15, 2013 at 11:42 AM, Ning Qu <quning@google.com> wrote:
> I agree with this. It has been like this just for a quick proof, but I
> need to address this problem as soon as possible.
>
> Thanks!
> Best wishes,
> --
> Ning Qu (=C7=FA=C4=FE) | Software Engineer | quning@google.com | +1-408-4=
18-6066
>
>
> On Tue, Oct 15, 2013 at 4:09 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
>> Ning Qu wrote:
>>> Signed-off-by: Ning Qu <quning@gmail.com>
>>> ---
>>>  mm/Kconfig | 4 ++--
>>>  mm/shmem.c | 5 +++++
>>>  2 files changed, 7 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/mm/Kconfig b/mm/Kconfig
>>> index 562f12f..4d2f90f 100644
>>> --- a/mm/Kconfig
>>> +++ b/mm/Kconfig
>>> @@ -428,8 +428,8 @@ config TRANSPARENT_HUGEPAGE_PAGECACHE
>>>       help
>>>         Enabling the option adds support hugepages for file-backed
>>>         mappings. It requires transparent hugepage support from
>>> -       filesystem side. For now, the only filesystem which supports
>>> -       hugepages is ramfs.
>>> +       filesystem side. For now, the filesystems which support
>>> +       hugepages are: ramfs and tmpfs.
>>>
>>>  config CROSS_MEMORY_ATTACH
>>>       bool "Cross Memory Support"
>>> diff --git a/mm/shmem.c b/mm/shmem.c
>>> index 75c0ac6..50a3335 100644
>>> --- a/mm/shmem.c
>>> +++ b/mm/shmem.c
>>> @@ -1672,6 +1672,11 @@ static struct inode *shmem_get_inode(struct supe=
r_block *sb, const struct inode
>>>                       break;
>>>               case S_IFREG:
>>>                       inode->i_mapping->a_ops =3D &shmem_aops;
>>> +                     /*
>>> +                      * TODO: make tmpfs pages movable
>>> +                      */
>>> +                     mapping_set_gfp_mask(inode->i_mapping,
>>> +                                          GFP_TRANSHUGE & ~__GFP_MOVAB=
LE);
>>
>> Unlike ramfs, tmpfs pages are movable before transparent page cache
>> patchset.
>> Making tmpfs pages non-movable looks like a big regression to me. It nee=
d
>> to be fixed before proposing it upstream.
>>
>> --
>>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
