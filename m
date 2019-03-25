Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E56C6C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:55:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB9EF206C0
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:55:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB9EF206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 488516B0003; Mon, 25 Mar 2019 18:55:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 438C36B0006; Mon, 25 Mar 2019 18:55:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3277A6B000D; Mon, 25 Mar 2019 18:55:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF50E6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 18:55:25 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y2so10634594pfl.16
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 15:55:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KeZjZ5F9zGathCuTVY7O0jvE4FRmDsDZ8gbaXBhjS0A=;
        b=SRyZpfsxOFbCMi1zNctvkEAuNzqvAaMnbAqUEaRHF9qYYH0Bp/BvMZq/VrzpT26/HE
         DvqnHTVoJBEIBV50L5ltfR9C4eRbCzWwFUN5hOP21IQ/C7vqvLynXrazmJTsynL3kyfb
         M1MbqI9i6TyIqsfPRMsrFvnYQbE6bs9xiFXTqdC+F1unZISVuZru2mS1dmCHgTm20Rkr
         havxL0WT00FLXupNo6R4KijOjxZaQ4JDYyqzwVxPGqHpQQWffYoxp+92jNXOanf8fVd+
         FY0dqlTWz8VgVL8GfYcLmUn02ZJCVyM5d5xltEgH29WgdHJuQl+9XI3hM/hZdeYxbsG2
         XhYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUlPR9W2h2u4l0M41pxKvBI2QHyybsuvoQwxbYO8kWHp0tIGe9J
	sO5B9ydyV6iq1ihrJtQqGzANnJ6iqS9CKirRmB8HrjU3apVQhm865l8jnF5dv7mw+DqJCxRjq8B
	xlZvXUjeseLy9Qwkz7IyYblX8vPgGEt2ZFw9Oh4O7tCHcT39lfP3qoKd02/YiElgxsg==
X-Received: by 2002:a63:4383:: with SMTP id q125mr24098276pga.370.1553554525582;
        Mon, 25 Mar 2019 15:55:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzu4KZrPT9P/U7MYrlG5Rro8VSrPtyDpy9cb9WgujmB/n4VVBpQY5AeU4SZDQm1wgN42A3G
X-Received: by 2002:a63:4383:: with SMTP id q125mr24098236pga.370.1553554524861;
        Mon, 25 Mar 2019 15:55:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553554524; cv=none;
        d=google.com; s=arc-20160816;
        b=k6/rtkl4F0AnDLZY9Jk1EDt+N/RAWfFEDwB424P9sPd3I/Z5+pGB2uHfls7qnPKzs0
         gXVmv+FEIf5NSWVmyeECKYhZyUoDOJALOtfj6fMGFlLCrZtijZJkqs7dwXqZXwV7/res
         xX/Tf1Cssxi788aQO1RmkqHNDk1ELvifhYm6YEbFDpu5R4W9GIRPhyE7oWNPt8SuKx/O
         D/nHZxH3O0f3wXBKVrsWPiqP2n+fbl+nengV2TIa404vcng8XMVOKvr0TVbe7F7WTJmb
         vcKIO5b7I5hO2Y57g/0nHCzRJxlK/lRDRruEx428mAFC3fLV08PRJkWaQbcg+/caq7/o
         TLIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KeZjZ5F9zGathCuTVY7O0jvE4FRmDsDZ8gbaXBhjS0A=;
        b=HEfMz/EoSVS146YcFsyGbBrc5SkglHpErgpWjOvABaJlM6m4cqV9kuMhhIapRO4jFS
         ztAF6RvYxT+U9cBkLqOkVk36m1fTQpVLk0E2YW4xX/6E7/5pvfx6J+HtJDnAEO2TPJja
         D9vTjtuy1UnrdGz4VDIIJc9x2wLHtF4Wm2GFy22rbvCMheYYrPs3XuPiryHc+TzQl9al
         gziFzXAujjNJ3qZCpA3tPz1ypODkSDmWiWbx4InjYtVVzI1ROmzzRa3LPU+BXPV/iRJp
         jlsEu6bnSo4tbpvlGO7CHO/dykOLAVbMBmbOrRNSZ/c/w2ztlB2cfYaWYoScxm3ti6hy
         hIGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z3si15010185pgr.90.2019.03.25.15.55.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 15:55:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Mar 2019 15:55:24 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,270,1549958400"; 
   d="scan'208";a="137221326"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 25 Mar 2019 15:55:22 -0700
Date: Mon, 25 Mar 2019 07:54:11 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-mips@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	linux-s390 <linux-s390@vger.kernel.org>,
	Linux-sh <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: [RESEND 4/7] mm/gup: Add FOLL_LONGTERM capability to GUP fast
Message-ID: <20190325145411.GI16366@iweiny-DESK2.sc.intel.com>
References: <20190317183438.2057-1-ira.weiny@intel.com>
 <20190317183438.2057-5-ira.weiny@intel.com>
 <CAA9_cmcx-Bqo=CFuSj7Xcap3e5uaAot2reL2T74C47Ut6_KtQw@mail.gmail.com>
 <20190325084225.GC16366@iweiny-DESK2.sc.intel.com>
 <20190325164713.GC9949@ziepe.ca>
 <20190325092314.GF16366@iweiny-DESK2.sc.intel.com>
 <20190325175150.GA21008@ziepe.ca>
 <20190325142125.GH16366@iweiny-DESK2.sc.intel.com>
 <CAPcyv4hG8WDhsWinXHYkReHKS6gdQ3gAHMcfVWvuP4c4SYBzXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hG8WDhsWinXHYkReHKS6gdQ3gAHMcfVWvuP4c4SYBzXQ@mail.gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 03:36:28PM -0700, Dan Williams wrote:
> On Mon, Mar 25, 2019 at 3:22 PM Ira Weiny <ira.weiny@intel.com> wrote:
> [..]
> > FWIW this thread is making me think my original patch which simply implemented
> > get_user_pages_fast_longterm() would be more clear.  There is some evidence
> > that the GUP API was trending that way (see get_user_pages_remote).  That seems
> > wrong but I don't know how to ensure users don't specify the wrong flag.
> 
> What about just making the existing get_user_pages_longterm() have a
> fast path option?

That would work but was not the direction we agreed upon before.[1]

At this point I would rather see this patch set applied, focus on fixing the
filesystem issues, and once that is done determine if FOLL_LONGTERM is needed
in any GUP calls.

Ira

[1] https://lkml.org/lkml/2019/2/11/2038

