Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EAB7C606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:06:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AAB721670
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:06:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AAB721670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9FC48E0046; Tue,  9 Jul 2019 06:06:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2AE78E0032; Tue,  9 Jul 2019 06:06:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A3DC8E0046; Tue,  9 Jul 2019 06:06:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3258E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 06:06:18 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x18so12143922pfj.4
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 03:06:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=YoyQuqmchxXCtUUzb+0q+2pUVVyMZKEeOc8s79T91Hs=;
        b=c548VBKk93cBqIFfawLo9u2oM5QkAiz4jdJV0zSnneOj7XzL0Y5onrE6Ihuj32RWZU
         fkfaIPjSj4O4gQrzoYp+H2lfFlFSpc+AHSd6j8DAE3Zbf3wNEM0yqDn6YIRBpm4EGb2s
         wFBq2Er2i4Kb2QJSXxqEevJT8ZwMFBhX2oWH0xu8QxicX4V+pH8VAtFEGB1JzB5MOqZC
         uVNcdYvxvXlX2sjf2pP6ZVFMluqXuWm7+Dz2OlAtuHkgdlhBzfBB4zkPByycUYUwApQc
         EjaGTEoZgnYNGiHkQUF7nilDZB0MZXgADD7Ki2LQyjm6fdfszWQBlZGp+rHTYfHrWSUg
         z/fg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUxJhSAsyw8SojcHMLKCO6lqFOxAHX4rNr77ytrV1Ww5EMScN1y
	6JQ6cM+XAlLK2+U+BaR4jjKbU4HnlqHF3eVuvsDJJhvERWZURLlWHxOhRTXgUtgpMegTbiK8uc+
	NCRMlIRLmoObW6xprPqqzcgGvQ2SzNJuMESDj+699cGOjZsR89U+e4WC8hjG3t0F4OQ==
X-Received: by 2002:a17:902:8c98:: with SMTP id t24mr31765028plo.320.1562666777953;
        Tue, 09 Jul 2019 03:06:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTbUl/94RB4BSy+edtRnCgCFtNbZNzkmcHzcrfB4ox2ej6JH25i52QxqSEwmoaV4acmzoX
X-Received: by 2002:a17:902:8c98:: with SMTP id t24mr31764901plo.320.1562666776471;
        Tue, 09 Jul 2019 03:06:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562666776; cv=none;
        d=google.com; s=arc-20160816;
        b=WLobn+4CN9tpTPGSIx0Er158YmSf+ZeVydTOnhvNQvjVDINome4r14d9GqymjZBmPn
         LxThcV+hCgF1lbKcDgRuz5MGOsYZZTUSNcZuw6Jc7ek037i0H8YVX8lCQrxwMAQDmxNA
         q/rT7GXcC5PaHFToh2YsBXoFVNY5S/0kFA/ouFKgO+u6I2NPuzREdSMn1vIdcoHLiMFj
         jaJ7OfkDpI2T7lW/WGKX7qcz2LY435WnpER97OT/Z6ocItQngtHxzlGybU954mJrMVcK
         O/0MhkepStcaaneIHcIhhCK9In0njuMAbuOqlhwR6i4VeED7dHSrIU9+9VZUvOmlqwew
         WOng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=YoyQuqmchxXCtUUzb+0q+2pUVVyMZKEeOc8s79T91Hs=;
        b=iUoYgrC7GWnyM6g6qv0ggnuV1Zsma3HGtil+dGYl7NVAYbZeMOywwUscBNGnimDNJ1
         oQO5EM8/qRFRxdY4ePQ/0+eQICAtR+ZidlrMVwU9CqewJm1UL2zF5tcKwn79HvdOXrza
         trl1nOMoGduUVE3tPS82+n4arMf5aSeJB56rrO99w2pcnbl+YJqwt5abL1woN0G971U2
         Sz31+xGZoO309Fwb3Qlm1D7cGyuBWjoQDrvuSWS8S/m+igzDQzdVuartvHkgZNsW7FDQ
         czui0xlHV+t4I05Qi9MKqcg0jbIJeRjDUfGFUwbJEJK2xED71ZRo47qkHhaFxChGzVI2
         ng5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q2si22579857pll.230.2019.07.09.03.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 03:06:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x69A2VwT096453
	for <linux-mm@kvack.org>; Tue, 9 Jul 2019 06:06:16 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tmr3uj3p3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Jul 2019 06:06:15 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 9 Jul 2019 11:06:13 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 9 Jul 2019 11:06:10 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x69A5uIN39190860
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 9 Jul 2019 10:05:56 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E3D89A4054;
	Tue,  9 Jul 2019 10:06:08 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2346BA405F;
	Tue,  9 Jul 2019 10:06:07 +0000 (GMT)
Received: from in.ibm.com (unknown [9.85.81.51])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue,  9 Jul 2019 10:06:06 +0000 (GMT)
Date: Tue, 9 Jul 2019 15:36:04 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com
Subject: Re: [RFC PATCH v4 6/6] kvmppc: Support reset of secure guest
Reply-To: bharata@linux.ibm.com
References: <20190528064933.23119-1-bharata@linux.ibm.com>
 <20190528064933.23119-7-bharata@linux.ibm.com>
 <20190617040632.jiq73ogxqyccvfjl@oak.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617040632.jiq73ogxqyccvfjl@oak.ozlabs.ibm.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-TM-AS-GCONF: 00
x-cbid: 19070910-0028-0000-0000-000003824118
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19070910-0029-0000-0000-000024424CDC
Message-Id: <20190709100604.GD27933@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-09_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907090122
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 02:06:32PM +1000, Paul Mackerras wrote:
> On Tue, May 28, 2019 at 12:19:33PM +0530, Bharata B Rao wrote:
> > Add support for reset of secure guest via a new ioctl KVM_PPC_SVM_OFF.
> > This ioctl will be issued by QEMU during reset and in this ioctl,
> > we ask UV to terminate the guest via UV_SVM_TERMINATE ucall,
> > reinitialize guest's partitioned scoped page tables and release all
> > HMM pages of the secure guest.
> > 
> > After these steps, guest is ready to issue UV_ESM call once again
> > to switch to secure mode.
> 
> Since you are adding a new KVM ioctl, you need to add a description of
> it to Documentation/virtual/kvm/api.txt.

Adding in the next version.

Regards,
Bharata.

