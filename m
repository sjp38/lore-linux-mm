Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF80DC74A42
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 05:09:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77E4D20872
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 05:09:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77E4D20872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF9188E00A7; Thu, 11 Jul 2019 01:09:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB35F8E0032; Thu, 11 Jul 2019 01:09:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B70658E00A7; Thu, 11 Jul 2019 01:09:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC178E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 01:09:02 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id i63so3172453ywc.1
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 22:09:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=YHlF9WzbCt7SXwaqQWzizTQ78jLxeE1dN1NjF7neDmI=;
        b=KVyDbJYZLrj+6beES5RLOp2payCjpwjz0h9yWdsV+DXZCsoVoF51npMEuWgjah8SrL
         zpWjpsBWn1OJcWEeRjYrCqtkZZERJOzqre6/4xlr6sMOl7yz6ixEkpEkXwFOhPPdwb0r
         a7qr40tCHFvUa+KLP47Y8yAsXfKPkSS+t5LOP+SglyJcrzymJzpaw2Do21ZCEobiSHkb
         A1JHHKuOjA7hv+L6qS68Xr8jiKqoArokip5uxdl5lcTZB4IS/9xm2++1XQnOb4fLIPE3
         1jtQimTnMbpfXQ1N76U/PMZYbSu4HuaQhqzWa+lxVi3yQnWnI2CnJ1tIPp3H7pXQCTe+
         mmmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUJrDi52wHpEHIdQ4Fz07FQP5d039WCfHVCiQZ+s0zUM0LBfx8Z
	5r3dEy+9vBbCawtRMo5XI/AnrS8kyWNfbrqvFLAkDTtZeNrroREmlFMNv6YE7SJEnHvdDMAuKwQ
	qrGjdTJbQNv+gd9GEu9BSfjpk+3pvHWXB7zv7teJ+Xqs+fcyYze+Z6MRXTGvMf4wGRA==
X-Received: by 2002:a0d:d603:: with SMTP id y3mr839865ywd.1.1562821742323;
        Wed, 10 Jul 2019 22:09:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIt0Mv7p9AwVxhoF5abDzeze4NBGRFgFOiyAACmwFIQGdPyZkceFQ7PHiULCH4zGdgaRhC
X-Received: by 2002:a0d:d603:: with SMTP id y3mr839840ywd.1.1562821741559;
        Wed, 10 Jul 2019 22:09:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562821741; cv=none;
        d=google.com; s=arc-20160816;
        b=tjC/Lg7uc7brMRA/bQPdoPHCmb7wDFH9ii82zGCLiT9GyDtoyel8EEtXeMnJhwKLwp
         vV4tcWvSl4Mal3FFmpZgV8R/wSCjMQdPi3Urb9yChzzqiPaYhcnkH48WKQ9xF7p2vavH
         LBGG+m3C03XO490v3CiTYKIwEKdyWjZvWVF3AF18MIB8CSj92wb9bdCSb7/VZ6P9Lfcc
         4V0dQ1cf/iuoR54TrEhTVOSBkRR7nBrW5GafaDaHZ4RbVXJ2aVxapDcTXP+y0YyHNtvU
         NudzT2in6J4q5SozTaILOAaZa3W85CkxdyxxXtKmcyguMHA295f6v9cPIuDd+8/aUHtk
         95QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=YHlF9WzbCt7SXwaqQWzizTQ78jLxeE1dN1NjF7neDmI=;
        b=jIvXC4AGjZX1hcrCIVbmMZufef/mzUVWCfxF0boNONXQEQcoDfqxxshcpbDgh5oIdy
         a7PkqpfWKzd4bCTjm/JG6a/iapuvL1XrIIu0kLNyL/Twt2LSVPbHZkfSpnxH0sh8D7db
         bhpHiTP1v2a238oScGtTvATM6s1kp6UcXL4P3pFYduSjAGz39f2A5ZFIsdB1lykN1oBl
         ttYRujTYtQ6puCJV6Yi2q09xbkDL8zyuua6G11aV1n2WAjJqF73DLDsffu6Ke++/+pnJ
         exc3WU4ZQAYdpeemDEAu2Ovyf/P/bGBr3nGpdwZcdcxeyk/o1zc8EkbA1QvlidASdAAS
         uyPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j4si1728163ybe.340.2019.07.10.22.09.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 22:09:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6B57MBa054052
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 01:09:00 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tnu35evbj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 01:08:59 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Thu, 11 Jul 2019 06:08:58 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 11 Jul 2019 06:08:54 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6B58rGX34406748
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 05:08:53 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 48B5D4C044;
	Thu, 11 Jul 2019 05:08:53 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2F6BA4C04A;
	Thu, 11 Jul 2019 05:08:51 +0000 (GMT)
