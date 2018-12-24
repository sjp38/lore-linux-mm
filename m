Return-Path: <SRS0=oA8h=PB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F7EAC64E79
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 16:11:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 029922173C
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 16:11:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ieI+2V8f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 029922173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E59A8E0002; Mon, 24 Dec 2018 11:11:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8948E8E0001; Mon, 24 Dec 2018 11:11:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 736A58E0002; Mon, 24 Dec 2018 11:11:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CD448E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 11:11:46 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q64so12742019pfa.18
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 08:11:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=SjgmuKwbiqLkWLZ9/CSf03ose+Q5MfHQJIptqdfeUz0=;
        b=cd1TmZk3fK+A6Ya3hQ2crvLPjfX+ewNVuFHw/9c8ZhWA1R8qkPd1sFE9WEMeKJwKqA
         /sff7pBRj7h6ZPkakX5MKz4op3/gFSKx+7+XSwsSbRzJgapAYlBoFs7Xv2GE8x7Sa6wn
         u05TvlMBlOcZpr0Sb9tBKsyHQ7rizzqK/tdfHYSZbswi9k+alEPPPLjCqNd6hgenx3mg
         boBvHMU4xGhJv1M+LC/U9W7rnp6+7agDnztXDlZtubUfqMcvFtAoYmdZSM8l96sJXZY6
         /U7/qqKqkjJnQYSSeFHDOgywgArLDGg32DtCI2i2ARUEtijT2PfZ27c7HClqK527RwGG
         YtVg==
X-Gm-Message-State: AJcUukfZqybv3QXqd4p97Lc17yEvn29Kt/1BePz8b4nXYRqYxHeeovZe
	GdGtlfwHpZzRK+IBlSVV58CO4qHztHZ+NLBAMQl4NqOF7EUYDb/HPeq+NNWeRn8oiR0Rnl4pwui
	LiszVh2VYjbCsXU8y+1modVhIdr34NlxM8fwH30G3X0ou81Ukl+Hi4t6Tv/BJXc84kw==
X-Received: by 2002:a17:902:3124:: with SMTP id w33mr13536683plb.241.1545667905707;
        Mon, 24 Dec 2018 08:11:45 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5KJr7GTOCH61MLetfSeKHtQ+E9hUVMEdcBQYz3Tc/5ZiXAuJgmyn3m0diSRdNvKsXWpEB3
X-Received: by 2002:a17:902:3124:: with SMTP id w33mr13536616plb.241.1545667904755;
        Mon, 24 Dec 2018 08:11:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545667904; cv=none;
        d=google.com; s=arc-20160816;
        b=teGvcFQ357gsLRVijizOpiUYpgPZGI6NgNma1+EpfXlc4Gyhp9IAbmiLACnR1NVCj9
         3Qmjoqbm0Xvno5Em4rBGJNGW+sSW8vaqZO7SVZca3+cP2RReLye+atsiHdmnvngMbP+k
         Vl7I7BrZqxNfGIgP5vXP2CftaNbIYtn2rO3C+CwXf1ez7Rg328SKkypqhb+8/MMoP3V3
         PFU0mYKNzJ0vMpQ2G9fZ3O8+n6ZIz0hWj8pQ2pX5IbB1aqaglN6egeTvmEAbnsFqpTc1
         gnRGIXr0smcqYfpIZUilhXbh/0Zi5FnUvYrOSXQXEsK4HkBudLxaIz33GjSvqGszgNm8
         nMKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=SjgmuKwbiqLkWLZ9/CSf03ose+Q5MfHQJIptqdfeUz0=;
        b=TLtSrBGoXUJM8dwSCAWiCbNYrXdi/Jsem1lZ5TqECg/rUeXteKLu5oPgRt1eD5QeCI
         4mHO+f4X8sb4NgFIwqbB6uFyM4b/0afM6JoTgnFEQSBlXXv8bGnSlI+p2HYUXZspbC4j
         rsCbAq681Q70xe3DJfi+stSPn1TB+a5ufxSVIoXV83+4syDdGkuk2Jpq7K4IthBbXwCO
         oOg28I7/xPlDYvYhsm0svJ/m8Ccq39q9UBTUyucGpbshGiyDmxTz2nUIrMIykKJ5aFhp
         5RtU+KBseiwIXzUUQ6WlFEyLyAIT+aXvzG43+17GaXZZhz4GJavZudcbRsKrDxxE8PdU
         FI9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ieI+2V8f;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id j10si9844542plg.123.2018.12.24.08.11.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Dec 2018 08:11:44 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ieI+2V8f;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBOBXl2c001189;
	Mon, 24 Dec 2018 11:35:32 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=SjgmuKwbiqLkWLZ9/CSf03ose+Q5MfHQJIptqdfeUz0=;
 b=ieI+2V8fVq642DYxxQS8bs/5e1W5gDSTc81TNQr+OctTmOPloIUQO6+v2GaJ7qBHrOmA
 yKEFxk+ztpjjv95veC1+dVsF6x+BezcqG/kDFircu7S81GtugP7Q3YEfRaiY2CRrYnIj
 qwGBuN66qRPoNZd7JG72DtDkXZXvob7tNc22a8waBa+AC6SwrRN91bEEV6QWiTQVKsIy
 tV6L0C7Bc2UUFdydbrlwIh1hydaz+21G8sI2uJY1b1lkaJLc33aVmI4B5JCfa0Zoejt0
 vQ9Zjs9uOqoXDpEfLPRQKUt/OkutsZPN2ETrSJfrm5xZewJhQTl+BEnmnjGKkXQqMElo iQ== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2phasdmqnw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 24 Dec 2018 11:35:32 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wBOBZUwP030778
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 24 Dec 2018 11:35:31 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBOBZTOT025976;
	Mon, 24 Dec 2018 11:35:29 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 24 Dec 2018 03:35:29 -0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: Bug with report THP eligibility for each vma
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181224074916.GB9063@dhcp22.suse.cz>
Date: Mon, 24 Dec 2018 04:35:28 -0700
Cc: Paul Oppenheimer <bepvte@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>,
        Jan Kara <jack@suse.cz>, Mike Rapoport <rppt@linux.ibm.com>,
        linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <78624B4A-EA8B-4D51-B3E6-448132BB839B@oracle.com>
