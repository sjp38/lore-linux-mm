Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6C65C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:14:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7211A206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:14:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7211A206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 017558E0003; Wed, 31 Jul 2019 10:14:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE3398E0001; Wed, 31 Jul 2019 10:14:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAC648E0003; Wed, 31 Jul 2019 10:14:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8AAFC8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:14:13 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so42539784eda.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:14:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=m0wLLaXnkURh8uA0kgpqUac1IoBcsqzS3q0bQGK8QS8=;
        b=qeyJtIgYhMGd0PUIQ2P35QLR2q0+Ms0Aj0+PDA5t4oDE4AeC8HhdTFlNFsRBPbJCSd
         olTYkThkz/kSq8eoJ+NtZowaYqnExpsW+ibTfgFiraDPRNCUP4HOS3qVx60RDL1VFWI5
         1AnusbJ0cWVarcQQBc8mWOoJ3Lny2jvUtoafuFeS4nEcwC52LJILnyBoFz07MwopEcnG
         Z7GRUcnY7eEJWMxgfMH3Q1kevWKIbZG4lKG4vUeeuokg/fPW23qJDYGqtfBArHTIcVWX
         l/TXYpzwBAkbWzB+iCT11q6pydeJ0qt2ZIb0nEzgFs+zG/kHLnnIr4nVlflV85poNJNL
         EFFg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUWsdwYVzoul276MOY6dItsDE4Di5WUR62P80C/QYopZ6KCbLLF
	CBe854I9sc2XwdspTFXWTlYOiaBBVb44lVK1JKBhZbaqE51tLb0qrKHUjHMLmypsPF9nHmTOX8R
	XdzVQwMmH2mqN6G1t+3IrM0d6Nx9v804VDTe3zKPM+QOy1x1zHVIbFiw5MDXys7k=
X-Received: by 2002:a50:d65e:: with SMTP id c30mr107290611edj.38.1564582453122;
        Wed, 31 Jul 2019 07:14:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZ8BqQbL94cmhz7JPafRSHnMcSHYzbJSf1EX5T3K2UaquGzmuE7r6DGy33e6LiKdTqCy6i
X-Received: by 2002:a50:d65e:: with SMTP id c30mr107290528edj.38.1564582452339;
        Wed, 31 Jul 2019 07:14:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564582452; cv=none;
        d=google.com; s=arc-20160816;
        b=D4CWtWZgp0bxElIZxJm+wA96tgM0M4TLUeg4Jm8vmD2hRADYRcwhujblSxyBsC0XR1
         ObUi4BusLYsSuX5FL6DBgC+ErBB9LNFaLNDEjS05+v3ZYAjPMNSIoGiObcqxbTQWvkIy
         kVKHUBl8V+Xn8O/tb+IOs/8snlpiKGe7yURX4w1F4JALOzjN51mOQuPyTEK9QrjKQ3UC
         zZlbHxtoUMROe6k0665/JtqwnfG2UbFySC1mWUObOROE3CdctzQRITvYPT+oIIwfMj7d
         YFmAVT2dgVv8QZVmLMnK9TN4zKhUoBdhP8ka6OwB5bukFFkZ9WhQqUOvwbyzRUAyr6DM
         AS9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=m0wLLaXnkURh8uA0kgpqUac1IoBcsqzS3q0bQGK8QS8=;
        b=gxD1zNt4ctScYFYdybSJs0dqT+J3H/OBoRLHxyODVhZecr4XrvUpGSiddJD8jXfLrZ
         qdXDgE25WEtfYrARyBO0xLK0X57r8AOXVYQ6otPQG4iR8OfcD6VCGyaELYIQkn7GKXoy
         xK5R0EhfgoyTToINFNiTbmkLy2CD722DNqdwxNJ5DulqP4QnCww9waY5Wc9hqFu7jn01
         LGEiyAKtIP2D4KNvO9IzhWi0N/64r/V9AwfBL32By28ZfYVbhQa2pIcOP2jGpqOZkm2h
         Nr9MqNwHSSnjqRc4mc9C7C2obmf7Ze/QVR+yU88CVi/q5SrXSxACsclQPzUIny76KQ9e
         IZQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f22si22429032eda.203.2019.07.31.07.14.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 07:14:12 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B7F4DAB9B;
	Wed, 31 Jul 2019 14:14:11 +0000 (UTC)
Date: Wed, 31 Jul 2019 16:14:11 +0200
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
Message-ID: <20190731141411.GU9330@dhcp22.suse.cz>
References: <20190731122213.13392-1-david@redhat.com>
 <20190731124356.GL9330@dhcp22.suse.cz>
 <f0894c30-105a-2241-a505-7436bc15b864@redhat.com>
 <20190731132534.GQ9330@dhcp22.suse.cz>
 <58bd9479-051b-a13b-b6d0-c93aac2ed1b3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58bd9479-051b-a13b-b6d0-c93aac2ed1b3@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 15:42:53, David Hildenbrand wrote:
> On 31.07.19 15:25, Michal Hocko wrote:
[...]
> > I know we have documented this as an ABI and it is really _sad_ that
> > this ABI didn't get through normal scrutiny any user visible interface
> > should go through but these are sins of the past...
> 
> A quick google search indicates that
> 
> Kata containers queries the block size:
> https://github.com/kata-containers/runtime/issues/796
> 
> Powerpc userspace queries it:
> https://groups.google.com/forum/#!msg/powerpc-utils-devel/dKjZCqpTxus/AwkstV2ABwAJ
> 
> I can imagine that ppc dynamic memory onlines only pieces of added
> memory - DIMMs AFAIK (haven't looked at the details).
> 
> There might be more users.

Thanks! I suspect most of them are just using the information because
they do not have anything better.

Thinking about it some more, I believe that we can reasonably provide
both APIs controlable by a command line parameter for backwards
compatibility. It is the hotplug code to control sysfs APIs.  E.g.
create one sysfs entry per add_memory_resource for the new semantic.

It is some time since I've checked the ACPI side of the matter but that
code shouldn't really depend on a particular size of the memblock
either when trigerring udev events. I might be wrong here of course.
-- 
Michal Hocko
SUSE Labs

