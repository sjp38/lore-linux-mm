Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F3EBC31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 13:55:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C96C20B1F
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 13:55:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DyjaHPUe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C96C20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2A336B0003; Wed, 12 Jun 2019 09:55:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDAF96B0005; Wed, 12 Jun 2019 09:55:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF1E76B0006; Wed, 12 Jun 2019 09:55:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0EE6B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 09:55:12 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i33so9828388pld.15
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 06:55:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=JuCNsBgKz2kjwwU2iDU7wV4lSMUa82jMKbRvCjaKNYk=;
        b=DKCj5x/LEteo12Pl6f0PlvP5F41uhewgkFKAZypoFnuJ2YeRmttCc/fB2tFmrMbdn6
         5EZ52TIAvrmDhbPZgRkvL7QSssk0z6Z/T2oevQtroRePupONPUge16hEFRsDZEhL5SwS
         ozbk539ZBF5LgK0u1/CRmFXH1VEHWYblQ1xw4tFk3BMRgl+BiWcz70JJ6sK634mqeTKu
         tIgvsquAljxnNwAYEWgbKupulB86SYnjqqKjW0BGkAKu8gmdBWoCkokYQN3OdRvlF7J5
         RqMBS5kPpLyWDySKcrMDyzNO5a+5VssBKYGc8IpD/1orFyCH1CelTBqK9x4HZdL42VIY
         SR1A==
X-Gm-Message-State: APjAAAVhGHiJkAtUn9E8tl2yIVBQw0kI1Kojnlso07jkv1wJ4DaYSbRU
	MzbbPMDZNTLm/J6B+i3HL8APO5tTykvjxZB1vw5Eyf5gK74lQ04WbzDQFODxqRWdXFGt0DU7+x5
	XJYJ44OUU1IcDHv/gy3VcakmpZvlS6yh3Fgser50ciMW3/L7j/mcxLgiTG7ScKmYRRQ==
X-Received: by 2002:a63:f349:: with SMTP id t9mr17498555pgj.296.1560347711781;
        Wed, 12 Jun 2019 06:55:11 -0700 (PDT)
X-Received: by 2002:a63:f349:: with SMTP id t9mr17498486pgj.296.1560347710637;
        Wed, 12 Jun 2019 06:55:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560347710; cv=none;
        d=google.com; s=arc-20160816;
        b=HOY8TVGDw0IVOMv+aesiupDp061W39sIoGoShRFvBrPOBnpy2Vbu0a9xUf6aR/l2J2
         gnnZKPfALkvycmQhYOle+ymb3X6ldbrKOubbB/IfLTBWCCXOc6RTW8c0dpb6Hrhtkbhp
         DipS3BFj+i392bvWdGjHG/KwmofAsvHnDDcNQsLGcbSWbR/BFRF9i282n5CqRce0SHXD
         Ry31hyeZi3MtxjQhNcwHjtLDeNo1fnHrgEgvBXu/KVqkGju1/WE60LKWkMRPk5PmgWOp
         w8nPsjk5Gnf20t++rSGXfr3wWHVNdr+1czpQ7/dn4lumk7qDga9iQ1TRxrTPgh8FHjdt
         sjwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=JuCNsBgKz2kjwwU2iDU7wV4lSMUa82jMKbRvCjaKNYk=;
        b=gpmdSgpV2sdFQ/czPpsriWO887yMrB3hPf/KUaSwBAaVOQSzKn5BSMIn5giJ1Ua/Xw
         sIJT0zBGx4g+hz/VPwhww2pxaw0OPPVxpr0AU9cx+l9H+13j0VRqcKXOMOrw0vLqMaes
         KuvXFSba/Pcn63eeFRCUmH9EpehBnbtW/jB5ItWYtKupEYHKv2HI8hb28rxMJe+bMCyv
         nTrxK3ISUy9mHrH5H3EJZZCan3upGkyctLKoboSyw8eZBsT6G7Y7PD6dUVo7TeXnI4iN
         sXX+NOMNtELvHRzP/uUfQcFTgJxvJY7XvHbjPxljvFrtUlhNt5nPhGFC6AFmB0EUfcOK
         NbLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DyjaHPUe;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor14570511pgc.35.2019.06.12.06.55.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 06:55:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DyjaHPUe;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=JuCNsBgKz2kjwwU2iDU7wV4lSMUa82jMKbRvCjaKNYk=;
        b=DyjaHPUeflN5ZsbtMGDS9Y5nT5fm3yy+sEHGvi6P//QVMQd2DHb7JAQZ1QAUpVOzvJ
         N+KZ9PwASzybi0SO1U8b+EDTeErIAqt7oZT6ojvJ5s9QMF+iex62ERsVrm8o8++vfvYF
         6VIib32cQ8JALMkAgDNWQCE8e241NVPKstnWeQ2+mGDa7iuxpNCsYDcTDmmSc7BWe0jg
         XvsfjxgQKxKqyhdeezlhXKq113Cv2BhnB7TVMXccoGCXQ37WlMG42T5+DCr0X7DLsQHw
         znEQuw8W69ywX1XQ5aVKeL7n1nqWdZLqmHcAvIkalngQAuijXjBjEd8XJaWH3wKRJYE9
         2Adw==
