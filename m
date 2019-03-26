Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2026CC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 10:08:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B54A92075D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 10:08:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B54A92075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DFB86B0007; Tue, 26 Mar 2019 06:08:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2668F6B0008; Tue, 26 Mar 2019 06:08:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 106D06B000A; Tue, 26 Mar 2019 06:08:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF71D6B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 06:08:24 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id z34so13040925qtz.14
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 03:08:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gaJIfwI62HJ7YQBY9KM4tG+PmlC+XoH7jLXQF/3vdN0=;
        b=n/MvFi88Z2Aw9so5/4Hk8WshOiqus4RKwzKcw/DiXPxd1jWXuavfjPvwP4jKPbHstB
         mokOUCkojC4gakqwzzitTOwKzmOsm2X25MBlgLw0QMcFG18N0X1VKHcjSlGAawS0BSBK
         IYe+itsNWJYmNVJ1PSS/yNMOnyY+lsoz1jg4NE/AUt7no0z0ecPgpy6CEecfWKd11M8V
         +ngdtgAI8cy/hysphbTCbPBONBK1wADP14eg2taLAvg31L932UVvyrlNAXc+CugjgxtQ
         3yLI7VGZAeb8ZeOxQmH5+10gcIhYT57srW2YBcBDr8AqIbtAAbbnr4C/G/+UxIh3pcB3
         fqIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUd+fJYElc2cyVKB9Z5iQFcDEEXL8YZrAIGBuFjsw+OrccknggI
	6ht69oanV7dKeizBGq5X3zuPMefHahXxxJa1d8IYZG2qubxsKqrcCCCq5QqFTF47hM8itmvyBaZ
	h+SdHRPCXTV42lt9hNNX5x3sSjSkqqdCDGGw5EbMb/OZNFzojW+qoIElI48JXp398YA==
X-Received: by 2002:a0c:9802:: with SMTP id c2mr24589120qvd.13.1553594904674;
        Tue, 26 Mar 2019 03:08:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8KLpAKxeJecHm+wwznOTR3PW77dhIw3k/w54bjhefiFj15aD79y/vZKWHyBgWJSF+dQ56
X-Received: by 2002:a0c:9802:: with SMTP id c2mr24589059qvd.13.1553594903821;
        Tue, 26 Mar 2019 03:08:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553594903; cv=none;
        d=google.com; s=arc-20160816;
        b=ZBVVPDFaW9Ko/yKh+sNDUd0C94nQuFW8RtvlZkynxD4IqavlaykZ0asckuoiS57KDw
         0s0wM8Z9m9OWMJunnBu2I3O1p1j4bIdNvFUWOncfHv23HZn9GqcnYZAukvBPqkLhTndX
         GZA3LpWgpX1Zwzn+x6qzw7JH5F1LcuyTT2NwuttxriI+eum2WfZXgR680yOdiJlLZEe2
         m0yQODgJRoNwCleMUOE/gkVvU2xzNr1snV0xS6gChfD7KhlIYwCcN5ra2sZ2DYH9fOcd
         X+71mu1n7p4CtTdM8WUsbpEC6/1AxtuAWYp5dTtiQH9fMbx+rQJQh9zFRMJOGiilSYMc
         jsCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gaJIfwI62HJ7YQBY9KM4tG+PmlC+XoH7jLXQF/3vdN0=;
        b=1CqUwiCx0NylCr2KMnJcHLatStFTTig77n/aj8hgnCxaVaBSvu8lGoyMZ5ZDaZ2Dig
         CA4kW3Yfiv2AiB9ngwKUHfbMinjEBfb93LomJ2sNJlR88VZPs+iHEoLLT1KqRdW2I8Gv
         OQ/rsASd4/H6ULozX4cy0xe6+y09ptVrjpdfOvqVqsst8ce49RfWQO51lSSn3wVk6q8n
         26UM7V2mSJFy1vgDPZyN+fVzsJ77uj6vr2tp+Fcz6Q+nvrc+ym/bxE9r6LmP1LKu/PM3
         PmfpPzcwBqFy2al0wY3awER3GCwQLKClihjCRZR2OywOqPsWYbdzfH2/xFGb+Na/TITI
         UotA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p66si2325767qkb.182.2019.03.26.03.08.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 03:08:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8B4FB3082AFA;
	Tue, 26 Mar 2019 10:08:21 +0000 (UTC)
