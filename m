Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A114FC606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:05:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51B0820844
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:05:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51B0820844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAF2D8E0045; Tue,  9 Jul 2019 06:05:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D379D8E0032; Tue,  9 Jul 2019 06:05:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB1D58E0045; Tue,  9 Jul 2019 06:05:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 837778E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 06:05:39 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a5so10440568pla.3
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 03:05:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=EN+aVEKqxNfPej/HdpWERlpnN+H5whgnsREdJrOEbBI=;
        b=dc3zRSjJpLZx6Q4KWdvt8z7dBGjcWQ4PeHo54xUsFwF/+GgW+wMprbtqFpBZJalO46
         7J3NWprpG+p2sSTX7i4wZihAHC1LlMY3VRh6dUJGA/BsRMLrrD4NN+WZ5cvpMrT6gUhb
         UFxnFyWjuTtVgUBGOlwwkQ3Ekmm34CL/Utbg7VtLzD9RbRv+Kx8ANMv39MA5XfycGdzg
         H28poB5iO2x7vVBDutqJbX3o5I73OMH2HnVU/KKiKF7HDh7GonVZnAuFwTMd03G97p55
         AIA/6jN+NT3b5XxzB/FyQ7xzovy2emQcEJcbtQgJ40319eZUdfK88mq5qP1gu3kk5AcS
         ln9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV9AUQ3SwMaeDqOZPLubwFol2QPYohAzO7W8KdY4SAfoVd7zeRH
	bjIqDLEvmAhynLOfNv44lBUVrkquMWIVWVrb8OpchIha/LJcjbV4Q/82g9vLhG4xfLWhRibI0FH
	kIjZhzfXif22CT+arJU+jSCdR5BZkuasQW+dSLkGeLMNCxKPhvEWBzlSA5t6VAkY24Q==
X-Received: by 2002:a17:902:2aa9:: with SMTP id j38mr29667829plb.206.1562666739193;
        Tue, 09 Jul 2019 03:05:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOinFy1K9v64MhTbFBuoIexhzBPftW4Gw4UCTSvcOp7N6OZN8aIRIFYbM0Mvjg9MBT74sE
X-Received: by 2002:a17:902:2aa9:: with SMTP id j38mr29667764plb.206.1562666738633;
        Tue, 09 Jul 2019 03:05:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562666738; cv=none;
        d=google.com; s=arc-20160816;
        b=jEblswVwXJU5fs6UUZNyBMDRtdNZveMHNMbYDAPK3fH7a2YENeGvb8Yn0BJ+DW5EWJ
         JuOFb3cPbeI7YRO96GfbFHg/fYi6m9Ij+juSQ20C4fCgcokIH0Zh/SssX7EqiI9EhWxL
         UkyaFpAJ7YhWsC03HgYvIDbDNiG8x+b+rgbrhygibOWHHbsZ1bC18DuHUQeuWTxK+czD
         83BJuxb8QbXV+/Ysc/viBWePZ9H5SjkTvqzQ5I9BsxmoW1oJiv5Q+eHNm2I+kRWDDwLC
         0i7BzmRow9WJiiuTZBRwMvzqkk1ik5pkHuNBvBlc1OQ7vYdQqghBIaE2FbBsfMA1Wbk1
         4lYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=EN+aVEKqxNfPej/HdpWERlpnN+H5whgnsREdJrOEbBI=;
        b=MlANHtCQjS0ICGhSQfIKh0DwOknIMEApXk0cNakUEuylGB42POUEVb0t0h8FAasV7S
         nee89JHmn6GShZJmn0FJvzBhJH64a02EUK8oac4NXNIB9OjmE5MEePVVVNR1JM9k8F1F
         vVm/rM5dIVIk1o/dzFrFroHYolgk7PE2E8TswRJJmLRQEo9UoojRSQOn3EWK20vFLihy
         f8TmBDL7WZeZyXTp/8Ja6ix+sAuPAwHjz4TIqIvMc6PJx0/qofaQkUus5F0cz1IQ10ps
         cylpXljX/OaGYSTtCPiiG5QHcGeLRfWROllCR4YLCPT+/2YZi5qX4gj7ejrKxc8eGbpN
         b76Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 37si20926684pld.231.2019.07.09.03.05.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 03:05:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x69A2Sbg039604
	for <linux-mm@kvack.org>; Tue, 9 Jul 2019 06:05:38 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tmptu5jw1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Jul 2019 06:05:37 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 9 Jul 2019 11:05:35 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 9 Jul 2019 11:05:31 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x69A5Uds50069548
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 9 Jul 2019 10:05:30 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5F311AE045;
	Tue,  9 Jul 2019 10:05:30 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9ACFBAE04D;
	Tue,  9 Jul 2019 10:05:28 +0000 (GMT)
Received: from in.ibm.com (unknown [9.85.81.51])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue,  9 Jul 2019 10:05:28 +0000 (GMT)
Date: Tue, 9 Jul 2019 15:35:26 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Thiago Jung Bauermann <bauerman@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com
Subject: Re: [PATCH v4 3/6] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE
 hcalls
Reply-To: bharata@linux.ibm.com
References: <20190528064933.23119-1-bharata@linux.ibm.com>
 <20190528064933.23119-4-bharata@linux.ibm.com>
 <87y31y7avd.fsf@morokweng.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y31y7avd.fsf@morokweng.localdomain>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-TM-AS-GCONF: 00
x-cbid: 19070910-0016-0000-0000-000002909329
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19070910-0017-0000-0000-000032EE4575
Message-Id: <20190709100526.GC27933@in.ibm.com>
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

On Tue, Jun 18, 2019 at 08:05:26PM -0300, Thiago Jung Bauermann wrote:
> 
> Hello Bharata,
> 
> Bharata B Rao <bharata@linux.ibm.com> writes:
> 
> > diff --git a/arch/powerpc/include/asm/kvm_book3s_hmm.h b/arch/powerpc/include/asm/kvm_book3s_hmm.h
> > index 21f3de5f2acb..3e13dab7f690 100644
> > --- a/arch/powerpc/include/asm/kvm_book3s_hmm.h
> > +++ b/arch/powerpc/include/asm/kvm_book3s_hmm.h
> > @@ -11,6 +11,8 @@ extern unsigned long kvmppc_h_svm_page_out(struct kvm *kvm,
> >  					  unsigned long gra,
> >  					  unsigned long flags,
> >  					  unsigned long page_shift);
> > +extern unsigned long kvmppc_h_svm_init_start(struct kvm *kvm);
> > +extern unsigned long kvmppc_h_svm_init_done(struct kvm *kvm);
> >  #else
> >  static inline unsigned long
> >  kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gra,
> > @@ -25,5 +27,15 @@ kvmppc_h_svm_page_out(struct kvm *kvm, unsigned long gra,
> >  {
> >  	return H_UNSUPPORTED;
> >  }
> > +
> > +static inine unsigned long kvmppc_h_svm_init_start(struct kvm *kvm)
> > +{
> > +	return H_UNSUPPORTED;
> > +}
> > +
> > +static inine unsigned long kvmppc_h_svm_init_done(struct kvm *kvm);
> > +{
> > +	return H_UNSUPPORTED;
> > +}
> >  #endif /* CONFIG_PPC_UV */
> >  #endif /* __POWERPC_KVM_PPC_HMM_H__ */
> 
> This patch won't build when CONFIG_PPC_UV isn't set because of two
> typos: "inine" and the ';' at the end of kvmppc_h_svm_init_done()
> function prototype.

Thanks. Fixed this.

Regards,
Bharata.

