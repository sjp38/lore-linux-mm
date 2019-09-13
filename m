Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3263C4CEC7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 13:16:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74E6C20CC7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 13:16:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74E6C20CC7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 007716B0005; Fri, 13 Sep 2019 09:16:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF9CA6B0006; Fri, 13 Sep 2019 09:16:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE81A6B0007; Fri, 13 Sep 2019 09:16:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0232.hostedemail.com [216.40.44.232])
	by kanga.kvack.org (Postfix) with ESMTP id B6AAC6B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:16:24 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 342AF181AC9BF
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 13:16:24 +0000 (UTC)
X-FDA: 75929946288.10.boot54_54e97649a901c
X-HE-Tag: boot54_54e97649a901c
X-Filterd-Recvd-Size: 6329
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 13:16:23 +0000 (UTC)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8DDD82b140834
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:16:22 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2v0awaam8t-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:16:21 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Fri, 13 Sep 2019 14:16:19 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 13 Sep 2019 14:16:15 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8DDFn9344368324
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 13 Sep 2019 13:15:50 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EBD19AE059;
	Fri, 13 Sep 2019 13:16:14 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5878BAE051;
	Fri, 13 Sep 2019 13:16:14 +0000 (GMT)
Received: from pomme.local (unknown [9.145.181.150])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 13 Sep 2019 13:16:14 +0000 (GMT)
Subject: Re: [PATCH 3/3] powerpc/mm: call H_BLOCK_REMOVE when supported
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, mpe@ellerman.id.au,
        benh@kernel.crashing.org, paulus@samba.org, npiggin@gmail.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
References: <20190830120712.22971-1-ldufour@linux.ibm.com>
 <20190830120712.22971-4-ldufour@linux.ibm.com>
 <5bcd3da7-1bc2-f3f9-3ed2-e3aa0bb540bd@linux.ibm.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Fri, 13 Sep 2019 15:16:13 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <5bcd3da7-1bc2-f3f9-3ed2-e3aa0bb540bd@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-TM-AS-GCONF: 00
x-cbid: 19091313-4275-0000-0000-000003654FAE
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091313-4276-0000-0000-00003877ADA2
Message-Id: <cf06842a-ea37-9684-5b28-de4277e7bef3@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-13_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909130130
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 12/09/2019 =C3=A0 16:20, Aneesh Kumar K.V a =C3=A9crit=C2=A0:
> On 8/30/19 5:37 PM, Laurent Dufour wrote:
>> Instead of calling H_BLOCK_REMOVE all the time when the feature is
>> exhibited, call this hcall only when the couple base page size, page s=
ize
>> is supported as reported by the TLB Invalidate Characteristics.
>>
>=20
> supported is not actually what we are checking here. We are checking=20
> whether the base page size actual page size remove can be done in chunk=
s of=20
> 8 blocks. If we don't support 8 block you fallback to bulk invalidate. =
May=20
> be update the commit message accordingly?

Yes that's correct.

I think I should also put the warning message displayed when reading the=20
characteristic in that commit and explicitly mentioned that we only suppo=
rt=20
8 entries size block for this hcall.
This way the limitation is limited to this commit.

>=20
>> For regular pages and hugetlb, the assumption is made that the page si=
ze is
>> equal to the base page size. For THP the page size is assumed to be 16=
M.
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
>> ---
>> =C2=A0 arch/powerpc/platforms/pseries/lpar.c | 11 +++++++++--
>> =C2=A0 1 file changed, 9 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/powerpc/platforms/pseries/lpar.c=20
>> b/arch/powerpc/platforms/pseries/lpar.c
>> index 375e19b3cf53..ef3dbf108a65 100644
>> --- a/arch/powerpc/platforms/pseries/lpar.c
>> +++ b/arch/powerpc/platforms/pseries/lpar.c
>> @@ -1143,7 +1143,11 @@ static inline void=20
>> __pSeries_lpar_hugepage_invalidate(unsigned long *slot,
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (lock_tlbie)
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 spin_lock_irqsa=
ve(&pSeries_lpar_tlbie_lock, flags);
>> -=C2=A0=C2=A0=C2=A0 if (firmware_has_feature(FW_FEATURE_BLOCK_REMOVE))
>> +=C2=A0=C2=A0=C2=A0 /*
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * Assuming THP size is 16M, and we only supp=
ort 8 bytes size buffer
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * for the momment.
>> +=C2=A0=C2=A0=C2=A0=C2=A0 */
>> +=C2=A0=C2=A0=C2=A0 if (mmu_psize_defs[psize].hblk[MMU_PAGE_16M] =3D=3D=
 8)
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 hugepage_block_=
invalidate(slot, vpn, count, psize, ssize);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 else
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 hugepage_bulk_i=
nvalidate(slot, vpn, count, psize, ssize);
>=20
>=20
>=20
> So we don't use block invalidate if blocksize is !=3D 8.

yes

>=20
>=20
>> @@ -1437,7 +1441,10 @@ static void pSeries_lpar_flush_hash_range(unsig=
ned=20
>> long number, int local)
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (lock_tlbie)
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 spin_lock_irqsa=
ve(&pSeries_lpar_tlbie_lock, flags);
>> -=C2=A0=C2=A0=C2=A0 if (firmware_has_feature(FW_FEATURE_BLOCK_REMOVE))=
 {
>> +=C2=A0=C2=A0=C2=A0 /*
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * Currently, we only support 8 bytes size bu=
ffer in do_block_remove().
>> +=C2=A0=C2=A0=C2=A0=C2=A0 */
>> +=C2=A0=C2=A0=C2=A0 if (mmu_psize_defs[batch->psize].hblk[batch->psize=
] =3D=3D 8) {
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 do_block_remove=
(number, batch, param);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 goto out;
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
>>
>=20
> -aneesh


