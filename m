Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59851C76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 15:50:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08F0B208C0
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 15:50:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08F0B208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BEBD8E0003; Thu, 18 Jul 2019 11:50:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66FAF8E0001; Thu, 18 Jul 2019 11:50:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 537A68E0003; Thu, 18 Jul 2019 11:50:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E12B8E0001
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 11:50:48 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d3so16879278pgc.9
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 08:50:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:in-reply-to:references:user-agent:mime-version
         :message-id;
        bh=j3WjNMUwByxrU9s6ZmYdWswyK6u9ATnu18+R2+ktpd0=;
        b=caaPfqNsKmhZv8O+2EXIiMxBpk6IjHXnnHdMwnrt5ttKgKPGrG1rhqIG/6k+P3vSqs
         OL2vEv/bhmnmHLEvEJL8gN8x1JrPZ3FUzEcyU0UTWSQbHJZy3FGkxMO1FZZTL2D7qN7j
         PUGfNIGUmUMDlg7q5Mp1y+FqeVn/0SGT7GqiHWWjXE1ACM0Yb+d6jilZj4H035+XZlP7
         FvUD0wf83ueI0zSmK9AYasD33iA+jaYTtSlA6Cp4VR5BU7j7MgQbMqEbL8Rh4NYNqXxl
         cU2MyoAbnMOUA7Pdss9K7idcUhxeJOPxPiAe2MaO4KmjR3JS5WL0OBDlxAUP6GapxjJ9
         FogQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=leonardo@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUeZTuYjpDimLSjWO/ddifuW0koOoHrMkVMNUZ9FqyTGeICLbIu
	HxbnhVpFC8bVl0kNbXBLBkCnbjLWT84D7eQlwUWDwxZ9br8k8/OhM4WXL/D3lMAZBN1QxLv6uTO
	Buk10/JbPvHjkhpparbAQNRwCsM6zelRsY/IJcJz5jueLQ7GkWFOlKQcKgrkhCCby9A==
X-Received: by 2002:a63:6f8f:: with SMTP id k137mr48283075pgc.90.1563465047615;
        Thu, 18 Jul 2019 08:50:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1bk914minpovLOZlUKAp7hfrKdc7e1pCfPw/YB2cIuFAZ/Ds+u5jSFBlXpF6Hv+Lqo/FJ
X-Received: by 2002:a63:6f8f:: with SMTP id k137mr48283023pgc.90.1563465046810;
        Thu, 18 Jul 2019 08:50:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563465046; cv=none;
        d=google.com; s=arc-20160816;
        b=JZ7SYZhrNElsuZMguTiRKRgm9uzskmo5pb4USzq8SEK1IC4cP7/H/ZO/YiepbfuHky
         66wwZByYqPgLs5S8LM76ZOCVcyl43ZJtmuPmbNFpCKXkgJEs4ShYKxy70p8CN9qYsTm7
         c/MY+Rbzzv71zVM2l4eqiCq6rPzyb6Ucjw4rPxKyF+OHcGUTVdyznxWqcgBvhRBZVM07
         2WJ78/TCxBQq8em50CPLBaH+bSY84/fZL/IOkjjhbUbG2397PXmkNP+JIPdtlOYbVCjy
         jYMJ4Vz4uNHl2oM83QQjCQ/CGG6EMn6HAjs08CU2Ae1wYkVgCrP8wMu9EKwwFWOGNZ7r
         Cmpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:user-agent:references:in-reply-to:date:cc
         :to:from:subject;
        bh=j3WjNMUwByxrU9s6ZmYdWswyK6u9ATnu18+R2+ktpd0=;
        b=Z1dHyLlOUXsvHl94ImNGtSi/+137Q+nVhUbfOqNnZRD8h+Mnx3buA+zWZsZfzAtf2N
         2cUi4ggG+o4kKIZLnex6h6MvKOZpeLpTMzosVb6kOp5g6fsZlhI+HnLu60eTBAjmMyWE
         S9lJ94WlJiXSgq3KDRVH5sh3QF2HP8YXTFGwBX9ctzSkAxF+xOFHQ3zAC3JPoFoYJsH/
         40WOkPBbZOC2CFeYXsjbaRIHNDchYFmepN1rWgxx1c2F50FLFN/1qunMVMg5WYWsV/l6
         msSKLlcEC2XcjEsGmAOxyo2nSaz4PNTlF5XfIhqSDjHdzzCYDtDepq1BYcQTfofYudSr
         y9cA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=leonardo@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j190si779436pge.92.2019.07.18.08.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 08:50:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=leonardo@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6IFgwPF042423
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 11:50:46 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tttb2m97h-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 11:50:45 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <leonardo@linux.ibm.com>;
	Thu, 18 Jul 2019 16:50:43 +0100
