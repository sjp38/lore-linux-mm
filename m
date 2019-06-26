Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C192CC4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:00:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FD40208CB
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:00:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FD40208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.vnet.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A6216B0003; Wed, 26 Jun 2019 02:00:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 156E38E0003; Wed, 26 Jun 2019 02:00:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06C9C8E0002; Wed, 26 Jun 2019 02:00:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id D92D36B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:00:17 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id k10so2735942ywb.18
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:00:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=ebCcSspas6nwuFe4Qx1xLvvGAPh/HEebf0TkVELkciI=;
        b=bGqcEryHcRiYT7t+pQBGaN0GGX7Q1wuPDBVuLzPCeRqetS23jmMVFBX52RhecRk+z5
         6qEqU5x5YvwoQA/9YkdU64s6eINsVK+E4QL5QiG0oC1wmlYlnItXVuSdXwEM1OSsMn+v
         iLFci77AwrwgqJ473VAujdt8rVGKfFdEg7TlDCmCx3aPzo61lKrnGj9YKLQdBchzFxtz
         GwxfzcEfSb5oJbK02sbxo/XLtPudYEgXR4oVZ952Po3iMzzPdGKghAx08mqRTFAaTOBb
         WsVfJpUBqwQOXAmronyJvYRgBIKgHCy1haZSLhnX+39tYyIia+crhAjFObXDf7bkbyfv
         3mqw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWMRL8CocCX2LM6Oio27+N63gaIcfez5iCrPr4WKhGEXNeuHDNs
	bJo5fyDjjYwwVJ75pn3FmGjwz/OM805lBevgZ5oVOQKW4qa5RomvPd7A9OE1TghvxYBfAW7WH1M
	ehh2X6G/ltah87rFY0ExqfiFc4+JY42omQ5mAEyjQ1hBlZ86Z2eMsYuYGJNLhw1Q=
X-Received: by 2002:a25:c68b:: with SMTP id k133mr1483477ybf.377.1561528817625;
        Tue, 25 Jun 2019 23:00:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjwutcbg/NWVe99zpIlmhgbGYwXXPechrxTKEQy1qI1QDX+lwYdNGx9kv+b03ptPqfM5pO
X-Received: by 2002:a25:c68b:: with SMTP id k133mr1483453ybf.377.1561528817162;
        Tue, 25 Jun 2019 23:00:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561528817; cv=none;
        d=google.com; s=arc-20160816;
        b=sZ3/QhEM7UKcQvSHX4opmnTHWZ7b/B8uPNVPSPZ6ZFBKSNSaFNpqu9e7/Yw0dg1OqB
         w1o94jboudCOBLJNMzvWVD5pxoBIcJ2UDxoYFkePa0CuB309Qiul9FJBKDvFqzIftcqO
         k7xHzrDEjJLNRbokPTUxX0NXhOugtP1/PMivSVs3HwGl4TyNDiMA2tbanwVKtWYcdD6G
         ZHVNxFBOShMfApjeVo91d7Il0+k79EMFBdNwZXthMYuN8P1n/H0DpEaGuf70naymcdda
         bUDcRL5htK04mIyUYt1aclLy2nK1PRznvfoXyPgY/Ec0PiY05ZPIPPAR+Pc8a+z2EjuB
         MZkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=ebCcSspas6nwuFe4Qx1xLvvGAPh/HEebf0TkVELkciI=;
        b=evOJrS1XG0ihaUqOweNAmMGIQ6nI7sGVgTaSbss5XRfT2aTQZfY0wh/sgTwKxCBIsF
         avnRyfYxwgJtcZVb58SUpEgGB4KNFA0bLTi3FIZYBBR/N1ulsHauXn1ZjQzXCQE1Z0Vb
         Ukks1EX4pgXo3f69glJZ+i0R/Y8UIvQgChaO5a+VL79hsQOzIeY1qIwVNEO0N7SQu1DD
         fN6Tgz6R/dcH+Udas50MEp9H1RUxyEmsU17n9xBkzfXQ/Sf5teLPSLHh2r906AA3nxb2
         Eb8dio/c2Or41sYNDSbCnNpSRfX7ykq7auqr/gaqwqEcxtKSe02NwJ8MHmpYxZVzxGKn
         94zw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g192si6879546ywh.38.2019.06.25.23.00.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 23:00:17 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5Q5veqo049643
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:00:16 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2tc2j1h1ab-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:00:16 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 26 Jun 2019 07:00:14 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 26 Jun 2019 07:00:11 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5Q60APB27197552
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 06:00:10 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 43B304C06D;
	Wed, 26 Jun 2019 06:00:10 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6BDD24C062;
	Wed, 26 Jun 2019 06:00:08 +0000 (GMT)
Received: from linux.vnet.ibm.com (unknown [9.126.150.29])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with SMTP;
	Wed, 26 Jun 2019 06:00:08 +0000 (GMT)
Date: Wed, 26 Jun 2019 11:30:07 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        matthew.wilcox@oracle.com, kirill.shutemov@linux.intel.com,
        peterz@infradead.org, oleg@redhat.com, rostedt@goodmis.org,
        kernel-team@fb.com, william.kucharski@oracle.com
Subject: Re: [PATCH v7 2/4] uprobe: use original page when all uprobes are
 removed
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20190625235325.2096441-1-songliubraving@fb.com>
 <20190625235325.2096441-3-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190625235325.2096441-3-songliubraving@fb.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-TM-AS-GCONF: 00
x-cbid: 19062606-0008-0000-0000-000002F7136A
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19062606-0009-0000-0000-0000226446C5
Message-Id: <20190626060007.GA9158@linux.vnet.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-26_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=772 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906260072
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Song Liu <songliubraving@fb.com> [2019-06-25 16:53:23]:

> Currently, uprobe swaps the target page with a anonymous page in both
> install_breakpoint() and remove_breakpoint(). When all uprobes on a page
> are removed, the given mm is still using an anonymous page (not the
> original page).
> 
> This patch allows uprobe to use original page when possible (all uprobes
> on the page are already removed).
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>
> 
Looks good to me.

Reviewed-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

-- 
Thanks and Regards
Srikar Dronamraju

