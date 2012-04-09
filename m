Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id DC7A36B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 03:37:55 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout4.samsung.com [203.254.224.34])
 by mailout4.samsung.com
 (Oracle Communications Messaging Exchange Server 7u4-19.01 64bit (built Sep  7
 2010)) with ESMTP id <0M2700CCEBU97M00@mailout4.samsung.com> for
 linux-mm@kvack.org; Mon, 09 Apr 2012 16:37:54 +0900 (KST)
Received: from NOSYRJEONG01 ([12.52.126.171])
 by mmp2.samsung.com (Oracle Communications Messaging Exchange Server 7u4-19.01
 64bit (built Sep  7 2010)) with ESMTPA id <0M2700MLUBV56E30@mmp2.samsung.com>
 for linux-mm@kvack.org; Mon, 09 Apr 2012 16:37:53 +0900 (KST)
From: =?utf-8?B?7KCV7Zqo7KeE?= <syr.jeong@samsung.com>
References: <201203301744.16762.arnd@arndb.de>
 <201204021145.43222.arnd@arndb.de>
 <alpine.LSU.2.00.1204020734560.1847@eggly.anvils>
 <201204021455.25029.arnd@arndb.de>
 <D70D75BB1A02CA42A3E28AA542D282303A0661B561@MILMBMIPV3.sdcorp.global.sandisk.com>
 <4F8245EA.6000600@kernel.org>
In-reply-to: <4F8245EA.6000600@kernel.org>
Subject: RE: swap on eMMC and other flash
Date: Mon, 09 Apr 2012 16:37:53 +0900
Message-id: <006f01cd1623$ac4a2860$04de7920$%jeong@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: quoted-printable
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>, 'Alex Lemberg' <Alex.Lemberg@sandisk.com>
Cc: 'Arnd Bergmann' <arnd@arndb.de>, linaro-kernel@lists.linaro.org, 'Rik van Riel' <riel@redhat.com>, linux-mmc@vger.kernel.org, linux-kernel@vger.kernel.org, "'Luca Porzio (lporzio)'" <lporzio@micron.com>, linux-mm@kvack.org, kernel-team@android.com, 'Yejin Moon' <yejin.moon@samsung.com>, 'Hugh Dickins' <hughd@google.com>, 'Yaniv Iarovici' <Yaniv.Iarovici@sandisk.com>, cpgs@samsung.com

Hi Minchan

How are you doing?

Regarding time to issue Discard/Trim :
eMMC point of view, I believe that the immediate Discard/Trim CMD after =
deleting/freezing a SWAP cluster is always better for all of general =
eMMC implementation.

Regarding swap page size:
Actually, I can't guarantee the optimal size of different eMMC in the =
industry, because it depends on NAND page size an firmware =
implementation inside eMMC. In case of SAMSUNG eMMC, 8KB page size and =
512KB block size(erase unit) is current implementation.
I think that the multiple of 8KB page size align with 512KB is good for =
SAMSUNG eMMC.
If swap system use 512KB page and issue Discard/Trim align with 512KB, =
eMMC make best performance as of today. However, large page size in swap =
partition may not best way in Linux system level.
I'm not sure that the best page size between Swap system and eMMC =
device.

Best Regards
Hyojin
-----Original Message-----
From: Minchan Kim [mailto:minchan@kernel.org]=20
Sent: Monday, April 09, 2012 11:14 AM
To: Alex Lemberg
Cc: Arnd Bergmann; linaro-kernel@lists.linaro.org; Rik van Riel; =
linux-mmc@vger.kernel.org; linux-kernel@vger.kernel.org; Luca Porzio =
(lporzio); linux-mm@kvack.org; Hyojin Jeong; kernel-team@android.com; =
Yejin Moon; Hugh Dickins; Yaniv Iarovici
Subject: Re: swap on eMMC and other flash

2012-04-08 =EC=98=A4=ED=9B=84 10:50, Alex Lemberg =EC=93=B4 =EA=B8=80:

> Hi Arnd,
>=20
> Regarding time to issue discard/TRIM commands:
> It would be advised to issue the discard command immediately after =
deleting/freeing a SWAP cluster (i.e. as soon as it becomes available).


Is it still good with page size, not cluster size?

>=20
> Regarding SWAP page size:
> Working with as large as SWAP pages as possible would be recommended =
(preferably 64KB). Also, writing in a sequential manner as much as =
possible while swapping large quantities of data is also advisable.
>=20
> SWAP pages and corresponding transactions should be aligned to the =
SWAP page size (i.e. 64KB above), the alignment should correspond to the =
physical storage "LBA 0", i.e. to the first LBA of the storage device =
(and not to a logical/physical partition).
>=20



I have a curiosity on above comment is valid on Samsung and other eMMC.
Hyojin, Could you answer?


> Thanks,
> Alex
>=20
>> -----Original Message-----
>> From: Arnd Bergmann [mailto:arnd@arndb.de]
>> Sent: Monday, April 02, 2012 5:55 PM
>> To: Hugh Dickins
>> Cc: linaro-kernel@lists.linaro.org; Rik van Riel; linux-=20
>> mmc@vger.kernel.org; Alex Lemberg; linux-kernel@vger.kernel.org; Luca =

>> Porzio (lporzio); linux-mm@kvack.org; Hyojin Jeong; kernel-=20
>> team@android.com; Yejin Moon
>> Subject: Re: swap on eMMC and other flash
>>
>> On Monday 02 April 2012, Hugh Dickins wrote:
>>> On Mon, 2 Apr 2012, Arnd Bergmann wrote:
>>>>
>>>> Another option would be batched discard as we do it for file
>> systems:
>>>> occasionally stop writing to swap space and scanning for areas that =

>>>> have become available since the last discard, then send discard=20
>>>> commands for those.
>>>
>>> I'm not sure whether you've missed "swapon --discard", which=20
>>> switches on discard_swap_cluster() just before we allocate from a=20
>>> new cluster; or whether you're musing that it's no use to you=20
>>> because you want to repurpose the swap cluster to match erase block: =

>>> I'm mentioning it in case you missed that it's already there (but=20
>>> few use it, since even done at that scale it's often more trouble =
than it's worth).
>>
>> I actually argued that discard_swap_cluster is exactly the right=20
>> thing to do, especially when clusters match erase blocks on the less=20
>> capable devices like SD cards.
>>
>> Luca was arguing that on some hardware there is no point in ever=20
>> submitting a discard just before we start reusing space, because at=20
>> that point it the hardware already discards the old data by=20
>> overwriting the logical addresses with new blocks, while issuing a=20
>> discard on all blocks as soon as they become available would make a=20
>> bigger difference. I would be interested in hearing from Hyojin Jeong =

>> and Alex Lemberg what they think is the best time to issue a discard, =

>> because they would know about other hardware than Luca.
>>
>>       Arnd
>=20
> PLEASE NOTE: The information contained in this electronic mail message =
is intended only for the use of the designated recipient(s) named above. =
If the reader of this message is not the intended recipient, you are =
hereby notified that you have received this message in error and that =
any review, dissemination, distribution, or copying of this message is =
strictly prohibited. If you have received this communication in error, =
please notify the sender by telephone or e-mail (as shown above) =
immediately and destroy any and all copies of this message in your =
possession (whether hard copies or electronically stored copies).
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in the body =

> to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign=20
> http://stopthemeter.ca/ Don't email: <a href=3Dilto:"dont@kvack.org">=20
> email@kvack.org </a>
>=20



--
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