Received: from b03cxnp08027.gho.boulder.ibm.com (9.17.130.19)
	by e34.co.us.ibm.com (192.168.1.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 18 Jul 2019 16:50:39 +0100
Received: from b03ledav006.gho.boulder.ibm.com (b03ledav006.gho.boulder.ibm.com [9.17.130.237])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6IFocVw60621270
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 18 Jul 2019 15:50:38 GMT
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BC60AC6057;
	Thu, 18 Jul 2019 15:50:38 +0000 (GMT)
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 02588C6055;
	Thu, 18 Jul 2019 15:50:34 +0000 (GMT)
Received: from LeoBras (unknown [9.85.162.151])
	by b03ledav006.gho.boulder.ibm.com (Postfix) with ESMTP;
	Thu, 18 Jul 2019 15:50:34 +0000 (GMT)
Subject: Re: [PATCH 1/1] mm/memory_hotplug: Adds option to hot-add memory in
 ZONE_MOVABLE
From: Leonardo Bras <leonardo@linux.ibm.com>
To: Oscar Salvador <osalvador@suse.de>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki"
 <rafael@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike
 Rapoport <rppt@linux.ibm.com>, Michal Hocko <mhocko@suse.com>,
        Pavel
 Tatashin <pasha.tatashin@oracle.com>,
        =?ISO-8859-1?Q?J=E9r=F4me?= Glisse
 <jglisse@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Pasha Tatashin
 <Pavel.Tatashin@microsoft.com>,
        Bartlomiej Zolnierkiewicz
 <b.zolnierkie@samsung.com>
Date: Thu, 18 Jul 2019 12:50:29 -0300
In-Reply-To: <1563430353.3077.1.camel@suse.de>
References: <20190718024133.3873-1-leonardo@linux.ibm.com>
	 <1563430353.3077.1.camel@suse.de>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-3qG8sm/tWDfxGznMgLRc"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19071815-0016-0000-0000-000009D1B406
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011452; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000287; SDB=6.01233984; UDB=6.00650254; IPR=6.01015312;
 MB=3.00027780; MTD=3.00000008; XFM=3.00000015; UTC=2019-07-18 15:50:43
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19071815-0017-0000-0000-00004412BFFF
Message-Id: <0e67afe465cbbdf6ec9b122f596910cae77bc734.camel@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-18_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907180163
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-3qG8sm/tWDfxGznMgLRc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2019-07-18 at 08:12 +0200, Oscar Salvador wrote:
> We do already have "movable_node" boot option, which exactly has that
> effect.
> Any hotplugged range will be placed in ZONE_MOVABLE.
Oh, I was not aware of it.

> Why do we need yet another option to achieve the same? Was not that
> enough for your case?
Well, another use of this config could be doing this boot option a
default on any given kernel.=20
But in the above case I agree it would be wiser to add the code on
movable_node_is_enabled() directly, and not where I did put.

What do you think about it?

Thanks for the feedback,

Leonardo Br=C3=A1s

--=-3qG8sm/tWDfxGznMgLRc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEMdeUgIzgjf6YmUyOlQYWtz9SttQFAl0wlUUACgkQlQYWtz9S
ttRBRRAAzXZyanM8TpDhxFNBGg0BldrMpkUJO/FKHGIUyK70KPr3a0bsWtNx2GLs
nrCP5UQhcNmKdiofCOf2kpAqsAv13a57vUoo0iozKF771s3gpih92gC1CuGrwKUp
lMRt9G3q6GqQx0fXPlrImutBHICAHTHOD5NUJkRF2FgGwKVxHXsPRF0h/yOxegMV
I/ToF2NmuOBbtBbQD7aEDMW7XG3w5nM/yn9aNqbwrDcuG4F77jsbaLqfBFMLEI5C
3hrvE98xy5W7XO3/yA3QcYC+WczN8dyzb1Y9F8nz9mWMiGKsBtGQxHyog2YMOMj3
NB43X4xEVlJwPD2eMdd3loukeoudUhnlIvjD7yIxd4z3oPXsz5wSL+r6cd9q1B05
v+Rw8QR6FQRlbv8idhMZ7Y5//g6Mwrxc8ecZfhpACmyIsWwSeMz7HXQmoFm7SM9k
mx5ET3BNYtrB08mRMt/cA1XakfMAp1PFi8OwhjIQShZib8xpOzWqVVKE79oVPptG
5H/71zXj2rgP/W5Zv0dGl2x7co+SbPwVwbMMBTiYf+8KXBhD+1K5AowNKZKMetR1
Ag7Cs18NBFpawxIoMPNbLYIz/hf1CvH2//vA7O7hV39CnD7Vakz8NNPVQkc109RJ
2OxDKtiVu+SCT6rjcTBkZfUJ7wTXKd2zKnvn1gKEpU2qKDC4tVw=
=OHH1
-----END PGP SIGNATURE-----

--=-3qG8sm/tWDfxGznMgLRc--

