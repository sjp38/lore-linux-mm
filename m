Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39069C04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 11:36:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9C39215EA
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 11:36:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="o7iRymlM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9C39215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 750AD6B0003; Mon, 29 Apr 2019 07:36:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7009F6B0006; Mon, 29 Apr 2019 07:36:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EED86B0007; Mon, 29 Apr 2019 07:36:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A53F6B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 07:36:26 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i23so7089569pfa.0
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 04:36:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:to:cc:subject:from:organization
         :references:date:in-reply-to:message-id:user-agent:mime-version;
        bh=VnsYAI9ZN9zVJAIgiBsb84bbY9EWS3zR+ILQZL/U3uA=;
        b=IvMgf9b1UNtYmOs7OybR2E2QA4YPRwGQhVtqKkJGOvqrDHx37+GFAKvjci8prjhcGY
         Et2GlKKbc6yueR8Z030GIRTKuXG7Qf3F25yQ8yLWvA7FuuqotMaPCYfz6nzMUd/xVmG8
         8/KO2p2gvVTnG4YghBxzZtW6+HJQ80RILcIYDugUeWZWxiuk/XzYgF+UFM+XpxvVJVBf
         wfCbHDCY6tdFzINbwGNK3QA1PcnkhC+RdDc/beRl3nw7h/wknvFRobnLXL8PNgxG9TQJ
         YQHM7fVPZtmRIpVlFgm9MQPcXlSs+smotly1b5bbb5cQgGAKeGU6TzYL5ZVmEULJmRzg
         asbQ==
X-Gm-Message-State: APjAAAXJXDeONQ5VxWb0T33KrURNZqh4uaNLgm8B8W3y0WVHd69vH5tc
	leL2lpHeGpJjUn9azOzr7XnZ8S0+Mvmt919Yh5Tggf3Kcf+346R3xV/nM8AO/gu4uafANEsOExX
	+rhJqy9nZDuUr9MhXnvsSJy4VWcBxCrOeTnQPqsA3cBWGFncw3eN8UWT+tBZ+tpGs8g==
X-Received: by 2002:a17:902:be09:: with SMTP id r9mr61878757pls.215.1556537785728;
        Mon, 29 Apr 2019 04:36:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjOZOE1Xvs55B4Qy73BATvLmaMznD8dusA7xxxSx+58OeFBIMd7rT2UxkCFlF/5UDZXFLA
