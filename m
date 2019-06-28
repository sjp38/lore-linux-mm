Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEFA3C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 07:31:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99B852064A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 07:31:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99B852064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B5DA6B0003; Fri, 28 Jun 2019 03:31:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23F3D8E0003; Fri, 28 Jun 2019 03:31:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 107668E0002; Fri, 28 Jun 2019 03:31:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3D9A6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 03:31:32 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m23so8146953edr.7
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 00:31:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XeQouqUJAzpEqvuzyif/2fBCLtdFeOZ7ChHqCkDtlwM=;
        b=niDCyKz65A5cCz1QWOTFR187pP3zwwUZU7zzzJw67mOFPNrLr7766C4PC9cKtK0oMR
         s40yPCYrKUuOF8XlrNav8NtuV7lXGM0E1yowWPaAqxXjJ5OGzbpnP68kgbXWAUSDmi5s
         lXucdTs3UPnd5CuKY82rjEUu44C7oKaohs7vexy7jnFIq8+ey7bOcGG3w5iqELxkXUgC
         OFlwFqgu7JH9NcEHWsendZrG3/olKFnVMN1K5v3WmXJ9XwAQWQlamxeHk6BuKU+GBDbm
         xkHQnquz7RnRYf9Mg4hno6CP5yYEg/lnd5ax0Tm72n/Y3YDjRAfEKhOg9jRqiAh3dYCs
         M4bw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV5dcquQXn+MdLsswijjA8gzNPyBa/bFkWbxE04GG4BAwCLGSb2
	PRn5FQe2zM4mI3jEltfR8TAwTGmYcXmn7/+p+BqkdfnzWd/qH1BIN16509IwA9XiIF8Y/4jo547
	oK2fFYZoENgIfcFK1LNrEJw3rrTzRAKEbZxiYNzs+6F5obnHRJ9Q39z6yrmeaDIs=
X-Received: by 2002:aa7:c14f:: with SMTP id r15mr9495616edp.116.1561707092294;
        Fri, 28 Jun 2019 00:31:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsVs4jLdgPmSMVhey2kFSJQxq8OK1GBXzt4ctv4ElKrim6x17sVxlSyUv7Q9YDlmRIHVek
X-Received: by 2002:aa7:c14f:: with SMTP id r15mr9495554edp.116.1561707091487;
        Fri, 28 Jun 2019 00:31:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561707091; cv=none;
        d=google.com; s=arc-20160816;
        b=MzPsNcQSCrz3YvfdBdKm/w51Gg3MHjW8wVF2Dfle5e0mcmbmkbUUuTfG8mciijLuLB
         U2RF31ZSM1sk45Vpgwdtz9Rkvka43yEzYKimLHYpYQGqSkkEjDNvx8RDLi+B/zE3CXa2
         odPeaQasem+KqX81LYbliXrRqW5nkwlMO6yANj3PxQO/EeUYLWSVeaVT9/+8s6SB8vLa
         oP8NEe85+oVefwMQ5zYgdzgrwkgCL3kfyZ4itFqphEdqFoc2P5E/O8YgGklPDON4OHcN
         U61BxGcoX6ZrDjrifq1mP0dXVYU6gA70CjxrqaDXvrtdO8M7Wqf88K0IEYp3qTYMnTFT
         XFyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XeQouqUJAzpEqvuzyif/2fBCLtdFeOZ7ChHqCkDtlwM=;
        b=VhBKpRF1OVSMRxLEnwUgmr9RTTSIxY0KW/7SwDLvgbINCajV3evaSegjCfsMgTnwRR
         tdTUWbY/WQwh02B/ek5oiGIebtMGRptZRlXXJcZ403j9nOUpJyxNqkg+RUAUaxlM5zY8
         r8a0fdIcxPeSpvm/0gvYsHPyhFRFgJT3lDMnMK20Fh/YiN744Mh94JcniXKl/7TZUFiL
         ixl90GPA4RQYNey0yhM3BP6/0pPpIzwvL1eTEi3X44UqXfmKNdRoiTEp9a10T76wlP0v
         flZ1Plc31ai/7BiLT4z+mG5gm6GVEtB5orPDU0t6YXbNGxi4PpbroaPkXNGA8oAadfTH
         g9hw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l18si880374ejp.37.2019.06.28.00.31.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 00:31:31 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D3DF7B167;
	Fri, 28 Jun 2019 07:31:30 +0000 (UTC)
Date: Fri, 28 Jun 2019 09:31:28 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm, slab: Extend vm/drop_caches to shrink kmem slabs
Message-ID: <20190628073128.GC2751@dhcp22.suse.cz>
References: <20190624174219.25513-1-longman@redhat.com>
 <20190624174219.25513-3-longman@redhat.com>
 <20190627151506.GE5303@dhcp22.suse.cz>
 <5cb05d2c-39a7-f138-b0b9-4b03d6008999@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5cb05d2c-39a7-f138-b0b9-4b03d6008999@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 27-06-19 17:16:04, Waiman Long wrote:
> On 6/27/19 11:15 AM, Michal Hocko wrote:
> > On Mon 24-06-19 13:42:19, Waiman Long wrote:
> >> With the slub memory allocator, the numbers of active slab objects
> >> reported in /proc/slabinfo are not real because they include objects
> >> that are held by the per-cpu slab structures whether they are actually
> >> used or not.  The problem gets worse the more CPUs a system have. For
> >> instance, looking at the reported number of active task_struct objects,
> >> one will wonder where all the missing tasks gone.
> >>
> >> I know it is hard and costly to get a real count of active objects.
> > What exactly is expensive? Why cannot slabinfo reduce the number of
> > active objects by per-cpu cached objects?
> >
> The number of cachelines that needs to be accessed in order to get an
> accurate count will be much higher if we need to iterate through all the
> per-cpu structures. In addition, accessing the per-cpu partial list will
> be racy.

Why is all that a problem for a root only interface that should be used
quite rarely (it is not something that you should be reading hundreds
time per second, right)?
-- 
Michal Hocko
SUSE Labs

