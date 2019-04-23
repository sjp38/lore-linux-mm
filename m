Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10069C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 13:37:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF65C21773
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 13:37:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF65C21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.vnet.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62F446B0006; Tue, 23 Apr 2019 09:37:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DD906B0007; Tue, 23 Apr 2019 09:37:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CF656B0008; Tue, 23 Apr 2019 09:37:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F3EB56B0006
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:37:07 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z29so7985335edb.4
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 06:37:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=B7tJqxoVScgp1Grf6BrLUr/PlHCshNQKutEkz7Hq354=;
        b=L17ri14G7SS61RgUWah8U6wzKRAjvPhOq2measQDCao9UqH2Np0weLdBs7IgFjYiND
         UvDcOlCLv9UbNP7CnmS+PQFw/0Ao+qVKU7q339V/Zqs7cQG7tFBqvhmzQMjfFN2yXDJI
         tY6Nm9EpGryvS247M+cVMIA01vayMl6oTejljUlSAjRMGtO2yrCYqrYw4NsP3tXHVeX0
         Q8dw+ZPE8Lt2YtnaNEQ7zhODmeW7TVO7JHCTekOkJnBDWFMngfagKe5WTjVZZAt6c32S
         cEynxxlPWz2w/N9Vu3tUjilaFDQb+WQ6+6i7wbwQu+OFPxzYEMYcRAhQ+djjfK82bOMU
         ByFw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of ldufour@linux.vnet.ibm.com) smtp.mailfrom=ldufour@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWolQXyEArTE1wGyB+gFVaqBI+V7ThVmN04p7oftiKggQD+WtFp
	u8OzNvJllYNKDNu/4Cl8uEKIP8Bx8GqXXIfP43AZzEqJ1uGccIkyR4rKycmiRtWpvnQaBQWJvPK
	gx7Rm5rwi12jKPR9vX397wwNSdddr0pmAfIReGpMQSuKAvst8NAStM2DPOha7sdA=
X-Received: by 2002:a17:906:724c:: with SMTP id n12mr842583ejk.192.1556026627473;
        Tue, 23 Apr 2019 06:37:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxp3BIzdCrliIfuHOYugxhKpHoKxetgYX0/AAXPuY1LswW4PqZTKOdNU4K2WtyOF0/0KR81
X-Received: by 2002:a17:906:724c:: with SMTP id n12mr842542ejk.192.1556026626549;
        Tue, 23 Apr 2019 06:37:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556026626; cv=none;
        d=google.com; s=arc-20160816;
        b=Vi0GbSNsRgjeS4bbWbOAXOT3PqMKSnN7hezwD76eyKcNjZVly533bOj7o8/5PrvTmv
         adr4vlI7b6s+SLqHND9lqbPIA75BeIlFqWe8+bM4LeH8g99X+WF6/+5WgviT2Im2WXR7
         v9MD2GIJz/eeBa5Vq/IWZH8FlmN3z9ebXr2p09iPTeZRiMYf+boHn+SDuUZpu5HhBvSY
         X0y+4zZWLzbFY9KlOdujVDDK+4IjAxTml0qIZNNQ7iiCdQw4JuATKkoEnJXxJSUZ0Pzf
         /ZHs5TNlsXs0yva8YdwWOpZEEjGWl8p61tB1uQeJvFSGfk6dYCULMcm+Ah+E4Q6QMPTr
         ZQQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=B7tJqxoVScgp1Grf6BrLUr/PlHCshNQKutEkz7Hq354=;
        b=TCxDzNBOGFDSrTwI1XdQ4EG5L/25scQ3mC6lXmORUoDQZ0MKQyOX9Esa1acVxyK5q9
         hgOTVUinD7v7VEgvQ1Fe7d/s9t3TOZHlglNLgsygYyZm/6cedI/xuLZmZE+TP3YvDpl9
         WI6h6ObsU1tVLrXNyMBPjaciG1P9Cb3H+tYwLy/YCPW3meNDZgo8XSkrEQbQakaJSTOB
         E0HoI0fozVNowSJOGDOrxbhgCg/78BQwax5zuBSTA8iJDdiyXBbC5dzx0KNS76+DTl0L
         Ru9hw9xlY9ATH0iYMbW+zno2a9e+tz16lnaPWHCgc6XrCb9JLJH5sMSi+JdAnezpq8o5
         C5iw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of ldufour@linux.vnet.ibm.com) smtp.mailfrom=ldufour@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g48si1597741edg.290.2019.04.23.06.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 06:37:06 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of ldufour@linux.vnet.ibm.com) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of ldufour@linux.vnet.ibm.com) smtp.mailfrom=ldufour@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3NDV6he082494
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:37:05 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s22r42yvd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:37:04 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 23 Apr 2019 14:37:03 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 23 Apr 2019 14:36:58 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3NDav3t34668690
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Apr 2019 13:36:57 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BD4134204D;
	Tue, 23 Apr 2019 13:36:57 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 03C0142047;
	Tue, 23 Apr 2019 13:36:57 +0000 (GMT)
