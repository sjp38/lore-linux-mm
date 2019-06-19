Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC4A3C31E5D
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:46:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99383217F4
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:46:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="3mOkbOhl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99383217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37F838E0008; Wed, 19 Jun 2019 12:46:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32F4E8E0001; Wed, 19 Jun 2019 12:46:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D1038E0008; Wed, 19 Jun 2019 12:46:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF0D68E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:46:41 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id a4so7887365vki.23
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:46:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qusBZmUrIraq40u5N2NLdGl6YAsSyS9aTyEvugUt21g=;
        b=OaLfZf3YE566AyQvFmueCQby0B4rG3n48hVqNyVWGOe0INhZKKrNh9Q0YgwWXKP9Z/
         IcAaumPuI7U/qoWhfw974eGHEkluVx4s7kxiZ/AJWlA1aldODy84RzRishVFzcoRj8wQ
         JU+V1HlcgD0SLBLG9oYgU+aUoPDoxPBC4s1LrzebeRkLsdezbIWiiyE9/1J09/CryC09
         uG0ABNQEOINulU58hLOEMyaQOWKJ3Fhk/6OFLnO+SWgKvEFoihYJ4qwFoJdseCVzI85l
         LxoyQi0yL4rlTHt2yMG8prIG0vtWn/7N06s+tYNRxaE4VZQTcwWSIR78nBSKY+iCzrUz
         X6rg==
X-Gm-Message-State: APjAAAV3fELxcEG24O3X6S9nFOjHgVtUimuOxlzbvLcOM19HPuBo/Km9
	Mvaw1WTJydWhB89MwYPhG4M4AdnT9KjxsPhN6DXniq0mhrVgbFIIiY1IuKvRIvcbgvNU7JkZZKC
	SKXdxhaqtu042BUzw1+T16a3CTHM59bM1lWPA5qBFZHi3xQQ0QW0jgop+0NROAj1YRA==
X-Received: by 2002:a67:fb87:: with SMTP id n7mr48939482vsr.9.1560962801638;
        Wed, 19 Jun 2019 09:46:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztNHrUne7qF9RmRa13ciR7bZXxvZKXDrLkEkkP21HNV6Z4XNEWFqp3jtCU+durvGyykyL6
X-Received: by 2002:a67:fb87:: with SMTP id n7mr48939439vsr.9.1560962800916;
        Wed, 19 Jun 2019 09:46:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560962800; cv=none;
        d=google.com; s=arc-20160816;
        b=v6dJsPcGNjzKjqIuGneaXgLZftWbLDyA0BvJIlfxOJOnFtXzzazFBTQlCsf0NVEr3t
         PHNktUb8+UR3O3CuvypvqI4D7+UsMuLpEm2ZiRLFoGNOIGoC6uIt+sCHTDvFcsDseVwY
         iEkYC7NDRfRl1U+E5Fl5q+jFHXvTkF3AnG8U3zy62wva4ncyozp15raCoTUrslTHNj92
         YQp2LsWJNIWkOCIexWdKtSwWGR/1vTu00Wmp8DpPjahnTk04dIJ83X3pdM4voiRCWtCP
         yCR3bWOLlxTVRQuCAEf8aPvPLMlZKOdy8d5nLdf3jI8pOZOFnDOHptcVrjRAF0SHt/4I
         TmYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:references:cc:to:from
         :subject:dkim-signature;
        bh=qusBZmUrIraq40u5N2NLdGl6YAsSyS9aTyEvugUt21g=;
        b=ql7w3bL4vrdsiO1mSUPxGHlhS5r00G8jdRd1wiTH5mM8rplU9Z0cts2y2oG2rH67Ws
         v7wiPE3HjRU7mS9Sv8RDusHjrzHKZp0JPcl1YI4vMCX6IArgPu9YQRu45R9rxa4lRkWp
         AWz479odxLP7asgPA+jLvz8O70vpmRoPaGEN9lYpAByFrg3bIMMcZgbrykG/CtXB5Mvn
         RjNaZX6zCEuO/tbLdIAxL2Yo9Mtc95iA3UdfDmCXSfStkollTHUtv3OzlZhY1yGBlsUV
         cJl4iERZRYkXx+snNmTRmmScDdSEvXyKbceYEd3thBguZFuRKAzJd275jb5QL10Xqx6T
         iXlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=3mOkbOhl;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i40si3601283uah.246.2019.06.19.09.46.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 09:46:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=3mOkbOhl;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5JGhjWl155566;
	Wed, 19 Jun 2019 16:46:26 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : references : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=qusBZmUrIraq40u5N2NLdGl6YAsSyS9aTyEvugUt21g=;
 b=3mOkbOhlBhirjqM80aK6s+wRkh63tDNK1RaC8xSpawtTEs22m3XRqKFCk5ZcVxQMeWWG
 oRqUIvbznqi8D/D4MfvNkUkTBObbb4xfdaZ+9y+7KCIERhSCf6fxDDTVjDvV7P4EcaLQ
 4ZoMmuup5lX7IGS8rh6szCE52BCuQdLriDGNSBTner55/rw1yPgc4xaDRa4nb2Y3jhO3
 JZBwISQ+4KZBRUU7ULX20bWmFi/EyzzMzXYgNNh/5zIapfvldsDZjRNNQzsEdP4praRm
 fnPHRUIEeAD5QVV8LOtA3Ajj+V7lRKrReZleJwOMtbES5LrqqDoDLwtauDb4vj2fYUoh lg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2t7809ckcb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Jun 2019 16:46:26 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5JGjFFn117750;
	Wed, 19 Jun 2019 16:46:25 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2t7rdwrdpr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Jun 2019 16:46:25 +0000
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5JGkK2N016173;
	Wed, 19 Jun 2019 16:46:21 GMT