References: <CALouPAi8KEuPw_Ly5W=MkYi8Yw3J6vr8mVezYaxxVyKCxH1x_g@mail.gmail.com>
 <20181224074916.GB9063@dhcp22.suse.cz>
To: Michal Hocko <mhocko@suse.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9116 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=908
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812240104
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181224113528.O38QrbLkx-WhDLJs3Sb923SUm8xIoq0nxn_h2wrmtDQ@z>



> On Dec 24, 2018, at 12:49 AM, Michal Hocko <mhocko@suse.com> wrote:
>=20
> [Cc-ing mailing list and people involved in the original patch]
>=20
> On Fri 21-12-18 13:42:24, Paul Oppenheimer wrote:
>> Hello! I've never reported a kernel bug before, and since its on the
>> "next" tree I was told to email the author of the relevant commit.
>> Please redirect me to the correct place if I've made a mistake.
>>=20
>> When opening firefox or chrome, and using it for a good 7 seconds, it
>> hangs in "uninterruptible sleep" and I recieve a "BUG" in dmesg. This
>> doesn't occur when reverting this commit:
>> =
https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit=
/?id=3D48cf516f8c.
>> Ive attached the output of decode_stacktrace.sh and the relevant =
dmesg
>> log to this email.
>>=20
>> Thanks
>=20
>> BUG: unable to handle kernel NULL pointer dereference at =
00000000000000e8
>=20
> Thanks for the bug report! This is offset 232 and that matches
> file->f_mapping as per pahole
> pahole -C file ./vmlinux | grep f_mapping
>        struct address_space *     f_mapping;            /*   232     8 =
*/
>=20
> I thought that each file really has to have a mapping. But the =
following
> should heal the issue and add an extra care.
>=20
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index f64733c23067..fc9d70a9fbd1 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -66,6 +66,8 @@ bool transparent_hugepage_enabled(struct =
vm_area_struct *vma)
> {
> 	if (vma_is_anonymous(vma))
> 		return __transparent_hugepage_enabled(vma);
> +	if (!vma->vm_file || !vma->vm_file->f_mapping)
> +		return false;
> 	if (shmem_mapping(vma->vm_file->f_mapping) && =
shmem_huge_enabled(vma))
> 		return __transparent_hugepage_enabled(vma);

=46rom what I see in code in mm/mmap.c, it seems if vma->vm_file is =
non-zero
vma->vm_file->f_mapping may be assumed to be non-NULL; see =
unlink_file_vma()
and __vma_link_file() for two examples, which both use the construct:

	file =3D vma->vm_file;
	if (file) {
		struct address_space *mapping =3D file->f_mapping;

		[ ... ]

		[ code that dereferences "mapping" without further =
checks ]
	}

I see nothing wrong with your second check but a few extra instructions
performed, but depending upon how often transparent_hugepage_enabled() =
is called
there may be at least theoretical performance concerns.

William Kucharski
william.kucharski@oracle.com

