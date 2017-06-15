Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 07C006B02B4
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 23:16:01 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u8so1940900pgo.11
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 20:16:00 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id x189si1295737pgd.305.2017.06.14.20.16.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 20:16:00 -0700 (PDT)
Subject: Re: [HMM-CDM 5/5] mm/hmm: simplify kconfig and enable HMM and
 DEVICE_PUBLIC for ppc64
References: <20170614201144.9306-1-jglisse@redhat.com>
 <20170614201144.9306-6-jglisse@redhat.com>
 <9aeed880-c200-a070-a7a4-212ee38c15ed@nvidia.com>
 <20170615020925.GC4666@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <71020519-41da-242f-9ce4-ce1bd7cda879@nvidia.com>
Date: Wed, 14 Jun 2017 20:15:46 -0700
MIME-Version: 1.0
In-Reply-To: <20170615020925.GC4666@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Nellans <dnellans@nvidia.com>, Balbir Singh <balbirs@au1.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/14/2017 07:09 PM, Jerome Glisse wrote:
> On Wed, Jun 14, 2017 at 04:10:32PM -0700, John Hubbard wrote:
>> On 06/14/2017 01:11 PM, J=C3=A9r=C3=B4me Glisse wrote:
[...]
>> Hi Jerome,
>>
>> There are still some problems with using this configuration. First and
>> foremost, it is still possible (and likely, given the complete dissimila=
rity
>> in naming, and difference in location on the screen) to choose HMM_MIRRO=
R,
>> and *not* to choose either DEVICE_PRIVATE or DEVICE_PUBLIC. And then we =
end
>> up with a swath of important page fault handling code being ifdef'd out,=
 and
>> one ends up having to investigate why.
>>
>> As for solutions, at least for the x86 (DEVICE_PRIVATE)case, we could do=
 this:
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 7de939a29466..f64182d7b956 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -279,6 +279,7 @@ config HMM_MIRROR
>>          bool "HMM mirror CPU page table into a device page table"
>>          depends on ARCH_HAS_HMM && X86_64
>>          select MMU_NOTIFIER
>> +       select DEVICE_PRIVATE
>>          select HMM
>>          help
>>            Select HMM_MIRROR if you want to mirror range of the CPU page=
 table of a
>>
>> ...and that is better than the other direction (having HMM_MIRROR depend=
 on
>> DEVICE_PRIVATE), because in the latter case, HMM_MIRROR will disappear (=
and
>> it's several lines above) until you select DEVICE_PRIVATE. That is hard =
to
>> work with for the user.
>>
>> The user will tend to select HMM_MIRROR, but it is *not* obvious that he=
/she
>> should also select DEVICE_PRIVATE. So Kconfig should do it for them.
>>
>> In fact, I'm not even sure if the DEVICE_PRIVATE and DEVICE_PUBLIC actua=
lly
>> need Kconfig protection, but if they don't, then life would be easier fo=
r
>> whoever is configuring their kernel.
>>
>=20
> We do need Kconfig for DEVICE_PRIVATE and DEVICE_PUBLIC. I can remove HMM=
_MIRROR
> and have HMM mirror code ifdef on DEVICE_PRIVATE.
>=20
> Cheers,
> J=C3=A9r=C3=B4me

That's probably fine.

(I see that you may have missed the rest of my response, but looks like Bal=
bir=20
covered it.)

thanks,
john h


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
