Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51F60C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:22:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E89E2082F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:22:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E89E2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1E086B0007; Mon, 25 Mar 2019 18:22:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA4846B0008; Mon, 25 Mar 2019 18:22:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A48156B000A; Mon, 25 Mar 2019 18:22:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 66BBC6B0007
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 18:22:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id p8so4290842pfd.4
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 15:22:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kBYvYqhG60ETdU1ejGn9ABkj+I7t2tDa9xJt7/kf8fI=;
        b=Zr5n+JVmtyJ4YgHqmevyMybFDR37GPZqFsoJPSGpU1tWpcLpL3uAE4dutLdGEqetDq
         uAfxERmwTQSQ0u1Im7vDGu/mClozvkFyv30T8GFkzkgZWJKpF+mXHHYJKFel+/0ntWg5
         pY4gSwimXCMiKeg0f7+/VOp4ho/VyqfZILT/e6ME1mwuW5R29/FTjk9P9ixx0zNXZAxP
         vq2N8+5Ak6wRpGBmc4HZNxedcHDB/papRO9p1Ukn0bWKeR3IE5bPq+bP3YpNb0RgromZ
         Tx0Dw9LE9hwjd4T5JuRlX0h/w0wEIwQFtwgFhKAzrOawko5cQytNX6gKZARDhTrhVr0S
         aG9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXuiAZPP1HzDgTGIflFuP8RhSJkNLKU9fKgtWmf/slY4CoHuDzi
	Xsyxubv6r/yEIt+FZLpSHiO8+WHONAmbAHjBZB6WzCp2/j6JV5LAjcGtg0s8NwAzyyEeqKBpPNm
	0h8N+yUKkHIMoMs8CdFzZUAy77tktilNCY0+gmrdjExN+7mQKHYXl/ON++H8pvJgNIA==
X-Received: by 2002:a17:902:501:: with SMTP id 1mr26996699plf.72.1553552558083;
        Mon, 25 Mar 2019 15:22:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeyB6YjHaEmHTbysi6VpzMANhMfqFMDx+d+4XEiIKzcQ3rbTHf9R+L6o6EEOsZzocZvx1K
X-Received: by 2002:a17:902:501:: with SMTP id 1mr26996651plf.72.1553552557312;
        Mon, 25 Mar 2019 15:22:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553552557; cv=none;
        d=google.com; s=arc-20160816;
        b=gQEfBhKoqfHIr9iPL38cMIOn1zfjUjIw1sB6x7MTrGm1247UQLuMluU7SEvNYoQkS+
         GHF9ng2uyLQYf7I/lpy68QC9P4WsedGWT+fxrGJt9edHUF7KeYB69f7m9oaOMpH/CF6n
         orgqplxj9kvFsfeiZbLCb9ux+MF9L6ZLTpQn54sZrhISOEyVuq4fQpT4CV6i4f/Dqqkn
         QNgRPQFQfjD64gOrzdPhLKeVxLCYP4UfnusqFyndEkZZyBvArLtE6bm0Smr1k1deCGyG
         Tvw/KYCZST9EYO2YhkgCU739JVnysSzOyHWTGhn6YGPbPukCaYJrc08CnABlGHOEuie1
         yTug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kBYvYqhG60ETdU1ejGn9ABkj+I7t2tDa9xJt7/kf8fI=;
        b=j53Sn3x5szFal6chmGStcMf41ufh0hLs6RM/I1ryT0ggVx4LODZWdDzienzNZMkCn1
         EPJIP3sHUUH6d3KBKzykBkOZfn5jyd9zZH7iejysxf39LGJCQVqZdcjkb8z73LxkafF1
         oxPHWDi9ibFJlfe6hQGssxws5g7oCn1z0v/NfkU0urDKjIsFX88Aqzufzbu1nopUlivC
         cOya4tY2YUKexXWbEqSnzXnKOoRgpJzt0fWfMdgIDHRNp9lkY7agiu3Vn3KCMW2XZrj7
         fTPUQaRtU1DlpjVewRjeoq1SwScM2mDmz6EoVW51qjah1L/FfhlXZmNq5Zq1sAM562FD
         TDfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k71si11560972pgd.583.2019.03.25.15.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 15:22:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Mar 2019 15:22:36 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,270,1549958400"; 
   d="scan'208";a="143760397"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by FMSMGA003.fm.intel.com with ESMTP; 25 Mar 2019 15:22:36 -0700
Date: Mon, 25 Mar 2019 07:21:25 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>,
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
	linux-rdma@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: [RESEND 4/7] mm/gup: Add FOLL_LONGTERM capability to GUP fast
Message-ID: <20190325142125.GH16366@iweiny-DESK2.sc.intel.com>
References: <20190317183438.2057-1-ira.weiny@intel.com>
 <20190317183438.2057-5-ira.weiny@intel.com>
 <CAA9_cmcx-Bqo=CFuSj7Xcap3e5uaAot2reL2T74C47Ut6_KtQw@mail.gmail.com>
 <20190325084225.GC16366@iweiny-DESK2.sc.intel.com>
 <20190325164713.GC9949@ziepe.ca>
 <20190325092314.GF16366@iweiny-DESK2.sc.intel.com>
 <20190325175150.GA21008@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190325175150.GA21008@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 02:51:50PM -0300, Jason Gunthorpe wrote:
> On Mon, Mar 25, 2019 at 02:23:15AM -0700, Ira Weiny wrote:
> > > > Unfortunately holding the lock is required to support FOLL_LONGTERM (to check
> > > > the VMAs) but we don't want to hold the lock to be optimal (specifically allow
> > > > FAULT_FOLL_ALLOW_RETRY).  So I'm maintaining the optimization for *_fast users
> > > > who do not specify FOLL_LONGTERM.
> > > > 
> > > > Another way to do this would have been to define __gup_longterm_unlocked with
> > > > the above logic, but that seemed overkill at this point.
> > > 
> > > get_user_pages_unlocked() is an exported symbol, shouldn't it work
> > > with the FOLL_LONGTERM flag?
> > > 
> > > I think it should even though we have no user..
> > > 
> > > Otherwise the GUP API just gets more confusing.
> > 
> > I agree WRT to the API.  But I think callers of get_user_pages_unlocked() are
> > not going to get the behavior they want if they specify FOLL_LONGTERM.
> 
> Oh? Isn't the only thing FOLL_LONGTERM does is block the call on DAX?

From an API yes.

> Why does the locking mode matter to this test?

DAX checks for VMA's being Filesystem DAX.  Therefore, it requires collection
of VMA's as the GUP code executes.  The unlocked version can drop the lock and
therefore the VMAs may become invalid.  Therefore, the 2 code paths are
incompatible.

Users of GUP unlocked are going to want the benefit of FAULT_FOLL_ALLOW_RETRY.
So I don't anticipate anyone using FOLL_LONGTERM with
get_user_pages_unlocked().

FWIW this thread is making me think my original patch which simply implemented
get_user_pages_fast_longterm() would be more clear.  There is some evidence
that the GUP API was trending that way (see get_user_pages_remote).  That seems
wrong but I don't know how to ensure users don't specify the wrong flag.

> 
> > What I could do is BUG_ON (or just WARN_ON) if unlocked is called with
> > FOLL_LONGTERM similar to the code in get_user_pages_locked() which does not
> > allow locked and vmas to be passed together:
> 
> The GUP call should fail if you are doing something like this. But I'd
> rather not see confusing specialc cases in code without a clear
> comment explaining why it has to be there.

Code comment would be necessary, sure.  Was just throwing ideas out there.

Ira

