Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98649C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:05:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B6872084E
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:05:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="WTdZ/AER"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B6872084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D60AB6B0010; Mon, 13 May 2019 12:05:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEA376B0266; Mon, 13 May 2019 12:05:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8CFF6B0269; Mon, 13 May 2019 12:05:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3296B0010
	for <linux-mm@kvack.org>; Mon, 13 May 2019 12:05:11 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b8so8633639pls.22
        for <linux-mm@kvack.org>; Mon, 13 May 2019 09:05:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=iQOB5KRWAw5aCrq5NScPGP6m3rv8ZkXQhJVOUTIv/ts=;
        b=GsNznHwqAgDEWfz/BB8DZBkLjvXmNXmeDbbSRy/5/jJH77aorIAHt/7bihhuXKfSWT
         qIzuZlqvqzHFK0knFf1r4lTYCJKNWuXMfSeXTNaGnudJPOjdDUYy5YDerSYWSzDExXhA
         nGwW9AEMF/bQ5DU3DQ/ZGZ/6BmGqgRtafiS8eU0fGF4Efvkd9zVTZFitCybkmXVzBbwY
         PgmqzJ7z/TJ+GTZVlyy8sj/n0hovcuAAKNznUVdyWJvl8mJ8Lxs/kLFZGYKZo9ZJOcTW
         CToo0jdfya/tVuPMhH6vp2W2XpH+1TLfBQ7Ufmvr/1Qt5CK1yM4Q5mCK46TS1R4YzC4B
         b6wA==
X-Gm-Message-State: APjAAAX/xRyJXVIjfkIoZXhULT5PewYdI18c4HiXzjNQ0l3zsJ+FRXVK
	1okardyJb3Y3zC4i9lPRWVbrNw+RaJK/3RK8QrpoBhsPM7gsGTsV85TAJccpDG5/vmb1UkLhZ68
	BEb+j0nz/9Vhfy/di6N5HmiAdarnovSd+NAOvK0IsNO3an2NqoOhh8timAB4b4vaglw==
X-Received: by 2002:a63:f315:: with SMTP id l21mr31887942pgh.417.1557763511203;
        Mon, 13 May 2019 09:05:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyObtiv0Qv+pDI0gwBJ+J51CNoiyfZr83rBZP1BT8u/YMsPpazK9FLoNG5NHpw1C+bFY8RR
X-Received: by 2002:a63:f315:: with SMTP id l21mr31887819pgh.417.1557763510440;
        Mon, 13 May 2019 09:05:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557763510; cv=none;
        d=google.com; s=arc-20160816;
        b=ozKcRPohuIRSz6oL3WqCKBowPyfJUuKs+z3aPa4dNcgZBzrUsPi17rDVTKyfJcxvNh
         z+Ybw1VUIUVzWKqWkJJidKUMMChlYb3MSjKlx2CAKgzCczVCRoCgy4HnShdHqSV9D/xJ
         GbI67/6MFuReXwqYwcbIEdvQa9+/YLllDTOYYu4BX70FgMoOLpLDkH+orv40Xp/XQ+O1
         azYN5ncRQSvpDkzAlYrAWBFZreXH3StmvQC2rzWMXtltg+enELE2rPxF6DqPj9nDOatr
         7fqq7S5+yJQAUb8VXwzyqEdWP4UrU6R72kpyU9w9f8tJN8cw0a+7YJzLeOceaKOhevg3
         E5bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=iQOB5KRWAw5aCrq5NScPGP6m3rv8ZkXQhJVOUTIv/ts=;
        b=N/5tEHEuljfyFmUF9AMIptr0s4xt0q3SwAh5irN8Cifz4HQyxzof4GoSXJhZCWZZPH
         DUoZr7lMgciYJv+1a2iAUAGIS4womQ/VKutbw/E6jLbuRG0pjrRFW89WgN37QMMml/CO
         O5WP7GLwWrhN/54B1j+uhFd4oCwhAuxgqRLbE/1rVsKeVeqwPUbD5+pPdzx6w4eiPWdq
         XtITjuxN39Dk2TAGK54R633aHgHtOhQpDfHUswNO3V4amk/ET7fWuzrflQbTR14WVKy5
         szJYw70jCAGL3f36ofHBlsXHIybFSs3bm3OwxMH3zPAiKE97U8cPlaoo+NIv/9VTtxeY
         1FNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="WTdZ/AER";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id q23si16999560pgq.246.2019.05.13.09.05.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 09:05:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="WTdZ/AER";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DFs3dw072771;
	Mon, 13 May 2019 16:04:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=iQOB5KRWAw5aCrq5NScPGP6m3rv8ZkXQhJVOUTIv/ts=;
 b=WTdZ/AERAY8uumxJJXYsPTnreT70nlTdVm2Uk+gpoBLOvefKgPXnZt9lMTEMJFC7AElo
 brnBgKufzGI6G7SdHRYtY9DNe1fPL/lr6yYBtqTq1NwJweBx96/lEPw0gXQDChYYuGac
 U23W2zUNgmJsl+a+kAph+SzIcbarXxPaSKnGTuApMEm9SALHEWk4vYdLv6/q4htUkhgF
 WE7JQ9OasaE8W8U4eHRDazsIYBZLsFHVvieWyLy4O0VCbRsaFoOYmSRDO8ige/yanJ96
 5o2bnR09qlNx9ZES5yobQvJ9oT4iiJzAV2mUdyrP8YoQNhZQX7fc7kZ/sA0B/Dpf0nCT +g== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2sdkwdg9ek-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 16:04:52 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DG4975087318;
	Mon, 13 May 2019 16:04:51 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2sf3cmrhbq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 16:04:51 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4DG4mrx011596;
	Mon, 13 May 2019 16:04:48 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 13 May 2019 09:04:48 -0700
Subject: Re: [RFC KVM 03/27] KVM: x86: Introduce KVM separate virtual address
 space
To: Andy Lutomirski <luto@kernel.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Peter Zijlstra <peterz@infradead.org>, kvm list <kvm@vger.kernel.org>,
        X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        jan.setjeeilers@oracle.com, Liran Alon <liran.alon@oracle.com>,
        Jonathan Adams <jwadams@google.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-4-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrV9-VAMS2K3pmkqM--pr0AYcb38ASETvwsZ5YhLtLq-9w@mail.gmail.com>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <8dba7da4-8087-1d80-5b60-fe651a930bb8@oracle.com>
Date: Mon, 13 May 2019 18:04:44 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <CALCETrV9-VAMS2K3pmkqM--pr0AYcb38ASETvwsZ5YhLtLq-9w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905130109
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130109
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/13/19 5:45 PM, Andy Lutomirski wrote:
> On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
> <alexandre.chartre@oracle.com> wrote:
>>
>> From: Liran Alon <liran.alon@oracle.com>
>>
>> Create a separate mm for KVM that will be active when KVM #VMExit
>> handlers run. Up until the point which we architectully need to
>> access host (or other VM) sensitive data.
>>
>> This patch just create kvm_mm but never makes it active yet.
>> This will be done by next commits.
> 
> NAK to this whole pile of code.  KVM is not so special that it can
> duplicate core infrastructure like this.  Use copy_init_mm() or
> improve it as needed.
> 
> --Andy
> 

This was originally inspired from how efi_mm is built. If I remember
correctly copy_init_mm() or other mm init functions do initialization
we don't need in this case; we basically want a blank mm. I will have
another look at copy_init_mm().

In any case, if we really need a mm create/init function I agree it
doesn't below to kvm. For now, this part of shortcuts used for the POC.

alex.

