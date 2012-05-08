Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id D1B076B00E9
	for <linux-mm@kvack.org>; Tue,  8 May 2012 12:35:57 -0400 (EDT)
Received: by bkwj4 with SMTP id j4so7275781bkw.22
        for <linux-mm@kvack.org>; Tue, 08 May 2012 09:35:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAB+TZU8FNWuHrf6Hqnjs5fwH8yMJgd=CLPB0iUkrs2a-fgehtQ@mail.gmail.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
 <1336054995-22988-2-git-send-email-svenkatr@ti.com> <20120506233117.GU5091@dastard>
 <CAB+TZU8FNWuHrf6Hqnjs5fwH8yMJgd=CLPB0iUkrs2a-fgehtQ@mail.gmail.com>
From: "S, Venkatraman" <svenkatr@ti.com>
Date: Tue, 8 May 2012 22:05:32 +0530
Message-ID: <CANfBPZ9dzzamHe=O+Zi0w+Romk8WPerp6qF+3KsRvv+U_ZBFYA@mail.gmail.com>
Subject: Re: [PATCH v2 01/16] FS: Added demand paging markers to filesystem
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mani <manishrma@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk

On Tue, May 8, 2012 at 11:58 AM, mani <manishrma@gmail.com> wrote:
> How about adding the AS_DMPG flag in the file -> address_space when getti=
ng
> a filemap_fault()
> so that we can treat the page fault pages as the high priority pages over
> normal read requests.
> How about changing below lines for the support of the pages those are
> requested for the page fault ?
>
>
> --- a/fs/mpage.c 2012-05-04 12:59:12.000000000 +0530
> +++ b/fs/mpage.c 2012-05-07 13:13:49.000000000 +0530
> @@ -408,6 +408,8 @@ mpage_readpages(struct address_space *ma
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 &last_block_in_=
bio, &map_bh,
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 &first_logical_=
block,
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 get_block);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if(test_bit(AS_DMPG, &mapping->flags) && =
bio)
>
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 bio->bi_rw |=3D REQ_RW_=
DMPG
> =A0=A0=A0=A0=A0=A0=A0 }
> =A0=A0=A0=A0=A0=A0=A0 page_cache_release(page);
> =A0=A0=A0 }
> --- a/include/linux/pagemap.h=A0=A0=A0 2012-05-04 12:57:35.000000000 +053=
0
> +++ b/include/linux/pagemap.h=A0=A0=A0 2012-05-07 13:15:24.000000000 +053=
0
> @@ -27,6 +27,7 @@ enum mapping_flags {
> =A0#if defined (CONFIG_BD_CACHE_ENABLED)
> =A0=A0=A0 AS_DIRECT=A0 =3D=A0=A0 __GFP_BITS_SHIFT + 4,=A0 /* DIRECT_IO sp=
ecified on file op
> */
> =A0#endif
> +=A0=A0 AS_DMPG=A0 =3D=A0=A0 __GFP_BITS_SHIFT + 5,=A0 /* DEMAND PAGE spec=
ified on file op
> */
> =A0};
>
> =A0static inline void mapping_set_error(struct address_space *mapping, in=
t
> error)
>
> --- a/mm/filemap.c=A0=A0 2012-05-04 12:58:49.000000000 +0530
> +++ b/mm/filemap.c=A0=A0 2012-05-07 13:15:03.000000000 +0530
> @@ -1646,6 +1646,7 @@ int filemap_fault(struct vm_area_struct
> =A0=A0=A0 if (offset >=3D size)
> =A0=A0=A0=A0=A0=A0=A0 return VM_FAULT_SIGBUS;
>
> +=A0=A0 set_bit(AS_DMPG, &file->f_mapping->flags);
> =A0=A0=A0 /*
> =A0=A0=A0=A0 * Do we have something in the page cache already?
> =A0=A0=A0=A0 */
>
> Will these changes have any adverse effect ?
>

Thanks for the example but I can't judge which of the two is the most
elegant or acceptable to maintainers.
I can test with your change and inform if it works.

> Thanks & Regards
> Manish
>
> On Mon, May 7, 2012 at 5:01 AM, Dave Chinner <david@fromorbit.com> wrote:
>>
>> On Thu, May 03, 2012 at 07:53:00PM +0530, Venkatraman S wrote:
>> > From: Ilan Smith <ilan.smith@sandisk.com>
>> >
>> > Add attribute to identify demand paging requests.
>> > Mark readpages with demand paging attribute.
>> >
>> > Signed-off-by: Ilan Smith <ilan.smith@sandisk.com>
>> > Signed-off-by: Alex Lemberg <alex.lemberg@sandisk.com>
>> > Signed-off-by: Venkatraman S <svenkatr@ti.com>
>> > ---
>> > =A0fs/mpage.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 ++
>> > =A0include/linux/bio.h =A0 =A0 =A0 | =A0 =A07 +++++++
>> > =A0include/linux/blk_types.h | =A0 =A02 ++
>> > =A03 files changed, 11 insertions(+)
>> >
>> > diff --git a/fs/mpage.c b/fs/mpage.c
>> > index 0face1c..8b144f5 100644
>> > --- a/fs/mpage.c
>> > +++ b/fs/mpage.c
>> > @@ -386,6 +386,8 @@ mpage_readpages(struct address_space *mapping,
>> > struct list_head *pages,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 &last_block_in_bio, &map_bh,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 &first_logical_block,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 get_block);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bio)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bio->bi_rw |=
=3D REQ_RW_DMPG;
>>
>> Have you thought about the potential for DOSing a machine
>> with this? That is, user data reads can now preempt writes of any
>> kind, effectively stalling writeback and memory reclaim which will
>> lead to OOM situations. Or, alternatively, journal flushing will get
>> stalled and no new modifications can take place until the read
>> stream stops.
>>
>> This really seems like functionality that belongs in an IO
>> scheduler so that write starvation can be avoided, not in high-level
>> data read paths where we have no clue about anything else going on
>> in the IO subsystem....
>>
>> Cheers,
>>
>> Dave.
>> --
>> Dave Chinner
>> david@fromorbit.com
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-mmc" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
