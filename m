Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9620C04AB3
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:00:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 752BE21479
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:00:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 752BE21479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAD266B0282; Fri, 10 May 2019 09:00:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E36876B0284; Fri, 10 May 2019 09:00:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D73436B0285; Fri, 10 May 2019 09:00:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A308A6B0282
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:00:30 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n23so4020519edv.9
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:00:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:date:from:to:cc:subject:in-reply-to
         :references:message-id:user-agent;
        bh=NBREdM08tymyVQfiChpYiD2+PTE/DbgIN8n0yrgglKs=;
        b=IxRz2cRNiu0UUIVII9CHo8S1T+MLDqfqigFDf+d2+q8zeQt97vbn/tX4F7ddt6zFnU
         70pDj9vIBmtQo9IWXkYZ+qceidKNPvN5jYcQftsRedPZTAwmrr6bqDCMT8k4P+V0ZR/7
         dsl8cb3KmwJkTE6rzSDNYxGFS3k+MEOkVdqmN6Jx2iJitXlAXJ8qamsRcZMkj6LXR84X
         ctDWgR9E44QHJf/L4Cif0851SD/tA7sJOI9w52Jd9rFXT7oDfgy/oZUHyRwrBR0dICv6
         ivKNdb1Zoc22cbuc71wn73XnDMNrqFlWnxRtpM3nfFxxPLF5oCIoSzN/q44nMIsy+Jya
         bkNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXEJyjaeV+uUjk6oIYtzdqGseMLrZ4QRlPBR3bbqavu+s3BQYM0
	Ap++AA8buE7d+b+MZINwSTTSEFpqRv+du53lfQUSJLobn5DrwXE2usnZLbw9luSJRBCXck/O06c
	SiiCuwiLhwNKrothoixmSamhCkhjAchrk8ZDF50GVtJmdBrA6dCT1E+mwuFCRuTzK3g==
X-Received: by 2002:a05:6402:149a:: with SMTP id e26mr10679372edv.241.1557493230254;
        Fri, 10 May 2019 06:00:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzRMGCnUyTATZUiHFazkGHpf1KTqUsdojL4tJ39RGV8k754xWOxn5nbFEZM+7v9p1YdGrx
X-Received: by 2002:a05:6402:149a:: with SMTP id e26mr10678665edv.241.1557493225989;
        Fri, 10 May 2019 06:00:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557493225; cv=none;
        d=google.com; s=arc-20160816;
        b=Eck4844N8kKokSWV0gW/0i9O1X1dywrhbXV1h9MGZjUsN0MgoOKYB9qyVV+mzVx7Kj
         2FtbI8U3z5Pg5+/paNyhEYOy7ySc6/LdTwdxK2xk0SNv5Ve5ic2tQahkEOCB+itdK1PB
         3oVZrkcTm6dWmH1FsJYjUk1CbZqLdgw8tgAlCDGM05t/16RtLYy+ufMERh+OwdyXsUBa
         5y0o+HgYPYVgkOZC0T1dZ59aRqWKkzOpjLC8DkMoI+d2DbcLj2rNIHAyE+HCdKiahroE
         KpGJug+f5H5Uz0fqX876hgnnYrpzjY2HmkJ/Z8t2Xe4LC431K8tiN3tZ12c2tX7tFWLx
         KKgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:references:in-reply-to:subject:cc:to:from
         :date:content-transfer-encoding:mime-version;
        bh=NBREdM08tymyVQfiChpYiD2+PTE/DbgIN8n0yrgglKs=;
        b=mFPaIbVxKKIXnCiRRvKHtsRikbMMJsOPYYb6Kv5ZYVlz6kejnuuGgT+7sSEX/UX7EX
         bXbhS92xUKnacpCwkz3bjoI9bkJX9z2UCMyhfHqJ+j91fqU+QIRXodIetqI13txRuCI6
         W6RL7xd21GY4Z21am/gmfzpaFMAVHEKSswddXgXQapjliHaQNfi7AtgxVWlC0+SiAgC/
         sj2bMDnrMc4lfCJzffmXc0UN2C8sEV7F6AIxjYKB8niSORzwSF8x7ILiPKQnndklFg/1
         mXajtnmtn6tN57O+o/DZWvA7A/vHWljaRRYCs+67d40LnDzzmQol1GiVkJKX2OeXR95Q
         giGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l4si383658edd.297.2019.05.10.06.00.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 06:00:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 749EDAEC6;
	Fri, 10 May 2019 13:00:25 +0000 (UTC)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Fri, 10 May 2019 15:00:25 +0200
From: osalvador@suse.de
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>, Vlastimil
 Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, Pavel
 Tatashin <pasha.tatashin@soleen.com>, linux-nvdimm@lists.01.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, owner-linux-mm@kvack.org
Subject: Re: [PATCH v8 08/12] mm/sparsemem: Prepare for sub-section ranges
In-Reply-To: <155718600896.130019.3565988182718346388.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155718600896.130019.3565988182718346388.stgit@dwillia2-desk3.amr.corp.intel.com>
Message-ID: <3b031a3e721fd81dcfd5fa344e2a5bd0@suse.de>
X-Sender: osalvador@suse.de
User-Agent: Roundcube Webmail
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-05-07 01:40, Dan Williams wrote:
> Prepare the memory hot-{add,remove} paths for handling sub-section
> ranges by plumbing the starting page frame and number of pages being
> handled through arch_{add,remove}_memory() to
> sparse_{add,remove}_one_section().
> 
> This is simply plumbing, small cleanups, and some identifier renames. 
> No
> intended functional changes.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>


