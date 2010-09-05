Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0C25D6B0047
	for <linux-mm@kvack.org>; Sat,  4 Sep 2010 22:51:20 -0400 (EDT)
Received: by iwn33 with SMTP id 33so3935551iwn.14
        for <linux-mm@kvack.org>; Sat, 04 Sep 2010 19:51:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100904020452.GA7788@localhost>
References: <1283438087-11842-1-git-send-email-minchan.kim@gmail.com>
	<20100903170227.b2f18ba4.akpm@linux-foundation.org>
	<20100904020452.GA7788@localhost>
Date: Sun, 5 Sep 2010 11:51:19 +0900
Message-ID: <AANLkTimzDkU-XqpFRTxB7Y0+q1vfs-o4pd8UrG7HPcNX@mail.gmail.com>
Subject: Re: [RESEND PATCH v2] compaction: fix COMPACTPAGEFAILED counting
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, Sep 4, 2010 at 11:04 AM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> On Sat, Sep 04, 2010 at 08:02:27AM +0800, Andrew Morton wrote:
>> On Thu, =A02 Sep 2010 23:34:47 +0900
>> Minchan Kim <minchan.kim@gmail.com> wrote:
>>
>> > Now update_nr_listpages doesn't have a role. That's because
>> > lists passed is always empty just after calling migrate_pages.
>> > The migrate_pages cleans up page list which have failed to migrate
>> > before returning by aaa994b3.
>> >
>> > =A0[PATCH] page migration: handle freeing of pages in migrate_pages()
>> >
>> > =A0Do not leave pages on the lists passed to migrate_pages(). =A0Seems=
 that we will
>> > =A0not need any postprocessing of pages. =A0This will simplify the han=
dling of
>> > =A0pages by the callers of migrate_pages().
>> >
>> > At that time, we thought we don't need any postprocessing of pages.
>> > But the situation is changed. The compaction need to know the number o=
f
>> > failed to migrate for COMPACTPAGEFAILED stat
>> >
>> > This patch makes new rule for caller of migrate_pages to call putback_=
lru_pages.
>> > So caller need to clean up the lists so it has a chance to postprocess=
 the pages.
>> > [suggested by Christoph Lameter]
>>
>> I'm having trouble predicting what the user-visible effects of this bug
>> might be. =A0Just an inaccuracy in the COMPACTPAGEFAILED vm event?
>
> Right, it's an accounting fix. Before patch COMPACTPAGEFAILED will
> remain 0 regardless of how many migration failures.
>
> The patch does slightly add dependency for migrate_pages() to return
> error code properly. Before patch, migrate_pages() calls
> putback_lru_pages() regardless of the error code. After patch, the
> migrate_pages() callers will check its return value before calling
> putback_lru_pages().
>
> In current code, the two conditions do seem to match:
>
> "some pages remained in the *from list" =3D=3D "migrate_pages() returns a=
n error code".

Exactly.
Thanks for the answering instead of me, Wu. :)

> Thanks,
> Fengguang
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
