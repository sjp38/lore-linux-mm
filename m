Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id BDFE86B025F
	for <linux-mm@kvack.org>; Mon, 16 May 2016 09:55:33 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id j8so98668106lfd.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 06:55:33 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id e89si20280161wmc.42.2016.05.16.06.55.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 06:55:32 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id e201so101984200wme.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 06:55:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5739B60E.1090700@suse.cz>
References: <1462713387-16724-1-git-send-email-anthony.romano@coreos.com>
	<5739B60E.1090700@suse.cz>
Date: Mon, 16 May 2016 06:55:32 -0700
Message-ID: <CAENtvd4js+a3RnvyRJWyRaCU9p-xoQ5F1F-yX2FF9WmbDHiL7Q@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: don't undo fallocate past its last page
From: Anthony Romano <anthony.romano@coreos.com>
Content-Type: multipart/alternative; boundary=001a1147145c5d5b000532f5faa4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--001a1147145c5d5b000532f5faa4
Content-Type: text/plain; charset=UTF-8

The code for shmem_undo_range is very similar to truncate_inode_pages_range
so I assume that's why it's using an inclusive range.

It appears the bug was introduced in
1635f6a74152f1dcd1b888231609d64875f0a81a

On Mon, May 16, 2016 at 4:59 AM, Vlastimil Babka <vbabka@suse.cz> wrote:

> On 05/08/2016 03:16 PM, Anthony Romano wrote:
>
>> When fallocate is interrupted it will undo a range that extends one byte
>> past its range of allocated pages. This can corrupt an in-use page by
>> zeroing out its first byte. Instead, undo using the inclusive byte range.
>>
>
> Huh, good catch. So why is shmem_undo_range() adding +1 to the value in
> the first place? The only other caller is shmem_truncate_range() and all
> *its* callers do subtract 1 to avoid the same issue. So a nicer fix would
> be to remove all this +1/-1 madness. Or is there some subtle corner case
> I'm missing?
>
> Signed-off-by: Anthony Romano <anthony.romano@coreos.com>
>>
>
> Looks like a stable candidate patch. Can you point out the commit that
> introduced the bug, for the Fixes: tag?
>
> Thanks,
> Vlastimil
>
>
> ---
>>   mm/shmem.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 719bd6b..f0f9405 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -2238,7 +2238,7 @@ static long shmem_fallocate(struct file *file, int
>> mode, loff_t offset,
>>                         /* Remove the !PageUptodate pages we added */
>>                         shmem_undo_range(inode,
>>                                 (loff_t)start << PAGE_SHIFT,
>> -                               (loff_t)index << PAGE_SHIFT, true);
>> +                               ((loff_t)index << PAGE_SHIFT) - 1, true);
>>                         goto undone;
>>                 }
>>
>>
>>
>

--001a1147145c5d5b000532f5faa4
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">The code for shmem_undo_range is very similar to truncate_=
inode_pages_range so I assume that&#39;s why it&#39;s using an inclusive ra=
nge.<br><br>It appears the bug was introduced in 1635f6a74152f1dcd1b8882316=
09d64875f0a81a<br></div><div class=3D"gmail_extra"><br><div class=3D"gmail_=
quote">On Mon, May 16, 2016 at 4:59 AM, Vlastimil Babka <span dir=3D"ltr">&=
lt;<a href=3D"mailto:vbabka@suse.cz" target=3D"_blank">vbabka@suse.cz</a>&g=
t;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On 05/0=
8/2016 03:16 PM, Anthony Romano wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
When fallocate is interrupted it will undo a range that extends one byte<br=
>
past its range of allocated pages. This can corrupt an in-use page by<br>
zeroing out its first byte. Instead, undo using the inclusive byte range.<b=
r>
</blockquote>
<br></span>
Huh, good catch. So why is shmem_undo_range() adding +1 to the value in the=
 first place? The only other caller is shmem_truncate_range() and all *its*=
 callers do subtract 1 to avoid the same issue. So a nicer fix would be to =
remove all this +1/-1 madness. Or is there some subtle corner case I&#39;m =
missing?<br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
Signed-off-by: Anthony Romano &lt;<a href=3D"mailto:anthony.romano@coreos.c=
om" target=3D"_blank">anthony.romano@coreos.com</a>&gt;<br>
</blockquote>
<br>
Looks like a stable candidate patch. Can you point out the commit that intr=
oduced the bug, for the Fixes: tag?<br>
<br>
Thanks,<br>
Vlastimil<div class=3D"HOEnZb"><div class=3D"h5"><br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
---<br>
=C2=A0 mm/shmem.c | 2 +-<br>
=C2=A0 1 file changed, 1 insertion(+), 1 deletion(-)<br>
<br>
diff --git a/mm/shmem.c b/mm/shmem.c<br>
index 719bd6b..f0f9405 100644<br>
--- a/mm/shmem.c<br>
+++ b/mm/shmem.c<br>
@@ -2238,7 +2238,7 @@ static long shmem_fallocate(struct file *file, int mo=
de, loff_t offset,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 /* Remove the !PageUptodate pages we added */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 shmem_undo_range(inode,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (loff_t)start &lt;&lt; PAGE_SHIFT,<b=
r>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(loff_t)index &lt;&lt; PAGE_SHIFT, tr=
ue);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0((loff_t)index &lt;&lt; PAGE_SHIFT) -=
 1, true);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto undone;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
<br>
<br>
</blockquote>
<br>
</div></div></blockquote></div><br></div>

--001a1147145c5d5b000532f5faa4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
