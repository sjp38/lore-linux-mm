Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01FEAC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:40:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACA1822CB8
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:40:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="IPH/9AVY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACA1822CB8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CB278E002E; Thu, 25 Jul 2019 01:40:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 453D78E001C; Thu, 25 Jul 2019 01:40:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A62A8E002E; Thu, 25 Jul 2019 01:40:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0ABE18E001C
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:40:07 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id s9so53681907iob.11
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:40:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=DIaad5qbirnDkeKlUJE4RYRnrPGQKiec4THTqLDSXrw=;
        b=Rt1WgLdfnZxO5MgY0rBFGNhwtHMWiNeTLKh1L9WQW/Zbqxc2lGgmdd1q3T/pfrVk6+
         VsB5H5cqUdIU2DDo8DSNpTsvmp93aszglu7iPrA1nXbCxYcNZa1A6WDeeXZUI1BIipxB
         Dx1G70mY0G4bSyQHlrOrgCCI1Sp0Z7CfQWxp1pMAs+9uayoaBohqdBYtIRZYHP33wuHb
         OMCo6izWrMU4YzWO6Wg+iiXOBnR7zl6/vA5tqLynDPTNDeHsAo4Y954EA2bFfUayF91v
         lhYSXHvqRLjaBzPuZKjsrxgr0deaj4Ee8WHPZfXMIDYXjF53e+h/9r4zJHPPIhemS7HA
         qF1g==
X-Gm-Message-State: APjAAAX1p3BRaJaYYnviirPyqsjbFC1rYTvwv7hGBeZ8OsNvNv/XwtI6
	RKrW5od1O/jlnkHtKcAqHlnope7Mb+NUlhYeRPdkbYX0hq0KNaQilMyBVBCfyA3jOkVtBs64F2t
	8OlTxWczgFgRTI9vczrzb8froF1ER+J4FXhrSEtX8GZPsWnXBKyDPAhN4a+NcixIF/g==
X-Received: by 2002:a02:cb96:: with SMTP id u22mr89267790jap.118.1564033206766;
        Wed, 24 Jul 2019 22:40:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqza+3NLDWbiMRz5qrdc+E2FB9IIo91iVMO72H3TdEMz6Pl/Teh3RQ4WWMVrEVBrHovW9X41
X-Received: by 2002:a02:cb96:: with SMTP id u22mr89267771jap.118.1564033206284;
        Wed, 24 Jul 2019 22:40:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564033206; cv=none;
        d=google.com; s=arc-20160816;
        b=qhYWFoPAM5kfZNdQygu7H7RZfwXpdWb0W+gVtA0adt1ix4sXUyVqjGna9F2DRhsxPi
         PWrEWIJL8V3rxHA/KLspTAw8E+egLO/CHCUq7cM7ejg3DQo4SSvoWTb4DC7tOO6zZnl8
         q3olnFcUD+NPYzDDkhSDdtAWnn30Z1Dx519guGLXNf+SKpNwVOkAXZgWPVwdfM9XQPeS
         7I3mIBOn1TWuhYTGgq0/1H01rNsjsTyFM4EFd6C50V3Jp/f0DY7KwKImETgpM+kPS58C
         EG19wf9hvame27PUb2RIEqw79ctQP3Inbof/bCHOwD+M8tSG23eWXbRDTtHyQwt73p65
         hOAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=DIaad5qbirnDkeKlUJE4RYRnrPGQKiec4THTqLDSXrw=;
        b=j2RU2lIuYGrh1V+hF2CXL10cWKXzZ1evLcYYHlm7KeT9uiF8k1N7lSoA3rKtaQJIvc
         O1p5IqZ9U3QGm2k9sZcqkusw3QYtJ90ouSktSlQ1JiI8zad6f1ZHwitFCfNzaOTONnpS
         JSN1eGqiJnhWMMPDJZ89TQsVSy42TD9vZwcBeilKI9pOtNYDhS+PRTizxb9l9NrVR0Ft
         baNY9EOjlWKeIJ+NwRLyJvPR9SG5vV9FvPDxmvJ3NbH07G04QNP5utuDSA7SlMrQX7wS
         Yd13Klylq7wooSDKNK+J8RU1ZL8t4HjurVvMpQWweaWxz35P6dE9h9E9XUITovlK7nV/
         pCKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="IPH/9AVY";
       spf=pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id g25si71075959jam.35.2019.07.24.22.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 22:40:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="IPH/9AVY";
       spf=pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6P5d0Xf078656;
	Thu, 25 Jul 2019 05:40:02 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=DIaad5qbirnDkeKlUJE4RYRnrPGQKiec4THTqLDSXrw=;
 b=IPH/9AVYiWVzq6wlgvo3F/88gUEHhrUGkzLM6HKQ3AmDJPgJ8FW1o+LAKoVFyJLNsUwb
 zsrH29WQGuIYFvvrTct1noJAWGP/8qtGXRkEr+gewJ/1f2dvoFCOpy3i9lZck/YnIK61
 jNr2CX38esOUkjQUYt0LsFbgzuHJIPziZ8qxVU66qow2iB++jbx1iY41Mr0DwIl6QHCA
 2ANpXPrK4JxlnkWQcrPaFf2m5BynwVihkJd0W4F9mSDy3r9CxoRka8aPoGoJUb0uyHbS
 YDvkMJudKzqg3boByZ4sZ9HKCuCpRp//23F3sY3O6NEQ4bNxLWaol7M+3AEhbFvKISaY NA== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2tx61c1f6c-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 05:40:01 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6P5bmEi117255;
	Thu, 25 Jul 2019 05:40:01 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2tx60yn82x-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 05:40:01 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6P5dxBH003035;
	Thu, 25 Jul 2019 05:39:59 GMT
Received: from [10.159.158.5] (/10.159.158.5)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 24 Jul 2019 22:39:56 -0700
Subject: Re: [PATCH v2 0/1] mm/memory-failure: Poison read receives SIGKILL
 instead of SIGBUS issue
To: Dan Williams <dan.j.williams@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Linux MM
 <linux-mm@kvack.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nvdimm <linux-nvdimm@lists.01.org>
References: <1564007603-9655-1-git-send-email-jane.chu@oracle.com>
 <CAPcyv4iqdbL+=boCciMTgUEn-GU1RQQmBJtNU9RHoV84XNMS+g@mail.gmail.com>
From: Jane Chu <jane.chu@oracle.com>
Organization: Oracle Corporation
Message-ID: <fa353250-2ea2-3be3-5e4d-1ccf7dc06014@oracle.com>
Date: Wed, 24 Jul 2019 22:39:38 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4iqdbL+=boCciMTgUEn-GU1RQQmBJtNU9RHoV84XNMS+g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=986
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907250067
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907250067
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/24/2019 3:52 PM, Dan Williams wrote:
> On Wed, Jul 24, 2019 at 3:35 PM Jane Chu <jane.chu@oracle.com> wrote:
>>
>> Changes in v2:
>>   - move 'tk' allocations internal to add_to_kill(), suggested by Dan;
> 
> Oh, sorry if it wasn't clear, this should move to its own patch that
> only does the cleanup, and then the follow on fix patch becomes
> smaller and more straightforward.
> 

Make sense, thanks! I'll split up the patch next.

thanks,
-jane

