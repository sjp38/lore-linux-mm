Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DCB9C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:14:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 152BD208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:14:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 152BD208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91E248E0006; Wed, 31 Jul 2019 09:14:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A7B98E0001; Wed, 31 Jul 2019 09:14:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76EDE8E0006; Wed, 31 Jul 2019 09:14:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 270C68E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:14:11 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z20so42415809edr.15
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:14:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NJmEW1L4/Swztjk74OmZ8UMrqvs5ODuxr4+RKgfOkFk=;
        b=OOe27G0T3MzrXJuYzSAZxwkakl9efrp/Ja6GE6xCAa5D8FUZGQsaQ+raS2oFDwTJ+r
         OmD5BAZQ85iKaArI/1gbG4k0Up1wgIq7MzxMrb8fLzsc3RiB26QoUq0qKsu8TeG9Sgag
         eMYmnedyRFMxIrvULkVyFDdWWYhiRPGS0pYfqN528YvrAVITPGvJ+aUylkQq6w9p5s21
         Fq8dp2qHCH047pztetYzVmCh6Mu9OWs6HVkrfhc19TPnoXdKa9CmtD6zVf5HhH9XvVW5
         8veC9/F2BiwjpwKfnwx23/MLJHJa17pe3Me8Pj8CDUQAbAObdeOPjCjTJUuGcbw/OFJr
         FzTQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVGjp47VxKhV1A4DBIAjQP0rowhoK6TQRn8HYZb4KsmbhOrwQ5e
	cs8yMGphbPQd8/M6qKatYOTAMRiWA42hf2QEYaE/2tOUfF5q3rlgX6LlpezMhr2fcOmLzX9FgTC
	sq5SDIJaK1Zd7sEDzzSVcGQvuk0uau4vLrfi0LE8JMcLgH676sfWcThINifzk6L8=
X-Received: by 2002:aa7:da14:: with SMTP id r20mr106512915eds.65.1564578850741;
        Wed, 31 Jul 2019 06:14:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSh2ZUTE89JjVr370c+SFN5Gf4cq4wo2zC7fGNtXWGdmzaaH1ULimAHWz6nmGcZuHIDkHD
X-Received: by 2002:aa7:da14:: with SMTP id r20mr106512866eds.65.1564578850118;
        Wed, 31 Jul 2019 06:14:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564578850; cv=none;
        d=google.com; s=arc-20160816;
        b=y5+2221dtb5Mx7vstxSxflFz9FUKE2VflQGuNTKz03wClfsG5CJRxvMbDoAsQyt8yc
         101ht9qQysxioAbFUPxp6GbSIXh16moKkffYvwbjPEu+b+KQ9OpRUF02XCcExYvSj2Oh
         JqWHfbVHwyw19xm8RJLru+y3n2tgcRRafddkaihABLsoKLtPIm7dXkUsj7o/BpoQZta9
         kVVkZTPt/xU9bs0fwbpbA7KTVnFH9A0RttL8fQScjjf4ly/GRIGWM8ogcNNFg436T8YZ
         G1H9ZXnKBgIMQLCfppNRmP4QxjryhJeBsm9kdLhV785TBTLUnEYvXZQPVhtlYwxecllw
         klJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NJmEW1L4/Swztjk74OmZ8UMrqvs5ODuxr4+RKgfOkFk=;
        b=dtsFb/2fEhyDivlDoWc++1b6Q4gaw7GsZEDzDGZp7N7tARlj4GIyyjxRv7aMoR46Iz
         N4uux/t/dExnNyfLMreU3DhiRRV1U2jFITJk3jzE9ryY82zQ6CPy/XYYQay3CoxvKEtJ
         mGA1XayHpHp3hFXmlWkQDtxNbbAsobi2UVkvDf690EJGayuVZwFKSJdl58JspyMHxvko
         b2xPTMnGKxJ2uwdD97DAbkoUdAlfvQWFl6vN8rcYlQlzKuteWZMhgKfOxRCLMmr4+AIe
         QG3IQqNRjpvvjDhyGAh5BPlyfnmKrm40NS/6+y7siyGPvarHFaMwGFZ0BFhRD9CWx4BF
         /q2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gj23si19474502ejb.165.2019.07.31.06.14.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 06:14:10 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 712F5AE21;
	Wed, 31 Jul 2019 13:14:09 +0000 (UTC)
Date: Wed, 31 Jul 2019 15:14:08 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-acpi@vger.kernel.org,
	"Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
	Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1] drivers/acpi/scan.c: Fixup "acquire
 device_hotplug_lock in acpi_scan_init()"
Message-ID: <20190731131408.GP9330@dhcp22.suse.cz>
References: <20190731123201.13893-1-david@redhat.com>
 <20190731125334.GM9330@dhcp22.suse.cz>
 <d3cc595d-7e6f-ef6f-044c-b20bd1de3fb0@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d3cc595d-7e6f-ef6f-044c-b20bd1de3fb0@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 15:02:49, David Hildenbrand wrote:
> On 31.07.19 14:53, Michal Hocko wrote:
> > On Wed 31-07-19 14:32:01, David Hildenbrand wrote:
> >> Let's document why we take the lock here. If we're going to overhaul
> >> memory hotplug locking, we'll have to touch many places - this comment
> >> will help to clairfy why it was added here.
> > 
> > And how exactly is "lock for consistency" comment going to help the poor
> > soul touching that code? How do people know that it is safe to remove it?
> > I am not going to repeat my arguments how/why I hate "locking for
> > consistency" (or fun or whatever but a real synchronization reasons)
> > but if you want to help then just explicitly state what should done to
> > remove this lock.
> > 
> 
> I know that you have a different opinion here. To remove the lock,
> add_memory() locking has to be changed *completely* to the point where
> we can drop the lock from the documentation of the function (*whoever
> knows what we have to exactly change* - and I don't have time to do that
> *right now*).

Not really. To remove a lock in this particular path it would be
sufficient to add
	/*
	 * Although __add_memory used down the road is documented to
	 * require lock_device_hotplug, it is not necessary here because
	 * this is an early code when userspace or any other code path
	 * cannot trigger hotplug operations.
	 */

Now that is a useful comment because it documents an exception and gives
you reasoning. If the above statement ever turns out to be incorrect due
to later changes then you can replace it with the lock and the new
reasoning.

But "just for consistency argument" doesn't tell you much when
scratching your head in the future and trying to figure out whether that
consistency argument still applies or there are new reasons the lock is
still needed.
-- 
Michal Hocko
SUSE Labs

