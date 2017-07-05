Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 043E26B03C8
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 19:16:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 1so3771768pfi.14
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 16:16:49 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id o13si222139pgs.13.2017.07.05.16.16.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 16:16:49 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id j186so409345pge.1
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 16:16:49 -0700 (PDT)
Date: Thu, 6 Jul 2017 07:16:49 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove zone restrictions
Message-ID: <20170705231649.GA10155@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170629073509.623-1-mhocko@kernel.org>
 <20170629073509.623-3-mhocko@kernel.org>
 <CADZGycaXs-TsVN2xy_rpFE_ML5_rs=iYN6ZQZsAfjTVHFyLyEQ@mail.gmail.com>
 <20170630083926.GA22923@dhcp22.suse.cz>
 <CADZGyca1-CzaHoR-==DN4kK_YrwmMVnKvowUv-5M4GQP7ZYubg@mail.gmail.com>
 <20170630095545.GF22917@dhcp22.suse.cz>
 <20170630110118.GG22917@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="C7zPtVaVf+AK4Oqc"
Content-Disposition: inline
In-Reply-To: <20170630110118.GG22917@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Xishi Qiu <qiuxishi@huawei.com>, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 30, 2017 at 01:01:18PM +0200, Michal Hocko wrote:
>On Fri 30-06-17 11:55:45, Michal Hocko wrote:
>> On Fri 30-06-17 17:39:56, Wei Yang wrote:
>> > On Fri, Jun 30, 2017 at 4:39 PM, Michal Hocko <mhocko@kernel.org> wrot=
e:
>> [...]
>> > > yes and to be honest I do not plan to fix it unless somebody has a r=
eal
>> > > life usecase for it. Now that we allow explicit onlininig type anywh=
ere
>> > > it seems like a reasonable behavior and this will allow us to remove
>> > > quite some code which is always a good deal wrt longterm maintenance.
>> > >
>> >=20
>> > hmm... the statistics displayed in /proc/zoneinfo would be meaningless
>> > for zone_normal and zone_movable.
>>=20
>> Why would they be meaningless? Counters will always reflect the actual
>> use - if not then it is a bug. And wrt to zone description what is
>> meaningless about
>> memory34/valid_zones:Normal
>> memory35/valid_zones:Normal Movable
>> memory36/valid_zones:Movable
>> memory37/valid_zones:Movable Normal
>> memory38/valid_zones:Movable Normal
>> memory39/valid_zones:Movable Normal
>> memory40/valid_zones:Normal
>> memory41/valid_zones:Movable
>>=20
>> And
>> Node 1, zone   Normal
>>   pages free     65465
>>         min      156
>>         low      221
>>         high     286
>>         spanned  229376
>>         present  65536
>>         managed  65536
>> [...]
>>   start_pfn:           1114112
>> Node 1, zone  Movable
>>   pages free     65443
>>         min      156
>>         low      221
>>         high     286
>>         spanned  196608
>>         present  65536
>>         managed  65536
>> [...]
>>   start_pfn:           1179648
>>=20
>> ranges are clearly defined as [start_pfn, start_pfn+managed] and managed
>
>errr, this should be [start_pfn, start_pfn + spanned] of course.
>

The spanned is not adjusted after offline, neither does start_pfn. For exam=
ple,
even offline all the movable_zone range, we can still see the spanned.

Below is a result with a little changed kernel to show the start_pfn always.
The sequence is:
1. bootup

Node 0, zone  Movable
        spanned  65536
	present  0
	managed  0
  start_pfn:           0

2. online movable 2 continuous memory_blocks

Node 0, zone  Movable
        spanned  65536
	present  65536
	managed  65536
  start_pfn:           1310720

3. offline 2nd memory_blocks

Node 0, zone  Movable
        spanned  65536
	present  32768
	managed  32768
  start_pfn:           1310720

4. offline 1st memory_blocks

Node 0, zone  Movable
        spanned  65536
	present  0
	managed  0
  start_pfn:           1310720

So I am not sure this is still clearly defined?

>> matches the number of onlined pages (256MB).
>
>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--C7zPtVaVf+AK4Oqc
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZXXNhAAoJEKcLNpZP5cTdkx8QAK6MKFdOR81MTDChHy5erI8x
8Z9cq7ZXivryS4ovYZIMAe+2FbjyztcZOnu74pWCQtVKVUEMBFSieetusRyKZ3Gx
Nk0K3+kI/PiZFyM51Cj2v4I0OQW2ZmqNXZjdzYXm0lSlGyp7bnjoJkNp+VJ1SGmi
5TcumSPh4gWDQw/LPZ65TwBkJ9yuWAnoTO5gm4n4IP4KDS1ysbuwN1nRQgTvP3oF
tCfbsP7ev9ELBa+T3ZVhfaLuIIh7rIAnX1DtpCQ+UTepqe6A2awEbfLx3tTwVZyl
hzgvuOoUcBTEtE+HeQwn6ucNqKIcR0POrfpPu2qcKgSoX0yxn0sQOdpkOIuv9s7k
AKlylHVa9hupFlHJ2UFj8ftPJ2lGMB35YgkV3Qm0d5t0Lm7eeGpVl0om0V6WRkFI
CgJ47uh1wUkR3UCci9btTyDv+q9wXpMsgL1MZz0NYFT5DtcRevOllYCiFa+vvA2Z
HHe9R+MK5G/pNNsrn1Mjyx34dwKzYDIJfoJDZPil948vrznTGssI/Y8G5GkJUqhU
Hm13YgUGmSdBSauMGOB/WysYnwJFuz91TknLCLwnxm0ydCJk9r6tvGSu/19RJqTJ
LoH8P0mO0pkSwG61N/TrK52XIK6IyjEehdw/lShuzz9phrhExHLsl8cbGDaVDrBf
zxaWb3mYtj5ytDjb3Fgy
=Xpx9
-----END PGP SIGNATURE-----

--C7zPtVaVf+AK4Oqc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
