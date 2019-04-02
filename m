Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B822C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 12:48:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2402720883
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 12:48:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2402720883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A13EC6B027F; Tue,  2 Apr 2019 08:48:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C3276B0280; Tue,  2 Apr 2019 08:48:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D9936B0281; Tue,  2 Apr 2019 08:48:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF376B027F
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 08:48:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k8so5803308edl.22
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 05:48:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iNNIva2PGlVd3YmU/50XrjSdWPADvFL/RX7vnfFf2Rs=;
        b=kX300+laHBFp2/0ou7LxD3MypNOtbOyw30FF4n2DRjktFMGNdHEPgIoVYga1R+gsvW
         NVv+HTn2jG9DlRoxyZZq/XayP3sIQMKjgTQHAM33FMQkcFeeElQGToGoeS++0jJAtX4y
         47NHMbMRKDUtjrZAvA+Gid8LjP2VNSHrhhJFPbe7zPi4t1a2O++uIMvJ0zS9kaqSmEPJ
         o8ccu7dAqfkAO1DigmtCPxzYQy7VliLdogUnv9ejqOVqd4Oyvk1e0WyXQ3sjypW+i7VE
         U4vNXWr6fk/e9mY9MVRFV+8D4ZeL/Ddbcrdllp7v2L7c93eIqiXFKprH/9M1fyIFWgsi
         TJ8Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVA8GFtDjtRQEgUAbcpHZCleuPVrulQ5ovED8J405OiFDt/J2GK
	nJHqjgB5AnVIjnEO2M/aA5AvLA2jOdMiR9LI9HNOSEzYSLOApY7j57PZlc7um/MZtunlLHnvt7W
	02PMs8pUs8Hi8n7EhJyU1+OQ23mN9vHzGwCXWdkkBHwrEwIK2d3v3tP90FP3FBCM=
X-Received: by 2002:a50:9e6b:: with SMTP id z98mr47461907ede.174.1554209327812;
        Tue, 02 Apr 2019 05:48:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzicnABrqCofQrvAy1ZJ5QC6azibIePzRLwCQzAR0JJqjR6sri8rwV/vzxH3nR3yP6oJBS4
X-Received: by 2002:a50:9e6b:: with SMTP id z98mr47461867ede.174.1554209326968;
        Tue, 02 Apr 2019 05:48:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554209326; cv=none;
        d=google.com; s=arc-20160816;
        b=bzGQuW81isel8Kh6eyaeMDOaCJZl7NevaSSnsygz7HDlThoqIaKQZr4V/pqMS1Z3rP
         vAlvCoNMGb3OyuWdvW5r8NR6nuWFeG3EHr1J6daTPShbFJy0ft9Mh+X4VOXog/bsBfXn
         LoYihtrboSfGsNN1BtoFQeCJwrm6b94T1GVWBYfYVDh/yiGiu5eo78PY6OSxHiUCMy5v
         S8T5X/iqCa7XrZ182yyiTrThLBeJqaRoxSzIPZoeUcN9KBGeD57HQmA2yBZ5m+8WonD6
         8K0yCTtmr1Sc6moLXw12nWaqO0mdFY8v1k4ZWEIa49Xfa5NVMcyebpRTpqVuS/fUdzSW
         ouCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iNNIva2PGlVd3YmU/50XrjSdWPADvFL/RX7vnfFf2Rs=;
        b=Dx29yIPc48bWNMvgfQQVOMCVjJkO/70t7wFASVBiryPOEHjyBKCzT9gWfF6Ufc/aVv
         Xgtx0cKCPfl8ABgozD5FhnzrTogh59b55ESk6n9Ynn1iUtjaY5JVIhStKIBzkdNjMoPE
         CnYWXn2zfVPikwI9Jay8JbkU/gVsbjq4yRbsWhCDmPvYXaDX1eeISm5gR36BJGyOdaqw
         WL+GlQNO+MaJXWYmLOXiDkL4VtomdW6lyytUngzDwpbb7koNjXBm/fjNq98zHiqaJcSJ
         ljmYnepmpbjFl4eWfq+KQxPboWIqM0y6pkeuC4xsjutwSdWxJbvwGWTwBI+OQ+H81l4Y
         V5Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m21si5416016edq.234.2019.04.02.05.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 05:48:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 62AC5ACAD;
	Tue,  2 Apr 2019 12:48:46 +0000 (UTC)
Date: Tue, 2 Apr 2019 14:48:45 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190402124845.GD28293@dhcp22.suse.cz>
References: <20190328134320.13232-1-osalvador@suse.de>
 <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
 <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
 <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
 <20190401115306.GF28293@dhcp22.suse.cz>
 <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 02-04-19 10:28:15, Oscar Salvador wrote:
> On Mon, Apr 01, 2019 at 01:53:06PM +0200, Michal Hocko wrote:
> > On Mon 01-04-19 09:59:36, Oscar Salvador wrote:
> > > On Fri, Mar 29, 2019 at 02:42:43PM +0100, Michal Hocko wrote:
> > > > Having a larger contiguous area is definitely nice to have but you also
> > > > have to consider the other side of the thing. If we have a movable
> > > > memblock with unmovable memory then we are breaking the movable
> > > > property. So there should be some flexibility for caller to tell whether
> > > > to allocate on per device or per memblock. Or we need something to move
> > > > memmaps during the hotremove.
> > > 
> > > By movable memblock you mean a memblock whose pages can be migrated over when
> > > this memblock is offlined, right?
> > 
> > I am mostly thinking about movable_node kernel parameter which makes
> > newly hotpluged memory go into ZONE_MOVABLE and people do use that to
> > make sure such a memory can be later hotremoved.
> 
> Uhm, I might be missing your point, but hot-added memory that makes use of
> vmemmap pages can be hot-removed as any other memory.
> 
> Vmemmap pages do not account as unmovable memory, they just stick around
> until all sections they referred to have been removed, and then, we proceed
> with removing them.
> So, to put it in another way: vmemmap pages are left in the system until the
> whole memory device (DIMM, virt mem-device or whatever) is completely
> hot-removed.

So what is going to happen when you hotadd two memblocks. The first one
holds memmaps and then you want to hotremove (not just offline) it?
-- 
Michal Hocko
SUSE Labs

