Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54A51C43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 13:42:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EDFB20675
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 13:42:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EDFB20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85AF08E014F; Sat, 23 Feb 2019 08:42:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 809918E014D; Sat, 23 Feb 2019 08:42:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D1788E014F; Sat, 23 Feb 2019 08:42:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE058E014D
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 08:42:31 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id a5so4023729pfn.2
        for <linux-mm@kvack.org>; Sat, 23 Feb 2019 05:42:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HTsI+/Mownet+K33ms74eIwTvzNXgOgLCWjmZnuLzaE=;
        b=I/y5V6UzVzgxVWCr540hRNv/smZ64s6rXjDOFxgqEeeyukx7Uz0kYlaK3IvvuvG/BJ
         6C3NRzeIb3p87BSxeYK7X1s5ciUqjSOrQW6ztBEGWOI1wIRidBugqw2D9JzROueRJF/W
         LzesqCiM2qVBi2ZIJIYWAd5AhrAmBnmQz5svBy6p94+FUAJkI4wWWGGuk9t4jjZLraJY
         COqH4pe6vFscQnUMsJWe8LzJH8F9w9B9u1MdhxiUFmhXhC5TUj1Xxq1GpcWVI3TJ81NK
         MzXh2pbDDRmnV/OJE2RsmfqkPKl4PdyVBLZax0KdBmx6EzUWiyuerpax4FYiqKlOP0sK
         8p7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuahytkO0rxZwAtIdJLJIPOXYoqVAl1ALOLv9Kbidxq43kCNk7D8
	Fd1+H1pawtMxksjy4Vm0HD04mSQFndpiuD2G45QEwDSiwz/yXENBUSLWH2+CDqPATnMm5+roGQx
	/Q4n2brusbf/NmngO2lCtdTpZ5nXe4l6n0pSJi0Oy/YAopLhO8GSRPbaKVWVdYf8kHQ==
X-Received: by 2002:a63:5359:: with SMTP id t25mr8225018pgl.99.1550929350772;
        Sat, 23 Feb 2019 05:42:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYVo+ByhP3KAsTmi01i88eRLiQsX2p1vaBgdQOvDMFT8PlivhhiBjl070TRXJf/oK8gFVIE
X-Received: by 2002:a63:5359:: with SMTP id t25mr8224967pgl.99.1550929349731;
        Sat, 23 Feb 2019 05:42:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550929349; cv=none;
        d=google.com; s=arc-20160816;
        b=DEiqXNFQOBVA/AlDg67fgCZcpX1BzrxqP3wHXbmwlPiIt5rpvrKVojsEeipfnYpjIg
         8mT7yxRFFLJoPfc79/FpvWSxJiWbOIGIHZ7Gva+EvEz6Vdjyo9V1+8GcmbZZ5XNrT5Bi
         iWGrGZFjkqYi03oKf2T8caCb5cEJl84uzZyz9r7KzWoN+Zt5QI8W4LQobo5mSd8tK/mX
         phMy7DCGIV/+wK6AuN+zkzKRX2CcHbPa3PEsYujI4tY985O4bvwsYWL1E/U9x8CdrKPt
         TPtiS0LcG8C3YwOmL3iMfZ0vWcD3WK5DyzmvBe3GvhnpkoyxDEIQ8kxKp9G5thN2SDj4
         K1OA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HTsI+/Mownet+K33ms74eIwTvzNXgOgLCWjmZnuLzaE=;
        b=S2LuX+f2I+R2vp6KDtoy4mqlm3YAWu0ph8owFD8j9TM87KftIPiMWUjedb2MVyqUdp
         GJOHRr129BJnHq2GNvRxUNtTI1VGfFD/VGFE53IUqmbkvYjCRfdYXLRFmQJh5VEuIdNd
         0wo1Yn7SWyiRk6gGh7DUZPPSCjq/bcFd9/oH0YzaO8WloKCMndsmG2KhIWNBIVdfEH50
         MEaE45Y+ewsaVfMRk9TN3vZP5Ugtb+0VC6FEcBeKmfmDmBIb2t28GV8g6iVth9xR27WA
         5bPrzMfTTRjXRTOkuKA4uhBBzVotH0xTIpYF0ZDOSeFS3Xzhk9i6KFPQ7Wyq+W5CCZiL
         zMaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id r1si3820837pfb.118.2019.02.23.05.42.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Feb 2019 05:42:29 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Feb 2019 05:42:28 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,403,1544515200"; 
   d="scan'208";a="135739557"
