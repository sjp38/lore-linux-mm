Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 621C16B0070
	for <linux-mm@kvack.org>; Sat,  1 Mar 2014 01:37:14 -0500 (EST)
Received: by mail-vc0-f179.google.com with SMTP id lh14so1717963vcb.10
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 22:37:14 -0800 (PST)
Received: from mail-vc0-x235.google.com (mail-vc0-x235.google.com [2607:f8b0:400c:c03::235])
        by mx.google.com with ESMTPS id us10si2735908vcb.59.2014.02.28.22.37.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 22:37:12 -0800 (PST)
Received: by mail-vc0-f181.google.com with SMTP id lg15so1661141vcb.40
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 22:37:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1402281657520.976@eggly.anvils>
References: <1393625931-2858-1-git-send-email-quning@google.com>
 <1393625931-2858-2-git-send-email-quning@google.com> <alpine.LSU.2.11.1402281657520.976@eggly.anvils>
From: Ning Qu <quning@google.com>
Date: Fri, 28 Feb 2014 22:36:29 -0800
Message-ID: <CACQD4-4bbwk_LOUVamTyB6V+Fg_F+Q4q2g8DxroTM7YiA=eJzQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm: implement ->map_pages for shmem/tmpfs
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Btw, should we first check if page returned by radix_tree_deref_slot is NUL=
L?

diff --git a/mm/filemap.c b/mm/filemap.c
index 1bc12a9..c129ee5 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1745,6 +1745,8 @@ void filemap_map_pages(struct vm_area_struct
*vma, struct vm_fault *vmf)
                        break;
 repeat:
                page =3D radix_tree_deref_slot(slot);
+               if (unlikely(!page))
+                       continue;
                if (radix_tree_exception(page)) {
                        if (radix_tree_deref_retry(page))


Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Fri, Feb 28, 2014 at 5:20 PM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 28 Feb 2014, Ning Qu wrote:
>
>> In shmem/tmpfs, we also use the generic filemap_map_pages,
>> seems the additional checking is not worth a separate version
>> of map_pages for it.
>>
>> Signed-off-by: Ning Qu <quning@google.com>
>> ---
>>  mm/shmem.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 1f18c9d..2ea4e89 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -2783,6 +2783,7 @@ static const struct super_operations shmem_ops =3D=
 {
>>
>>  static const struct vm_operations_struct shmem_vm_ops =3D {
>>       .fault          =3D shmem_fault,
>> +     .map_pages      =3D filemap_map_pages,
>>  #ifdef CONFIG_NUMA
>>       .set_policy     =3D shmem_set_policy,
>>       .get_policy     =3D shmem_get_policy,
>> --
>
> (There's no need for a 0/1, all the info should go into the one patch.)
>
> I expect this will prove to be a very sensible and adequate patch,
> thank you: it probably wouldn't be worth more effort to give shmem
> anything special of its own, and filemap_map_pages() is already
> (almost) coping with exceptional entries.
>
> But I can't Ack it until I've tested it some more, won't be able to
> do so until Sunday; and even then some doubt, since this and Kirill's
> are built upon mmotm/next, which after a while gives me spinlock
> lockups under load these days, yet to be investigated.
>
> "almost" above because, Kirill, even without Ning's extension to
> shmem, your filemap_map_page() soon crashes on an exceptional entry:
>
> Don't try to dereference an exceptional entry.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
>
> --- mmotm+kirill/mm/filemap.c   2014-02-28 15:17:50.984019060 -0800
> +++ linux/mm/filemap.c  2014-02-28 16:38:04.976633308 -0800
> @@ -2084,7 +2084,7 @@ repeat:
>                         if (radix_tree_deref_retry(page))
>                                 break;
>                         else
> -                               goto next;
> +                               continue;
>                 }
>
>                 if (!page_cache_get_speculative(page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
