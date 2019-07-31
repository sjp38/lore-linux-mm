Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEDD4C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:37:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B1772089E
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:37:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B1772089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 313828E0005; Wed, 31 Jul 2019 10:37:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C39C8E0001; Wed, 31 Jul 2019 10:37:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18C2D8E0005; Wed, 31 Jul 2019 10:37:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C10FE8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:37:16 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y24so42603673edb.1
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:37:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=So2BqeAhYIGhnn9/LcBQ8ANJy/L5YQB8n4YH5s7LXo0=;
        b=pVj5rxqbADg3G5mJ7VSI6DmW6OKwSPTytjedz++CkFkdfwMOCjfGmjvm8R30lLzLD4
         IJ3f/5yPUnNJd57LlpCdC/6AV4fkc5527gFkYqMbn9vZekRYr9bslFe/Fe2ic9Opyd3c
         BHQcGdlQxmjnOeeUqE45uEDjGYS8pBREK5QLX+8ONYRxViirczT1zlFYQyuh0h67XpvS
         xTwZK1HE+ZWlO3S9Rl/Vo35+Vy+dc3Exd1HE+5eJHfL6132rxXPff/DER4Ksrsl9+tVG
         L9lChksUUdbBS9kDf4Xh9t2M0pCo+b2JxQprYrRlwOyZormjIf+N5VJrBVTOqh8c7MQr
         RruA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXRWBvLvDSFOyT6SzF8Y1Ht+2bsYgOVVTTW2MbSa85OehCsNMpB
	lPfmkkae+eKrMdzVjuyNsoAUfY3QDYfd2oEze/nXCq72gYL+7DlWW3BfuXeEqvJHo76Kd04ggSC
	k3ciQ/lWT3VX8tbumcnRpja26zgayTfNArjZuwXOlOVKFU1D++LlE6fc5JsFBgME=
X-Received: by 2002:a50:9822:: with SMTP id g31mr104798705edb.175.1564583836342;
        Wed, 31 Jul 2019 07:37:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzY3yBMPSiZCAbwoiCwLRwa0YEIG2qD3KZ+su3IkzjfrotwGrggKODt+2SI2kVRWXzlTt2q
X-Received: by 2002:a50:9822:: with SMTP id g31mr104798608edb.175.1564583835428;
        Wed, 31 Jul 2019 07:37:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564583835; cv=none;
        d=google.com; s=arc-20160816;
        b=SUBYUAWpccim1NzvjhDxGXReEwhV3sIFkYK/McANNVXQLbmGxqanjIwV32toqn7bip
         Nvym/+phLYXdF8UIqgf4ofKcqScPVIyxaklcLyOzZU0yoaCLRIs0nwMtuucLdvC0uuKi
         iynrPlUVZHcDIeYnEjsqcEWgGYtL8w8fX+Q/BaCu1YBvksPswehnDMY1uOTLBsdX1RSn
         pFqWdPD/c1AQwfBUInjpjgic8X1pGt10POnnVBc3MVXH1aMMxIMc1rWVGhYmSjUksjl8
         g16nyD/8uWWV3Hi4ts/mQIum/TCP7vjOuFy6KuqyPQoQfXE5Po/DgSiaL0xN8PQqsE5t
         rQHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=So2BqeAhYIGhnn9/LcBQ8ANJy/L5YQB8n4YH5s7LXo0=;
        b=IJx8d19L3IHTz5VEXDNOS28/KZBg0yLL51E0/UwVQaxRxMolrdefIkMFrskXndvRJ/
         nVuvV7ldYBpsUIrYeHcAeke/KyL9PxabqreSZtYIMPPsz/OkplcTiWojxmECtqXYtQMk
         E9w/dD2ZFuheZ1d5O7gWVbTpG2ctRUOIl8qwPQ16H193wLnYiPfABHuA+JSG1KbxpIj4
         evG9v0yfAlrFJXwqqNBoRlTOFaYA/haWGkpowGUfa3YAdrxPe7Rxh2hDR3Q2tSYVyn3w
         qUcUFkSpKyXHzOqHGF+Qtn8fK5GR+FOqDXzw1LKip+g9umdlUeOlEbar+yjshquWgolQ
         o+pw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x15si18314058ejv.41.2019.07.31.07.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 07:37:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E5D3EAC9A;
	Wed, 31 Jul 2019 14:37:14 +0000 (UTC)
Date: Wed, 31 Jul 2019 16:37:14 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] drivers/base/memory.c: Don't store end_section_nr in
 memory blocks
Message-ID: <20190731143714.GX9330@dhcp22.suse.cz>
References: <20190731122213.13392-1-david@redhat.com>
 <20190731124356.GL9330@dhcp22.suse.cz>
 <f0894c30-105a-2241-a505-7436bc15b864@redhat.com>
 <20190731132534.GQ9330@dhcp22.suse.cz>
 <58bd9479-051b-a13b-b6d0-c93aac2ed1b3@redhat.com>
 <20190731141411.GU9330@dhcp22.suse.cz>
 <c92a4d6f-b0f2-e080-5157-b90ab61a8c49@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c92a4d6f-b0f2-e080-5157-b90ab61a8c49@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 16:21:46, David Hildenbrand wrote:
[...]
> > Thinking about it some more, I believe that we can reasonably provide
> > both APIs controlable by a command line parameter for backwards
> > compatibility. It is the hotplug code to control sysfs APIs.  E.g.
> > create one sysfs entry per add_memory_resource for the new semantic.
> 
> Yeah, but the real question is: who needs it. I can only think about
> some DIMM scenarios (some, not all). I would be interested in more use
> cases. Of course, to provide and maintain two APIs we need a good reason.

Well, my 3TB machine that has 7 movable nodes could really go with less
than
$ find /sys/devices/system/memory -name "memory*" | wc -l
1729

when it doesn't really make any sense to offline less than a
hotremovable entity which is the whole node effectivelly. I have seen
reports where a similarly large machine chocked on boot just because of
too many udev events...

In other words allowing smaller granularity is a nice toy but real
usecases usually work with the whole hotplugable entity (e.g. the whole
ACPI container).

> (one sysfs per add_memory_resource() won't cover all DIMMs completely as
> far as I remember - I might be wrong, I remember there could be a
> sequence of add_memory(). Also, some DIMMs might actually overlap with
> memory indicated during boot - complicated stuff)

Which is something we have to live with anyway due to nodes interleaving.
So nothing really new.
-- 
Michal Hocko
SUSE Labs

