Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E2EFC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 11:36:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E11A92173B
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 11:36:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E11A92173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CD036B0005; Fri, 19 Jul 2019 07:36:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47DEA6B0006; Fri, 19 Jul 2019 07:36:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36B978E0001; Fri, 19 Jul 2019 07:36:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E18896B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 07:36:50 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d27so21864388eda.9
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 04:36:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZkwLhCl205TZqQkCcgXIQR3FVhajaLXAXKtHwZ66THE=;
        b=WQPgtZ0ffwvxATjveFi8GfBa2e4AMj71PAwpACKEY+0jJnRSWtwKScyD1db6CBHEHb
         C28/vU0BE0uAFbd5SWTiszJnKnsjDEEVgKhfIsieF68jS+hNVfeUIeQu2m3C5zjSQQqz
         kb5Tbuo5HOpWb65e6SEnk+XtGb9DTZ0AbMfxP59uezOmnz0vWnDEzymIdTX5s1VQPFuR
         grpIgX1u7Biza1mBF/e/HaTT+xKgILIWVvrQSyYxfAKQd+9L/wS+2k14qChsKlL8D1Lc
         oOlJkza42Rw2OCl2NWilU0hRibi7nsCW+DfCdJQiTh9gkuwuy0egaZ3qODIeg3EkCpk7
         wTJg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWNfFG8plexU6VtBsOra3XiBNL4QpmnMqRTRFnpAxB+68P0d+Vn
	xis7Xveoomt4u2C64A3fWlfnoQ9Toyj3ie+huSD37xBr3Du/pkIF2PXjPIy263cwockOiSmJqYd
	FbEt0/YFin58qHBIPkZZu9JtKSRJQ+nx2lymNKKBVYjWZ6vgtHr0BDDw8NO6/5VQ=
X-Received: by 2002:a17:906:4354:: with SMTP id z20mr596329ejm.163.1563536210486;
        Fri, 19 Jul 2019 04:36:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwV/MOnM/vg+LI7TKLCujgfNonUp+gQ5gn5g2XJwSE2z4QNkAuNwtITu4LR0tcfOQ3T5ADk
X-Received: by 2002:a17:906:4354:: with SMTP id z20mr596241ejm.163.1563536209192;
        Fri, 19 Jul 2019 04:36:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563536209; cv=none;
        d=google.com; s=arc-20160816;
        b=nY6gGQ/m1zfS4/cjkyndiSteiagMjk8YmX7Rix71ziyxfZet7d2HT7c2bNb0IlcjBn
         9qARkruXSDD0GTYh2m+iOe/M6ZWOIwqwZNt50FToHMZcV4T/bcjWQGpcTvNmensqObGm
         B+3RfSqW1IVw+vXDKV7DQTvSU3S1zRJw9E+l3rmbG9VgvcgPxDbPhO7HkEFazLqXVyXT
         mWfBy17q7stoYKRgjF1Si7T2AKUEpqLA4B9G3Rru95cQ256tJWX9986eEpTEj1CEam2a
         xOMzOgUUbIe7uHeeDXyozhaPgEDxCK/RKeAUCCGjbtZMG+Xy/Jy6iFdZ7dytzm8a1Vwx
         QJyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZkwLhCl205TZqQkCcgXIQR3FVhajaLXAXKtHwZ66THE=;
        b=XgghaOpgEz/aMe97JCGsuiurQjgKrK327ZYf79V+6WNW7rMob48SPjm4T3POAk8m0g
         HfLMOQ01/y3U9rw2o9Z35KKdcYgCusE7UqFifa82GU8qNxol4UE5piO+yNSBkNgfSpYK
         BcD8H/yClxCS/E9nk4bcc4fMdvoed+9vRdmv/Ns5xFE/m9zxqzRvdhru7kmbWuOUCYWu
         pi1Ob7rRmUnykMlxWWorhZtYAQBbMV3AZamtA+5/yKjc0exDj8m7e/gfTslViG4JGISj
         YGd3DYG1nmeDTdcXPSgloM2jOV2cnbcqKDpmHGW1ykvmbB2un3wdqRlKObR83ZSX/u5I
         adAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9si964303ejk.288.2019.07.19.04.36.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 04:36:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A675DAB98;
	Fri, 19 Jul 2019 11:36:48 +0000 (UTC)
Date: Fri, 19 Jul 2019 13:36:47 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] drivers/base/node.c: Simplify
 unregister_memory_block_under_nodes()
Message-ID: <20190719113647.GS30461@dhcp22.suse.cz>
References: <20190718142239.7205-1-david@redhat.com>
 <20190719084239.GO30461@dhcp22.suse.cz>
 <eff19965-f280-6124-8fc5-56e3101f67cb@redhat.com>
 <20190719091313.GR30461@dhcp22.suse.cz>
 <48ea1d5d-ce40-aaad-b9fe-006488ed71dc@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48ea1d5d-ce40-aaad-b9fe-006488ed71dc@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 19-07-19 11:20:43, David Hildenbrand wrote:
> On 19.07.19 11:13, Michal Hocko wrote:
> > On Fri 19-07-19 11:05:51, David Hildenbrand wrote:
> >> On 19.07.19 10:42, Michal Hocko wrote:
> >>> On Thu 18-07-19 16:22:39, David Hildenbrand wrote:
> >>>> We don't allow to offline memory block devices that belong to multiple
> >>>> numa nodes. Therefore, such devices can never get removed. It is
> >>>> sufficient to process a single node when removing the memory block.
> >>>>
> >>>> Remember for each memory block if it belongs to no, a single, or mixed
> >>>> nodes, so we can use that information to skip unregistering or print a
> >>>> warning (essentially a safety net to catch BUGs).
> >>>
> >>> I do not really like NUMA_NO_NODE - 1 thing. This is yet another invalid
> >>> node that is magic. Why should we even care? In other words why is this
> >>> patch an improvement?
> >>
> >> Oh, and to answer that part of the question:
> >>
> >> We no longer have to iterate over each pfn of a memory block to be removed.
> > 
> > Is it possible that we are overzealous when unregistering syfs files and
> > we should simply skip the pfn walk even without this change?
> > 
> 
> I assume you mean something like v1 without the warning/"NUMA_NO_NODE -1"?
> 
> See what I have right now below.

Yes. I didn'g get to look closely but you caught the idea. Thanks!
-- 
Michal Hocko
SUSE Labs