Received: from xiaqing-mobl.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.208.151])
  by FMSMGA003.fm.intel.com with ESMTP; 23 Feb 2019 05:42:27 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gxXZS-00010q-Pu; Sat, 23 Feb 2019 21:42:26 +0800
Date: Sat, 23 Feb 2019 21:42:26 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org,
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>,
	linux-nvme@lists.infradead.org
Subject: Re: [LSF/MM ATTEND ] memory reclaim with NUMA rebalancing
Message-ID: <20190223134226.spesmpw6qnnfyvrr@wfg-t540p.sh.intel.com>
References: <20190130174847.GD18811@dhcp22.suse.cz>
 <87h8dpnwxg.fsf@linux.ibm.com>
 <20190223132748.awedzeybi6bjz3c5@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190223132748.awedzeybi6bjz3c5@wfg-t540p.sh.intel.com>
User-Agent: NeoMutt/20170609 (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 23, 2019 at 09:27:48PM +0800, Fengguang Wu wrote:
>On Thu, Jan 31, 2019 at 12:19:47PM +0530, Aneesh Kumar K.V wrote:
>>Michal Hocko <mhocko@kernel.org> writes:
>>
>>> Hi,
>>> I would like to propose the following topic for the MM track. Different
>>> group of people would like to use NVIDMMs as a low cost & slower memory
>>> which is presented to the system as a NUMA node. We do have a NUMA API
>>> but it doesn't really fit to "balance the memory between nodes" needs.
>>> People would like to have hot pages in the regular RAM while cold pages
>>> might be at lower speed NUMA nodes. We do have NUMA balancing for
>>> promotion path but there is notIhing for the other direction. Can we
>>> start considering memory reclaim to move pages to more distant and idle
>>> NUMA nodes rather than reclaim them? There are certainly details that
>>> will get quite complicated but I guess it is time to start discussing
>>> this at least.
>>
>>I would be interested in this topic too. I would like to understand
>
>So do me. I'd be glad to take in the discussions if can attend the slot.
>
>>the API and how it can help exploit the different type of devices we
>>have on OpenCAPI.
>>
>>IMHO there are few proposals related to this which we could discuss together
>>
>>1. HMAT series which want to expose these devices as Numa nodes
>>2. The patch series from Dave Hansen which just uses Pmem as Numa node.
>>3. The patch series from Fengguang Wu which does prevent default
>>allocation from these numa nodes by excluding them from zone list.
>>4. The patch series from Jerome Glisse which doesn't expose these as
>>numa nodes.
>>
>>IMHO (3) is suggesting that we really don't want them as numa nodes. But
>>since Numa is the only interface we currently have to present them as
>>memory and control the allocation and migration we are forcing
>>ourselves to Numa nodes and then excluding them from default allocation.
>
>Regarding (3), we actually made a default policy choice for
>"separating fallback zonelists for PMEM/DRAM nodes" for the
>typical use scenarios.
>
>In long term, it's better to not build such assumption into kernel.
>There may well be workloads that are cost sensitive rather than
>performance sensitive. Suppose people buy a machine with tiny DRAM
>and large PMEM. In which case the suitable policy may be to
>
>1) prefer (but not bind) slab etc. kernel pages in DRAM
>2) allocate LRU etc. pages from either DRAM or PMEM node

The point is not separating fallback zonelists for DRAM and PMEM in
this case.

>In summary, kernel may offer flexibility for different policies for
>use by different users. PMEM has different characteristics comparing
>to DRAM, users may or may not be treated differently than DRAM through
>policies.
>
>Thanks,
>Fengguang

