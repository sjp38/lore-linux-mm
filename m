Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6BC6C4CEC5
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 21:18:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 871EE206A4
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 21:18:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="a8vMpoPx";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="MRuTWkgj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 871EE206A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0244F6B0007; Fri, 13 Sep 2019 17:18:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F16EF6B0008; Fri, 13 Sep 2019 17:18:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDF7E6B000A; Fri, 13 Sep 2019 17:18:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0052.hostedemail.com [216.40.44.52])
	by kanga.kvack.org (Postfix) with ESMTP id BCC216B0007
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 17:18:40 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 65D0787D3
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 21:18:40 +0000 (UTC)
X-FDA: 75931161600.12.nail19_4b9c6e331bc22
X-HE-Tag: nail19_4b9c6e331bc22
X-Filterd-Recvd-Size: 13467
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 21:18:39 +0000 (UTC)
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x8DLIbt1013239;
	Fri, 13 Sep 2019 14:18:37 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=a0xuC6eR/lnVf73YQTrGDn/ESnrsxFtf3ZvbEG/m9BA=;
 b=a8vMpoPxuYoVWjaPcsrOthX8LVX1dso2kREoCVpwK9KBP+Mzd0Oehu/ZRjFCwBVhgHxe
 qX5R1rn3CYDQ8lUXVQUgCplJI8zYh7QwzcnGANiTJw4Gv/OqGDMHqt25YQJcdCkH3R9l
 d9MljPmiKMgpHIAol8Ur9IHckmDeBiEorRs= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2uytcqdx8k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Fri, 13 Sep 2019 14:18:36 -0700
Received: from ash-exhub203.TheFacebook.com (2620:10d:c0a8:83::5) by
 ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 13 Sep 2019 14:17:11 -0700
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Fri, 13 Sep 2019 14:17:11 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=SGwBrhwruGUMHEjOz3U7AfFEzZjqMvY95fwiBCFeB+bZIlNcO6MT3u3KCTmh7bu2DgWQNu0sMgxBqku9S22NN+qK+AK4dY8OdBCltm9WN6plmxS4c/D4E1CAm5E6YTKxQpB4EgzjNsVwGeCHqQrIQ+LNKPHS7U6LBSI+ZCS5oErn7t0v5nTb/GIiGs4CNKpi9hHE363MKjdKFS6h+gJj9+2YYoMRQbr4N5QnIBmJzbm4XxcQxdtXrWkbi8wnYnoKilb8EL3Av7PQ+Xs+2qibKOwNmKCP1ANyqLnG8yqPyDflVqletWxHsXg5/8VEMk0YgljpBaSm7sPkPVT6PP/oZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=a0xuC6eR/lnVf73YQTrGDn/ESnrsxFtf3ZvbEG/m9BA=;
 b=kx6DMCONnPNoMWJ43wYdyBjJf1Tr0jXL3y7bSYMZYt36nLcSukr0wCLM3BPsKyVSHEIjh0Ite5UQrracDmmn2xiY7aLHhoAPUaiGcq5TIyrRylhIUr5Pr9PXxFu3s00AjYla0mIRmfA1p2eAkvSuEv/HKnmNRFMsln9FaloaJC0qfki+oEbuHfhVJZGGeQQg0E6ajZNi00vSDLbwYksFxPsBlbS7bt0wcuvFJfBOvITYonb6ryIu47zJqNuwiVeQIMtsRU2hf2lpbJX+ow0ZYTAO6jaAq1/UetIHhwrG6QVwYtoQg7/i/5efPgEzsaR95B39y25aOqC8U54uilgF9Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=a0xuC6eR/lnVf73YQTrGDn/ESnrsxFtf3ZvbEG/m9BA=;
 b=MRuTWkgjVRRQdiHlx03ykrNxI8fZO3Nz+w9FiSesRCPY9HlYmWbi19pQemR5t7zNPXXC+woiKykQx4+s36UwKL+hCRLrmpvbyNJ7kZ29tZP9vds/jC3Au7Us6dTk5lN9TcD18BLSGNWHk2YaIaErjVuoq98LaYr1/xBVaM6p4po=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB2251.namprd15.prod.outlook.com (20.176.69.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2241.18; Fri, 13 Sep 2019 21:17:09 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::845f:c175:4860:45db]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::845f:c175:4860:45db%3]) with mapi id 15.20.2241.022; Fri, 13 Sep 2019
 21:17:09 +0000
From: Roman Gushchin <guro@fb.com>
To: Lucian Grijincu <lucian@fb.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Souptick Joarder
	<jrdr.linux@gmail.com>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        "Andrew
 Morton" <akpm@linux-foundation.org>,
        Rik van Riel <riel@fb.com>
Subject: Re: [Potential Spoof] [PATCH v3] mm: memory: fix /proc/meminfo
 reporting for MLOCK_ONFAULT
