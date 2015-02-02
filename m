Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id E7E0E6B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 01:57:30 -0500 (EST)
Received: by mail-la0-f51.google.com with SMTP id ge10so37759273lab.10
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 22:57:30 -0800 (PST)
Received: from fiona.linuxhacker.ru ([217.76.32.60])
        by mx.google.com with ESMTPS id c6si4285270lag.104.2015.02.01.22.57.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Feb 2015 22:57:29 -0800 (PST)
Subject: Re: [PATCH] gfs2: use __vmalloc GFP_NOFS for fs-related allocations.
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <20150202053708.GG4251@dastard>
Date: Mon, 2 Feb 2015 01:57:23 -0500
Content-Transfer-Encoding: quoted-printable
Message-Id: <E68E8257-1CE5-4833-B751-26478C9818C7@linuxhacker.ru>
References: <1422849594-15677-1-git-send-email-green@linuxhacker.ru> <20150202053708.GG4251@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hello!

On Feb 2, 2015, at 12:37 AM, Dave Chinner wrote:

> On Sun, Feb 01, 2015 at 10:59:54PM -0500, green@linuxhacker.ru wrote:
>> From: Oleg Drokin <green@linuxhacker.ru>
>>=20
>> leaf_dealloc uses vzalloc as a fallback to kzalloc(GFP_NOFS), so
>> it clearly does not want any shrinker activity within the fs itself.
>> convert vzalloc into __vmalloc(GFP_NOFS|__GFP_ZERO) to better achieve
>> this goal.
>>=20
>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>> ---
>> fs/gfs2/dir.c | 3 ++-
>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/fs/gfs2/dir.c b/fs/gfs2/dir.c
>> index c5a34f0..6371192 100644
>> --- a/fs/gfs2/dir.c
>> +++ b/fs/gfs2/dir.c
>> @@ -1896,7 +1896,8 @@ static int leaf_dealloc(struct gfs2_inode *dip, =
u32 index, u32 len,
>>=20
>> 	ht =3D kzalloc(size, GFP_NOFS | __GFP_NOWARN);
>> 	if (ht =3D=3D NULL)
>> -		ht =3D vzalloc(size);
>> +		ht =3D __vmalloc(size, GFP_NOFS | __GFP_NOWARN | =
__GFP_ZERO,
>> +			       PAGE_KERNEL);
> That, in the end, won't help as vmalloc still uses GFP_KERNEL
> allocations deep down in the PTE allocation code. See the hacks in
> the DM and XFS code to work around this. i.e. go look for callers of
> memalloc_noio_save().  It's ugly and grotesque, but we've got no
> other way to limit reclaim context because the MM devs won't pass
> the vmalloc gfp context down the stack to the PTE allocations....

Hm, interesting.
So all the other code in the kernel that does this sort of thing (and =
there's quite a bit
outside of xfs and ocfs2) would not get the desired effect?

So, I did some digging in archives and found this thread from 2010 =
onward with various
patches and rants.
Not sure how I missed that before.

Should we have another run at this I wonder?

Bye,
    Oleg=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
