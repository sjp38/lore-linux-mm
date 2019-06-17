Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C148C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:22:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51FBE21E6D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:22:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51FBE21E6D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2DDA8E0003; Mon, 17 Jun 2019 04:22:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB77D8E0001; Mon, 17 Jun 2019 04:22:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA4A88E0003; Mon, 17 Jun 2019 04:22:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7AABF8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 04:22:01 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y24so15365329edb.1
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 01:22:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7ymvn5JUry7KtFqwp5cxRbfksIusBDKC6pSOP5eNR8Y=;
        b=a8dOI8E7Fb4SErLyqxxtapkfT7Z1BIQDmIYz0wctQEmTn1TQpBYR1btKfIOvvuzuSu
         1Ry/OvqwNx1d3KyPcFiuFePhCIGWiKJf4o7FojZRG5E0dVz/A/gle7wmVYzhc4GJ7z7S
         NUjky4Bn5MJ+95pGDefMd3p9ri2FcZI+A1o5VT8FHUsKIMuz0zg2/St3xm+7YNnl12Zn
         aTEp5rJ69xbXroIa+8FUGV9mAIKGWVjyY1LnmdKSTvo6qAoY79RaAS3kr7yLXadTEIDN
         p10GfaZbjGXgaOSI1QVpkypWSIoldg4ZZ1fOCQG8wjpwlPuG2Wc9SxD8JX0+6sNOUyf0
         T2tA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW5sbCs1UUAYb9SKaf6H+kx3h/9nECQ1XFbwIkIneamZqrO1g9k
	IBUdXkRmp9yzJJr/MCgcyPNjKmMiS+Xw8N1FZGAtXVPw7CR9+RX6wsbra/jTtCSryhV0scGebaX
	H2+yxsA7OSCFU4wIwhKP1JJ1o8I4F5yRXM1fji7sxFxhEYUbz89cK1gdt0SQHQBs=
X-Received: by 2002:a17:906:a308:: with SMTP id j8mr43613100ejz.167.1560759721036;
        Mon, 17 Jun 2019 01:22:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsF2lEmT0OGg7OIEU2qoad5dXIXmKMqLAcBhq+bVz+2SLuvN7tcoN76+kWgK+3RF/bu3pm
X-Received: by 2002:a17:906:a308:: with SMTP id j8mr43613062ejz.167.1560759720305;
        Mon, 17 Jun 2019 01:22:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560759720; cv=none;
        d=google.com; s=arc-20160816;
        b=Kwb9ANBcvlo5i78QjrzCiFdOp93Rgb26otwiBDXrPf10b1H2XUmE6sIBjDdhZCUoNT
         Csn4Pu4OOhaTLe1F29EcMuYkYr/gZtust/UEScl3Dt6XNhnXyU4AP+TUDS4kaLWExBWD
         xfphPx+6FTXyKQoGndlDgeMUL57gF29mrjtmpihvwKinWDH7uJrncN40kaEbe6SSpdT4
         qg+QwNzBzdBOnoHRmGg6AnspWnhD3BQowt9AMFFPMQCOrP6Xt3zsQZxsPOTLjafsCbag
         j1BMVAXmq/FrP563T2YQWW3Ztnht+xJrQxu/3GDhRpginm4inpU+6wB3YT3iQlsPRzXE
         H/ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7ymvn5JUry7KtFqwp5cxRbfksIusBDKC6pSOP5eNR8Y=;
        b=SWz3v31KjXXN+p7oAMfWzjq3CUPsyetEt7SPHpkagc17TzeMxk7qfyHeYA+DhVhUJC
         YwSIlkAmF1T0DC4xpTFgTu6MHHcImvHXBaOJTA+5uAXV7KOw80fJZYAbdyH6WB0hJ8vO
         uFxUNyZj7D7VNKAsn+nX5zNrb1/1uV0dUMpKw9TQNgn1fe4VsrnV5kVQDGVYqbkWB1Hw
         ng/OXTGqi3Pd3VKgai7WERoXPPYJaVO/41g4C106Yi8HynYZO1pSam/qveVTXapsmvvb
         yHCDZY5r6Qxsk2y0eh/8UDLPRkIcZhOYQXm+7tCMNtFQTQ5A1Yhk7PbvuzZolNMyY9Xz
         /buw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d16si443017ejj.185.2019.06.17.01.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 01:22:00 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 642EFAF4C;
	Mon, 17 Jun 2019 08:21:59 +0000 (UTC)
