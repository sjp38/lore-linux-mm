Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5B18C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 06:46:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4C4820665
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 06:46:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4C4820665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A2286B0006; Tue,  6 Aug 2019 02:46:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 477256B0008; Tue,  6 Aug 2019 02:46:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33FE66B000A; Tue,  6 Aug 2019 02:46:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DBF416B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 02:46:40 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w25so53094178edu.11
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 23:46:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+mOi+B0C2GQ0Wqp9BkDJ5RZZSZa/Z+lqdj4zyeet2Kw=;
        b=aMcuDoaVCbxtvIZvI98JwlnoCfaiSosAlnyHdDzz5UZZBMQqp2ZHk6U/fAsh8FZlQm
         dwONdxAp/BDNzkaJFHgz5DCAk82jwZEYcitPK6L6qO5LMvCW7MBqVKtgOZQGvF5nhhYO
         0/FY7mo6N/Lhn1qp1LKfayH7Q/IMyR+SxyTa0J0TXklh9h/xmYL/T+aovhNpn3Jxevlg
         JDFEvSDZW6LMGgd6tSdt7/FWjC4iuxO0N+8NlWCIej1ZeCuXjkPe6QhUUFQyUL8zMJPc
         AKlKIlAL7KfniBS1trnFaBU+YdotOF5LlzsHLc1cgsu0A3ilLiauD0KxVCRaccguAEzD
         3n1A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWyVyGpDszKMO7JT0W04b9jgvnuOmHHa5KDkk/32triYUDgwNlr
	xoH0aGOSmiSV2We+VDOLx7n2wmXBlD1ncMl8U5DxiYsVzhfhoYGsZ4xs3q40cYj4pYjuEFvYNNA
	7h3AWnY6gnxAoWqL/kBmT5Vs1cF21BWO/y2evInQXrU/1HzbdfH8iCCwbifV9mOY=
X-Received: by 2002:a17:906:e2c2:: with SMTP id gr2mr1664794ejb.284.1565074000445;
        Mon, 05 Aug 2019 23:46:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxV+Moue9mRQuBH+7/aadh4ruY65i9sA0J7WriyKhWpHdlSCquEVQ8GzxkmQ+EkMeGcSrHY
X-Received: by 2002:a17:906:e2c2:: with SMTP id gr2mr1664745ejb.284.1565073999630;
        Mon, 05 Aug 2019 23:46:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565073999; cv=none;
        d=google.com; s=arc-20160816;
        b=Rtgu3JHNkkAA870JtJ2Cza1ixSeE49l1JrG5WpFzbLpqLU7zZ6dFXtS2JLkZju3Z/6
         hZxC3csV/imx7yEpjWQMv3CyrofGF5Wp2BI1iYMwmPADj1q01z/sACSSqxEplQzHf+xb
         NoLddr/wFNNzIgjZ74gIQF6jpTP8Cfi1+SNO9SGFVHKpu3DndTwKliMjB/67IzdJjqWT
         Wqq8UDi3F6Q+jBWtQpmq2DirRZ2Z501nrkRdlkSnByJCnJEH0cFmHKCEH76+qSWRLmqF
         IV9Y+IomdWCz0uXVowjHfRs5Fnwp3GzSL7GK/zDIwjguo5Ncf+mC8F4MkCA4q0g4MX+S
         qlfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+mOi+B0C2GQ0Wqp9BkDJ5RZZSZa/Z+lqdj4zyeet2Kw=;
        b=TtQublJAeQFJtdJnzhtK9leylpmyFNHCNXS2LL83pO/GjXfVEiaimDge+giSt4ljNz
         HHgAoRQOslSkD74aLPnuQgmErrVARInxkJi3ydrT9ZKO3BJ9vLwS+g4VdMkJkda45I43
         QUukWW8INeiJT7qDgWO0P6aZ117A/nZPFoXoi/quwYicm1uPqmcJDiJIvN5yMVwEJ0R4
         ShKM3fMHF8ZlTLgneoBQvk1Itd/NBRJpPG4fnSwUDvH7DZO54+pOzErFJQ9tPQIPWy1C
         OSQt6uee5tk4xnB0FZJd2uu8y/avwhAn32oG3SWrMBxaOMq9GAyvv9yFH1fa2j5+ELT5
         o59Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gf12si27184184ejb.392.2019.08.05.23.46.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 23:46:39 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1979AB602;
	Tue,  6 Aug 2019 06:46:39 +0000 (UTC)
Date: Tue, 6 Aug 2019 08:46:36 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"hch@lst.de" <hch@lst.de>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Junichi Nomura <j-nomura@ce.jp.nec.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH 2/2] /proc/kpageflags: do not use uninitialized struct
 pages
Message-ID: <20190806064636.GU7597@dhcp22.suse.cz>
References: <20190725023100.31141-1-t-fukasawa@vx.jp.nec.com>
 <20190725023100.31141-3-t-fukasawa@vx.jp.nec.com>
 <20190725090341.GC13855@dhcp22.suse.cz>
 <40b3078e-fb8b-87ef-5c4e-6321956cc940@vx.jp.nec.com>
 <20190726070615.GB6142@dhcp22.suse.cz>
 <3a926ce5-75b9-ea94-d6e4-6888872e0dc4@vx.jp.nec.com>
 <CAPcyv4iCXWgxkLi3eM_EaqD0cuzmRyg5k4c9CeS1TyN+bajXFw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iCXWgxkLi3eM_EaqD0cuzmRyg5k4c9CeS1TyN+bajXFw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 05-08-19 20:27:03, Dan Williams wrote:
