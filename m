Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E37CC43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 10:48:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFA222081C
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 10:48:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFA222081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 673C16B0003; Fri,  3 May 2019 06:48:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 626086B0005; Fri,  3 May 2019 06:48:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 514766B0007; Fri,  3 May 2019 06:48:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00B546B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 06:48:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n52so3378922edd.2
        for <linux-mm@kvack.org>; Fri, 03 May 2019 03:48:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JbOcbgDDMMI3oeDclWlVxOnJw5yFvcXIYuO9D4pP5t8=;
        b=iA8umKWBLP7mzgLLEtYu+u4YrC5h8B7XWjknvr5wbYL7nP4ubKs2cPEQELoQRf9jZj
         FkL30wtF+dX+DEZRlIAIrzqfewBSCOgmnFERpiEm1xm0uCZmlT/GKyy1WILTV+xvTlnQ
         pilA8N/iAdDCvA+SByBFyHrEvkOy8gI/jTu2/iJ5QYJjD2MpXqA6QxzjFPogtIbK8x4m
         2aBQ37Kz3B+zf0JP8gb5kC2a6F5bFgC/Azq317z2/sDGnTk4lMIF2FmgfUBVpisB7n8z
         NxRqe7lRngMpLHX9aPE/7SSAyJj30T4mM5LWiAhU0Wf1drARpNXdv+p/tG55Vd8ZnLal
         PuaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXCjt9n4KwWagGg8I8XoUaVG0ExBB2aXyYgo2YxCiNhBQ8FFDP+
	78DVqQOdmFd3KXobY4HyIR2X75j/7vKxlrGLg6QtMa7cbx40NKxCt5oyiLNHrGg6YfAsT8HeDmA
	5JTDG6fOMnpCyvNMpgliWrl7HNu/PJVq3c80EddYhVt06/H5xkubyrj59/i8HxYIDTA==
X-Received: by 2002:a50:e101:: with SMTP id h1mr7633362edl.180.1556880518565;
        Fri, 03 May 2019 03:48:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2Pj9Yv0vJ/bX+8wTDDKd4xVkkI819x2OSsSlPZUrKQY+EEvhhWFlZ+oOK7kNmb+88+ztK
X-Received: by 2002:a50:e101:: with SMTP id h1mr7633295edl.180.1556880517638;
        Fri, 03 May 2019 03:48:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556880517; cv=none;
        d=google.com; s=arc-20160816;
        b=HFjWpDmJ0wQCQSNAvg+Ymem3yv3o9fkGBLVoS4MaPwWXe1Pp9vPkRzSjbzR9+Py6Dy
         BqYUcmN8oPLJzpwKBnE1MZ3i8qaSwa+JkUQRIH/8w5ffBAHABxcSnukvVzL+RNKU/RmM
         NBbdIqvsIefsNfQD+CDSa05AyQm2ySZW6Y4L7pRp3y6NFDQJeTzlcrNSBqXFq35vEaFN
         vsnoUi3Q4E7TwViZfJphEOSkaGXDdA+3k+TAQuLX4JU9OTqoJmQuYRkUth9Cw/3kBY0C
         LsT2IEmw6zqG8onmU+sOVvNUjq/oMpyp6vTp+fcA5igOcOVlBS12GzFzyP1iYxFEvXT7
         PRMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JbOcbgDDMMI3oeDclWlVxOnJw5yFvcXIYuO9D4pP5t8=;
        b=j6xHiN55n1kptEMErNK4oeT/ZN84OKnMvxy6E5ZSnwnDj9mEamM/MfcUyaZojfGp5c
         iPgXq05AHZTgg7PYqVXH7G6rAUmcS0baH/wQwRr+dd9V9yg7g3IBQZDXYPbNK1hRUd0N
         WTJDGD4KxhcVwKiLqLYhy5QCO9l7lLD1Eg0UwtL4Axn4LDh3mAl44kCddKH0OPSfZMFe
         T1/BguRa3alY2q1eaH7dS86lDQXDcRbEdj5hykHvqZWyQMMK7qLILI6seZucp+NEBjCX
         mdT989SI+KG+pu/K6Mm6QzFHZfJQ87EpxIaYrN2bFDwNvWFyzK61tom8OikolVUyxxCU
         QNsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d16si1296887ede.160.2019.05.03.03.48.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 03:48:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0A4E7AD89;
	Fri,  3 May 2019 10:48:37 +0000 (UTC)
Date: Fri, 3 May 2019 12:48:32 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Hildenbrand <david@redhat.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>,
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
	stable <stable@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v6 00/12] mm: Sub-section memory hotplug support
