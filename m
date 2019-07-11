Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B899C742A2
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 20:17:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38A4F21537
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 20:17:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38A4F21537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC1EF8E00F8; Thu, 11 Jul 2019 16:17:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C72C08E00DB; Thu, 11 Jul 2019 16:17:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B131F8E00F8; Thu, 11 Jul 2019 16:17:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0E08E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 16:17:27 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id b188so5984773ywb.10
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 13:17:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=qziThXBBDBww5HpD4tsDVFG8ojwFCeNQs2KfyoG9baA=;
        b=n1rvpo9RmXkmjFC30NlP0GSjOBEtrAoHChjIqwZl/EgFQPTVdcKy3Kc+V8pO3g0kk4
         oBXsDQ3lS6NFUMdH2/8Cahm+I5hJb/c1Q69kywdESPxGtxiNVXXIgHFBXNAqVBDmUOdZ
         jvbRkGXjBc5rHfizl6zdsBLL3Or0AWDl+U8Eb0XU8wA8PDPeUK/dI3/QjUwUsJxnGYkN
         DZSuNfvvjTxt0KMYAJKI94fVNZerHHLHcLOT+tKFBA0KZ44b+y/K4HpzTq1Y6K23UAEl
         QTvniQ5SxVppmqOvKrTpn1lMxclcIleDU6/VixSUL/0llR8CQRkAWM70zDZgm8KRgJ+D
         FIrA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXFYElPoZlgta8x8md0fkg3PUx2Mjmvr4+2Ls52k/DMKEX8Pd7L
	VzHkMgMgi37+LJCTfjO6VuBY8sBCjcuOaCAwHdfxPZXMTHq01c1PwW/FHLwXfiRCgmz4NBvRxqH
	bISIl2z6NbMC7PS954lcn0gu+2ZukW1vlYVQPD6VFxtcgwARwmhqyurf1MrsXIujqeQ==
X-Received: by 2002:a81:3795:: with SMTP id e143mr3608030ywa.508.1562876247353;
        Thu, 11 Jul 2019 13:17:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw31p5MqTsZO/G7WMo+lWegoR00FrHD6hqmHRdVv7sNcfrIcTRrWjRbFRkZiFlM+6w1OAVD
X-Received: by 2002:a81:3795:: with SMTP id e143mr3608000ywa.508.1562876246794;
        Thu, 11 Jul 2019 13:17:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562876246; cv=none;
        d=google.com; s=arc-20160816;
        b=nOAY03/CI7kYYHRwDpGXn/7JLutbMYT1+QUVZsOtRf3JxtjUTsuTS3vTrvZ0qu8Ht0
         qfMIO8HapoYPV+ttwbv4j8hZGP1SlpQCkXGaLGt6DZy032MzBXFXvf2QM/sIkl4KZXQX
         0T+zSi7czsfRdS116Tt0it5S1soGrRaU3Z+EMEVgUpGT2ASvGGfwf4vOrgmHzu0199Hl
         YeooRrsHRt7NRKzeiUnh42XU6t6Li8a9UFQn97ph97N9VKe+yYq6el9FrrOVzIRlPGVU
         DQr3/gEgxQn93kYDKeQuDoS0ecqaIHex6qrwpea4BwE+8d2mNt+tq3PI3SEWq8uO7Cmq
         xVog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=qziThXBBDBww5HpD4tsDVFG8ojwFCeNQs2KfyoG9baA=;
        b=omGtYHrlwJy3LGoXbNLHqv7bYEWhJlWp+JA5VYhZyw6yMuTwN0eqFn+cQ5lX2occch
         WkZNSWL3cPFBfwJxAx1MLF+Kgy/IwtTSCguzTalZDJ7igb1mLnwmL9JM0y+14LF5NDV1
         aawYF9DPzk+mWyurkEq5Zy+rOLIC6IDAmcytH1r4UVACpOBQKk72zeY+MEyOhIBNNt9v
         4u5E8F3lRSUJojxiNPAvdtjTJ6MiEnVbhVxST5q9pjtpItCJaemc1s1G4vFCXVnFLrem
         gYPD2mJI//S136+y/FbfgVAABYJ7LD88gZhg6vZfdcHxeynW27nQ/x7/cXaQaOVM635Y
         r/aQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d22si2480119ywd.42.2019.07.11.13.17.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 13:17:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6BKHOOm103739
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 16:17:26 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tp960q4un-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 16:17:26 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 11 Jul 2019 21:17:21 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 11 Jul 2019 21:17:15 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6BKHErw49217562
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 20:17:14 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4BFD152052;
	Thu, 11 Jul 2019 20:17:14 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.152])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 2AD435205A;
	Thu, 11 Jul 2019 20:17:09 +0000 (GMT)
Date: Thu, 11 Jul 2019 23:17:07 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andi Kleen <andi@firstfloor.org>
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>, pbonzini@redhat.com,
        rkrcmar@redhat.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de,
        hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org,
        peterz@infradead.org, kvm@vger.kernel.org, x86@kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
        liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
        rppt@linux.vnet.ibm.com
Subject: Re: [RFC v2 02/26] mm/asi: Abort isolation on interrupt, exception
 and context switch
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <1562855138-19507-3-git-send-email-alexandre.chartre@oracle.com>
 <874l3sz5z4.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <874l3sz5z4.fsf@firstfloor.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19071120-0012-0000-0000-00000331E9C1
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19071120-0013-0000-0000-0000216B57DD
Message-Id: <20190711201706.GB20140@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-11_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=956 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907110224
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 01:11:43PM -0700, Andi Kleen wrote:
> Alexandre Chartre <alexandre.chartre@oracle.com> writes:
> >  	jmp	paranoid_exit
> > @@ -1182,6 +1196,16 @@ ENTRY(paranoid_entry)
> >  	xorl	%ebx, %ebx
> >  
> >  1:
> > +#ifdef CONFIG_ADDRESS_SPACE_ISOLATION
> > +	/*
> > +	 * If address space isolation is active then abort it and return
> > +	 * the original kernel CR3 in %r14.
> > +	 */
> > +	ASI_START_ABORT_ELSE_JUMP 2f
> > +	movq	%rdi, %r14
> > +	ret
> > +2:
> > +#endif
> 
> Unless I missed it you don't map the exception stacks into ASI, so it
> has likely already triple faulted at this point.

The exception stacks are in the CPU entry area, aren't they?
 
> -Andi
> 

-- 
Sincerely yours,
Mike.

