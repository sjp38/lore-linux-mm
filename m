Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3F01C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 21:47:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88173217F5
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 21:47:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88173217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CF8B8E0002; Thu, 14 Feb 2019 16:47:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0586A8E0001; Thu, 14 Feb 2019 16:47:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3B9E8E0002; Thu, 14 Feb 2019 16:47:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C43C8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 16:47:00 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id b15so5849449pfi.6
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 13:47:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hvQJpm+mV7X4eaXVQRDtl3tzptiQH+a3WDEWk8temtY=;
        b=Xhxftc+eP5yN2BQre+jjhrOagz1J+jLeA2+qu+TuzVcJu/wDCVO/8PfiTGlUC1j496
         49/wQbDmNpZG5w5gE/Z3wkiLMQky08iVKz9eVTzhca9j0UVDt1ZTkNMIPQf/K/z19k7i
         /pH0cDbdvZHkhHXXRknMuIdh/2Sb3AjpfQlPrSVJ4zGYLtTMLUmUct/Pck4k9lZNOYk5
         tIGeECIM4ktggruHpvgZ1X1yqmX3q64BhrLhwKrn/gJS7aJasOHZgkETrfbaX7cX2uwV
         Qhn/AoD2LZKvIAQpGorZ9cmfKsilvfV9xt2qRLwUFRZiGKoHo8YyhDYVIcYQdN3vAJvW
         Uy8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAua8Fz+jQ7A/l2XXQFG3yOvoQnLTS+onhzSa16NmMzqXvIncWqqP
	qM39VQhM27x8Tgz6QlRw1VHqrvQwrkwAwUHvSx0IV1+kWggj5FwADIsHRsT1A4puXG9afoOB/RN
	P+rZ+60feMmItuxhrDqFONaeJK2N4sU8MWYMQzOVtvlzsnBEs2n7BOg4SpICFJ9XZAg==
X-Received: by 2002:a62:9305:: with SMTP id b5mr6265862pfe.10.1550180820309;
        Thu, 14 Feb 2019 13:47:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYtAgkG/s6Mt6mx0l9IbcWCHLvc8y53pUrf7HDM/NjUpBwRwnyfKMJVihgYmMbPegzD7mxd
X-Received: by 2002:a62:9305:: with SMTP id b5mr6265785pfe.10.1550180819114;
        Thu, 14 Feb 2019 13:46:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550180819; cv=none;
        d=google.com; s=arc-20160816;
        b=QbIo3/boeb/5SsKCBwlNoT/kkg1/Nd8DDmGMdl7UL4JSOyV+kzsJ93uaWjk2xJ+WYs
         riQ7n3+qk9N2wqNuwLbUE9Kdd4X89GrurzU8RkAGaIuCpz+7zgCKp7ggBFnaVlp3iEK4
         EZUAuuD85F5oNYxehldujO5XgvnLfQZPZtOFhH+cAd7WZiwZBOfMbLgA/SrVmK+8sEwT
         Cc+szIVQDKbtsJlFZjR9YhYmvAMmzKL3xPyyLr6JUD6+7gP0TS95w1wCSrtTQ4yMQZDa
         z5DmWECEZePLS4h/CoZA2VJTuZIjPXvLd+kTJTS4o1zVUC6nVoSe034J+L5aksluGmKq
         FKDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hvQJpm+mV7X4eaXVQRDtl3tzptiQH+a3WDEWk8temtY=;
        b=yyyW2bmRE3jUYjyrWuO/43fbE3WDddfC9sJfz0covAHWTyl6SAaLbLaU3OJFBznheb
         SzlvJB8QWv+r1MXw+f/jXDPyrogIHfm57dHM+5e3EbLdSmv4KH5B1yUYRtuFQdNYMryn
         yT+Xg74o3MX6CV5Ka6r/ChyeS98o0fgnuUIAIO5bGVxSRqWqWbRt8FgR+2FhdPZwHXG2
         50J1sXCp0usV7enLvwRoGiXHuZjDzXvnS2RJ3MW34HMOi+GOqkf8+KP4j75jibfR2w/g
         d/jyzSztUU/vWBN3ayux46zkwCBFRzyrV+4EDTF0UXFerobkHhHqXbfvmoYK13cbmMHv
         9axw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id p18si3323145pgl.557.2019.02.14.13.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 13:46:59 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 13:46:58 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,370,1544515200"; 
   d="scan'208";a="118016118"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga008.jf.intel.com with ESMTP; 14 Feb 2019 13:46:57 -0800
Date: Thu, 14 Feb 2019 13:46:51 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
	dave@stgolabs.net, jack@suse.cz, cl@linux.com, linux-mm@kvack.org,
	kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
	linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
	paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
	hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru
Subject: Re: [PATCH 0/5] use pinned_vm instead of locked_vm to account pinned
 pages
Message-ID: <20190214214650.GB7512@iweiny-DESK2.sc.intel.com>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211225447.GN24692@ziepe.ca>
 <20190214015314.GB1151@iweiny-DESK2.sc.intel.com>
 <20190214060006.GE24692@ziepe.ca>
 <20190214193352.GA7512@iweiny-DESK2.sc.intel.com>
 <20190214201231.GC1739@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214201231.GC1739@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 01:12:31PM -0700, Jason Gunthorpe wrote:
> On Thu, Feb 14, 2019 at 11:33:53AM -0800, Ira Weiny wrote:
> 
> > > I think it had to do with double accounting pinned and mlocked pages
> > > and thus delivering a lower than expected limit to userspace.
> > > 
> > > vfio has this bug, RDMA does not. RDMA has a bug where it can
> > > overallocate locked memory, vfio doesn't.
> > 
> > Wouldn't vfio also be able to overallocate if the user had RDMA pinned pages?
> 
> Yes
>  
> > I think the problem is that if the user calls mlock on a large range then both
> > vfio and RDMA could potentially overallocate even with this fix.  This was your
> > initial email to Daniel, I think...  And Alex's concern.
> 
> Here are the possibilities
> - mlock and pin on the same pages - RDMA respects the limit, VFIO halfs it.
> - mlock and pin on different pages - RDMA doubles the limit, VFIO
>   respects it
> - VFIO and RDMA in the same process, the limit is halfed or doubled, depending.
> 
> IHMO we should make VFIO & RDMA the same, and then decide what to do
> about case #2.

I'm not against that.  Sorry if I came across that way.  For this series I
agree we should make it consistent.

> 
> > > Really unclear how to fix this. The pinned/locked split with two
> > > buckets may be the right way.
> > 
> > Are you suggesting that we have 2 user limits?
> 
> This is what RDMA has done since CL's patch.

I don't understand?  What is the other _user_ limit (other than
RLIMIT_MEMLOCK)?

> 
> It is very hard to fix as you need to track how many pages are mlocked
> *AND* pinned.

Understood. :-/

Ira

> 
> Jason

