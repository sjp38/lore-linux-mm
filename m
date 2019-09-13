Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8427C49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 11:09:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93A4220830
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 11:09:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93A4220830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 262A06B0005; Fri, 13 Sep 2019 07:09:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2135B6B0006; Fri, 13 Sep 2019 07:09:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 129476B0007; Fri, 13 Sep 2019 07:09:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0074.hostedemail.com [216.40.44.74])
	by kanga.kvack.org (Postfix) with ESMTP id E64576B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 07:09:56 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 759302123C
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 11:09:56 +0000 (UTC)
X-FDA: 75929627592.30.rifle72_90ed32ddffa14
X-HE-Tag: rifle72_90ed32ddffa14
X-Filterd-Recvd-Size: 7575
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 11:09:55 +0000 (UTC)
Received: from pps.filterd (m0187473.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8DB7uBm144389
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 07:09:54 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uytcju1uc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 07:09:51 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Fri, 13 Sep 2019 12:09:48 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 13 Sep 2019 12:09:44 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8DB9hGG46399596
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 13 Sep 2019 11:09:43 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9D65FA4054;
	Fri, 13 Sep 2019 11:09:43 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E6658A4062;
	Fri, 13 Sep 2019 11:09:42 +0000 (GMT)
Received: from pomme.local (unknown [9.145.117.92])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 13 Sep 2019 11:09:42 +0000 (GMT)
Subject: Re: [PATCH 0/3] powerpc/mm: Conditionally call H_BLOCK_REMOVE
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, mpe@ellerman.id.au,
        benh@kernel.crashing.org, paulus@samba.org, npiggin@gmail.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
References: <20190830120712.22971-1-ldufour@linux.ibm.com>
 <1c499131-36f2-9d89-ed4c-5cb59a08398d@linux.ibm.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Fri, 13 Sep 2019 13:09:42 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <1c499131-36f2-9d89-ed4c-5cb59a08398d@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-TM-AS-GCONF: 00
x-cbid: 19091311-0028-0000-0000-0000039BCDFA
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091311-0029-0000-0000-0000245E3CB4
Message-Id: <6d9ca38f-2b80-a2a5-491e-d818a3ebcd32@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-13_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909130107
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 12/09/2019 =C3=A0 15:44, Aneesh Kumar K.V a =C3=A9crit=C2=A0:
> On 8/30/19 5:37 PM, Laurent Dufour wrote:
>> Since the commit ba2dd8a26baa ("powerpc/pseries/mm: call H_BLOCK_REMOV=
E"),
>> the call to H_BLOCK_REMOVE is always done if the feature is exhibited.
>>
>> On some system, the hypervisor may not support all the combination of
>> segment base page size and page size. When this happens the hcall is
>> returning H_PARAM, which is triggering a BUG_ON check leading to a pan=
ic.
>>
>> The PAPR document is specifying a TLB Block Invalidate Characteristics=
 item
>> detailing which couple base page size, page size the hypervisor is
>> supporting through H_BLOCK_REMOVE. Furthermore, the characteristics ar=
e
>> also providing the size of the block the hcall could process.
>>
>> Supporting various block size seems not needed as all systems I was ab=
le to
>> play with was support an 8 addresses block size, which is the maximum
>> through the hcall. Supporting various size may complexify the algorith=
m in
>> call_block_remove() so unless this is required, this is not done.
>>
>> In the case of block size different from 8, a warning message is displ=
ayed
>> at boot time and that block size will be ignored checking for the
>> H_BLOCK_REMOVE support.
>>
>> Due to the minimal amount of hardware showing a limited set of
>> H_BLOCK_REMOVE supported page size, I don't think there is a need to p=
ush
>> this series to the stable mailing list.
>>
>> The first patch is initializing the penc values for each page size to =
an
>> invalid value to be able to detect those which have been initialized a=
s 0
>> is a valid value.
>>
>> The second patch is reading the characteristic through the hcall
>> ibm,get-system-parameter and record the supported block size for each =
page
>> size.
>>
>> The third patch is changing the check used to detect the H_BLOCK_REMOV=
E
>> availability to take care of the base page size and page size couple.
>>
>=20
> So ibm,segment-page-sizes indicates wether we support a combination of =
base=20
> page size and actual page size. You are suggesting that the value repor=
ted=20
> by that is not correct? Can you also share the early part of dmesg as b=
elow.

I'm not saying that the value reported by ibm,segment-page-sizes are=20
incorrect, I'm saying that some couple are not supported by the hcall=20
H_BLOCK_REMOVE.

May be should I change the second sentence by

On some system, the hypervisor may not support all the combination of=20
segment base page size and page size for the hcall H_BLOCK_REMOVE. When=20
this happens the hcall is returning H_PARAM, which is triggering a BUG_ON=
=20
check leading to a panic.

Is that clear enough now ?

>=20
> [=C2=A0=C2=A0=C2=A0 0.000000] hash-mmu: Page sizes from device-tree:
> [=C2=A0=C2=A0=C2=A0 0.000000] hash-mmu: base_shift=3D12: shift=3D12, sl=
lp=3D0x0000,=20
> avpnm=3D0x00000000, tlbiel=3D1, penc=3D0
> [=C2=A0=C2=A0=C2=A0 0.000000] hash-mmu: base_shift=3D12: shift=3D16, sl=
lp=3D0x0000,=20
> avpnm=3D0x00000000, tlbiel=3D1, penc=3D7
> [=C2=A0=C2=A0=C2=A0 0.000000] hash-mmu: base_shift=3D12: shift=3D24, sl=
lp=3D0x0000,=20
> avpnm=3D0x00000000, tlbiel=3D1, penc=3D56
> [=C2=A0=C2=A0=C2=A0 0.000000] hash-mmu: base_shift=3D16: shift=3D16, sl=
lp=3D0x0110,=20
> avpnm=3D0x00000000, tlbiel=3D1, penc=3D1
> [=C2=A0=C2=A0=C2=A0 0.000000] hash-mmu: base_shift=3D16: shift=3D24, sl=
lp=3D0x0110,=20
> avpnm=3D0x00000000, tlbiel=3D1, penc=3D8
> [=C2=A0=C2=A0=C2=A0 0.000000] hash-mmu: base_shift=3D24: shift=3D24, sl=
lp=3D0x0100,=20
> avpnm=3D0x00000001, tlbiel=3D0, penc=3D0
> [=C2=A0=C2=A0=C2=A0 0.000000] hash-mmu: base_shift=3D34: shift=3D34, sl=
lp=3D0x0120,=20
> avpnm=3D0x000007ff, tlbiel=3D0, penc=3D3
>=20
> That shows different base page size and actual page size combination.
>=20
>=20
>> Laurent Dufour (3):
>> =C2=A0=C2=A0 powerpc/mm: Initialize the HPTE encoding values
>> =C2=A0=C2=A0 powperc/mm: read TLB Block Invalidate Characteristics
>> =C2=A0=C2=A0 powerpc/mm: call H_BLOCK_REMOVE when supported
>>
>> =C2=A0 arch/powerpc/include/asm/book3s/64/mmu.h |=C2=A0=C2=A0 3 +
>> =C2=A0 arch/powerpc/mm/book3s64/hash_utils.c=C2=A0=C2=A0=C2=A0 |=C2=A0=
=C2=A0 8 +-
>> =C2=A0 arch/powerpc/platforms/pseries/lpar.c=C2=A0=C2=A0=C2=A0 | 118 +=
+++++++++++++++++++++-
>> =C2=A0 3 files changed, 125 insertions(+), 4 deletions(-)
>>
>=20
>=20
> -aneesh


