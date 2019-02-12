Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 866FBC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:42:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E1182083B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:42:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E1182083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F12038E0003; Tue, 12 Feb 2019 09:42:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC2678E0001; Tue, 12 Feb 2019 09:42:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8AEB8E0003; Tue, 12 Feb 2019 09:42:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 80CBA8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:42:45 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id w51so2492029edw.7
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:42:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XoJCZ4ReoRcrPVyOtTuGtgH1CAFS3WdhgjXxJf3MNLQ=;
        b=N5DjVDD+kl/Mf4AKvZsp5JJPPBrNVVtaKIU9c7UbzcTWVAJNZ052RnTqCMsH+KgANT
         B+qNqBRBRUi3gnddR7xo2w8Hhgin3OsNkbUNgULL3+e+OeRA1/H0WQlJaqdjVjKNIHzz
         kALlw81Cxr3aiq/JIx5UOqCcqQ/H3tiPXeOm656Uet1HuMBQVwHfqFps7bNxG34cJsOB
         OUyoC+8OZHyOLzH+hvmPUjtubHRx0vnSpxuQoF96I3lUcd+j9vHDtCPq2zOq3F9VCf4E
         LHq3Q2TZ5YweTAIf9j7AqsRiGbvg795xPqPf/iU0Igm+7tM0PIyTmpfXlPg9oFOG8K90
         0MpA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAub4h5lDM/Z7pYTrIr5uAOEvRC77eCgfLKmcowLPedoN+Nd03NVp
	XUFgiOuDmwcHPva8eIgQ/Tpe91B6gaY93Av7y7y5deSXfRyHxfuUOCSzy6PtGt3nt6inPIQgqLY
	nDNuQu8+vUuYGZlMMaaB9D04+X/k7nQd0AVSbw2ZbUwiLLCyLCIYyTR21GVru1gs=
X-Received: by 2002:a17:906:358e:: with SMTP id o14mr3023441ejb.212.1549982565074;
        Tue, 12 Feb 2019 06:42:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYnpAP2q5HyVpKXdHUTKhedeDSzn6yznIsX7JtReZHbo1qa0bu5yhNa3UkMqz5z7VkY2WRE
X-Received: by 2002:a17:906:358e:: with SMTP id o14mr3023376ejb.212.1549982564036;
        Tue, 12 Feb 2019 06:42:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549982564; cv=none;
        d=google.com; s=arc-20160816;
        b=R2niLIQeyUjBFqsaWK1Lpr11tdemuPlCvvvMsEXSh65h4dxtgw5dIzsgbIbJhX8eCT
         NgBiMjT4z5/0WinOokOvgZrhh3co5u2I2H+Qm5O7BSsGXxKTj7n81kfONrQRct0oFH8l
         Il4w7Erl1ORkmQwKOqTC2Rq6KdGUt8BEKvhzb8bNUZrCC064b86uQ5CCKMDFHdt23HGo
         apbPDm8iQgpKa/xFv/RQB1k9zHhkcGA+D2VAgKYF7T/ejFYgXgoWs4y70TWtKB4HUfMz
         zPwkDNK/OCjXgtLa/DLY8H2LU3VWUYgYY3WH43l/W+cxZbxNxhKIW6Zm4js9jSTdZ2vP
         p0cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XoJCZ4ReoRcrPVyOtTuGtgH1CAFS3WdhgjXxJf3MNLQ=;
        b=QuYE67mFSY2MeahttOpVEGa0xGhXPKJ2nWtKQXbR73jQTFY7kH+fEnmd21jX4/Hg3N
         TEsT7qg/Im2vAgfnGpj/FhF6qGwIa4aQxpmQA6AFIxdS3NtWLFS2A1snOlIxsaTPWIRQ
         LpTQscvIrmxl02oAUFPTEXDZ0XtDwzw1i5hzZaeN26NUFldjxVuNyDFovElNOmVXvKTx
         XkhuJ0pUexH85FwuDK8rnt2vV2QRhilyOqd798SzMj0Jspzjij/FYtRMnvhfKoceVdp3
         caYUpul0nJq7dLzU2NObyBinTcGElFWMCc1l1qvJfwLCjcDjKSkRNs8omxV0YPDV+rnY
         U+vw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b2si6376646edy.279.2019.02.12.06.42.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 06:42:44 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 54795AF01;
	Tue, 12 Feb 2019 14:42:43 +0000 (UTC)
Date: Tue, 12 Feb 2019 15:42:42 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Shameerali Kolothum Thodi <shameerali.kolothum.thodi@huawei.com>,
	Jonathan Cameron <jonathan.cameron@huawei.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>,
	"Pavel.Tatashin@microsoft.com" <Pavel.Tatashin@microsoft.com>,
	"david@redhat.com" <david@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dave.hansen@intel.com" <dave.hansen@intel.com>,
	Linuxarm <linuxarm@huawei.com>, Robin Murphy <robin.murphy@arm.com>
Subject: Re: [RFC PATCH v2 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20190212144242.GZ15609@dhcp22.suse.cz>
References: <20190122103708.11043-1-osalvador@suse.de>
 <20190212124707.000028ea@huawei.com>
 <5FC3163CFD30C246ABAA99954A238FA8392B5DB6@lhreml524-mbs.china.huawei.com>
 <20190212135658.fd3rdil634ztpekj@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212135658.fd3rdil634ztpekj@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 14:56:58, Oscar Salvador wrote:
> On Tue, Feb 12, 2019 at 01:21:38PM +0000, Shameerali Kolothum Thodi wrote:
> > > Hi Oscar,
> > > 
> > > I ran tests on one of our arm64 machines. Particular machine doesn't actually
> > > have
> > > the mechanics for hotplug, so was all 'faked', but software wise it's all the
> > > same.
> > > 
> > > Upshot, seems to work as expected on arm64 as well.
> > > Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> 
> Thanks Jonathan for having given it a spin, much appreciated!
> I was short of arm64 machines.
> 
> > (qemu) object_add memory-backend-ram,id=mem1,size=1G
> > (qemu) device_add pc-dimm,id=dimm1,memdev=mem1,node=1
> > root@ubuntu:~# 
> > root@ubuntu:~# numactl -H
> ...
> > node 1 cpus:
> > node 1 size: 1008 MB
> > node 1 free: 1008 MB
> > node distances:
> > node   0   1 
> >   0:  10  20 
> >   1:  20  10 
> > root@ubuntu:~#  
> 
> Ok, this is what I wanted to see.
> When you hotplugged 1GB, 16MB out of 1024MB  were spent
> for the memmap array, that is why you only see 1008MB there.
> 
> I am not sure what is the default section size for arm64, but assuming
> is 128MB, that would make sense as 1GB would mean 8 sections,
> and each section takes 2MB.
> 
> That means that at least the mechanism works.

Please make sure to test on a larger machine which has multi section
memblocks. This is where I was hitting on bugs hard.
-- 
Michal Hocko
SUSE Labs

