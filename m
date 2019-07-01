Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12237C06511
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:47:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFFBF2133D
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:47:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFFBF2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29BC46B0006; Mon,  1 Jul 2019 06:47:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24B268E0009; Mon,  1 Jul 2019 06:47:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 139B18E0002; Mon,  1 Jul 2019 06:47:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f78.google.com (mail-ed1-f78.google.com [209.85.208.78])
	by kanga.kvack.org (Postfix) with ESMTP id 9B44F6B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 06:47:01 -0400 (EDT)
Received: by mail-ed1-f78.google.com with SMTP id o13so16571060edt.4
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 03:47:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uGdDddJBdJpBa1UkXgnQ/Zcc02heFyJUY26VzUcvXV4=;
        b=A8lD2iS99L1wyqD/3+j23wzEReoWaKQOQx3bw+NlUDMo/oXE2hqBPCLIul0a6Hf5di
         Mo+bG7umTZJ1RKGuvk7Ti5FYCDqKypXY0k55HwBNE3ySzWhUHwtGpBlAPztTbCNbaTzE
         GkGSlbSLZcs5wxTz6Qh4s8VSH/GHbNHDntjnJzah2rJHQFdbMMSJUOmpGS0EaY1yJZOs
         8et+yLbW7YZo+dZTAp6tWB1DrhHLF/7EeB7PPaORDYARMlcbacOeM9NAItC842ItQ/lG
         QPDGAmyJ0bvnmvJxY9DUc0AfnthIVKrt4iKsg8asUPe0tVI09b4k0Ji1550Raqhf0G7e
         g3gw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU1xttXSFIQUnWQ8uP8AQN12jwTg5TOqHWZxkzC+WGtAp4g+ub8
	PvVZBusWXVRol5vLOZPq15p9qndx8yti5m46JBOYgj/jVS39U0+vUzkjaHZ2HL0DgGjqnXTKeFa
	ekSkGSUBf/vXijc9UblG/9M4K7WfrXW/Avy7lS5MdX65Vgqt/D6SkAkHlqwLOhFo=
X-Received: by 2002:a50:a3f5:: with SMTP id t50mr27924243edb.273.1561978021214;
        Mon, 01 Jul 2019 03:47:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwErAX9RIK6IIERpQwbkPpbTqm3uo3kyRENyxtklnAaBc51QJWn5s/OW/r+Rtqk1WRVPp1n
X-Received: by 2002:a50:a3f5:: with SMTP id t50mr27924178edb.273.1561978020442;
        Mon, 01 Jul 2019 03:47:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561978020; cv=none;
        d=google.com; s=arc-20160816;
        b=Iu4JE1JHp2rhkg1sMaglJ4bKg1kk3Ar2rK8Yft/KhTYIYQucAoNBg0UYsxmM8R6ciZ
         Bi7vhcrHmSWnJnUPhTaR90+dcYWIY/UYFdrds/itSOwFpbn4FA9lUXZQBlzoxFr7Htqw
         f1J9Gbfh80imTwOz7dYx1vlarqyx1J0vj6jflleG3BGe18ALPUQmRLbqJSbHCBC5UPSe
         w6Ruh8XRbOFYT/iSH0aMzog0HvF85FtbevTDeiilLolUvy/OHMV3wEDgP5mIrxqN8/2R
         EPpluuHE5U/d5guw67KpTs0NeN9R3xJ5rnkgdZ7JSSQNjvneFgophaRpCy5VvHkKy77S
         lrVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uGdDddJBdJpBa1UkXgnQ/Zcc02heFyJUY26VzUcvXV4=;
        b=vaxOkrqlYYSssHbk5K9ulvVN3mPYnayzdT5uCWpd9MK/01EG9UrTdwaaztI71zuNpX
         UDn80y33cd+sdvkujwuqn584odZYEH8LxfxIz1t8YdysvbvxR39AuxZ5szCo7OIhDArd
         C55ldNXsjroosxjGj0IuD17qqNMIc32T6BwNmR4Sex3kBpdVCPnCFMtpX0hw2sxd3iH/
         rzEvzeAfHMRWTFI+iYyPj8KwPebSK+5zLWFt2KTmpPUyOrqfdF/gDaTvQ50ErVhUbC1L
         lWx/un4sawj0SpHPnYjTiZ6y3kMKiJN2pVdz3RvNavJ+QFPBPZh+LKz4LL3oXy+X+BHs
         HEvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r5si2598237ejj.371.2019.07.01.03.47.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 03:47:00 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 972EBAD8D;
	Mon,  1 Jul 2019 10:46:59 +0000 (UTC)
Date: Mon, 1 Jul 2019 12:46:58 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@d-silva.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Oscar Salvador <osalvador@suse.de>,
	Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 1/3] mm: Trigger bug on if a section is not found in
 __section_nr
Message-ID: <20190701104658.GA6549@dhcp22.suse.cz>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
 <20190626061124.16013-2-alastair@au1.ibm.com>
 <20190626062113.GF17798@dhcp22.suse.cz>
 <d4af66721ea53ce7df2d45a567d17a30575672b2.camel@d-silva.org>
 <20190626065751.GK17798@dhcp22.suse.cz>
 <e66e43b1fdfbff94ab23a23c48aa6cbe210a3131.camel@d-silva.org>
 <20190627080724.GK17798@dhcp22.suse.cz>
 <833b9675bc363342827cb8f7c76ebb911f7f960d.camel@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <833b9675bc363342827cb8f7c76ebb911f7f960d.camel@d-silva.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 28-06-19 10:46:28, Alastair D'Silva wrote:
[...]
> Given that there is already a VM_BUG_ON in the code, how do you feel
> about broadening the scope from 'VM_BUG_ON(!root)' to 'VM_BUG_ON(!root
> || (root_nr == NR_SECTION_ROOTS))'?

As far as I understand the existing VM_BUG_ON will hit when the
mem_section tree gets corrupted. This is a different situation to an
incorrect section given so I wouldn't really mix those two. And I still
do not see much point to protect from unexpected input parameter as this
is internal function as already pointed out.

-- 
Michal Hocko
SUSE Labs

