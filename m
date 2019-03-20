Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8378C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 08:00:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D13C2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 08:00:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D13C2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 428596B0007; Wed, 20 Mar 2019 04:00:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D6F16B0008; Wed, 20 Mar 2019 04:00:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27D3B6B000A; Wed, 20 Mar 2019 04:00:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3F596B0007
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:00:15 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id z34so1580343qtz.14
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 01:00:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zIkvq2NA7Nd91AnSX4+S2o8nn3TJRHaoKnp3ci1iuVI=;
        b=LPMi6t/vnCInzm9wKTKicq+UAfPiXqMyIqay5WHZ/TrczavvmoCLFEWtKgxAxDzyfC
         epS0cnkuaCrXpRnwI/uPdPLx/Qk/zDLHcJOmQ7Fa5uy/DbsFRTMmZKbOsNOsbGQlrSiZ
         7SM0Fi3cflMqMhzcidRTl7cUvnCiMhHOb/dRzIqKwp/Xclb1g9cmcfDmt2DrKbkhO8mV
         BWX0He06a96+dsouhAoRMnxORsvmE4J0sH+ioC481D17BEwsePfcjo/aozOnXs7mXFEC
         Dbf5FV/kOscUYx2zOTen4wUW52Af1VGcvou9VySakyNuweXJDbG21A9lEYy9ObiKBsp3
         y/Cg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXEy9hmGg/6ZyOe0TZeLEbQh8/HqlMYhI5jO3KnicHmDJyMJnJ/
	ktpWXEyumfH9V6+Y+r50HElLV8fIqhbZf6Zv1EqG7FPe28wU8/7fz45MiEgAg4lzSx4l/7VFhrl
	bXllTUouWGvliSCNyMm9rbpkWPm9Dn8DDGGLM+fF8RN4D9JcmaO7opqHR1Z/66O+iqA==
X-Received: by 2002:a37:7ac6:: with SMTP id v189mr5284835qkc.205.1553068815794;
        Wed, 20 Mar 2019 01:00:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCGXPqE0csu5pGvlXO5kgLxk2qGfj6knY9luPaumbKaTMViZgKNgI+rIj+XfwPbQfaHWnJ
X-Received: by 2002:a37:7ac6:: with SMTP id v189mr5284791qkc.205.1553068815143;
        Wed, 20 Mar 2019 01:00:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553068815; cv=none;
        d=google.com; s=arc-20160816;
        b=H6cp4PKv9G1L4UqnW4exdMIM6poZEiU28i8caYjF4doYFygO+4JMlsH3vBB6iKlAaL
         mLDw+xyeYuHpIniHod5Th71itO5hGuUDsftyQ/5epY5qK6E8yw2uqgsQY0u7+KRonoGF
         FQwFc0p7VlmYgUn6vS//P5B2xjNGk9BeU7Axi0kJlizj29D/SY+SDsL61vx7EvtmaUeD
         POtzxcNCe0NJTNkKFeTZKn1nJh40yNfbXLWMPyWusLFrpbuUl+rz1k4zL1COYIzZYFhl
         K1rBsayIXYaiRJ6Ie4ehk+yH9jBFL1AzE732mgxhesmlHu93CcsJ2jz82tBGWIoFzSmu
         9LKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zIkvq2NA7Nd91AnSX4+S2o8nn3TJRHaoKnp3ci1iuVI=;
        b=f97G0Sc3oF4LizBXKBPDr23c1haJxpDaHR7sjl7tl74zHMyo1lQ3tl+twTu5dZ70vw
         1PMYwlRm+erjUKmjTpvqbEdvB/sRG9CGX+oXqBnX+MX7Xdhi4n+xtVVazRF8DmkuKEWT
         LhMmFGsmau2CbYtwW6WE8qQ+cjKu19pSC1/wboM2T/o4bcRyiKzsr+fQiIbM9BjIGqgc
         gvybUy2GQSLIKECAlAwZyiqgsT7NbOgT4qjzaU0gYTItkrSSi67t1G4XMvM3dOrw2Nz/
         FS20msRnanI2yPRZlAgGL+Gc6c6jGR7XCVo98RA2fwT7sgwLoRDYsS9SINjR6mV2oFum
         /8Sg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f3si773747qtb.264.2019.03.20.01.00.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 01:00:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3235DC057F9A;
	Wed, 20 Mar 2019 08:00:14 +0000 (UTC)
Received: from localhost (ovpn-12-38.pek2.redhat.com [10.72.12.38])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7E0465D70A;
	Wed, 20 Mar 2019 08:00:11 +0000 (UTC)
Date: Wed, 20 Mar 2019 16:00:08 +0800
From: Baoquan He <bhe@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	pasha.tatashin@oracle.com, mhocko@suse.com, rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com, linux-mm@kvack.org
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190320080008.GK18740@MiWiFi-R3L-srv>
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320075058.GB13626@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320075058.GB13626@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 20 Mar 2019 08:00:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/20/19 at 09:50am, Mike Rapoport wrote:
> Hi,
> 
> On Wed, Mar 20, 2019 at 03:35:38PM +0800, Baoquan He wrote:
> > The code comment above sparse_add_one_section() is obsolete and
> > incorrect, clean it up and write new one.
> > 
> > Signed-off-by: Baoquan He <bhe@redhat.com>
> > ---
> >  mm/sparse.c | 9 ++++++---
> >  1 file changed, 6 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index 77a0554fa5bd..0a0f82c5d969 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -674,9 +674,12 @@ static void free_map_bootmem(struct page *memmap)
> >  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
> > 
> >  /*
> > - * returns the number of sections whose mem_maps were properly
> > - * set.  If this is <=0, then that means that the passed-in
> > - * map was not consumed and must be freed.
> > + * sparse_add_one_section - add a memory section
> 
> Please mention that this is only intended for memory hotplug

Will do. Thanks for reviewing.

> 
> > + * @nid:	The node to add section on
> > + * @start_pfn:	start pfn of the memory range
> > + * @altmap:	device page map
> > + *
> > + * Return 0 on success and an appropriate error code otherwise.
> 
> s/Return/Return:/ please

Thanks, will change.

> 
> >   */
> >  int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
> >  				     struct vmem_altmap *altmap)
> > -- 
> > 2.17.2
> > 
> 
> -- 
> Sincerely yours,
> Mike.
> 