X-Received: by 2002:a17:902:be09:: with SMTP id r9mr61878711pls.215.1556537785153;
        Mon, 29 Apr 2019 04:36:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556537785; cv=none;
        d=google.com; s=arc-20160816;
        b=1JRYQ1MEPY4IawkGOIEQnw1PwSzyoSMumX0A0hzao9Kp7H865hDNRvEpfCxI0w4y7u
         6uysTz10PMzlmH6JJf+nic5JlGRhDknVwSLwhQNB/cfsQrMUU02AQ6RgdWbeEosR+MmB
         qqonXWtVJA+22sJMbTGL28DGpsH0RlmCQuzEanjFKYJwlbcHBrSOyiELIet8fOvoCk20
         pPg6HHVhhfb+CTe3QgusKNMFCCgMY+/SdSvwJaqJEHt8NVsh4+oz8EgBLHuOJyiS+a3j
         83YZ/QSR0pEobAzVE3/5VwMVNVL1k7PaFFZrNJn1zwTeOlvNDDu04wuDOzOjxm02euU1
         tR/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :organization:from:subject:cc:to:dkim-signature;
        bh=VnsYAI9ZN9zVJAIgiBsb84bbY9EWS3zR+ILQZL/U3uA=;
        b=rEnniFiKph17ikGCNtccznb/L303ESMTmsSeYhMOkF5g16SRGzyK7CRVdFOiQBJwD4
         HS2bbS4N/9t8AJWdcNonb7dftejZv7Aq4sfVeYKb/JkcoqscyAsB9VhEfookk1kiJ/jI
         UzXft9BCAG2YSdcI4YefC1SgNlyCR3yost1v7/nbzL2+X5zkR0VRc1u3ca28Q8JZaOPR
         iOGO6VjjnfC3i30vzfRWmP53BLYLG7Mh7/26H/SVsvPQ06gWEoeDAcr/btIQ+8+IFtfu
         su+SUxBbqLdgBIMQvUAn9HkarwnjEtbjT9e1eI4bpC3dGTQcW41E29e5Hh31Y/KgzCem
         P8Ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=o7iRymlM;
       spf=pass (google.com: domain of martin.petersen@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=martin.petersen@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id c24si34171209plo.220.2019.04.29.04.36.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 04:36:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of martin.petersen@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=o7iRymlM;
       spf=pass (google.com: domain of martin.petersen@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=martin.petersen@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3TBTGpW161561;
	Mon, 29 Apr 2019 11:36:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=to : cc : subject :
 from : references : date : in-reply-to : message-id : mime-version :
 content-type; s=corp-2018-07-02;
 bh=VnsYAI9ZN9zVJAIgiBsb84bbY9EWS3zR+ILQZL/U3uA=;
 b=o7iRymlMtfbbOGsumicBT986h1iCmQts5STzmDGB2qRLj+90ubE3RPKHzE8xxb4TI0H5
 iUdv6vQ2VPc6TVI1x3/GXeCFCv6lKEq8RhiKLkS709XD0+9Ff7rG1YaDGZ99P/p3qjiP
 yawzvuSJEK6C+x74iRf8rh8Lvhc6C3zwrfcwKKBI8o0+q3pY0Dc/I5yb1F4Jgbc7Et+K
 MXtcZLwcVo9+FcL/1fSpK9mJ+wZYD6rpWb4yzYjWNR91k8yM8ncTqopJmm+iEdxLpXQt
 y4MSxhQqmeJNwM0HaXg2uzKSSxjthHCA1xWwcoZ9TH5aOtAKmf1ZxDZNbx9D63Pa1IJx tQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2130.oracle.com with ESMTP id 2s4ckd604c-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 29 Apr 2019 11:36:23 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3TBYrbu115467;
	Mon, 29 Apr 2019 11:36:22 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2s4ew0m9m9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 29 Apr 2019 11:36:22 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3TBaI0I011719;
	Mon, 29 Apr 2019 11:36:20 GMT
Received: from ca-mkp.ca.oracle.com (/10.159.214.123)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 29 Apr 2019 04:36:17 -0700
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Vlastimil Babka <vbabka@suse.cz>, Jens Axboe <axboe@kernel.dk>,
        lsf@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-block@vger.kernel.org, linux-mm@kvack.org,
        Jerome Glisse <jglisse@redhat.com>, linux-fsdevel@vger.kernel.org,
        lsf-pc@lists.linux-foundation.org
Subject: Re: [Lsf] [LSF/MM] Preliminary agenda ? Anyone ... anyone ? Bueller ?
From: "Martin K. Petersen" <martin.petersen@oracle.com>
Organization: Oracle Corporation
References: <20190425200012.GA6391@redhat.com>
	<83fda245-849a-70cc-dde0-5c451938ee97@kernel.dk>
	<503ba1f9-ad78-561a-9614-1dcb139439a6@suse.cz>
	<yq1v9yx2inc.fsf@oracle.com>
	<1556537518.3119.6.camel@HansenPartnership.com>
Date: Mon, 29 Apr 2019 07:36:15 -0400
In-Reply-To: <1556537518.3119.6.camel@HansenPartnership.com> (James
	Bottomley's message of "Mon, 29 Apr 2019 07:31:58 -0400")
Message-ID: <yq1zho911sg.fsf@oracle.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1.92 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9241 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=681
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904290084
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9241 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=704 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904290084
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


James,

> Next year, simply expand the blurb to "sponsors, partners and
> attendees" to make it more clear ... or better yet separate them so
> people can opt out of partner spam and still be on the attendee list.

We already made a note that we need an "opt-in to be on the attendee
list" as part of the registration process next year. That's how other
conferences go about it...

-- 
Martin K. Petersen	Oracle Linux Engineering

