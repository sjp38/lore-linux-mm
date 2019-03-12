Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 840F7C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:50:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B1EF2177E
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:50:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B1EF2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 895C78E0002; Tue, 12 Mar 2019 18:50:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 818BF8E0004; Tue, 12 Mar 2019 18:50:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50AA38E0002; Tue, 12 Mar 2019 18:50:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC3118E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:50:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id o67so4703446pfa.20
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:50:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=Pm8+meUbkvkR9A0u86pNhDMiCGoEcDHdubseq6BWAqw=;
        b=sp/06+tJ7I72V131uCxhITBksh3l6VMMyKkxRk8QrYpiAY4Jfmr+rYgxMUL+hPwVL2
         UYkQOciMXXrm1Rc8zfH2kd/FtcaZChwyu8krVdPb93FhfTtHHmHIbMvAT87R4LB1XMpJ
         jptM2/cb5StALEHIG6Ao193NUUF8ZpIFNORARNGHAnae4GilZSMtqoeBMiTdBrz55RhC
         L0GbkMcHySucWVVB1U72cISRrJUJxtbhXrIY7IFnCI+8dz9S1b4PUrf82d+STCFc+Jm0
         YLK57HmrLw1BDrStyKrUTUK3hrTYkBDvMnxfIv36KF3KRvx6E0uwdYs2XILk/gUY/CkQ
         +sKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVH5IMPNUumgQIxcheeIo4DnSEd51GXWuHeTOk+W+XxjLdmiCRf
	98b/GKfPDtTe3toXYMgQbHWqPRaIxeCLCzv/kWBN0HLsqtlJqaiwVYJ8YJ6ev/Cq0VTdYF+XFBS
	mcfwSYcs1poI3/qXWdDE7WtN742hzYEShJGyWkAc3mbQNKTF7DcEjWDn2E78xery0rQ==
X-Received: by 2002:aa7:92da:: with SMTP id k26mr41256340pfa.216.1552431038476;
        Tue, 12 Mar 2019 15:50:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwF/g7nhmPhzoUWazNuVzQcJ1JGO6ItyeHcK0OE7nRqf13rcwUFhLdHDHIy+OlLpuvxzMuO
X-Received: by 2002:aa7:92da:: with SMTP id k26mr41256301pfa.216.1552431037640;
        Tue, 12 Mar 2019 15:50:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552431037; cv=none;
        d=google.com; s=arc-20160816;
        b=QqcQi9E9BRFUQ8VLS0CCgpfGlMFVTV1wBwjd8s4V2ZblbUkXVrfZ8Q1XwS4tYCKH/u
         Mevu4vEajJBclzQcfw+wpAaeurcgZbmXgHJTXIrHlIkisdbCb+4SgIdEY6z0/pv151Ws
         qJx2B1iCu90fDCBACcs8fh3G4KprdJn3LHgYQHLvma4kByDx+lLKXnCF3TvEgkpLKcu1
         6XYiBtjvzTyr3snfAiknFtAzHQPevprmLvyjGpQf7BIMcJg2T1TbJCXldADUSIQh5HK9
         eMiTCbZ/k+LVZfIB5bKyfGQfAicWVhH4V5jir0IYi9s6RyxVU01emiRb7inoKqBnaAXo
         kbIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=Pm8+meUbkvkR9A0u86pNhDMiCGoEcDHdubseq6BWAqw=;
        b=ghajkT4IQr4rUOF1HHlpI/6Jidh1mnN+LZyHae3c7hydYL8x4cEHTvcmvP1jyum4+q
         IJSQTade2OduO+LSZ8Fx1lkPW8f5yxuyId9lk0mC9OUYnp6cQU+HajoPqnRyOnsz/LAr
         HMHSumYPsdKt72cXUQQs3+tIxWLsEWHgmISWr4J+TZVuRmjtyG/2M90+dk2BkgTcZw9N
         4Wq3VG6CFDaaFSraOMkf29jTRV1m97RQnRNOzW6vudj7nbVhI5Wx3wFSJuod0ObXv49G
         40RjtpSqqxyjspRmszm4mIEpL75rMMv9z4yob290NWH6ap3ZEdYeE0i1zL4Brj2nmW1B
         pnWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id az4si6719207plb.143.2019.03.12.15.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:50:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Mar 2019 15:50:36 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,472,1544515200"; 
   d="scan'208";a="212101963"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga001.jf.intel.com with ESMTP; 12 Mar 2019 15:50:36 -0700
Message-ID: <4c72a04bb87e341ea7c747d509f42136a99a0716.camel@linux.intel.com>
Subject: Re: [mm PATCH v6 6/7] mm: Add reserved flag setting to
 set_page_links
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko
 <mhocko@kernel.org>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org,
 davem@davemloft.net,  pavel.tatashin@microsoft.com, mingo@kernel.org,
 kirill.shutemov@linux.intel.com,  dan.j.williams@intel.com,
 dave.jiang@intel.com, rppt@linux.vnet.ibm.com,  willy@infradead.org,
 vbabka@suse.cz, khalid.aziz@oracle.com,  ldufour@linux.vnet.ibm.com,
 mgorman@techsingularity.net,  yi.z.zhang@linux.intel.com
Date: Tue, 12 Mar 2019 15:50:36 -0700
In-Reply-To: <20190312150727.cb15cbc323a742e520b9a881@linux-foundation.org>
References: 
	<154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
	 <154361479877.7497.2824031260670152276.stgit@ahduyck-desk1.amr.corp.intel.com>
	 <20181205172225.GT1286@dhcp22.suse.cz>
	 <19c9f0fe83a857d5858c386a08ca2ddeba7cf27b.camel@linux.intel.com>
	 <20181205204247.GY1286@dhcp22.suse.cz>
	 <20190312150727.cb15cbc323a742e520b9a881@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-03-12 at 15:07 -0700, Andrew Morton wrote:
> On Wed, 5 Dec 2018 21:42:47 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > I got your explanation. However Andrew had already applied the patches
> > > and I had some outstanding issues in them that needed to be addressed.
> > > So I thought it best to send out this set of patches with those fixes
> > > before the code in mm became too stale. I am still working on what to
> > > do about the Reserved bit, and plan to submit it as a follow-up set.
> > > From my experience Andrew can drop patches between different versions of
> > the patchset. Things can change a lot while they are in mmotm and under
> > the discussion.
> 
> It's been a while and everyone has forgotten everything, so I'll drop
> this version of the patchset.
> 

As far as getting to the reserved bit I probably won't have the time in
the near future. If I were to resubmit the first 4 patches as a
standalone patch set would that be acceptable, or would they be held up
as well until the reserved bit issues is addressed?

- Alex



