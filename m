Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5DC6C4CEC5
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 10:56:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A48812089F
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 10:56:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A48812089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 022A06B0005; Fri, 13 Sep 2019 06:56:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F15826B0006; Fri, 13 Sep 2019 06:56:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDC026B0007; Fri, 13 Sep 2019 06:56:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0041.hostedemail.com [216.40.44.41])
	by kanga.kvack.org (Postfix) with ESMTP id B650A6B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 06:56:25 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 5501D75A4
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 10:56:25 +0000 (UTC)
X-FDA: 75929593530.23.army66_1adc9a2f3a924
X-HE-Tag: army66_1adc9a2f3a924
X-Filterd-Recvd-Size: 5723
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 10:56:24 +0000 (UTC)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8DArble040952
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 06:56:23 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2v07esdb0j-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 06:56:22 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Fri, 13 Sep 2019 11:56:20 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 13 Sep 2019 11:56:18 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8DAuHSe54657154
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 13 Sep 2019 10:56:17 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8AB1CA405F;
	Fri, 13 Sep 2019 10:56:17 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DB402A405B;
	Fri, 13 Sep 2019 10:56:16 +0000 (GMT)
Received: from pomme.local (unknown [9.145.117.92])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 13 Sep 2019 10:56:16 +0000 (GMT)
Subject: Re: [PATCH 1/3] powerpc/mm: Initialize the HPTE encoding values
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, mpe@ellerman.id.au,
        benh@kernel.crashing.org, paulus@samba.org, npiggin@gmail.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
References: <20190830120712.22971-1-ldufour@linux.ibm.com>
 <20190830120712.22971-2-ldufour@linux.ibm.com>
 <527b1a15-e37f-0d76-b999-e22cf04f9f7e@linux.ibm.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Fri, 13 Sep 2019 12:56:16 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <527b1a15-e37f-0d76-b999-e22cf04f9f7e@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-TM-AS-GCONF: 00
x-cbid: 19091310-0012-0000-0000-0000034AD1F3
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091310-0013-0000-0000-0000218541AB
Message-Id: <4ea08df8-1a32-cbeb-1f4c-83b28bf7fd11@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-13_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909130104
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 12/09/2019 =C3=A0 15:37, Aneesh Kumar K.V a =C3=A9crit=C2=A0:
> On 8/30/19 5:37 PM, Laurent Dufour wrote:
>> Before reading the HPTE encoding values we initialize all of them to -=
1 (an
>> invalid value) to later being able to detect the initialized ones.
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
>> ---
>> =C2=A0 arch/powerpc/mm/book3s64/hash_utils.c | 8 ++++++--
>> =C2=A0 1 file changed, 6 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/powerpc/mm/book3s64/hash_utils.c=20
>> b/arch/powerpc/mm/book3s64/hash_utils.c
>> index c3bfef08dcf8..2039bc315459 100644
>> --- a/arch/powerpc/mm/book3s64/hash_utils.c
>> +++ b/arch/powerpc/mm/book3s64/hash_utils.c
>> @@ -408,7 +408,7 @@ static int __init htab_dt_scan_page_sizes(unsigned=
=20
>> long node,
>> =C2=A0 {
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 const char *type =3D of_get_flat_dt_pro=
p(node, "device_type", NULL);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 const __be32 *prop;
>> -=C2=A0=C2=A0=C2=A0 int size =3D 0;
>> +=C2=A0=C2=A0=C2=A0 int size =3D 0, idx, base_idx;
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /* We are scanning "cpu" nodes only */
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (type =3D=3D NULL || strcmp(type, "c=
pu") !=3D 0)
>> @@ -418,6 +418,11 @@ static int __init htab_dt_scan_page_sizes(unsigne=
d=20
>> long node,
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (!prop)
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 0;
>> +=C2=A0=C2=A0=C2=A0 /* Set all the penc values to invalid */
>> +=C2=A0=C2=A0=C2=A0 for (base_idx =3D 0; base_idx < MMU_PAGE_COUNT; ba=
se_idx++)
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for (idx =3D 0; idx < MMU_=
PAGE_COUNT; idx++)
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mm=
u_psize_defs[base_idx].penc[idx] =3D -1;
>> +
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pr_info("Page sizes from device-tree:\n=
");
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 size /=3D 4;
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 cur_cpu_spec->mmu_features &=3D ~(MMU_F=
TR_16M_PAGE);
>> @@ -426,7 +431,6 @@ static int __init htab_dt_scan_page_sizes(unsigned=
=20
>> long node,
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 unsigned int sl=
benc =3D be32_to_cpu(prop[1]);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 unsigned int lp=
num =3D be32_to_cpu(prop[2]);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 struct mmu_psiz=
e_def *def;
>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 int idx, base_idx;
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 size -=3D 3; pr=
op +=3D 3;
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 base_idx =3D ge=
t_idx_from_shift(base_shift);
>>
>=20
> We already do this in mmu_psize_set_default_penc() ?

Correct, I missed that, then this patch is no more needed.


