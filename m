Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EAC2C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:31:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C8D120863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:31:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C8D120863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBA516B0005; Tue, 26 Mar 2019 05:31:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6A7A6B0006; Tue, 26 Mar 2019 05:31:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D30826B0007; Tue, 26 Mar 2019 05:31:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id AEEC16B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:31:01 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id f89so12989680qtb.4
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:31:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QUbBtAEPboZ0CwnqIy7RoCiz4Q/t4tx3oYPQtQ4VCDs=;
        b=dxU+BxO5+kMiYMbjikP3GRL/rzJt1tr8e/SfockF6TX9AvSsbyAJ4/xSDyGZQK3en5
         V3FMAY6bbiqlYrKOevrKdMe7Gmu5PeHB5sM28Rbr2q+wOIqFjcPXS3HQ9GzdYYyhUOsL
         ZF8gn1HQSb4slpndc+iMXtM0/qMrrsSQDW/fe7gi40ie5/bQBi0jhD4RQclMSm6ZD156
         jNnUxqRphOGq6JHpmhguFdcV/aLm9Ax2GBjFEpk0lv+AR3DQUq+6RgeDcYOCB4hRSTy2
         dGzPugkPhqQpfMObTsK2Ct61xFUrnFNq0mqcL3qP98rluGqp6g2I5TPqQWhztH7wvVgy
         gXSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVSM2LFKFB4vktY6onRqYb0scVmjJxwNtdRIbKgXXz60BJ+0fA6
	rW3lEBkABEcTlwtZliIYzGgsmvJ1tthLBaWStw94COj9uJSdrtso7SX/Z4a/OlRCKmk2fnQmBQ9
	6sP9PBjJeGvGgfH6edbmupNegTR1O8qb4Lx+XMvzIz37S7X1N8byhGr/Db3IiyzOBNg==
X-Received: by 2002:ac8:2b65:: with SMTP id 34mr23210694qtv.93.1553592661495;
        Tue, 26 Mar 2019 02:31:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWZ5ar4ASD1k/pQQ1/Fp8cMZN9T9T1MYa6jlEwR1IjD/dgfia6vxlYZ3OCiUyRwxzm8dQY
X-Received: by 2002:ac8:2b65:: with SMTP id 34mr23210660qtv.93.1553592660993;
        Tue, 26 Mar 2019 02:31:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553592660; cv=none;
        d=google.com; s=arc-20160816;
        b=KWSxCuHoDOsGu/9Ucls/gRSE7NGyA06xrl17rGt608Mg0yHy8M3IN27J3ndSNZ94St
         /7L7jWyp9dqhx40aHc2hS0oVkPFGYqEQt34UiOidLI3p/p9iBAONwxsh9vkhZekNfkRx
         71rFFVulIhaEzXHYNYcZU5NJa9j9T3hvLlrwtFwvijjwmtLATAMmcgJXkr6Yhq/R12hn
         pwVvCQr0h4iXpRN4Fgzpq9AJPY3Jdd/7maUj4PMrovWzu/Llimbc58HYIh2qxgAuq397
         JvAwmqwvpXkCVRWMwISGvzLwNt1DH2p0lTfwb5JBnIL7KNLz7tTHrOFf3diykDogLBKo
         ksMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QUbBtAEPboZ0CwnqIy7RoCiz4Q/t4tx3oYPQtQ4VCDs=;
        b=ptKTCxbP1KCsEeruUzsqLANj3qq+TDuDpmRE+PB5pEUAoJs3sfQzzqUmwIkWOGrP2w
         frai41ywvqNENFAtAXep1IjMgrOMrX2swLKiG2XO6VL5OKomFT1S/+Xs5UiVr2EvD6fe
         EpP5KXf3t3L4LvVbKpZPEpezQT0kyO3eKSA91fGvF2uFkomf+Kbz0cACi7gSHFTn28JA
         IS5HcbZDkHhQpFRgencVXQWE4VN3FR/iPArNnzAz2DWRKS+76vwK3NqyvVGt5cmYYZWE
         h+tvt5UTvoO0jvo6x60DywTH393KsroomC2jCwxVd+5wvPUL56QyiPZ2N4Z7W/mZTD+G
         6MCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d21si2327912qtd.189.2019.03.26.02.31.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:31:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2A2E5307D923;
	Tue, 26 Mar 2019 09:31:00 +0000 (UTC)
Received: from localhost (ovpn-12-21.pek2.redhat.com [10.72.12.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 838371001E6B;
	Tue, 26 Mar 2019 09:30:59 +0000 (UTC)
Date: Tue, 26 Mar 2019 17:30:57 +0800
From: Baoquan He <bhe@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, rppt@linux.ibm.com, osalvador@suse.de,
	willy@infradead.org, william.kucharski@oracle.com
Subject: Re: [PATCH v2 1/4] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190326093057.GS3659@MiWiFi-R3L-srv>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-2-bhe@redhat.com>
 <20190326092324.GJ28406@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326092324.GJ28406@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Tue, 26 Mar 2019 09:31:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/26/19 at 10:23am, Michal Hocko wrote:
> On Tue 26-03-19 17:02:24, Baoquan He wrote:
> > The code comment above sparse_add_one_section() is obsolete and
> > incorrect, clean it up and write new one.
> > 
> > Signed-off-by: Baoquan He <bhe@redhat.com>
> 
> Please note that you need /** to start a kernel doc. Other than that.

I didn't find a template in coding-style.rst, and saw someone is using
/*, others use /**. I will use '/**' instead. Thanks for telling.

> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> > ---
> > v1-v2:
> >   Add comments to explain what the returned value means for
> >   each error code.
> > 
> >  mm/sparse.c | 15 ++++++++++++---
> >  1 file changed, 12 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index 69904aa6165b..b2111f996aa6 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -685,9 +685,18 @@ static void free_map_bootmem(struct page *memmap)
> >  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
> >  
> >  /*
> > - * returns the number of sections whose mem_maps were properly
> > - * set.  If this is <=0, then that means that the passed-in
> > - * map was not consumed and must be freed.
> > + * sparse_add_one_section - add a memory section
> > + * @nid: The node to add section on
> > + * @start_pfn: start pfn of the memory range
> > + * @altmap: device page map
> > + *
> > + * This is only intended for hotplug.
> > + *
> > + * Returns:
> > + *   0 on success.
> > + *   Other error code on failure:
> > + *     - -EEXIST - section has been present.
> > + *     - -ENOMEM - out of memory.
> >   */
> >  int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
> >  				     struct vmem_altmap *altmap)
> > -- 
> > 2.17.2
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

