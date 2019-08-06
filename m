Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5DA9C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:25:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83541216F4
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:25:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83541216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 284376B000A; Tue,  6 Aug 2019 17:25:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25A7E6B000C; Tue,  6 Aug 2019 17:25:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 149BD6B000D; Tue,  6 Aug 2019 17:25:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D4C686B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 17:25:05 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x10so56777288pfa.23
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 14:25:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=WmYq8/RzGfPtUhY+ApVR9bsohbv/vIQGCTG3CCxvwTc=;
        b=osgg5zF5QPtatzpR4ZF4BVfURJ9QmE4W2WKC+KhhDTlidAvPefwnGEsmfK6cGAS70k
         f6HTL+4pVjCIsIAO1ZmYhNR28kp4/vYEVegaWPMeN4Ynl0Gjsos+v4I6WzKK3KFNW+wA
         3y044VYOOItzY3bo+tD/nwhBBbBPZo48Au9UG+/iVS2w2mipDDAZS640ZBYGqveC7+qz
         8ebR1xgc55bGHcHFbPTJvnq/a0Sj00+qyRaWM+pxm7rLp/cr5SHOzS6UHmFeiUKxkd62
         13y1t8hafXKDQSswCX1nWZSOPrMSMADmSOie1bg6MRbXN6Lq0OmplSZNrT9/5oRu2Ow5
         bl9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVGosYcziXbkx63lbmZCGk4dG83jLFXNQ6nA8+oNOVrOEWgHLwx
	E7L/I6ihvm+w3EawCNsnNyevh/4bn9oB9YAsm+gEjhp2Bi5N5ze9LNYkNUF5bqA+NiWR7SeMqqW
	X6+fSa3OoGSz4+oMrv2E090gdPGL85Qel0gCnw3KYD/Go+f70HnPbsOqC4DKIPSUUTQ==
X-Received: by 2002:a63:550e:: with SMTP id j14mr4291833pgb.302.1565126705395;
        Tue, 06 Aug 2019 14:25:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRxMUHRkAMn76vvxj8xneBJ7GjNwvtcFQvc+3x9ow5wHwe5VihIumpgSWrp8/fc4Py2vVJ
X-Received: by 2002:a63:550e:: with SMTP id j14mr4291811pgb.302.1565126704669;
        Tue, 06 Aug 2019 14:25:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565126704; cv=none;
        d=google.com; s=arc-20160816;
        b=SiWrEmi5hRkYAik57oarJVpnNWxTop67qTw6fzadqimvsJT36X58A7iGjTrMtXk881
         b7pWdY/DMh3VwAfplvnKa+zI+ASkdXXRhJlQrNem8h5sHSDpTixaQWCXl3yze/9KM4Ij
         js+OtCUVH0LakFzpHC96oFv3psIqi+KMsJMZoe3O/FYG/0MpHyI07HVf1M4kvHzCdLkH
         VCLcsHtsvQSxG/XtNin55YdOFijmMhr8wT36O5DLCTZ2zwePMyrXPCihIM1S4VkjvbJp
         8R9xHWhlGUhgJYxPjfZT5sQhfhNJu32KfHzHawKF73RNkTYK9JX/lGDSsOvy6anhZYhV
         n5kQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=WmYq8/RzGfPtUhY+ApVR9bsohbv/vIQGCTG3CCxvwTc=;
        b=Z9w7Nn1FVu6lpSyXXjU3BEzxs8bnZTmVJi4v3kuk74gZtjRQhd2pAHGbQg/IqFp2TO
         vdHvnGKXa9NsrzctyDYDZfbVkIURZrAYyBoDlsL61JL7zzBBCml/HKuLZw/dWChj1CxX
         7A6v8mElXeV4Ukln6qOn97HsDECiNdESjDx0CXhyLh4qLVwbpgSQfm/ZKmbr/pIGmkyz
         yWCRxAkuZq5CA/hJfQYLlLB5VG4Ta37JeiLXPqOeiFOOJdeexBppXuNjm95AN3ZYUs+A
         6D1ZX+iJWgoC93xLBsgXOif/cSMar6Pcc2gfmluoqKf7fRERweze3lelLzJBwVQdg6j6
         dl1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id v4si42272856plp.212.2019.08.06.14.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 14:25:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Aug 2019 14:25:04 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,353,1559545200"; 
   d="scan'208";a="165111737"
Received: from sai-dev-mach.sc.intel.com ([143.183.140.153])
  by orsmga007.jf.intel.com with ESMTP; 06 Aug 2019 14:25:03 -0700
Message-ID: <25c28a6e5137aa396bc13a2f581566e13e98f45e.camel@intel.com>
Subject: Re: [PATCH V2] fork: Improve error message for corrupted page tables
From: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com,
  Ingo Molnar <mingo@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter
 Zijlstra <peterz@infradead.org>,  Andrew Morton
 <akpm@linux-foundation.org>, Anshuman Khandual <anshuman.khandual@arm.com>
Date: Tue, 06 Aug 2019 14:21:54 -0700
In-Reply-To: <20190806083605.GA19060@dhcp22.suse.cz>
References: 
	<3ef8a340deb1c87b725d44edb163073e2b6eca5a.1565059496.git.sai.praneeth.prakhya@intel.com>
	 <20190806083605.GA19060@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5-0ubuntu0.18.10.1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-08-06 at 10:36 +0200, Michal Hocko wrote:
> On Mon 05-08-19 20:05:27, Sai Praneeth Prakhya wrote:
> > When a user process exits, the kernel cleans up the mm_struct of the user
> > process and during cleanup, check_mm() checks the page tables of the user
> > process for corruption (E.g: unexpected page flags set/cleared). For
> > corrupted page tables, the error message printed by check_mm() isn't very
> > clear as it prints the loop index instead of page table type (E.g:
> > Resident
> > file mapping pages vs Resident shared memory pages). The loop index in
> > check_mm() is used to index rss_stat[] which represents individual memory
> > type stats. Hence, instead of printing index, print memory type, thereby
> > improving error message.
> > 
> > Without patch:
> > --------------
> > [  204.836425] mm/pgtable-generic.c:29: bad p4d
> > 0000000089eb4e92(800000025f941467)
> > [  204.836544] BUG: Bad rss-counter state mm:00000000f75895ea idx:0 val:2
> > [  204.836615] BUG: Bad rss-counter state mm:00000000f75895ea idx:1 val:5
> > [  204.836685] BUG: non-zero pgtables_bytes on freeing mm: 20480
> > 
> > With patch:
> > -----------
> > [   69.815453] mm/pgtable-generic.c:29: bad p4d
> > 0000000084653642(800000025ca37467)
> > [   69.815872] BUG: Bad rss-counter state mm:00000000014a6c03
> > type:MM_FILEPAGES val:2
> > [   69.815962] BUG: Bad rss-counter state mm:00000000014a6c03
> > type:MM_ANONPAGES val:5
> > [   69.816050] BUG: non-zero pgtables_bytes on freeing mm: 20480
> 
> I like this. On any occasion I am investigating an issue with an rss
> inbalance I have to go back to kernel sources to see which pte type that
> is.
> 

Hopefully, this patch will be useful to you the next time you run into any rss
imbalance issues.

> > Also, change print function (from printk(KERN_ALERT, ..) to pr_alert()) so
> > that it matches the other print statement.
> 
> good change as well. Maybe we should also lower the loglevel (in a
> separate patch) as well. While this is not nice because we are
> apparently leaking memory behind it shouldn't be really critical enough
> to jump on normal consoles.

Ya.. I think, probably could be lowered to pr_err() or pr_warn().

Regards,
Sai

