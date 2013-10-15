Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1151E6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 14:43:02 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so9477637pab.34
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 11:43:02 -0700 (PDT)
Received: by mail-ve0-f181.google.com with SMTP id pa12so882054veb.40
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 11:43:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131015110905.085B1E0090@blue.fi.intel.com>
References: <20131015001826.GL3432@hippobay.mtv.corp.google.com> <20131015110905.085B1E0090@blue.fi.intel.com>
From: Ning Qu <quning@google.com>
Date: Tue, 15 Oct 2013 11:42:39 -0700
Message-ID: <CACz4_2cVZBxg88hqzOHpASN4e=hVYMTTQkXHssDjfXpcqACONw@mail.gmail.com>
Subject: Re: [PATCH 11/12] mm, thp, tmpfs: enable thp page cache in tmpfs
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

I agree with this. It has been like this just for a quick proof, but I
need to address this problem as soon as possible.

Thanks!
Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Tue, Oct 15, 2013 at 4:09 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Ning Qu wrote:
>> Signed-off-by: Ning Qu <quning@gmail.com>
>> ---
>>  mm/Kconfig | 4 ++--
>>  mm/shmem.c | 5 +++++
>>  2 files changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 562f12f..4d2f90f 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -428,8 +428,8 @@ config TRANSPARENT_HUGEPAGE_PAGECACHE
>>       help
>>         Enabling the option adds support hugepages for file-backed
>>         mappings. It requires transparent hugepage support from
>> -       filesystem side. For now, the only filesystem which supports
>> -       hugepages is ramfs.
>> +       filesystem side. For now, the filesystems which support
>> +       hugepages are: ramfs and tmpfs.
>>
>>  config CROSS_MEMORY_ATTACH
>>       bool "Cross Memory Support"
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 75c0ac6..50a3335 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -1672,6 +1672,11 @@ static struct inode *shmem_get_inode(struct super=
_block *sb, const struct inode
>>                       break;
>>               case S_IFREG:
>>                       inode->i_mapping->a_ops =3D &shmem_aops;
>> +                     /*
>> +                      * TODO: make tmpfs pages movable
>> +                      */
>> +                     mapping_set_gfp_mask(inode->i_mapping,
>> +                                          GFP_TRANSHUGE & ~__GFP_MOVABL=
E);
>
> Unlike ramfs, tmpfs pages are movable before transparent page cache
> patchset.
> Making tmpfs pages non-movable looks like a big regression to me. It need
> to be fixed before proposing it upstream.
>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