Received: from [10.65.164.174] (/10.65.164.174)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 19 Jun 2019 16:46:20 +0000
Subject: Re: [PATCH v17 04/15] mm, arm64: untag user pointers passed to memory
 syscalls
From: Khalid Aziz <khalid.aziz@oracle.com>
To: Andrey Konovalov <andreyknvl@google.com>,
        linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
        dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
        linux-media@vger.kernel.org, kvm@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>,
        Vincenzo Frascino <vincenzo.frascino@arm.com>,
        Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>,
        Felix Kuehling <Felix.Kuehling@amd.com>,
        Alexander Deucher <Alexander.Deucher@amd.com>,
        Christian Koenig <Christian.Koenig@amd.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Jens Wiklander <jens.wiklander@linaro.org>,
        Alex Williamson <alex.williamson@redhat.com>,
        Leon Romanovsky <leon@kernel.org>,
        Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
        Dave Martin <Dave.Martin@arm.com>, enh <enh@google.com>,
        Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>,
        Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
        Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>,
        Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
        Jacob Bramley <Jacob.Bramley@arm.com>,
        Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Kevin Brodsky <kevin.brodsky@arm.com>,
        Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <f9b50767d639b7116aa986dc67f158131b8d4169.1560339705.git.andreyknvl@google.com>
 <a5e0e465-89d5-91d0-c6a4-39674269bbf2@oracle.com>
Organization: Oracle Corp
Message-ID: <c4bdd767-eb3f-6668-0f49-4aaf4bc7689d@oracle.com>
Date: Wed, 19 Jun 2019 10:46:17 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <a5e0e465-89d5-91d0-c6a4-39674269bbf2@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9293 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906190135
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9293 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906190135
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/19/19 9:55 AM, Khalid Aziz wrote:
> On 6/12/19 5:43 AM, Andrey Konovalov wrote:
>> This patch is a part of a series that extends arm64 kernel ABI to allo=
w to
>> pass tagged user pointers (with the top byte set to something else oth=
er
>> than 0x00) as syscall arguments.
>>
>> This patch allows tagged pointers to be passed to the following memory=

>> syscalls: get_mempolicy, madvise, mbind, mincore, mlock, mlock2, mprot=
ect,
>> mremap, msync, munlock, move_pages.
>>
>> The mmap and mremap syscalls do not currently accept tagged addresses.=

>> Architectures may interpret the tag as a background colour for the
>> corresponding vma.
>>
>> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
>> Reviewed-by: Kees Cook <keescook@chromium.org>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>> ---
>=20
> Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
>=20
>=20

I would also recommend updating commit log for all the patches in this
series that are changing files under mm/ as opposed to arch/arm64 to not
reference arm64 kernel ABI since the change applies to every
architecture. So something along the lines of "This patch is part of a
series that extends kernel ABI to allow......."

--
Khalid


