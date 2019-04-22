Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1173C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 12:23:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5325420811
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 12:23:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5325420811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E23616B0003; Mon, 22 Apr 2019 08:23:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA9736B0006; Mon, 22 Apr 2019 08:23:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4BF56B0007; Mon, 22 Apr 2019 08:23:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id A0C406B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 08:23:26 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id z19so7521047qkj.5
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 05:23:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JYnUSwIHXQmchYq7l6wkzAg1jaXrA8yfR9AmIFNunsE=;
        b=VYLB1upxjQHOoAoxb2tc6YmQcXL4Ky7Q3ymDIbQ7aolWPNgHbIbOjOFbpBkDfufG+T
         pJwA8G2/vOlWsTxiViANSgki0vG4OMNVsl9bSg+WFyswBhxB0JzmXNAeZLJmYhxEsuPG
         SfCT4ozsp23qHwj1xPnBMQ+3Z0p28ElS8ygBj4P/Avuoa1cXt4we4tFzvhNcQoWCPSIh
         XGo/PGNFsE6FwWKRcIVIUrxWi1LABhLadpZwo4FYRCaOlYjQHSjToX45W/wKj5lrDe/O
         8+2bP0tchJ8JLt8xWP4PmF4l42iaQYZnzj7aahq6HhOxybB/5yXT3pSy+YPGR6sPIVc6
         MrLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXDpYkQgdymufm6p25ELYJxP/yVLTXcPukMjhtDdxFOLJAjYPeB
	cPXREHoWMZUqJwWeZeLdii7zlePmAs3P2cSEa7jfTM7YY/CWW+IOsgpePs261m+LDXinjf9j+GT
	L82SQcmQCu9nrezbdQC1e77xhCcT3aEs6xJ8oaqIw7RE71hkVIiGubJ9BmNMceyy16g==
X-Received: by 2002:ae9:e309:: with SMTP id v9mr2634414qkf.121.1555935806412;
        Mon, 22 Apr 2019 05:23:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBeA3onFTGZfdu2BXmbw97Uxxb+B/u1zAXRZcto0bHqbVS0unZeIkeQQNCUr1O4IyddLA5
X-Received: by 2002:ae9:e309:: with SMTP id v9mr2634381qkf.121.1555935805825;
        Mon, 22 Apr 2019 05:23:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555935805; cv=none;
        d=google.com; s=arc-20160816;
        b=eTVuQqxa3kxujreie6iI8caH5HxveTEDUpAn7GsLZXjTxTqKEq5aiXoeIUVYnT8grl
         3O9kNv3YpTm2Ni8sXCl0LeffY/XudUwpFJuX4rT1jZK1JL2J2rzu8dgvGU+xtEq2o2UI
         vloUE6+5wXolJFWRlb9F9FDeILTkUIdvERjdu6BmIWt9cD1j5IzQktMCICJKLL4oOvGa
         /yKGlxKqcMApDrCyMkcDYtqWTI4M3SWPr+Up3DB/SWf/uRtxFat16vUp8gEj4MUbZiSp
         hyfRsnmLgHW6XDiWiNkFR7PU88gu2DtpXPDxQrp8TtFe9lM6/XJFBBFOavIg8uFi2v7Q
         tCWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JYnUSwIHXQmchYq7l6wkzAg1jaXrA8yfR9AmIFNunsE=;
        b=gSTFTi5boJeLQNxjuVFLTmgN9tyDVgXTckZN2UdDDLVg6qKPao4OUmNnGvaZcmh33K
         OAnTMq7Bi+bZqn9urQRLe9IANrHaHwNAstFjzWfuuwFBoyATSB9ONMY20+Rx7aOsd8Xu
         B95vZagWlBzytXryeJzE/ECqGApyurvjEhNBAZR5G0ZcPfSW+mf6seEPVcIvmwKjVETm
         5M50GszIJv1UjG1UK2mUXxCeRMZWtX8BVDfayj50rS+Q2sOGdoyxVq/6Tw5RLgh59T4x
         OBndXBS6nTrVVykXpN8pXnvlw2OD8oZP4qzgLEsGT3E37IqvYQl0ynXAU2ExtWvLn7j6
         e/hw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q26si8825435qvc.217.2019.04.22.05.23.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 05:23:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D666CC0495A3;
	Mon, 22 Apr 2019 12:23:24 +0000 (UTC)