X-Google-Smtp-Source: APXvYqxlJ7e75DsWX7egMpEWIh17YRS2EgGe1PzB66KsEeNy0SS0S0WCNWEmTNn2GsRLsUzGK7fXXQ==
X-Received: by 2002:a63:574b:: with SMTP id h11mr5323558pgm.25.1560347710137;
        Wed, 12 Jun 2019 06:55:10 -0700 (PDT)
Received: from dhcp-128-55.nay.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id j11sm2865040pfa.2.2019.06.12.06.55.05
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 06:55:09 -0700 (PDT)
Date: Wed, 12 Jun 2019 21:54:58 +0800
From: Pingfan Liu <kernelfans@gmail.com>
To: "Weiny, Ira" <ira.weiny@intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Busch, Keith" <keith.busch@intel.com>,
	Christoph Hellwig <hch@infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCHv3 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
Message-ID: <20190612135458.GA19916@dhcp-128-55.nay.redhat.com>
References: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
 <87tvcwhzdo.fsf@linux.ibm.com>
 <2807E5FD2F6FDA4886F6618EAC48510E79D8D79B@CRSMSX101.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2807E5FD2F6FDA4886F6618EAC48510E79D8D79B@CRSMSX101.amr.corp.intel.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 04:29:11PM +0000, Weiny, Ira wrote:
> > Pingfan Liu <kernelfans@gmail.com> writes:
> > 
> > > As for FOLL_LONGTERM, it is checked in the slow path
> > > __gup_longterm_unlocked(). But it is not checked in the fast path,
> > > which means a possible leak of CMA page to longterm pinned requirement
> > > through this crack.
> > 
> > Shouldn't we disallow FOLL_LONGTERM with get_user_pages fastpath? W.r.t
> > dax check we need vma to ensure whether a long term pin is allowed or not.
> > If FOLL_LONGTERM is specified we should fallback to slow path.
> 
> Yes, the fastpath bails to the slowpath if FOLL_LONGTERM _and_ DAX.  But it does this while walking the page tables.  I missed the CMA case and Pingfan's patch fixes this.  We could check for CMA pages while walking the page tables but most agreed that it was not worth it.  For DAX we already had checks for *_devmap() so it was easier to put the FOLL_LONGTERM checks there.
> 
Then for CMA pages, are you suggesting something like:
diff --git a/mm/gup.c b/mm/gup.c
index 42a47c0..8bf3cc3 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2251,6 +2251,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
        if (unlikely(!access_ok((void __user *)start, len)))
                return -EFAULT;

+       if (unlikely(gup_flags & FOLL_LONGTERM))
+               goto slow;
        if (gup_fast_permitted(start, nr_pages)) {
                local_irq_disable();
                gup_pgd_range(addr, end, gup_flags, pages, &nr);
@@ -2258,6 +2260,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
                ret = nr;
        }

+slow:
        if (nr < nr_pages) {
                /* Try to get the remaining pages with get_user_pages */
                start += nr << PAGE_SHIFT;

Thanks,
  Pingfan