>>  mm/madvise.c   | 2 ++
>>  mm/mempolicy.c | 3 +++
>>  mm/migrate.c   | 2 +-
>>  mm/mincore.c   | 2 ++
>>  mm/mlock.c     | 4 ++++
>>  mm/mprotect.c  | 2 ++
>>  mm/mremap.c    | 7 +++++++
>>  mm/msync.c     | 2 ++
>>  8 files changed, 23 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/madvise.c b/mm/madvise.c
>> index 628022e674a7..39b82f8a698f 100644
>> --- a/mm/madvise.c
>> +++ b/mm/madvise.c
>> @@ -810,6 +810,8 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, siz=
e_t, len_in, int, behavior)
>>  	size_t len;
>>  	struct blk_plug plug;
>> =20
>> +	start =3D untagged_addr(start);
>> +
>>  	if (!madvise_behavior_valid(behavior))
>>  		return error;
>> =20
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index 01600d80ae01..78e0a88b2680 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -1360,6 +1360,7 @@ static long kernel_mbind(unsigned long start, un=
signed long len,
>>  	int err;
>>  	unsigned short mode_flags;
>> =20
>> +	start =3D untagged_addr(start);
>>  	mode_flags =3D mode & MPOL_MODE_FLAGS;
>>  	mode &=3D ~MPOL_MODE_FLAGS;
>>  	if (mode >=3D MPOL_MAX)
>> @@ -1517,6 +1518,8 @@ static int kernel_get_mempolicy(int __user *poli=
cy,
>>  	int uninitialized_var(pval);
>>  	nodemask_t nodes;
>> =20
>> +	addr =3D untagged_addr(addr);
>> +
>>  	if (nmask !=3D NULL && maxnode < nr_node_ids)
>>  		return -EINVAL;
>> =20
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index f2ecc2855a12..d22c45cf36b2 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -1616,7 +1616,7 @@ static int do_pages_move(struct mm_struct *mm, n=
odemask_t task_nodes,
>>  			goto out_flush;
>>  		if (get_user(node, nodes + i))
>>  			goto out_flush;
>> -		addr =3D (unsigned long)p;
>> +		addr =3D (unsigned long)untagged_addr(p);
>> =20
>>  		err =3D -ENODEV;
>>  		if (node < 0 || node >=3D MAX_NUMNODES)
>> diff --git a/mm/mincore.c b/mm/mincore.c
>> index c3f058bd0faf..64c322ed845c 100644
>> --- a/mm/mincore.c
>> +++ b/mm/mincore.c
>> @@ -249,6 +249,8 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, siz=
e_t, len,
>>  	unsigned long pages;
>>  	unsigned char *tmp;
>> =20
>> +	start =3D untagged_addr(start);
>> +
>>  	/* Check the start address: needs to be page-aligned.. */
>>  	if (start & ~PAGE_MASK)
>>  		return -EINVAL;fixup_user_fault
>> diff --git a/mm/mlock.c b/mm/mlock.c
>> index 080f3b36415b..e82609eaa428 100644
>> --- a/mm/mlock.c
>> +++ b/mm/mlock.c
>> @@ -674,6 +674,8 @@ static __must_check int do_mlock(unsigned long sta=
rt, size_t len, vm_flags_t fla
>>  	unsigned long lock_limit;
>>  	int error =3D -ENOMEM;
>> =20
>> +	start =3D untagged_addr(start);
>> +
>>  	if (!can_do_mlock())
>>  		return -EPERM;
>> =20
>> @@ -735,6 +737,8 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, siz=
e_t, len)
>>  {
>>  	int ret;
>> =20
>> +	start =3D untagged_addr(start);
>> +
>>  	len =3D PAGE_ALIGN(len + (offset_in_page(start)));
>>  	start &=3D PAGE_MASK;
>> =20
>> diff --git a/mm/mprotect.c b/mm/mprotect.c
>> index bf38dfbbb4b4..19f981b733bc 100644
>> --- a/mm/mprotect.c
>> +++ b/mm/mprotect.c
>> @@ -465,6 +465,8 @@ static int do_mprotect_pkey(unsigned long start, s=
ize_t len,
>>  	const bool rier =3D (current->personality & READ_IMPLIES_EXEC) &&
>>  				(prot & PROT_READ);
>> =20
>> +	start =3D untagged_addr(start);
>> +
>>  	prot &=3D ~(PROT_GROWSDOWN|PROT_GROWSUP);
>>  	if (grows =3D=3D (PROT_GROWSDOWN|PROT_GROWSUP)) /* can't be both */
>>  		return -EINVAL;
>> diff --git a/mm/mremap.c b/mm/mremap.c
>> index fc241d23cd97..64c9a3b8be0a 100644
>> --- a/mm/mremap.c
>> +++ b/mm/mremap.c
>> @@ -606,6 +606,13 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsi=
gned long, old_len,
>>  	LIST_HEAD(uf_unmap_early);
>>  	LIST_HEAD(uf_unmap);
>> =20
>> +	/*
>> +	 * Architectures may interpret the tag passed to mmap as a backgroun=
d
>> +	 * colour for the corresponding vma. For mremap we don't allow tagge=
d
>> +	 * new_addr to preserve similar behaviour to mmap.
>> +	 */
>> +	addr =3D untagged_addr(addr);
>> +
>>  	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
>>  		return ret;
>> =20
>> diff --git a/mm/msync.c b/mm/msync.c
>> index ef30a429623a..c3bd3e75f687 100644
>> --- a/mm/msync.c
>> +++ b/mm/msync.c
>> @@ -37,6 +37,8 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t,=
 len, int, flags)
>>  	int unmapped_error =3D 0;
>>  	int error =3D -EINVAL;
>> =20
>> +	start =3D untagged_addr(start);
>> +
>>  	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
>>  		goto out;
>>  	if (offset_in_page(start))
>>
>=20
>=20