Date: Mon, 17 Jun 2019 10:21:56 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@d-silva.org>
Cc: 'Alastair D'Silva' <alastair@au1.ibm.com>,
	'Arun KS' <arunks@codeaurora.org>,
	'Mukesh Ojha' <mojha@codeaurora.org>,
	'Logan Gunthorpe' <logang@deltatee.com>,
	'Wei Yang' <richard.weiyang@gmail.com>,
	'Peter Zijlstra' <peterz@infradead.org>,
	'Ingo Molnar' <mingo@kernel.org>, linux-mm@kvack.org,
	'Qian Cai' <cai@lca.pw>, 'Thomas Gleixner' <tglx@linutronix.de>,
	'Andrew Morton' <akpm@linux-foundation.org>,
	'Mike Rapoport' <rppt@linux.vnet.ibm.com>,
	'Baoquan He' <bhe@redhat.com>,
	'David Hildenbrand' <david@redhat.com>,
	'Josh Poimboeuf' <jpoimboe@redhat.com>,
	'Pavel Tatashin' <pasha.tatashin@soleen.com>,
	'Juergen Gross' <jgross@suse.com>,
	'Oscar Salvador' <osalvador@suse.com>,
	'Jiri Kosina' <jkosina@suse.cz>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 4/5] mm/hotplug: Avoid RCU stalls when removing large
 amounts of memory
Message-ID: <20190617082156.GA1492@dhcp22.suse.cz>
References: <20190617043635.13201-1-alastair@au1.ibm.com>
 <20190617043635.13201-5-alastair@au1.ibm.com>
 <20190617074715.GE30420@dhcp22.suse.cz>
 <068b01d524e2$4a5f5c30$df1e1490$@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <068b01d524e2$4a5f5c30$df1e1490$@d-silva.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 17-06-19 17:57:16, Alastair D'Silva wrote:
> > -----Original Message-----
> > From: Michal Hocko <mhocko@kernel.org>
> > Sent: Monday, 17 June 2019 5:47 PM
> > To: Alastair D'Silva <alastair@au1.ibm.com>
> > Cc: alastair@d-silva.org; Arun KS <arunks@codeaurora.org>; Mukesh Ojha
> > <mojha@codeaurora.org>; Logan Gunthorpe <logang@deltatee.com>; Wei
> > Yang <richard.weiyang@gmail.com>; Peter Zijlstra <peterz@infradead.org>;
> > Ingo Molnar <mingo@kernel.org>; linux-mm@kvack.org; Qian Cai
> > <cai@lca.pw>; Thomas Gleixner <tglx@linutronix.de>; Andrew Morton
> > <akpm@linux-foundation.org>; Mike Rapoport <rppt@linux.vnet.ibm.com>;
> > Baoquan He <bhe@redhat.com>; David Hildenbrand <david@redhat.com>;
> > Josh Poimboeuf <jpoimboe@redhat.com>; Pavel Tatashin
> > <pasha.tatashin@soleen.com>; Juergen Gross <jgross@suse.com>; Oscar
> > Salvador <osalvador@suse.com>; Jiri Kosina <jkosina@suse.cz>; linux-
> > kernel@vger.kernel.org
> > Subject: Re: [PATCH 4/5] mm/hotplug: Avoid RCU stalls when removing large
> > amounts of memory
> > 
> > On Mon 17-06-19 14:36:30,  Alastair D'Silva  wrote:
> > > From: Alastair D'Silva <alastair@d-silva.org>
> > >
> > > When removing sufficiently large amounts of memory, we trigger RCU
> > > stall detection. By periodically calling cond_resched(), we avoid
> > > bogus stall warnings.
> > >
> > > Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
> > > ---
> > >  mm/memory_hotplug.c | 3 +++
> > >  1 file changed, 3 insertions(+)
> > >
> > > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c index
> > > e096c987d261..382b3a0c9333 100644
> > > --- a/mm/memory_hotplug.c
> > > +++ b/mm/memory_hotplug.c
> > > @@ -578,6 +578,9 @@ void __remove_pages(struct zone *zone, unsigned
> > long phys_start_pfn,
> > >  		__remove_section(zone, __pfn_to_section(pfn),
> > map_offset,
> > >  				 altmap);
> > >  		map_offset = 0;
> > > +
> > > +		if (!(i & 0x0FFF))
> > > +			cond_resched();
> > 
> > We already do have cond_resched before __remove_section. Why is an
> > additional needed?
> 
> I was getting stalls when removing ~1TB of memory.

Have debugged what is the source of the stall? We do cond_resched once a
memory section which should be a constant unit of work regardless of the
total amount of memory to be removed.
-- 
Michal Hocko
SUSE Labs