Received: from [9.145.7.116] (unknown [9.145.7.116])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 23 Apr 2019 13:36:56 +0000 (GMT)
Subject: bos
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        LKML <linux-kernel@vger.kernel.org>, rguenther@suse.de,
        mhocko@suse.com, vbabka@suse.cz, luto@amacapital.net, x86@kernel.org,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        stable@vger.kernel.org
References: <20190401141549.3F4721FE@viggo.jf.intel.com>
 <alpine.DEB.2.21.1904191248090.3174@nanos.tec.linutronix.de>
 <87d0lht1c0.fsf@concordia.ellerman.id.au>
 <6718ede2-1fcb-1a8f-a116-250eef6416c7@linux.vnet.ibm.com>
 <alpine.DEB.2.21.1904231533190.9956@nanos.tec.linutronix.de>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 23 Apr 2019 15:36:56 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1904231533190.9956@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19042313-0008-0000-0000-000002DCBE43
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042313-0009-0000-0000-000022490F58
Message-Id: <4791a72f-901c-59cb-0553-5c32e26423f7@linux.vnet.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-23_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904230092
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 23/04/2019 à 15:34, Thomas Gleixner a écrit :
> On Tue, 23 Apr 2019, Laurent Dufour wrote:
>> Le 20/04/2019 à 12:31, Michael Ellerman a écrit :
>>> Thomas Gleixner <tglx@linutronix.de> writes:
>>>> Aside of that the powerpc variant looks suspicious:
>>>>
>>>> static inline void arch_unmap(struct mm_struct *mm,
>>>>                                 unsigned long start, unsigned long end)
>>>> {
>>>>    	if (start <= mm->context.vdso_base && mm->context.vdso_base < end)
>>>>                   mm->context.vdso_base = 0;
>>>> }
>>>>
>>>> Shouldn't that be:
>>>>
>>>>    	if (start >= mm->context.vdso_base && mm->context.vdso_base < end)
>>>>
>>>> Hmm?
>>>
>>> Yeah looks pretty suspicious. I'll follow-up with Laurent who wrote it.
>>> Thanks for spotting it!
>>
>> I've to admit that I had to read that code carefully before answering.
>>
>> There are 2 assumptions here:
>>   1. 'start' and 'end' are page aligned (this is guaranteed by __do_munmap().
>>   2. the VDSO is 1 page (this is guaranteed by the union vdso_data_store on
>> powerpc).
>>
>> The idea is to handle a munmap() call surrounding the VDSO area:
>>        | VDSO |
>>   ^start         ^end
>>
>> This is covered by this test, as the munmap() matching the exact boundaries of
>> the VDSO is handled too.
>>
>> Am I missing something ?
> 
> Well if this is the intention, then you missed to add a comment explaining it :)
> 
> Thanks,
> 
> 	tglx

You're right, and I was thinking the same when I read that code this 
morning ;)

I'll propose a patch to a add an explicit comment.

Thanks,
Laurent.

