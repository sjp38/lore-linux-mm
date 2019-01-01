Return-Path: <SRS0=ID2a=PJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55F4AC43387
	for <linux-mm@archiver.kernel.org>; Tue,  1 Jan 2019 03:28:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFDF22080D
	for <linux-mm@archiver.kernel.org>; Tue,  1 Jan 2019 03:28:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFDF22080D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1308F8E0006; Mon, 31 Dec 2018 22:28:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E0AE8E0002; Mon, 31 Dec 2018 22:28:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EED0C8E0006; Mon, 31 Dec 2018 22:28:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A81BA8E0002
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 22:28:19 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id r9so30188786pfb.13
        for <linux-mm@kvack.org>; Mon, 31 Dec 2018 19:28:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=R2qZDoT70Zu2X9/alWDRbiHk6g+ZxG2uWIdVW5Xe5nE=;
        b=nBes0Uje3MAIg5++HpNiqxzmE364ufgqmYAbCzAqugvXAIfhl/k3PoMlQoUOhcNNU8
         Skcabh4SjDZs18lMwk93WtbHIoyW7ab5wY/Zb0EH4mTT/PCeqEK3tvHPg7Jyno+xEjk2
         PH2fXZqDT9br1TBI86y1ItMweiE0yVmjbSRVODGm3bRhHeQ0sMaFqB5nIdgZgrnoxR38
         fKreQ3TU0DN6PnpfMIGKgxJCBuP6T4Wms9o8u34kJPR4BtAVm8Uv7Ra1OdvXna4suGKF
         txGm9/hXtenfQXSYLAuZxtAGaK9AK1dkLrg9S1MH0IN/hvVX0qjzNNMwsm4kSVYwfFtR
         bghA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AA+aEWZky6IutwvHx8cVlcC8U+0rIl5mTiivmuaInM8TQTGN0mTuPYLX
	ngbIKwjAlaGA77QPWcVxqAgDvtp8y9/Es8BaeTtirXLUZZ1nzq72d1cknNj0AcLPTcojMW2cg4I
	g5Sk3R4Fv12T1pPMdcmbAGT71lDRJKe8wTkx6MMTeObrGHmIXUSH9Bu/svl70f6FkgA==
X-Received: by 2002:a62:a1a:: with SMTP id s26mr40238094pfi.31.1546313299114;
        Mon, 31 Dec 2018 19:28:19 -0800 (PST)
X-Google-Smtp-Source: AFSGD/XEl6EE1Fm9yJr4kJoH5bmqxVNb10WWb/ausJUODYGiuJtZcbL7xQyrcD+DtOx6qvNTSSeH
X-Received: by 2002:a62:a1a:: with SMTP id s26mr40238056pfi.31.1546313298296;
        Mon, 31 Dec 2018 19:28:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546313298; cv=none;
        d=google.com; s=arc-20160816;
        b=R2ivfM0syRy6MdtvOTjO+atNGftWDu50X9GYjshODC2I9bl+5XOkVqtpQBYJPzY1kS
         aZCB2LSMHxPIogR6kd/vP81rSE2sVg1eWfTJhglyYt/Lnob7KTNnIqKs5B0Q4ZFvJRXc
         ZOAhCpG2hUYJbx8tr1us02tfZZXYCWP6ar7Ucsl5Lo7ub1wC76LJxlr7ZI12P3uIyxPd
         CwuMJa/iuH2OaUmyTMowM1XQpc2JyF6BdDC+YOBja51wVk+7hz8cHGWem2+A/xyLAX/x
         rmQbeWZuW4grQFd89lPOgJb04nu15KpbHB7khmf6EQnM3BK7ON3fvNkPHrsHx+aBVyjy
         0aSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=R2qZDoT70Zu2X9/alWDRbiHk6g+ZxG2uWIdVW5Xe5nE=;
        b=YSsaxPNPhK5baVlJNuWL5hwPMc5ZqYqbJJYQK2QOZ1x2ZYDWvHUZYBVYAC6GO8D7iH
         NApSNE1QpE+WlNo8T7/MiAGKLVHFvmsoW+TBqTOc9+0UtLP9KbfIM8IluMhvHdwgPiSF
         EBYwIDOTNK6iyokIpSktqc94RulG12v5rrO77NP0Ay3STt+KT1Brj75BGAO6/9Ns9Ib4
         mU7k/rzUl584oyN5Jjfq+UJYZteOzjkf8+8PAUjKAE6Pk+R7ftWDKnmH38tgZkKs063b
         LPvPpKvUjJKLb2mjitQFKP0hvSaemD4qFADpiDzR7CYOFUp29anHEM0kf42XcZkx/iEy
         8EDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p4si13626206pli.432.2018.12.31.19.28.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Dec 2018 19:28:18 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x013OcVQ123356
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 22:28:17 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pqtnas7vk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 22:28:17 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 1 Jan 2019 03:28:15 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 1 Jan 2019 03:28:13 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x013SC1j59572470
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 1 Jan 2019 03:28:12 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AA67C4C040;
	Tue,  1 Jan 2019 03:28:12 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A3DE44C046;
	Tue,  1 Jan 2019 03:28:11 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.88.250])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue,  1 Jan 2019 03:28:11 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Matthew Wilcox <willy@infradead.org>,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Introduce page_size()
In-Reply-To: <20181231134223.20765-1-willy@infradead.org>
References: <20181231134223.20765-1-willy@infradead.org>
Date: Tue, 01 Jan 2019 08:57:53 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-TM-AS-GCONF: 00
x-cbid: 19010103-0016-0000-0000-0000023E0CBE
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19010103-0017-0000-0000-000032970CDB
Message-Id: <87y385awg6.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-01_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=865 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901010029
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190101032753.TOYPrhwk6NwKgj-AC7Y3ORlWKOf0GwgQPOG66RH7LLc@z>

Matthew Wilcox <willy@infradead.org> writes:


>  static inline unsigned hstate_index_to_shift(unsigned index)
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5411de93a363e..e920ef9927539 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -712,6 +712,12 @@ static inline void set_compound_order(struct page *page, unsigned int order)
>  	page[1].compound_order = order;
>  }
>  
> +/* Returns the number of bytes in this potentially compound page. */
> +static inline unsigned long page_size(struct page *page)
> +{
> +	return (unsigned long)PAGE_SIZE << compound_order(page);
> +}
> +


How about compound_page_size() to make it clear this is for
compound_pages? Should we make it work with Tail pages by doing
compound_head(page)?


-aneesh

