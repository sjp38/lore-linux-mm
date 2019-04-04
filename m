Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83879C10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:25:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FDCC21741
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:25:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FDCC21741
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E31ED6B0003; Thu,  4 Apr 2019 09:25:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE1656B0005; Thu,  4 Apr 2019 09:25:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF7766B0006; Thu,  4 Apr 2019 09:25:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA026B0003
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 09:25:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p90so1397979edp.11
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 06:25:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=scS5grmSBc6INQUXfM9sGzHnKbj0BCOeAX3cB8O08ds=;
        b=a8zm4pqWFIM6ARhPfYMrFoLzH7PSw/aVaYgbzlRWVH8SpHyHEN/eeSrltwKkABio8C
         Mi6xziyTCgw9kmp5RAvNJwmJIkqI3Ci1cxM6fbV6uV6vmzQS207sgx9oewvoImh83fgW
         L52n3qQGzmxaTjAw8zs0F0nP4mDp1QiJBK/NdG7N5JwyDI4/jHF74XF803D7B/71KQcg
         MeiCDrGCP9wturZHiWXRR9ONOl9fFL+/2NXCQb60jBr1ZFW7Gck1gLxrtVTlJCkCHdJi
         nGDftczZOWlPNYHGmuzhLcG7++jP6W8yERGVhRJEPIoCCvZe6H+rubEFZmNpD2CnUAQl
         eZkg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAU8tZkLsnEhpACu0g4706DpJFScGAYAONynZpwI1KBJb4dDuqYU
	M2+k5usbdNKmjhlZimv53o25EjxfXBTnbXjDTvjNobcHC+rPk4y2o4gH7PxHudRvuxat84x8RT0
	apc5Be0kOPcXzgJH8yF5dfFWy/yQTv+1UnGr1eCLBmHRyRhRUzu1kv4utWREAaig=
X-Received: by 2002:a17:906:d512:: with SMTP id ge18mr3612268ejb.232.1554384312179;
        Thu, 04 Apr 2019 06:25:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlsYzeL88el/rvsfPxy5utNrbI+FeSvsX3RBLuY5N0XtTNbpmqrA9FtzwuSk1MZJcIzPlR
X-Received: by 2002:a17:906:d512:: with SMTP id ge18mr3612218ejb.232.1554384311124;
        Thu, 04 Apr 2019 06:25:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554384311; cv=none;
        d=google.com; s=arc-20160816;
        b=rMge5Ldga+NNu0hiaaHzJXn2aQEmJGefF0LoVFD8V/7QyvoXEXwKtA7aR/AWoOI83W
         53j2WPCQrB7ELpfqLikvh9eiyoxMXaUhT2SI2wQLQIw3xXUDeISZYRzw0fzQ/hnDQNMi
         rcnpeXa52N0tpEpVBKG6mmOifsSFjiJycNH3oqOgQGvDn/xaB992ywtL8Qz8vgQwLU6z
         PbzdkmT3SUCn8dPHwQPPHNHOqiMI52777APWVhFCKzDajv9G4PrvgVVjOWK0WLehRFu4
         F5R8t3TebcMhohGsy8V8Yhne2605BQHGSkOzwDDSGhz+/MdlDMKSErbgG7WpQ4uXc54d
         5lqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=scS5grmSBc6INQUXfM9sGzHnKbj0BCOeAX3cB8O08ds=;
        b=pKDzk4w6XpyvGvLQbQcN0Q8uG304Sb5qGRmuALQCZroIQoaMaGVb4bhCIo5P/HOqdb
         loZJZEgxsQag1wJeZ5quXpvZMhPdNhoCOEPcL2LwP5a85UJkkBl67vZD2pdE+AQ4GvS+
         0xBQloZSPp3HKOx4P05W6lUe3Z9s6Re+Eguvg/eLYGu43VS8+u3ueEN0zEtpBJDKwvOQ
         EyoJnG6lQRyUKn8b4102LYgkzV8qDEHdHiGG+wPJfg42FAYmUxCBh90yQJa564+uIUOI
         ZjycFJW2AJeoaG4/F71YYF8zRWTdWDSGBlVef9Tp9VIguqUs3Lf3jwZhtUl5OtgR9XSa
         GYSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id j3si41140edc.3.2019.04.04.06.25.10
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 06:25:11 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 16B4D481A; Thu,  4 Apr 2019 15:25:09 +0200 (CEST)
Date: Thu, 4 Apr 2019 15:25:09 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 1/2] mm, memory_hotplug: cleanup memory offline path
Message-ID: <20190404132506.kaqzop4qs6m56plu@d104.suse.de>
References: <20190404125916.10215-1-osalvador@suse.de>
 <20190404125916.10215-2-osalvador@suse.de>
 <f2360f11-4360-b678-f095-c4ebbf7cd0ec@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f2360f11-4360-b678-f095-c4ebbf7cd0ec@redhat.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 03:18:00PM +0200, David Hildenbrand wrote:
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index f206b8b66af1..d8a3e9554aec 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1451,15 +1451,11 @@ static int
> >  offline_isolated_pages_cb(unsigned long start, unsigned long nr_pages,
> >  			void *data)
> >  {
> > -	__offline_isolated_pages(start, start + nr_pages);
> > -	return 0;
> > -}
> > +	unsigned long offlined_pages;
> >  
> > -static void
> > -offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
> > -{
> > -	walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
> > -				offline_isolated_pages_cb);
> > +	offlined_pages = __offline_isolated_pages(start, start + nr_pages);
> > +	*(unsigned long *)data += offlined_pages;
> 
> unsigned long *offlined_pages = data;
> 
> *offlined_pages += __offline_isolated_pages(start, start + nr_pages);

Yeah, more readable.

> Only nits

About the identation, I double checked the code and it looks fine to me.
In [1] looks fine too, might be your mail client?

[1] https://patchwork.kernel.org/patch/10885571/

> 
> Reviewed-by: David Hildenbrand <david@redhat.com>

Thanks ;-)

-- 
Oscar Salvador
SUSE L3