> On Sun, Aug 4, 2019 at 10:31 PM Toshiki Fukasawa
> <t-fukasawa@vx.jp.nec.com> wrote:
> >
> > On 2019/07/26 16:06, Michal Hocko wrote:
> > > On Fri 26-07-19 06:25:49, Toshiki Fukasawa wrote:
> > >>
> > >>
> > >> On 2019/07/25 18:03, Michal Hocko wrote:
> > >>> On Thu 25-07-19 02:31:18, Toshiki Fukasawa wrote:
> > >>>> A kernel panic was observed during reading /proc/kpageflags for
> > >>>> first few pfns allocated by pmem namespace:
> > >>>>
> > >>>> BUG: unable to handle page fault for address: fffffffffffffffe
> > >>>> [  114.495280] #PF: supervisor read access in kernel mode
> > >>>> [  114.495738] #PF: error_code(0x0000) - not-present page
> > >>>> [  114.496203] PGD 17120e067 P4D 17120e067 PUD 171210067 PMD 0
> > >>>> [  114.496713] Oops: 0000 [#1] SMP PTI
> > >>>> [  114.497037] CPU: 9 PID: 1202 Comm: page-types Not tainted 5.3.0-rc1 #1
> > >>>> [  114.497621] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.11.0-0-g63451fca13-prebuilt.qemu-project.org 04/01/2014
> > >>>> [  114.498706] RIP: 0010:stable_page_flags+0x27/0x3f0
> > >>>> [  114.499142] Code: 82 66 90 66 66 66 66 90 48 85 ff 0f 84 d1 03 00 00 41 54 55 48 89 fd 53 48 8b 57 08 48 8b 1f 48 8d 42 ff 83 e2 01 48 0f 44 c7 <48> 8b 00 f6 c4 02 0f 84 57 03 00 00 45 31 e4 48 8b 55 08 48 89 ef
> > >>>> [  114.500788] RSP: 0018:ffffa5e601a0fe60 EFLAGS: 00010202
> > >>>> [  114.501373] RAX: fffffffffffffffe RBX: ffffffffffffffff RCX: 0000000000000000
> > >>>> [  114.502009] RDX: 0000000000000001 RSI: 00007ffca13a7310 RDI: ffffd07489000000
> > >>>> [  114.502637] RBP: ffffd07489000000 R08: 0000000000000001 R09: 0000000000000000
> > >>>> [  114.503270] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000240000
> > >>>> [  114.503896] R13: 0000000000080000 R14: 00007ffca13a7310 R15: ffffa5e601a0ff08
> > >>>> [  114.504530] FS:  00007f0266c7f540(0000) GS:ffff962dbbac0000(0000) knlGS:0000000000000000
> > >>>> [  114.505245] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > >>>> [  114.505754] CR2: fffffffffffffffe CR3: 000000023a204000 CR4: 00000000000006e0
> > >>>> [  114.506401] Call Trace:
> > >>>> [  114.506660]  kpageflags_read+0xb1/0x130
> > >>>> [  114.507051]  proc_reg_read+0x39/0x60
> > >>>> [  114.507387]  vfs_read+0x8a/0x140
> > >>>> [  114.507686]  ksys_pread64+0x61/0xa0
> > >>>> [  114.508021]  do_syscall_64+0x5f/0x1a0
> > >>>> [  114.508372]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> > >>>> [  114.508844] RIP: 0033:0x7f0266ba426b
> > >>>>
> > >>>> The reason for the panic is that stable_page_flags() which parses
> > >>>> the page flags uses uninitialized struct pages reserved by the
> > >>>> ZONE_DEVICE driver.
> > >>>
> > >>> Why pmem hasn't initialized struct pages?
> > >>
> > >> We proposed to initialize in previous approach but that wasn't merged.
> > >> (See https://marc.info/?l=linux-mm&m=152964792500739&w=2)
> > >>
> > >>> Isn't that a bug that should be addressed rather than paper over it like this?
> > >>
> > >> I'm not sure. What do you think, Dan?
> > >
> > > Yeah, I am really curious about details. Why do we keep uninitialized
> > > struct pages at all? What is a random pfn walker supposed to do? What
> > > kind of metadata would be clobbered? In other words much more details
> > > please.
> > >
> > I also want to know. I do not think that initializing struct pages will
> > clobber any metadata.
> 
> The nvdimm implementation uses vmem_altmap to arrange for the 'struct
> page' array to be allocated from a reservation of a pmem namespace. A
> namespace in this mode contains an info-block that consumes the first
> 8K of the namespace capacity, capacity designated for page mapping,
> capacity for padding the start of data to optionally 4K, 2MB, or 1GB
> (on x86), and then the namespace data itself. The implementation
> specifies a section aligned (now sub-section aligned) address to
> arch_add_memory() to establish the linear mapping to map the metadata,
> and then vmem_altmap indicates to memmap_init_zone() which pfns
> represent data. The implementation only specifies enough 'struct page'
> capacity for pfn_to_page() to operate on the data space, not the
> namespace metadata space.

Maybe I am dense but I do not really understand what prevents those
struct pages to be initialized to whatever state nvidimm subsystem
expects them to be? Is that a initialization speed up optimization?
 
> The proposal to validate ZONE_DEVICE pfns against the altmap seems the
> right approach to me.

This however means that all pfn walkers have to be aware of these
special struct pages somehow and that is error prone.

-- 
Michal Hocko
SUSE Labs

