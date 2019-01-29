Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83B14C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:13:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BAF020857
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:13:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BAF020857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F21D78E0005; Tue, 29 Jan 2019 04:13:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED1B98E0002; Tue, 29 Jan 2019 04:13:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC08B8E0005; Tue, 29 Jan 2019 04:13:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7DA078E0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 04:13:24 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f31so7565422edf.17
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 01:13:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SC7CocLDdA6XyArTDMOCU2Ngc7FJpHL2Kcc3DR+AUNM=;
        b=rw/FoHXBhVXqTwhR2Sib576Szdhtbzi+uNUZmHKg/XTZ3iC4bmLvAIG8caeXRuoMsm
         Bws5kRhD26CyJdy5stqUql/eekd1/dIb8QJayntR6NSRe0+DRjl1iZpX1ZJMGN64r5sy
         DPfs0yG5Frg4jBiGZprDDEnMTycZWDdxTnqXy1VdHUJIYFBSwVXeqnr6/bSLTd4GFY39
         zKESYFS9CNEeW7+a05SrqeipHcHCtLL14Hz290qRSb2zY4WgAhhjL4uDRcwR1nJM3d1P
         QKrmujTSouTqWQhTeAwYMA0+3OsVUcUoP+HgD8z6Jr44bVUht9lu8aYSoS8rduZpNi07
         tJhQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukeaHAd9GAFnxovgTyuNMnTkgLgRfncc9RbMdXPjOCJhaquzyoHs
	F81UKcZuYZquo812JwucwDVBCJ0Hkfyj7w06w0yV7dhxNv8wYiIkGV0H0ygoJh4Gkk5nnm758MU
	GjQCfa2XR0Kj/5qo1cdImlhPrLJ/pBsmFdHF9lYS56VX9aTGIhQuwhajcNTCWt90=
X-Received: by 2002:a50:ea8d:: with SMTP id d13mr24234294edo.126.1548753204070;
        Tue, 29 Jan 2019 01:13:24 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4MHE2oyYeO37WvHx3A3MXMGbUG4knujdSwCg/F+cxfw085ZmZGuvOvZXA8HprifY2o8zlI
X-Received: by 2002:a50:ea8d:: with SMTP id d13mr24234261edo.126.1548753203203;
        Tue, 29 Jan 2019 01:13:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548753203; cv=none;
        d=google.com; s=arc-20160816;
        b=XK1thkrkqOIRpSGptb3eNd+66tS3176GTpdM55EKmmCQy3zpexJ48Zhwvl41bbstfn
         c2fH0hed+XqupFQTyEc1PrrWLHhh8qhbPYRZDjF4JUNxaGsdEVNowF4ZwqzDGJ0Vg3Sy
         qyE4OGBMp5RVkHqli7j0My9nlgHS7y6JVz1RHcEsMTZPoyP7vhwWhl+dqxKQov+An2nY
         MKxtDKToqu5cdGq2VbUapRHgHJrUkZuGS9F75II1gxmH7wLMWw2TncmZcy9Gp6jpPWCy
         JCH0XpsjoE/6sH0/8WSvWaM0MnS0Pc2Lzxq3Qb924upXQew/b/cyPYRnVj/y3Bhvs3sP
         L2nA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SC7CocLDdA6XyArTDMOCU2Ngc7FJpHL2Kcc3DR+AUNM=;
        b=rrv2ToqdwZrr7OvwkM/iXAwLbdd0kkqOJiCYYkDUzdAJxwkTSQQzfBinfHMGNlxtH0
         saK+U8fYNo6WqCaMVWRNzn7gmY4KZxUnn87it8vCBItcF4FiQaehImqw4EPbk20PefEx
         L0I5mdYkctrrduG8RFcxtMuPNj36fQWhw707HNb95nhyrc/pctvArF6uvcmZq7YItYTN
         K94qfpzQbeDXC4PMOD3kLWgM5Xl/M4sZez2EJ9dZ/xMgBYVDcUKs1MOaiN2yxCOgEftk
         s1I/K/mmRdhEoRA6/yWBbxDs0vLln9m0OlbUQdwtwMGEG4zmtxgebx1xt8jfmKvTU8ms
         TY7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a12si1464113edk.106.2019.01.29.01.13.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 01:13:23 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CFC79AE5E;
	Tue, 29 Jan 2019 09:13:22 +0000 (UTC)
Date: Tue, 29 Jan 2019 10:13:21 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com,
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: test_pages_in_a_zone do not pass
 the end of zone
Message-ID: <20190129091321.GH18811@dhcp22.suse.cz>
References: <20190128144506.15603-1-mhocko@kernel.org>
 <20190128144506.15603-3-mhocko@kernel.org>
 <20190129090908.oms43oyjicozkvzu@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129090908.oms43oyjicozkvzu@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 29-01-19 10:09:08, Oscar Salvador wrote:
> On Mon, Jan 28, 2019 at 03:45:06PM +0100, Michal Hocko wrote:
> > From: Mikhail Zaslonko <zaslonko@linux.ibm.com>
> > 
> > If memory end is not aligned with the sparse memory section boundary, the
> > mapping of such a section is only partly initialized. This may lead to
> > VM_BUG_ON due to uninitialized struct pages access from test_pages_in_a_zone()
> > function triggered by memory_hotplug sysfs handlers.
> > 
> > Here are the the panic examples:
> >  CONFIG_DEBUG_VM_PGFLAGS=y
> >  kernel parameter mem=2050M
> >  --------------------------
> >  page:000003d082008000 is uninitialized and poisoned
> >  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> >  Call Trace:
> >  ([<0000000000385b26>] test_pages_in_a_zone+0xde/0x160)
> >   [<00000000008f15c4>] show_valid_zones+0x5c/0x190
> >   [<00000000008cf9c4>] dev_attr_show+0x34/0x70
> >   [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
> >   [<00000000003e4194>] seq_read+0x204/0x480
> >   [<00000000003b53ea>] __vfs_read+0x32/0x178
> >   [<00000000003b55b2>] vfs_read+0x82/0x138
> >   [<00000000003b5be2>] ksys_read+0x5a/0xb0
> >   [<0000000000b86ba0>] system_call+0xdc/0x2d8
> >  Last Breaking-Event-Address:
> >   [<0000000000385b26>] test_pages_in_a_zone+0xde/0x160
> >  Kernel panic - not syncing: Fatal exception: panic_on_oops
> > 
> > Fix this by checking whether the pfn to check is within the zone.
> > 
> > [mhocko@suse.com: separated this change from
> > http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com]
> > Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Looks good to me:
> 
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
> 
> > ---
> >  mm/memory_hotplug.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 07872789d778..7711d0e327b6 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1274,6 +1274,9 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
> >  				i++;
> >  			if (i == MAX_ORDER_NR_PAGES || pfn + i >= end_pfn)
> >  				continue;
> > +			/* Check if we got outside of the zone */
> > +			if (zone && !zone_spans_pfn(zone, pfn + i))
> > +				return 0;
> >  			page = pfn_to_page(pfn + i);
> 
> Since we are already checking if the zone spans that pfn, is it safe to get
> rid of the below check? Or maybe not because we might have intersected zones?

Exactly. The new zone might start at the next pfn. Look for the cover
leter for such an example.
 
> >  			if (zone && page_zone(page) != zone)
> >  				return 0;
> 
> -- 
> Oscar Salvador
> SUSE L3

-- 
Michal Hocko
SUSE Labs

