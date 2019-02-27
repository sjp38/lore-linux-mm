Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5406C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 08:53:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A45C8218D0
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 08:53:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A45C8218D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 354128E0003; Wed, 27 Feb 2019 03:53:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 303D78E0001; Wed, 27 Feb 2019 03:53:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21A398E0003; Wed, 27 Feb 2019 03:53:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE86B8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 03:53:10 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id q3so12511912ior.1
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 00:53:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=lexw7B2xRyuEiV3piNTaz41+nkc10fPvAkzZb6Y2C5Q=;
        b=YXyBUK8Q42U/WxbGMiPTLS7NbDp7wAHFmeZdGSXbQTEpiIp3ZF9QYwubN1siJGMVGZ
         ZgcAOHTkY4VSEnsID1DrS1Ea5DH9abvJJLcupFaY/u2M6U7D9yq+hGjJUhtNeg2X0Y0C
         iaPTx7/cjTb43+NeYIXMTqBi6DNSwcdOhrthE0+hagG/2E+6wQ4FTGccEjUCj8KFHtMh
         9IhXxp7zQed8PWLG1ysYYJZTxI3BGGsXYi+jcDNAg7uyriyaoaYmWD/89Vq0XKyXFGXS
         2yq7CKA/3mCt1hOnpzdvx2OyQnDm7/Q+NzyQDEyU8v4iRZ0yzj8s9DSkwRs0cIoaJAyF
         Oaxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUXlX2b+m2tqBEe9rtif2lQmA/yP+e47PIQskppFTMM8fcVsVBO
	X5ylIh2s0zGE+lvIkMiHBii7XSHc1lgbp70KFOKInFVzljlh5JOW9/rW4uG/sB70DBOttaaagb5
	ZeNv9nCe4OpBl7AKp2Rj6YMGHx/Un72UD3Xp4lK8NWdW4PE8G88DUcuSeR8G1LdHwFg==
X-Received: by 2002:a24:4e50:: with SMTP id r77mr772403ita.142.1551257590775;
        Wed, 27 Feb 2019 00:53:10 -0800 (PST)
X-Google-Smtp-Source: APXvYqz2xKssW00s51K6nqoDZVIFFP4fwieCndUnN51ELVEgdf18+T7JxDsGr0qMJx8XgSghjx6T
X-Received: by 2002:a24:4e50:: with SMTP id r77mr772374ita.142.1551257589760;
        Wed, 27 Feb 2019 00:53:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551257589; cv=none;
        d=google.com; s=arc-20160816;
        b=D0xyOH7rFDTNB5Q9i4HTmKBfUpa0GoDiyT2WpBxCCwfOomTT85KImV5e47+4CEBcH3
         5j1ENf2in6WFpr7FtWc5auZW4MnMc6/Xvl0iNc0HRDECav0f4BoAGU05z8pWXIGAgGew
         P3i462gMNB6xWNCBWdIt7GAmhn0t4me9JwoQgPgA3eNUegGNo3AyWUgtL44/U5tnpeuL
         NV1WUmnKqRjuHLEY9QNPgcQO3Tx1HugJbOjPh2q8zAoYE5DtwAxjq3s6OA8gp+vLTukL
         11mDUepfDH0ErDWSrsjP3ZM2avJKjdcVacPSEEg7mmBdo8EI1ZsiLOD2Nkx4fKmNqOVT
         uC3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=lexw7B2xRyuEiV3piNTaz41+nkc10fPvAkzZb6Y2C5Q=;
        b=P6SkQaID5tOI6Ltx+OT77ezVGotG+Kg55mvlTd+TlbrHzKahk5jll0qoI7uhQf9uN0
         YMveeBx5ZZJSwog2MplaEsyZti4EeQtm3pmwY1Jvwuoy6XCIF+zqy0fxh6lbi6mVRkvy
         cUwjoqY8BoMBNJDDKcvHSTqqVc62Uoq2P6IJs9LkW47uW2nkFXTPuAUmV9w4x1PgApdi
         csPFSXWrLRSffoDBEWAldMwv0zcqUzxDt+1BcFCBmyUQ+DGvGFx8ZkiK3WG+39xMc8oz
         jhPcG6nnU6GfBiC1Z2/oisTFukC2YgrtCEsYFdqd/ViTuoYCZn6dw+/TFPm2fTyzS+uh
         QgOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y10si866840itb.95.2019.02.27.00.53.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 00:53:09 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1R8jCQt086026
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 03:53:08 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qwpr7j5mn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 03:53:08 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 27 Feb 2019 08:53:07 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 27 Feb 2019 08:53:04 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1R8r3cw32833740
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Feb 2019 08:53:03 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id ED7E052050;
	Wed, 27 Feb 2019 08:53:02 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.124.31.69])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id 5B23152052;
	Wed, 27 Feb 2019 08:53:01 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>,
        David Gibson <david@gibson.dropbear.id.au>,
        Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH V7 0/4] mm/kvm/vfio/ppc64: Migrate compound pages out of CMA region
In-Reply-To: <20190226155324.e99d5200cc6293138ac5c6fa@linux-foundation.org>
References: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com> <20190226155324.e99d5200cc6293138ac5c6fa@linux-foundation.org>
Date: Wed, 27 Feb 2019 14:22:58 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19022708-0012-0000-0000-000002FABA32
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022708-0013-0000-0000-0000213260FF
Message-Id: <87mumhtxxx.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-27_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=591 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902270060
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000022, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> [patch 1/4]: OK.  I guess.  Was this worth consuming our last PF_ flag?

That was done based on request from Andrea and it also helps in avoiding
allocating pages from CMA region where we know we are anyway going to
migrate them out. So yes, this helps. 

> [patch 2/4]: unreviewed
> [patch 3/4]: unreviewed, mpe still unhappy, I expect?

I did reply to that email. I guess mpe is ok with that?

> [patch 4/4]: unreviewed

-aneesh

