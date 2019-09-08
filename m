Return-Path: <SRS0=7uET=XD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DA07C4332F
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 17:07:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 128B3218DE
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 17:07:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 128B3218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4A8F6B0006; Sun,  8 Sep 2019 13:07:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFB076B0007; Sun,  8 Sep 2019 13:07:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EA8E6B0008; Sun,  8 Sep 2019 13:07:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0216.hostedemail.com [216.40.44.216])
	by kanga.kvack.org (Postfix) with ESMTP id 7E02C6B0007
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 13:07:53 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2474981CB
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 17:07:53 +0000 (UTC)
X-FDA: 75912385626.21.swim80_44c947e4b4321
X-HE-Tag: swim80_44c947e4b4321
X-Filterd-Recvd-Size: 6437
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 17:07:52 +0000 (UTC)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x88H7Dks099386
	for <linux-mm@kvack.org>; Sun, 8 Sep 2019 13:07:51 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2uvt5pe9gg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 08 Sep 2019 13:07:51 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zohar@linux.ibm.com>;
	Sun, 8 Sep 2019 18:07:49 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 8 Sep 2019 18:07:45 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x88H7ikw42336420
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 8 Sep 2019 17:07:44 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A86E011C050;
	Sun,  8 Sep 2019 17:07:44 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AE86C11C054;
	Sun,  8 Sep 2019 17:07:43 +0000 (GMT)
Received: from localhost.localdomain (unknown [9.85.159.93])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Sun,  8 Sep 2019 17:07:43 +0000 (GMT)
Subject: Re: [PATCH 3/3] ima: update the file measurement on writes
From: Mimi Zohar <zohar@linux.ibm.com>
To: Janne Karhunen <janne.karhunen@gmail.com>, linux-integrity@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-mm@kvack.org,
        viro@zeniv.linux.org.uk
Cc: Konsta Karsisto <konsta.karsisto@gmail.com>
Date: Sun, 08 Sep 2019 13:07:42 -0400
In-Reply-To: <20190902094540.12786-3-janne.karhunen@gmail.com>
References: <20190902094540.12786-1-janne.karhunen@gmail.com>
	 <20190902094540.12786-3-janne.karhunen@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.20.5 (3.20.5-1.fc24) 
Mime-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19090817-0008-0000-0000-00000312C6ED
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19090817-0009-0000-0000-00004A3127E8
Message-Id: <1567962462.4614.202.camel@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-08_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909080188
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-09-02 at 12:45 +0300, Janne Karhunen wrote:
> From: Konsta Karsisto <konsta.karsisto@gmail.com>
>=20
> Hook do_writepages() in order to do IMA measurement of an inode
> that is written out.

With this explanation I would expect to see a security/ima hook in
do_writepages(), nothing else.=C2=A0=C2=A0There's a lot more going on her=
e than
that. =C2=A0The memory management maintainer(s) doesn't really care about
IMA. =C2=A0Please break this patch up so that it is easier to review and
upstream.

My comments on the first patch in this patch set (e.g. function names,
ifdefs in C code, workqueue belonging in a separate patch) are also
applicable to this patch.

>=20
> Depends on commit 72649b7862a7 ("ima: keep the integrity state of open =
files up to date")'
>=20
> Signed-off-by: Konsta Karsisto <konsta.karsisto@gmail.com>
> Signed-off-by: Janne Karhunen <janne.karhunen@gmail.com>
> ---

[snip]


> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 1804f64ff43c..d5041c625529 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -38,6 +38,7 @@
>  #include <linux/sched/rt.h>
>  #include <linux/sched/signal.h>
>  #include <linux/mm_inline.h>
> +#include <linux/ima.h>
>  #include <trace/events/writeback.h>
> =20
>  #include "internal.h"
> @@ -2347,6 +2348,12 @@ int do_writepages(struct address_space *mapping,=
 struct writeback_control *wbc)
>  		cond_resched();
>  		congestion_wait(BLK_RW_ASYNC, HZ/50);
>  	}
> +	if (ret =3D=3D 0) {
> +		if (wbc->sync_mode =3D=3D WB_SYNC_ALL)
> +			ima_inode_update(mapping->host);
> +		else
> +			ima_inode_delayed_update(mapping->host);

It's hard enough upstreaming a single security or IMA hook. =C2=A0There's
no need for two. =C2=A0security/IMA hooks are normally based on function
names (eg. ima_do_writepages). =C2=A0The sync_mode should be an argument.

> +	}
>  	return ret;
>  }
> =20


> diff --git a/security/integrity/ima/ima_main.c b/security/integrity/ima=
/ima_main.c
> index 46d28cdb6466..affc74a07125 100644

> @@ -425,6 +430,42 @@ int ima_bprm_check(struct linux_binprm *bprm)
>  }
> =20
>  #ifdef CONFIG_IMA_MEASURE_WRITES
> +void ima_get_file(struct integrity_iint_cache *iint,
> +		  struct file *file)
> +{
> +	struct ima_fl_entry *e;
> +
> +	if (!iint || !file)
> +		return;
> +	if (!(file->f_mode & FMODE_WRITE) ||
> +	    !test_bit(IMA_UPDATE_XATTR, &iint->atomic_flags))
> +		return;
> +
> +	list_for_each_entry(e, &iint->file_list, list) {
> +		if (e->file =3D=3D file)
> +			return;
> +	}
> +	e =3D kmalloc(sizeof(*e), GFP_KERNEL);
> +	if (!e)
> +		return;
> +	e->file =3D file;
> +	list_add(&e->list, &iint->file_list);
> +}
> +
> +void ima_put_file(struct integrity_iint_cache *iint,
> +		  struct file *file)
> +{
> +	struct ima_fl_entry *e;
> +
> +	list_for_each_entry(e, &iint->file_list, list) {
> +		if (e->file =3D=3D file) {
> +			list_del(&e->list);
> +			kfree(e);
> +			break;
> +		}
> +	}
> +}
> +

Functions with "get" or "put" in their name increment/decrement a
reference count. =C2=A0No reference count is being updated here.

Mimi