Message-ID: <20190503104831.GF15740@linux>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CA+CK2bBT=goxf5KWLhca7uQutUj9670aL9r02_+BsJ+bLkjj=g@mail.gmail.com>
 <CAPcyv4gWZxSepaACiyR43qytA1jR8fVaeLy1rv7dFJW-ZE63EA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gWZxSepaACiyR43qytA1jR8fVaeLy1rv7dFJW-ZE63EA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 02, 2019 at 04:20:03PM -0700, Dan Williams wrote:
> On Thu, May 2, 2019 at 3:46 PM Pavel Tatashin <pasha.tatashin@soleen.com> wrote:
> >
> > Hi Dan,
> >
> > How do you test these patches? Do you have any instructions?
> 
> Yes, I briefly mentioned this in the cover letter, but here is the
> test I am using:
> 
> >
> > I see for example that check_hotplug_memory_range() still enforces
> > memory_block_size_bytes() alignment.
> >
> > Also, after removing check_hotplug_memory_range(), I tried to online
> > 16M aligned DAX memory, and got the following panic:
> 
> Right, this functionality is currently strictly limited to the
> devm_memremap_pages() case where there are guarantees that the memory
> will never be onlined. This is due to the fact that the section size
> is entangled with the memblock api. That said I would have expected
> you to trigger the warning in subsection_check() before getting this
> far into the hotplug process.
> >
> > # echo online > /sys/devices/system/memory/memory7/state
> > [  202.193132] WARNING: CPU: 2 PID: 351 at drivers/base/memory.c:207
> > memory_block_action+0x110/0x178
> > [  202.193391] Modules linked in:
> > [  202.193698] CPU: 2 PID: 351 Comm: sh Not tainted
> > 5.1.0-rc7_pt_devdax-00038-g865af4385544-dirty #9
> > [  202.193909] Hardware name: linux,dummy-virt (DT)
> > [  202.194122] pstate: 60000005 (nZCv daif -PAN -UAO)
> > [  202.194243] pc : memory_block_action+0x110/0x178
> > [  202.194404] lr : memory_block_action+0x90/0x178
> > [  202.194506] sp : ffff000016763ca0
> > [  202.194592] x29: ffff000016763ca0 x28: ffff80016fd29b80
> > [  202.194724] x27: 0000000000000000 x26: 0000000000000000
> > [  202.194838] x25: ffff000015546000 x24: 00000000001c0000
> > [  202.194949] x23: 0000000000000000 x22: 0000000000040000
> > [  202.195058] x21: 00000000001c0000 x20: 0000000000000008
> > [  202.195168] x19: 0000000000000007 x18: 0000000000000000
> > [  202.195281] x17: 0000000000000000 x16: 0000000000000000
> > [  202.195393] x15: 0000000000000000 x14: 0000000000000000
> > [  202.195505] x13: 0000000000000000 x12: 0000000000000000
> > [  202.195614] x11: 0000000000000000 x10: 0000000000000000
> > [  202.195744] x9 : 0000000000000000 x8 : 0000000180000000
> > [  202.195858] x7 : 0000000000000018 x6 : ffff000015541930
> > [  202.195966] x5 : ffff000015541930 x4 : 0000000000000001
> > [  202.196074] x3 : 0000000000000001 x2 : 0000000000000000
> > [  202.196185] x1 : 0000000000000070 x0 : 0000000000000000
> > [  202.196366] Call trace:
> > [  202.196455]  memory_block_action+0x110/0x178
> > [  202.196589]  memory_subsys_online+0x3c/0x80
> > [  202.196681]  device_online+0x6c/0x90
> > [  202.196761]  state_store+0x84/0x100
> > [  202.196841]  dev_attr_store+0x18/0x28
> > [  202.196927]  sysfs_kf_write+0x40/0x58
> > [  202.197010]  kernfs_fop_write+0xcc/0x1d8
> > [  202.197099]  __vfs_write+0x18/0x40
> > [  202.197187]  vfs_write+0xa4/0x1b0
> > [  202.197295]  ksys_write+0x64/0xd8
> > [  202.197430]  __arm64_sys_write+0x18/0x20
> > [  202.197521]  el0_svc_common.constprop.0+0x7c/0xe8
> > [  202.197621]  el0_svc_handler+0x28/0x78
> > [  202.197706]  el0_svc+0x8/0xc
> > [  202.197828] ---[ end trace 57719823dda6d21e ]---

This warning relates to:

        for (; section_nr < section_nr_end; section_nr++) {
                if (WARN_ON_ONCE(!pfn_valid(pfn)))
                        return false;

from pages_correctly_probed().
AFAICS, this is orthogonal to subsection_check().


-- 
Oscar Salvador
SUSE L3