Received: from localhost (ovpn-12-21.pek2.redhat.com [10.72.12.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 917992636E;
	Tue, 26 Mar 2019 10:08:20 +0000 (UTC)
Date: Tue, 26 Mar 2019 18:08:17 +0800
From: Baoquan He <bhe@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, rppt@linux.ibm.com, osalvador@suse.de,
	willy@infradead.org, william.kucharski@oracle.com
Subject: Re: [PATCH v2 2/4] mm/sparse: Optimize sparse_add_one_section()
Message-ID: <20190326100817.GV3659@MiWiFi-R3L-srv>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-3-bhe@redhat.com>
 <20190326092936.GK28406@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326092936.GK28406@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 26 Mar 2019 10:08:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/26/19 at 10:29am, Michal Hocko wrote:
> On Tue 26-03-19 17:02:25, Baoquan He wrote:
> > Reorder the allocation of usemap and memmap since usemap allocation
> > is much simpler and easier. Otherwise hard work is done to make
> > memmap ready, then have to rollback just because of usemap allocation
> > failure.
> 
> Is this really worth it? I can see that !VMEMMAP is doing memmap size
> allocation which would be 2MB aka costly allocation but we do not do
> __GFP_RETRY_MAYFAIL so the allocator backs off early.

In !VMEMMAP case, it truly does simple allocation directly. surely
usemap which size is 32 is smaller. So it doesn't matter that much who's
ahead or who's behind. However, this benefit a little in VMEMMAP case.

And this make code a little cleaner, e.g the error handling at the end
is taken away.

> 
> > And also check if section is present earlier. Then don't bother to
> > allocate usemap and memmap if yes.
> 
> Moving the check up makes some sense.
> 
> > Signed-off-by: Baoquan He <bhe@redhat.com>
> 
> The patch is not incorrect but I am wondering whether it is really worth
> it for the current code base. Is it fixing anything real or it is a mere
> code shuffling to please an eye?

It's not a fixing, just a tiny code refactorying inside
sparse_add_one_section(), seems it doesn't worsen thing if I got the
!VMEMMAP case correctly, not quite sure. I am fine to drop it if it's
not worth. I could miss something in different cases.

Thanks
Baoquan

> 
> > ---
> > v1->v2:
> >   Do section existence checking earlier to further optimize code.
> > 
> >  mm/sparse.c | 29 +++++++++++------------------
> >  1 file changed, 11 insertions(+), 18 deletions(-)
> > 
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index b2111f996aa6..f4f34d69131e 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -714,20 +714,18 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
> >  	ret = sparse_index_init(section_nr, nid);
> >  	if (ret < 0 && ret != -EEXIST)
> >  		return ret;
> > -	ret = 0;
> > -	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> > -	if (!memmap)
> > -		return -ENOMEM;
> > -	usemap = __kmalloc_section_usemap();
> > -	if (!usemap) {
> > -		__kfree_section_memmap(memmap, altmap);
> > -		return -ENOMEM;
> > -	}
> >  
> >  	ms = __pfn_to_section(start_pfn);
> > -	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
> > -		ret = -EEXIST;
> > -		goto out;
> > +	if (ms->section_mem_map & SECTION_MARKED_PRESENT)
> > +		return -EEXIST;
> > +
> > +	usemap = __kmalloc_section_usemap();
> > +	if (!usemap)
> > +		return -ENOMEM;
> > +	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> > +	if (!memmap) {
> > +		kfree(usemap);
> > +		return  -ENOMEM;
> >  	}
> >  
> >  	/*
> > @@ -739,12 +737,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
> >  	section_mark_present(ms);
> >  	sparse_init_one_section(ms, section_nr, memmap, usemap);
> >  
> > -out:
> > -	if (ret < 0) {
> > -		kfree(usemap);
> > -		__kfree_section_memmap(memmap, altmap);
> > -	}
> > -	return ret;
> > +	return 0;
> >  }
> >  
> >  #ifdef CONFIG_MEMORY_HOTREMOVE
> > -- 
> > 2.17.2
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

