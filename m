Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E654AC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:45:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEB2420863
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:45:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEB2420863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 502AE6B0007; Mon, 25 Mar 2019 12:45:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B25E6B0008; Mon, 25 Mar 2019 12:45:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 354C76B000A; Mon, 25 Mar 2019 12:45:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE03A6B0007
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 12:45:13 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g83so10077797pfd.3
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 09:45:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ztjnRBMg/NxK+mAWIpF+P6fDPIGVkIMF4Of6+/FJOw8=;
        b=UC7aoPjfB9I4oWZONTSqDf7DV6cqUkkyfKv6iOCWIwxnhUmJHacD6f2/ORx7FWK8Wc
         5MHkP7n4RvK8cLv/ytle92H5IE1Mj8rjNRQwTXhrlcW46YWrZlS7sF55RAn3YcZeauQv
         7KwCHQ2Minqtbw+NnKxbJUDbn3cDwRUOoy8+d5g4HUDuyCPC7uJgHY/6Li4JjhUU5Dfy
         a6/kgqwrdVayDa9B4u5ewIk5fPCdT59FaevRJ/ZUsHwxkJ2DcKEPfBZWO6oZTeSpllXD
         voHpTJiHE6iOUW1tkghEGWVJH82brF4m5FRLtaFv4Cry7lXTanhLGHkXRbB2GWEdAoG7
         sxBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUdUP8s2aaV7yZR8p3isviowMg0KMixlITikPCyqEkx6XP5V3Nk
	4i4SsTU+IaxqlBYH1SO2Ng4C5tGy7MarVYUnV/iHjOHx2PuSrB/vWr/rprlpcTgq3hZESzL7LiC
	cNBKXMgtytDT94e8FI81+x/MqHeBBWXg5+5+Dt0flDZuKDYEUqBZ0wcaUWDu04rCmTQ==
X-Received: by 2002:a17:902:b713:: with SMTP id d19mr10198405pls.54.1553532313661;
        Mon, 25 Mar 2019 09:45:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyht/YQYlUMxZJlXXzOrlW71XyVO/HM7oEGnYwlTHFYhV4mK6ABQrndvljqSFEMj1NDvvXp
X-Received: by 2002:a17:902:b713:: with SMTP id d19mr10198347pls.54.1553532313048;
        Mon, 25 Mar 2019 09:45:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553532313; cv=none;
        d=google.com; s=arc-20160816;
        b=nQXtM6PKuFfoVPt6DsulXDPAul8Vi0CU5OjnoDbuPEAOi75WcLbW0iYxlkDYZwLJcB
         UvpserG2uv9nUcSVX7NUsCR9vw11cma4Q5qdyUtEcr1KuAxkeQoJf19E0yC6b4e/FQUB
         NGwJc37oaOJBySX/UvMjwvOCE20AEI+JT8NsYiOxfrEZPH9IKk9tH+zPnQd1mS9P6BEy
         GUVQTHNGuDgFRuRBhCXQKUdxLOD7YhxWUVN+gaASFBF8kpJFZXZnho9n976cZyqH2CYP
         BytQr9VSCSQxn99rjAObgqzCIFLubP3YSTfqyeaGMc94QYrmc66kI8Q6XVhduY79o5XM
         ICYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ztjnRBMg/NxK+mAWIpF+P6fDPIGVkIMF4Of6+/FJOw8=;
        b=p+TO3cbSXm+tR0El+nAay2TCpdPEUdQKUAWaTLIZVw4lxQWZBRmAbcLSKLy0kjg+0z
         CfXrnwYT9ZvQLmBi9Bb2hH/e2zwEwOfINR4ixD1pUxvZapf5FLDOH+wRVwf1uX8dYYw9
         C6u9TldLXpJQyo2tOdRKqcPcgbn2Rwx22Bo5mXzVRRyC8dHjX8pYFT+1Ee17X3ItvDV5
         rTX8Bbwzq4nN2c3TGHbFAtSj74E6/B6YEbPbMz0orYidbn4teyXmF8DU/sB2onvrkoPU
         cR7IBXpeA/QO0ls3VWs5njkGeNY+MAgvP74vQ1QUxe5t/HJkX9jRy09OVh6a2jERQlSN
         5oDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id o8si14473344pfh.136.2019.03.25.09.45.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 09:45:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Mar 2019 09:45:12 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,269,1549958400"; 
   d="scan'208";a="125726528"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga007.jf.intel.com with ESMTP; 25 Mar 2019 09:45:11 -0700
Date: Mon, 25 Mar 2019 01:43:59 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
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
Subject: Re: [RESEND 5/7] IB/hfi1: Use the new FOLL_LONGTERM flag to
 get_user_pages_fast()
Message-ID: <20190325084359.GD16366@iweiny-DESK2.sc.intel.com>
References: <20190317183438.2057-1-ira.weiny@intel.com>
 <20190317183438.2057-6-ira.weiny@intel.com>
 <CAA9_cmdQjMekSFU09gLc87-PVx2iHeeh2jC6KeFY1UeadpPh4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9_cmdQjMekSFU09gLc87-PVx2iHeeh2jC6KeFY1UeadpPh4A@mail.gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 03:14:26PM -0700, Dan Williams wrote:
> On Sun, Mar 17, 2019 at 7:36 PM <ira.weiny@intel.com> wrote:
> >
> > From: Ira Weiny <ira.weiny@intel.com>
> >
> > Use the new FOLL_LONGTERM to get_user_pages_fast() to protect against
> > FS DAX pages being mapped.
> >
> > Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> > ---
> >  drivers/infiniband/hw/hfi1/user_pages.c | 6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
> > index 78ccacaf97d0..6a7f9cd5a94e 100644
> > --- a/drivers/infiniband/hw/hfi1/user_pages.c
> > +++ b/drivers/infiniband/hw/hfi1/user_pages.c
> > @@ -104,9 +104,11 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
> >                             bool writable, struct page **pages)
> >  {
> >         int ret;
> > +       unsigned int gup_flags = writable ? FOLL_WRITE : 0;
> 
> Maybe:
> 
>     unsigned int gup_flags = FOLL_LONGTERM | (writable ? FOLL_WRITE : 0);
> 
> ?

Sure looks good.

Ira

> 
> >
> > -       ret = get_user_pages_fast(vaddr, npages, writable ? FOLL_WRITE : 0,
> > -                                 pages);
> > +       gup_flags |= FOLL_LONGTERM;
> > +
> > +       ret = get_user_pages_fast(vaddr, npages, gup_flags, pages);
> >         if (ret < 0)
> >                 return ret;
> >
> > --
> > 2.20.1
> >
> 