Received: from in.ibm.com (unknown [9.85.85.188])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 11 Jul 2019 05:08:51 +0000 (GMT)
Date: Thu, 11 Jul 2019 10:38:48 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: janani <janani@linux.ibm.com>, linuxppc-dev@lists.ozlabs.org,
        linuxram@us.ibm.com, cclaudio@linux.ibm.com, kvm-ppc@vger.kernel.org,
        linux-mm@kvack.org, jglisse@redhat.com,
        aneesh.kumar@linux.vnet.ibm.com, paulus@au1.ibm.com,
        sukadev@linux.vnet.ibm.com,
        Linuxppc-dev <linuxppc-dev-bounces+janani=linux.ibm.com@lists.ozlabs.org>
Subject: Re: [PATCH v5 1/7] kvmppc: HMM backend driver to manage pages of
 secure guest
Reply-To: bharata@linux.ibm.com
References: <20190709102545.9187-1-bharata@linux.ibm.com>
 <20190709102545.9187-2-bharata@linux.ibm.com>
 <29e536f225036d2a93e653c56a961fcb@linux.vnet.ibm.com>
 <20190710134734.GB2873@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190710134734.GB2873@ziepe.ca>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-TM-AS-GCONF: 00
x-cbid: 19071105-0028-0000-0000-0000038315C2
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19071105-0029-0000-0000-00002443285B
Message-Id: <20190711050848.GB12321@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-11_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907110059
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 10, 2019 at 10:47:34AM -0300, Jason Gunthorpe wrote:
> On Tue, Jul 09, 2019 at 01:55:28PM -0500, janani wrote:
> 
> > > +int kvmppc_hmm_init(void)
> > > +{
> > > +	int ret = 0;
> > > +	unsigned long size;
> > > +
> > > +	size = kvmppc_get_secmem_size();
> > > +	if (!size) {
> > > +		ret = -ENODEV;
> > > +		goto out;
> > > +	}
> > > +
> > > +	kvmppc_hmm.device = hmm_device_new(NULL);
> > > +	if (IS_ERR(kvmppc_hmm.device)) {
> > > +		ret = PTR_ERR(kvmppc_hmm.device);
> > > +		goto out;
> > > +	}
> > > +
> > > +	kvmppc_hmm.devmem = hmm_devmem_add(&kvmppc_hmm_devmem_ops,
> > > +					   &kvmppc_hmm.device->device, size);
> > > +	if (IS_ERR(kvmppc_hmm.devmem)) {
> > > +		ret = PTR_ERR(kvmppc_hmm.devmem);
> > > +		goto out_device;
> > > +	}
> 
> This 'hmm_device' API family was recently deleted from hmm:

Hmmm... I still find it in upstream, guess it will be removed soon?

I find the below commit in mmotm.

> 
> commit 07ec38917e68f0114b9c8aeeb1c584b5e73e4dd6
> Author: Christoph Hellwig <hch@lst.de>
> Date:   Wed Jun 26 14:27:01 2019 +0200
> 
>     mm: remove the struct hmm_device infrastructure
>     
>     This code is a trivial wrapper around device model helpers, which
>     should have been integrated into the driver device model usage from
>     the start.  Assuming it actually had users, which it never had since
>     the code was added more than 1 1/2 years ago.
> 
> This patch should use the driver core directly instead.
> 
> Regards,
> Jason