Thread-Topic: [Potential Spoof] [PATCH v3] mm: memory: fix /proc/meminfo
 reporting for MLOCK_ONFAULT
Thread-Index: AQHVanfTSfRS6C+xc0+kVsEX6I4P3acqHD+A
Date: Fri, 13 Sep 2019 21:17:08 +0000
Message-ID: <20190913211705.GA5392@tower.DHCP.thefacebook.com>
References: <20190913211119.416168-1-lucian@fb.com>
In-Reply-To: <20190913211119.416168-1-lucian@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR0201CA0019.namprd02.prod.outlook.com
 (2603:10b6:301:74::32) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:7a97]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 99f507b0-5420-47eb-bd27-08d7388fbc66
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR15MB2251;
x-ms-traffictypediagnostic: DM6PR15MB2251:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <DM6PR15MB22511005FF8FCB507FA0D083BEB30@DM6PR15MB2251.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2043;
x-forefront-prvs: 0159AC2B97
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(346002)(39860400002)(376002)(136003)(199004)(189003)(14454004)(81166006)(81156014)(76176011)(46003)(476003)(66446008)(52116002)(186003)(6116002)(11346002)(102836004)(6636002)(6512007)(99286004)(316002)(8936002)(6436002)(66476007)(66556008)(446003)(6246003)(71200400001)(256004)(14444005)(478600001)(229853002)(33656002)(4326008)(71190400001)(386003)(6506007)(6486002)(7736002)(64756008)(66946007)(9686003)(54906003)(25786009)(1076003)(53936002)(305945005)(86362001)(5660300002)(8676002)(2906002)(486006)(6862004);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB2251;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 8IT2kIPiznAi7Evv8uEo7BigShLyJ9SFGgyki/H2sD4BCSmueuhHdLFpwCdTUPgFtCKVGhtWOh0qzpATX/vKKuGpbsx877mJOfsAltK1LLiWYXbQh7hmmT1qxILNs2X0HMzMcxRZOnQlknyT4CrGvdIbJb1kLQfrPrY321imGxT1ravZ+v8pekXJNQvShOI74VK8+/RXJYonyqwEtfpUyFX4AwLSlbUjrEHo76Vt7LF50tAOv/TjzjhCmwoKH0x9WsbWSd20+bgBoOYRTlkHCSkGwsc0EqaTbb0KY0Ca/i0LXHBK9ay/D6j9wpcdYTB9Q59QiNLLtXDyHoz1Std6oLIgnZacRpiVGO4CCQzNHT6KL/EPrtQguSY6qf57ajfszWTANp7hjnD26dmYwf2bCjfXYKyk5EceoMAvnyh8C6k=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <46ABEF5E05BF4C48B61E4522FF292AB2@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 99f507b0-5420-47eb-bd27-08d7388fbc66
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Sep 2019 21:17:09.0132
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: oz/cDCWTOa5Ptw4Hp1HA1aRdnQOx0CKeptwkMcQ6+JrTJtKFs5AQv2Z9CQdMuIap
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB2251
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-13_10:2019-09-11,2019-09-13 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 suspectscore=0
 impostorscore=0 mlxscore=0 adultscore=0 mlxlogscore=881 bulkscore=0
 lowpriorityscore=0 priorityscore=1501 clxscore=1015 malwarescore=0
 spamscore=0 phishscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-1908290000 definitions=main-1909130213
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 13, 2019 at 02:11:19PM -0700, Lucian Adrian Grijincu wrote:
> As pages are faulted in MLOCK_ONFAULT correctly updates
> /proc/self/smaps, but doesn't update /proc/meminfo's Mlocked field.
>=20
> - Before this /proc/meminfo fields didn't change as pages were faulted in=
:
>=20
> =3D Start =3D
> /proc/meminfo
> Unevictable:       10128 kB
> Mlocked:           10132 kB
> =3D Creating testfile =3D
>=20
> =3D after mlock2(MLOCK_ONFAULT) =3D
> /proc/meminfo
> Unevictable:       10128 kB
> Mlocked:           10132 kB
> /proc/self/smaps
> 7f8714000000-7f8754000000 rw-s 00000000 08:04 50857050   /root/testfile
> Locked:                0 kB
>=20
> =3D after reading half of the file =3D
> /proc/meminfo
> Unevictable:       10128 kB
> Mlocked:           10132 kB
> /proc/self/smaps
> 7f8714000000-7f8754000000 rw-s 00000000 08:04 50857050   /root/testfile
> Locked:           524288 kB
>=20
> =3D after reading the entire the file =3D
> /proc/meminfo
> Unevictable:       10128 kB
> Mlocked:           10132 kB
> /proc/self/smaps
> 7f8714000000-7f8754000000 rw-s 00000000 08:04 50857050   /root/testfile
> Locked:          1048576 kB
>=20
> =3D after munmap =3D
> /proc/meminfo
> Unevictable:       10128 kB
> Mlocked:           10132 kB
> /proc/self/smaps
>=20
> - After: /proc/meminfo fields are properly updated as pages are touched:
>=20
> =3D Start =3D
> /proc/meminfo
> Unevictable:          60 kB
> Mlocked:              60 kB
> =3D Creating testfile =3D
>=20
> =3D after mlock2(MLOCK_ONFAULT) =3D
> /proc/meminfo
> Unevictable:          60 kB
> Mlocked:              60 kB
> /proc/self/smaps
> 7f2b9c600000-7f2bdc600000 rw-s 00000000 08:04 63045798   /root/testfile
> Locked:                0 kB
>=20
> =3D after reading half of the file =3D
> /proc/meminfo
> Unevictable:      524220 kB
> Mlocked:          524220 kB
> /proc/self/smaps
> 7f2b9c600000-7f2bdc600000 rw-s 00000000 08:04 63045798   /root/testfile
> Locked:           524288 kB
>=20
> =3D after reading the entire the file =3D
> /proc/meminfo
> Unevictable:     1048496 kB
> Mlocked:         1048508 kB
> /proc/self/smaps
> 7f2b9c600000-7f2bdc600000 rw-s 00000000 08:04 63045798   /root/testfile
> Locked:          1048576 kB
>=20
> =3D after munmap =3D
> /proc/meminfo
> Unevictable:         176 kB
> Mlocked:              60 kB
> /proc/self/smaps
>=20
> Repro code.
> ---
>=20
> int mlock2wrap(const void* addr, size_t len, int flags) {
>   return syscall(SYS_mlock2, addr, len, flags);
> }
>=20
> void smaps() {
>   char smapscmd[1000];
>   snprintf(
>       smapscmd,
>       sizeof(smapscmd) - 1,
>       "grep testfile -A 20 /proc/%d/smaps | grep -E '(testfile|Locked)'",
>       getpid());
>   printf("/proc/self/smaps\n");
>   fflush(stdout);
>   system(smapscmd);
> }
>=20
> void meminfo() {
>   const char* meminfocmd =3D "grep -E '(Mlocked|Unevictable)' /proc/memin=
fo";
>   printf("/proc/meminfo\n");
>   fflush(stdout);
>   system(meminfocmd);
> }
>=20
>   {                                                 \
>     int rc =3D (call);                                \
>     if (rc !=3D 0) {                                  \
>       printf("error %d %s\n", rc, strerror(errno)); \
>       exit(1);                                      \
>     }                                               \
>   }
> int main(int argc, char* argv[]) {
>   printf("=3D Start =3D\n");
>   meminfo();
>=20
>   printf("=3D Creating testfile =3D\n");
>   size_t size =3D 1 << 30; // 1 GiB
>   int fd =3D open("testfile", O_CREAT | O_RDWR, 0666);
>   {
>     void* buf =3D malloc(size);
>     write(fd, buf, size);
>     free(buf);
>   }
>   int ret =3D 0;
>   void* addr =3D NULL;
>   addr =3D mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
>=20
>   if (argc > 1) {
>     PCHECK(mlock2wrap(addr, size, MLOCK_ONFAULT));
>     printf("=3D after mlock2(MLOCK_ONFAULT) =3D\n");
>     meminfo();
>     smaps();
>=20
>     for (size_t i =3D 0; i < size / 2; i +=3D 4096) {
>       ret +=3D ((char*)addr)[i];
>     }
>     printf("=3D after reading half of the file =3D\n");
>     meminfo();
>     smaps();
>=20
>     for (size_t i =3D 0; i < size; i +=3D 4096) {
>       ret +=3D ((char*)addr)[i];
>     }
>     printf("=3D after reading the entire the file =3D\n");
>     meminfo();
>     smaps();
>=20
>   } else {
>     PCHECK(mlock(addr, size));
>     printf("=3D after mlock =3D\n");
>     meminfo();
>     smaps();
>   }
>=20
>   PCHECK(munmap(addr, size));
>   printf("=3D after munmap =3D\n");
>   meminfo();
>   smaps();
>=20
>   return ret;
> }
>=20
> ---
>=20
> Signed-off-by: Lucian Adrian Grijincu <lucian@fb.com>
> Acked-by: Souptick Joarder <jrdr.linux@gmail.com>
> ---
>  mm/memory.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/mm/memory.c b/mm/memory.c
> index e0c232fe81d9..55da24f33bc4 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3311,6 +3311,8 @@ vm_fault_t alloc_set_pte(struct vm_fault *vmf, stru=
ct mem_cgroup *memcg,
>  	} else {
>  		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
>  		page_add_file_rmap(page, false);
> +		if (vma->vm_flags & VM_LOCKED && !PageTransCompound(page))
> +			mlock_vma_page(page);

Acked-by: Roman Gushchin <guro@fb.com>

Thanks!

