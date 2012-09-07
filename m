Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 8034E6B005A
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 02:29:30 -0400 (EDT)
Received: by eaaf11 with SMTP id f11so912740eaa.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 23:29:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.00.1209061255530.509@new-host-2>
References: <5040C11C.4060505@gmail.com>
	<alpine.LFD.2.00.1209061255530.509@new-host-2>
Date: Fri, 7 Sep 2012 08:29:28 +0200
Message-ID: <CANGUGtB9-DuypSnT0zobd9CK88SW8x=FGCnwaHZEDjtkJ33doQ@mail.gmail.com>
Subject: Re: [PATCH 00/21] drop vmtruncate
From: Marco Stornelli <marco.stornelli@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-2?Q?Luk=E1=B9_Czerner?= <lczerner@redhat.com>
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

2012/9/6 Luk=C3=A1=C5=A1 Czerner <lczerner@redhat.com>:
> On Fri, 31 Aug 2012, Marco Stornelli wrote:
>
>> Date: Fri, 31 Aug 2012 15:50:20 +0200
>> From: Marco Stornelli <marco.stornelli@gmail.com>
>> To: Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org
>> Cc: Linux Kernel <linux-kernel@vger.kernel.org>
>> Subject: [PATCH 00/21] drop vmtruncate
>>
>> Hi all,
>>
>> with this patch series I try to clean the vmtruncate code. The theory of
>> operation:
>>
>> old               new
>> vmtruncate() =3D>   inode_newsize_ok+truncate_setsize+fs truncate
>>
>> Where vmtruncate was used without any error check, the code now is:
>>
>> if (inode_newsize_ok() =3D=3D 0) {
>>       truncate_setsize();
>>       fs truncate();
>> }
>>
>> So, performance and semantic nothing change at all. I think that maybe i=
n some
>> point we can skip inode_newsize_ok (where the error check of vmtruncate =
wasn't
>> used) but since there is a swap check in case of no-extension, maybe it'=
s
>> better to avoid regressions. After this clean, of course, each fs can cl=
ean in
>> a deeply way.
>>
>> With these patches even the inode truncate callback is deleted.
>>
>> Any comments/feedback/bugs are welcome.
>
> Could you explain the reason behind this change a little bit more ?
> This does not make any sense to me since you're replacing
> vmtruncate() which does basically
>
> if (inode_newsize_ok() =3D=3D 0) {
>         truncate_setsize();
>         fs truncate();
> }
>
> as you mentioned above by exactly the same thing but doing it within
> the file system. It does not seem like an improvement to me ... how
> is this a clean up ?
>
> Thanks!
> -Lukas
>

First of all we have one function less in our stack :) Vmtruncate (see
comments) is deprecated, so it's better to remove it completly. In
this way we can remove even the truncate call back in inode operations
(so save 4byte/8byte per struct for the pointer). The first goal of
this cleaning activity, however, is remove a "deprecated" function to
have a code much more readable. As I said, this patch series is only a
*first* cleanup, each fs can of course clean its code in a deeply way.
As you can see, the patch span over several fs, to be *safe* I
preferred to use a conservative approach. Where vmtruncate was called
without error check, as I said, maybe we can remove
inode_newsize_ok(), but since in this way we skip a check, I preferred
that approach. It seems that for NTFS and Raiserfs it's ok.

Marco

Marco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
