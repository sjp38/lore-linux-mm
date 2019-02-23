Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73F1AC10F0B
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 13:27:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15CFE2086C
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 13:27:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15CFE2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 706D98E014E; Sat, 23 Feb 2019 08:27:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B5D58E014D; Sat, 23 Feb 2019 08:27:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5577D8E014E; Sat, 23 Feb 2019 08:27:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 113268E014D
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 08:27:54 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id o24so3715836pgh.5
        for <linux-mm@kvack.org>; Sat, 23 Feb 2019 05:27:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xfeCRzpqKVfmRtcBUM7dvs52nVHBKG/RDM1btAzuTcw=;
        b=DO5hGFRq6VKwlfaEBaS+uW45Jr2zIFm3jtRtSrNpipiZYrnQTkqrumndCuojy122jw
         LtrueZTRJice3NcnMMRI0z7I6E6uzXiPVmGQHOcizSP+zHj0khp8AZhBufEnp3nISNuS
         mtRMC1PQZKgWpu0gVVwMWqIBH+DX4xK1CtUa9+Z8pjFN643nFlLQS55KlurxA2O6cBaT
         ihxILpOTyRLKRkpWa6rLn9vRj/ev2sZECzomwHvpmaMjcLwXaVBIxSvEG4jaaxUe4L5U
         0hcUHlVN/BAX8t+f5xj+F3FHPFnL1ajlcrw2sb10coRJxWnCbjNlfoYFcvhSJBiXVBZI
         rdWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZTOX9+Ba5Kg+ZZ0Lkub8HDFbOlAv9PY3GLwycF7fyvxlMNd/Xt
	FK42ZnrbIsY7cdD5vdqUuMVn7mhhLTj/nivHQUhdW2mLoJSk14Uzv4WOmmrKqFcOFE7ys9Wr7qy
	vxQ/AKzAZ1ouOa9lu5bCk29Qh03WN8VyOlcjKC6L+hYbyJbre09i+Nu5vYCWUj0DV5A==
X-Received: by 2002:a62:4d81:: with SMTP id a123mr9675543pfb.122.1550928473547;
        Sat, 23 Feb 2019 05:27:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaIMENpd2Vp0S3nq2qvabnaQGtbrK4U9wWpNJHmcIB+Ixbvwa/nS6qZYFc9rX7e8VsSoBxA
X-Received: by 2002:a62:4d81:: with SMTP id a123mr9675455pfb.122.1550928472293;
        Sat, 23 Feb 2019 05:27:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550928472; cv=none;
        d=google.com; s=arc-20160816;
        b=VXVVTLVKAVO3hKf31MI0Cu4WpBh28vXXoVkAHfOgwh8L8MbAYC+l2T/a62igcsw+A8
         hFMrcSECHRRZUbbohbpGp+A3XF47IxbPKj0F+8e9r/k01WedE9iSdIggWeTLGq5vdGkf
         uAlszD/mPkOsWQNPaX2a73SUIHkRKF/XEo7LZ1uMku0RgJPdw6Zn72uFCQ+yl4PRQ/Vo
         6ndiN4Qqu7wKf72RBoYVRyvGzxtrjFeK8mm+hJYtysMypuJz/cu+K2B2jBmgH68XN0Wd
         gEXaE6BkR38KlS5eBESUQ/1PKy87hfsM8AnDSCbw7KG7kjitA/l3qIgNavub1ny+jr0d
         rV1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xfeCRzpqKVfmRtcBUM7dvs52nVHBKG/RDM1btAzuTcw=;
        b=bh55aHHuls5wmTpvpWc7eQZl/qTWOOvBajfMlr0tCCpDOveayzlml07qmuW1o8MsG1
         wImDzXh5yRtqf6fo2j/8iyJIQ57yS3k+vXQaJgFJCwX/FVszLZ0utCFWjRgS47FegaoW
         Yfj+Ck3AxlQvG4lIC+FhkAQsb64/gXrP5XgZmpxYQk8rjFRwcitOtr8tN8wYA/R6bWO1
         +rLl6yf13V5Pnh9nZXi/YNbGW3aDPy94pFSdvsD9OzSQ+hZt+YqwSDc2lf8sJ7nO/FMm
         zJTtC+Pwy9skPdWdvig2mr7UKFBkmvz4E7vKJw4UQ6JVkBNS/riWyMobTVREZclnW09O
         7+5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s80si3763640pgs.165.2019.02.23.05.27.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Feb 2019 05:27:52 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Feb 2019 05:27:50 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,403,1544515200"; 
   d="scan'208";a="135737996"
Received: from xiaqing-mobl.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.208.151])
  by FMSMGA003.fm.intel.com with ESMTP; 23 Feb 2019 05:27:49 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gxXLI-0000tT-Of; Sat, 23 Feb 2019 21:27:48 +0800
Date: Sat, 23 Feb 2019 21:27:48 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org,
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>,
	linux-nvme@lists.infradead.org
Subject: Re: [LSF/MM ATTEND ] memory reclaim with NUMA rebalancing
Message-ID: <20190223132748.awedzeybi6bjz3c5@wfg-t540p.sh.intel.com>
References: <20190130174847.GD18811@dhcp22.suse.cz>
 <87h8dpnwxg.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <87h8dpnwxg.fsf@linux.ibm.com>
User-Agent: NeoMutt/20170609 (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 12:19:47PM +0530, Aneesh Kumar K.V wrote:
>Michal Hocko <mhocko@kernel.org> writes:
>
>> Hi,
>> I would like to propose the following topic for the MM track. Different
>> group of people would like to use NVIDMMs as a low cost & slower memory
>> which is presented to the system as a NUMA node. We do have a NUMA API
>> but it doesn't really fit to "balance the memory between nodes" needs.
>> People would like to have hot pages in the regular RAM while cold pages
>> might be at lower speed NUMA nodes. We do have NUMA balancing for
>> promotion path but there is notIhing for the other direction. Can we
>> start considering memory reclaim to move pages to more distant and idle
>> NUMA nodes rather than reclaim them? There are certainly details that
>> will get quite complicated but I guess it is time to start discussing
>> this at least.
>
>I would be interested in this topic too. I would like to understand

So do me. I'd be glad to take in the discussions if can attend the slot.

>the API and how it can help exploit the different type of devices we
>have on OpenCAPI.
>
>IMHO there are few proposals related to this which we could discuss together
>
>1. HMAT series which want to expose these devices as Numa nodes
>2. The patch series from Dave Hansen which just uses Pmem as Numa node.
>3. The patch series from Fengguang Wu which does prevent default
>allocation from these numa nodes by excluding them from zone list.
>4. The patch series from Jerome Glisse which doesn't expose these as
>numa nodes.
>
>IMHO (3) is suggesting that we really don't want them as numa nodes. But
>since Numa is the only interface we currently have to present them as
>memory and control the allocation and migration we are forcing
>ourselves to Numa nodes and then excluding them from default allocation.

Regarding (3), we actually made a default policy choice for
"separating fallback zonelists for PMEM/DRAM nodes" for the
typical use scenarios.

In long term, it's better to not build such assumption into kernel.
There may well be workloads that are cost sensitive rather than
performance sensitive. Suppose people buy a machine with tiny DRAM
and large PMEM. In which case the suitable policy may be to

1) prefer (but not bind) slab etc. kernel pages in DRAM
2) allocate LRU etc. pages from either DRAM or PMEM node

In summary, kernel may offer flexibility for different policies for
use by different users. PMEM has different characteristics comparing
to DRAM, users may or may not be treated differently than DRAM through
policies.

Thanks,
Fengguang