Received: from xz-x1 (ovpn-12-23.pek2.redhat.com [10.72.12.23])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 41BBC1A8F4;
	Mon, 22 Apr 2019 12:23:15 +0000 (UTC)
Date: Mon, 22 Apr 2019 20:23:12 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v3 17/28] userfaultfd: wp: support swap and page migration
Message-ID: <20190422122312.GB25896@xz-x1>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-18-peterx@redhat.com>
 <20190418205907.GL3288@redhat.com>
 <20190419074220.GG13323@xz-x1>
 <20190419150802.GB3311@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190419150802.GB3311@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Mon, 22 Apr 2019 12:23:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 11:08:02AM -0400, Jerome Glisse wrote:
> On Fri, Apr 19, 2019 at 03:42:20PM +0800, Peter Xu wrote:
> > On Thu, Apr 18, 2019 at 04:59:07PM -0400, Jerome Glisse wrote:
> > > On Wed, Mar 20, 2019 at 10:06:31AM +0800, Peter Xu wrote:
> > > > For either swap and page migration, we all use the bit 2 of the entry to
> > > > identify whether this entry is uffd write-protected.  It plays a similar
> > > > role as the existing soft dirty bit in swap entries but only for keeping
> > > > the uffd-wp tracking for a specific PTE/PMD.
> > > > 
> > > > Something special here is that when we want to recover the uffd-wp bit
> > > > from a swap/migration entry to the PTE bit we'll also need to take care
> > > > of the _PAGE_RW bit and make sure it's cleared, otherwise even with the
> > > > _PAGE_UFFD_WP bit we can't trap it at all.
> > > > 
> > > > Note that this patch removed two lines from "userfaultfd: wp: hook
> > > > userfault handler to write protection fault" where we try to remove the
> > > > VM_FAULT_WRITE from vmf->flags when uffd-wp is set for the VMA.  This
> > > > patch will still keep the write flag there.
> > > > 
> > > > Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > > 
> > > Some missing thing see below.
> > > 
> > > [...]
> > > 
> > > > diff --git a/mm/memory.c b/mm/memory.c
> > > > index 6405d56debee..c3d57fa890f2 100644
> > > > --- a/mm/memory.c
> > > > +++ b/mm/memory.c
> > > > @@ -736,6 +736,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> > > >  				pte = swp_entry_to_pte(entry);
> > > >  				if (pte_swp_soft_dirty(*src_pte))
> > > >  					pte = pte_swp_mksoft_dirty(pte);
> > > > +				if (pte_swp_uffd_wp(*src_pte))
> > > > +					pte = pte_swp_mkuffd_wp(pte);
> > > >  				set_pte_at(src_mm, addr, src_pte, pte);
> > > >  			}
> > > >  		} else if (is_device_private_entry(entry)) {
> > > 
> > > You need to handle the is_device_private_entry() as the migration case
> > > too.
> > 
> > Hi, Jerome,
> > 
> > Yes I can simply add the handling, but I'd confess I haven't thought
> > clearly yet on how userfault-wp will be used with HMM (and that's
> > mostly because my unfamiliarity so far with HMM).  Could you give me
> > some hint on a most general and possible scenario?
> 
> device private is just a temporary state with HMM you can have thing
> like GPU or FPGA migrate some anonymous page to their local memory
> because it is use by the GPU or the FPGA. The GPU or FPGA behave like
> a CPU from mm POV so if it wants to write it will fault and go through
> the regular CPU page fault.
> 
> That said it can still migrate a page that is UFD write protected just
> because the device only care about reading. So if you have a UFD pte
> to a regular page that get migrated to some device memory you want to
> keep the UFD WP flags after the migration (in both direction when going
> to device memory and from coming back from it).
> 
> As far as UFD is concern this is just another page, it just does not
> have a valid pte entry because CPU can not access such memory. But from
> mm point of view it just another page.

I see the point.  Thanks for explaining that!

-- 
Peter Xu

