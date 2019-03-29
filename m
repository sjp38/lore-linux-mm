Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27E7AC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:31:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D40DA2082F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:31:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D40DA2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E4A46B000E; Fri, 29 Mar 2019 05:31:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 593E36B0269; Fri, 29 Mar 2019 05:31:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4835D6B026A; Fri, 29 Mar 2019 05:31:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 136E66B000E
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 05:31:58 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j1so1135475pff.1
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 02:31:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=LC/FqAiw4ofHRvWAswJncPs0S9pCTkcDuORTEyuEPLM=;
        b=ML9BYqdq17p017xCKD3g8OClGdb6DrW+06Nn3gi7HE1EU2Zzxmr3el7SmrB+2YCsrb
         xzk3H2g35X6NJ0GSm/RIRDxBuAg0L15DhIQknBTEGz4x2OyoMo4CeDx+p4nspiqk64DX
         zlQjQfvJZu9fJRmK+S8+4xDOr1VZPWM2sT5LQwRpWxtC5q3kwfdRT73L2Taw63HttIAI
         b9P5eDexkNFgcz2JZSPmdm27btJyuWeHmlatccvU15mAnDr5HbZZskQEEP/UIiuWoavj
         lcA95epxT93nhav6xIWBhF6dIIxxkl9i9ZyNjNLPwKdOqxNNqMPJhAQM+R3r4Bhh2hx0
         7yEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUlGU54VVtmW0IkxIxQy6l8mh80CWgjjpg8JAajF8yAvQ0pGlDA
	dc0A9bRdSWrHB7HjkwFbCBT5T8o5Y0vlNV9UeMbkVKNIjAyCjvE/hGh4J58vEKn0Q6s1S+xMGko
	qi7R+5P6rfqQes+XtVFSVwKlF6m29npbdLiIZVb9zgFm0bSo7HeD2QSI7r7h3eyJHZw==
X-Received: by 2002:a63:db14:: with SMTP id e20mr21149374pgg.437.1553851917741;
        Fri, 29 Mar 2019 02:31:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFbuFeMuH2cJJMMe4nTil18GgZTKNvSq9J2EjCYvukDQtP67o/6DJRFFp9T59G0HpUFlaY
X-Received: by 2002:a63:db14:: with SMTP id e20mr21149322pgg.437.1553851916951;
        Fri, 29 Mar 2019 02:31:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553851916; cv=none;
        d=google.com; s=arc-20160816;
        b=Tz1LSAkzRUiz4ba7IQFPUkHM+Ew5Ltt9ZEu5g9YsX2hMj6GGXmulyFPCo21W/UgD9b
         ZUduRQrPoSJ+3/7o7D1BUqAlQ1VT/FcfAAfAyNiH/USCIYFMTy7VxdBaSfdOb9T/ov7z
         NBBXi8MLqm/DlBPam7lcHpPei9Fue8tRieEEHxv2oHVR8NyOhKxO9CvVeBF4zR7gdVDP
         5vWcaqHC9yQrd7ZIcNi4HEP7VMDsbfYbBPBFG3rxLyRC7zLKw+FsOwKpI4Nishs/GS67
         goMHYJu0WzSrdVZ1Dr7I8+r8KexO27XLZR8rZVTrpO8KgUk8JUPcGlWWSJcPsDCVyV2Z
         72dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=LC/FqAiw4ofHRvWAswJncPs0S9pCTkcDuORTEyuEPLM=;
        b=MrMv0RQzI2it6E42StNdLIodks0vZ+VA5okc3k8B/KwtV0dSnfrGiVZ+oXdQRmEoy0
         W5ae/MGw37YH7T0qLvjhBMCcOHc2lpjVjonwO1SiM30UG/ANNpw5PxFhyBB2eYc1sYWP
         YqXeZhP1DTjGEbd1/oXt4AT+AUez1A5UkJH0sJik1EOK048Q6Yq89dCYRPtrOcUJa+wZ
         Bl0EzqeYhdU1P0TCnaDyWy9rSKVVBGUvUgcSkyNbqCSBRK50OVUlEYUrpZ4iFEIz2Ok+
         mAFkSi/Fx8nRCoX4Q4Zy8awgKNgs6ZCLWfgE70QLvNHenDZHK3Mb9ysClZMJTxPmH6nf
         WTaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 32si1505044plc.427.2019.03.29.02.31.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 02:31:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2T9OJsS127387
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 05:31:56 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rhecjr7kt-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 05:31:56 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Fri, 29 Mar 2019 09:31:53 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 29 Mar 2019 09:31:50 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2T9VnMG41746662
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 29 Mar 2019 09:31:49 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 49BC5A4062;
	Fri, 29 Mar 2019 09:31:49 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E5D7CA4060;
	Fri, 29 Mar 2019 09:31:47 +0000 (GMT)
Received: from [9.145.61.64] (unknown [9.145.61.64])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 29 Mar 2019 09:31:47 +0000 (GMT)
Subject: Re: [LSF/MM TOPIC] Using XArray to manage the VMA
To: Matthew Wilcox <willy@infradead.org>,
        Michel Lespinasse <walken@google.com>,
        David Rientjes <rientjes@google.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
        linux-kernel@vger.kernel.org,
        "Liam R. Howlett" <Liam.Howlett@Oracle.com>
References: <7da20892-f92a-68d8-4804-c72c1cb0d090@linux.ibm.com>
 <20190313180142.GK19508@bombadil.infradead.org>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Fri, 29 Mar 2019 10:31:45 +0100
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190313180142.GK19508@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19032909-0028-0000-0000-00000359ECAD
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032909-0029-0000-0000-00002418B0C3
Message-Id: <e2d4f70e-12c0-7bdb-131a-c916f0aab0a5@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-29_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903290069
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Adding Michel and David in the loop who are interested in this topic too.

Le 13/03/2019 à 19:01, Matthew Wilcox a écrit :
> On Wed, Mar 13, 2019 at 04:10:14PM +0100, Laurent Dufour wrote:
>> If this is not too late and if there is still place available, I would like
>> to attend the MM track and propose a topic about using the XArray to replace
>> the VMA's RB tree and list.
> 
> If there isn't room on the schedule, then Laurent and I are definitely
> going to sneak off and talk about this ourselves at some point.  Having a
> high-bandwidth conversation about this is going to be really important
> for us, and I think having other people involved would be good.
> 
> If there're still spots, it'd be good to have Liam Howlett join us.
> He's doing the actual writing-of-code for the Maple Tree at the moment
> (I did some earlier on, but recent commits are all him).
> 
>> Using the XArray in place of the VMA's tree and list seems to be a first
>> step to the long way of removing/replacing the mmap_sem.
>> However, there are still corner cases to address like the VMA splitting and
>> merging which may raise some issue. Using the XArray's specifying locking
>> would not be enough to handle the memory management, and additional fine
>> grain locking like a per VMA one could be studied, leading to further
>> discussion about the merging of the VMA.
>>
>> In addition, here are some topics I'm interested in:
>> - Test cases to choose for demonstrating mm features or fixing mm bugs
>> proposed by Balbir Singh
>> - mm documentation proposed by Mike Rapoport
>>
>> Laurent.
>>
> 

