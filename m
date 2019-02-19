Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DC72C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 03:38:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A22AC21773
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 03:38:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A22AC21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 444678E0003; Mon, 18 Feb 2019 22:38:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F3638E0002; Mon, 18 Feb 2019 22:38:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BBCC8E0003; Mon, 18 Feb 2019 22:38:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 041C28E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 22:38:00 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id m37so18632621qte.10
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 19:37:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=jkKfsZ/Mv5e4B+VYbeV119k3o5CGhhXHEWO4AOTjcms=;
        b=eGJ8+ewyd2nEm7bgo2XuKWEY+RVUAVi1XRI8SeIMofOOm8LnK3tpw7ViLogQcAHpbg
         gZEZmevxj+Ja4Wa3NLA9qi7pFBrmcpEZ0FjhbDAyOLD9GfbmPQgKLtszlqXcjRtBlE3s
         OVnHXk8VHW34exxz9UDP8t5kFKh1z7tZwUvN0rxBIqln6LF3emzMW3URwGAxBVg17Hxl
         /7zhwGOsVibcmr1wehcbIAZupWAL150A3LiNjTldjlNcO091SkbTyA33sY3c6sPvYuoD
         r9Z5uSYQ+Ce8z2BJNv5s1q+aLF+l0+Co0gClbLYLYzX3TaZjByGOEnyn28jAazFkZJyY
         WjhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuaI7U1C7qnxa+93Z2I9jakEoStjsE01wQaZVTMgtM7dSe1Oz/k6
	zMIUTOhr4eharQZ8q4wbwcZSTNk2rCjGoWzRnX1bMi0x0npZQbujx3q2MtlCbF9kTH8HnJBOc91
	V0RsiUwIm+Newy+7+6xvhcrkSBLLfNczSWKnwHHUUDOmglRNolFIiS77sfeaucuCG9Q==
X-Received: by 2002:ac8:366e:: with SMTP id n43mr21526334qtb.162.1550547479799;
        Mon, 18 Feb 2019 19:37:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZsrsKnnp/2nRzwRgzFVV/4KhA00yf4H3IyihgwFpnj2APayB58eJMfxNdRj7VEnvnXVau1
X-Received: by 2002:ac8:366e:: with SMTP id n43mr21526324qtb.162.1550547479389;
        Mon, 18 Feb 2019 19:37:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550547479; cv=none;
        d=google.com; s=arc-20160816;
        b=YqmLFdCbKEyufSllU03s719RQAT145s7q1TSPY4re49yANmV/AwHqWYT3ZFiZk8Ktd
         9EixxaGJ2TuFdVye8OFNBrNzXnuq0w5mYdmINJyIWl4eA5hIpyFY5OKruzc9U2QwsRfU
         Y6C7+FGB317srZRLU9IgugvVi2WMcs8KeAdYIWLzrxrgwHWGIrZNongD/jSRXzaLyeqT
         MRdStEX0hT77fQeINVfzYygY8WbczJyw/9am2VMvmGs2kv90kN14cyjFFL5bUn22Si6W
         pX8KqCUzJRWI1Vg7xQieDglRM3tEYwwhQazKPVcJdc6o5BFBwNF3BQSUV0U5JvbrhYB3
         96Sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=jkKfsZ/Mv5e4B+VYbeV119k3o5CGhhXHEWO4AOTjcms=;
        b=SiLhhJeRjS+tjxFHsixeRvE0IP62mF0pkwh9cGHNnDP+M4EvTeR2TCWgfWL5xVsvY4
         DnjCENijh7gCVyAZ1d+1sDqur0v8JhcGalCQ5QRx4XVmREnSfICFeJGhi7sCbNLumyDq
         4Lw2sO4kWRMEgI9WMDqReztyACOAdHFBR7Kw9XTOmGhZbIJUr4MtI/HWAcYVE6qD3AEL
         tGQyTYPvYPbHBlKotPmNZU1GFS1l/dY14FSBcxjAYl3MBTq/7K26DuX82QnRAXERI1ZO
         XmugcFtFnZdWDjarX3LA0045TIjlc9NHasx11Zs4XqNSzgDxvOPOQ+5zuVFmfwmO1E2/
         liSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p6si4761453qvi.100.2019.02.18.19.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 19:37:59 -0800 (PST)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1J3Y3Dw109846
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 22:37:58 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qr9c69t8v-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 22:37:58 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 19 Feb 2019 03:37:57 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 19 Feb 2019 03:37:53 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1J3bpFM29098224
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 19 Feb 2019 03:37:51 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8D012A404D;
	Tue, 19 Feb 2019 03:37:51 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 25C67A4055;
	Tue, 19 Feb 2019 03:37:49 +0000 (GMT)
Received: from in.ibm.com (unknown [9.85.68.139])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 19 Feb 2019 03:37:48 +0000 (GMT)
Date: Tue, 19 Feb 2019 09:07:46 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, benh@linux.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com
Subject: Re: [RFC PATCH v3 3/4] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE
 hcalls
Reply-To: bharata@linux.ibm.com
References: <20190130060726.29958-1-bharata@linux.ibm.com>
 <20190130060726.29958-4-bharata@linux.ibm.com>
 <20190219032140.GA5353@blackberry>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190219032140.GA5353@blackberry>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-TM-AS-GCONF: 00
x-cbid: 19021903-0012-0000-0000-000002F75402
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021903-0013-0000-0000-0000212EDF22
Message-Id: <20190219033746.GA19191@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-19_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=970 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902190026
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 02:21:40PM +1100, Paul Mackerras wrote:
> On Wed, Jan 30, 2019 at 11:37:25AM +0530, Bharata B Rao wrote:
> > H_SVM_INIT_START: Initiate securing a VM
> > H_SVM_INIT_DONE: Conclude securing a VM
> > 
> > During early guest init, these hcalls will be issued by UV.
> > As part of these hcalls, [un]register memslots with UV.
> 
> That last sentence is a bit misleading as it implies that
> H_SVM_INIT_DONE causes us to unregister the memslots with the UV,
> which is not the case.  Shouldn't it be "As part of H_SVM_INIT_START,
> register all existing memslots with the UV"?

Ok, makes sense to rephrase.

> 
> Also, do we subsequently communicate changes in the memslots to the
> UV?

Yes, currently handing KVM_MR_DELETE, yet to handle KVM_MR_MOVE

Regards,
Bharata.

