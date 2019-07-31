Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57D99C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:41:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 177582089E
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:41:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 177582089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B27188E0006; Wed, 31 Jul 2019 10:41:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD7C68E0001; Wed, 31 Jul 2019 10:41:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99F8E8E0006; Wed, 31 Jul 2019 10:41:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4536D8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:41:20 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i9so42532373edr.13
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:41:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LK1BVrRQqISCQGamxhhg6KSVLI9B4UulWVhgTFJZxBk=;
        b=Rvn+rQFHfWyzJ7Om6EO9Fa4Sk4zFdY+gF40wKjc5l3AGSh0VMHOieSdivXg3FDP1g4
         5cN2jmi6nU+459geilm+AflUI+iWKlfSCW/zEz+BGhR/TFhMvFuLHRZ98qSyHk6mwsvD
         4utjgcieDxq2FDNjoUTmB5g8JYOkL/uGsIRJiPj+Jn7ZMsMkEAzKdxB+ur1rE8kSnpku
         58XOJl7vtoGehovGDDbHYXBPS7BTycW10htfAmNk6ThSIg3BSIOjt+PSp6WT0SJGGP1V
         D49Xl1k8C9LK+6sHyRgpvK0moPBkcpWIgBYylEba0EMCJFgft4zw7cZb4fkQrJFEt47F
         Xy+w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWdBnQmE8M0rkSjFVI1FJB7MNuHMnN3r3GVKl05r0ROUc4ScuGY
	4mcjT1o0+z5KM/TjQRytWGuhPyTeDLUkIsXCCtSOlgMKuMMXgP4xOBqYi8/JyfKgwasUBZLDuWy
	DWFzLktXYT5+1FnKoAGB0gRS7GQjJ1oJTPxfLGaAn3UCxdXZIvGqSbgUxdMWREe8=
X-Received: by 2002:a17:906:4882:: with SMTP id v2mr34194485ejq.100.1564584079819;
        Wed, 31 Jul 2019 07:41:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwM7nY9AvBmuWJSXeR9BwcIYvDsu1bT8O8NWdFZ9R1Wb3OE1iP8F9z5woS517ic/ZiGcoOd
X-Received: by 2002:a17:906:4882:: with SMTP id v2mr34194416ejq.100.1564584078963;
        Wed, 31 Jul 2019 07:41:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564584078; cv=none;
        d=google.com; s=arc-20160816;
        b=IpyzN5CVGbpIvNEhT1KcbhEONPw7+EZXY1eHb7VJYYHnZwfOn26uLMiu6dqy5Je46l
         dVeYa1YKfQMtFBuSDgiuk1QEDWFdAJ6TORSTdavJaIv7lJSM0Bqtbw03GFpN6Y7mfR8J
         jd1mQnb8Fr9vylt2bx5zSVzBZI2acIYi7rD7gIX0Xmqc1tnwthknFC5GE+uz9MxjVjp5
         O4RF7wJwCOZHuD5Q9ETo6/WWjrs2YOHyc6Ms8JQrXrcGw3vNEPYfpwvipdMIdUY5leyJ
         CI9ZGux+hUBiyyoy9nrycRtSuFiEF6R7g+7MqU1xAiNpCIDF1sulmsliMD6oq7W8v28Y
         kpdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LK1BVrRQqISCQGamxhhg6KSVLI9B4UulWVhgTFJZxBk=;
        b=BjJpebdGCAhzhdLHQmmeUdH0Uhg9f0lfDxej5F4WVJI7qZfqwzBc5o7S4eAMNmdGSW
         f63LmTURBsV4ruYxgPFC86O/QA5Qcqe5fZvSbTt2O13JPRYPzxxIfBoWPNhF/UWi0sti
         Ts9+m17eBrA92UIFaoNXGtpScP8Ket1RVEcGgBr0QLHNA/2iBOQKUkBeHt0RidKPJb6r
         iHrzw0O1TsiR7G9jC6nNEf4hOLr/2aJyNIsvnapbHkEfOmQ3+uzcn1XUQGQtDmRFZZ5o
         TwqoPyqlxdIV6pA2+B9e4wrSlC/oj6xu30qzTx14hWnXP1qBNjC2vcTSS/zent9d5XOk
         ZMJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jp14si19123849ejb.398.2019.07.31.07.41.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 07:41:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E6CFCB0C6;
	Wed, 31 Jul 2019 14:41:17 +0000 (UTC)
Date: Wed, 31 Jul 2019 16:41:14 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Hoan Tran OS <hoan@os.amperecomputing.com>,
	Will Deacon <will@kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	Paul Mackerras <paulus@samba.org>,
	"H . Peter Anvin" <hpa@zytor.com>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	"x86@kernel.org" <x86@kernel.org>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Ingo Molnar <mingo@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Open Source Submission <patches@amperecomputing.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Will Deacon <will.deacon@arm.com>, Borislav Petkov <bp@alien8.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	Oscar Salvador <osalvador@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"David S . Miller" <davem@davemloft.net>,
	"willy@infradead.org" <willy@infradead.org>
Subject: Re: microblaze HAVE_MEMBLOCK_NODE_MAP dependency (was Re: [PATCH v2
 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by default for NUMA)
Message-ID: <20190731144114.GY9330@dhcp22.suse.cz>
References: <20190712150007.GU29483@dhcp22.suse.cz>
 <730368c5-1711-89ae-e3ef-65418b17ddc9@os.amperecomputing.com>
 <20190730081415.GN9330@dhcp22.suse.cz>
 <20190731062420.GC21422@rapoport-lnx>
 <20190731080309.GZ9330@dhcp22.suse.cz>
 <20190731111422.GA14538@rapoport-lnx>
 <20190731114016.GI9330@dhcp22.suse.cz>
 <20190731122631.GB14538@rapoport-lnx>
 <20190731130037.GN9330@dhcp22.suse.cz>
 <20190731142129.GA24998@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731142129.GA24998@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 17:21:29, Mike Rapoport wrote:
> On Wed, Jul 31, 2019 at 03:00:37PM +0200, Michal Hocko wrote:
> > On Wed 31-07-19 15:26:32, Mike Rapoport wrote:
> > > On Wed, Jul 31, 2019 at 01:40:16PM +0200, Michal Hocko wrote:
> > > > On Wed 31-07-19 14:14:22, Mike Rapoport wrote:
> > > > > On Wed, Jul 31, 2019 at 10:03:09AM +0200, Michal Hocko wrote:
> > > > > > On Wed 31-07-19 09:24:21, Mike Rapoport wrote:
> > > > > > > [ sorry for a late reply too, somehow I missed this thread before ]
> > > > > > > 
> > > > > > > On Tue, Jul 30, 2019 at 10:14:15AM +0200, Michal Hocko wrote:
> > > > > > > > [Sorry for a late reply]
> > > > > > > > 
> > > > > > > > On Mon 15-07-19 17:55:07, Hoan Tran OS wrote:
> > > > > > > > > Hi,
> > > > > > > > > 
> > > > > > > > > On 7/12/19 10:00 PM, Michal Hocko wrote:
> > > > > > > > [...]
> > > > > > > > > > Hmm, I thought this was selectable. But I am obviously wrong here.
> > > > > > > > > > Looking more closely, it seems that this is indeed only about
> > > > > > > > > > __early_pfn_to_nid and as such not something that should add a config
> > > > > > > > > > symbol. This should have been called out in the changelog though.
> > > > > > > > > 
> > > > > > > > > Yes, do you have any other comments about my patch?
> > > > > > > > 
> > > > > > > > Not really. Just make sure to explicitly state that
> > > > > > > > CONFIG_NODES_SPAN_OTHER_NODES is only about __early_pfn_to_nid and that
> > > > > > > > doesn't really deserve it's own config and can be pulled under NUMA.
> > > > > > > > 
> > > > > > > > > > Also while at it, does HAVE_MEMBLOCK_NODE_MAP fall into a similar
> > > > > > > > > > bucket? Do we have any NUMA architecture that doesn't enable it?
> > > > > > > > > > 
> > > > > > > 
> > > > > > > HAVE_MEMBLOCK_NODE_MAP makes huge difference in node/zone initialization
> > > > > > > sequence so it's not only about a singe function.
> > > > > > 
> > > > > > The question is whether we want to have this a config option or enable
> > > > > > it unconditionally for each NUMA system.
> > > > > 
> > > > > We can make it 'default NUMA', but we can't drop it completely because
> > > > > microblaze uses sparse_memory_present_with_active_regions() which is
> > > > > unavailable when HAVE_MEMBLOCK_NODE_MAP=n.
> > > > 
> > > > I suppose you mean that microblaze is using
> > > > sparse_memory_present_with_active_regions even without CONFIG_NUMA,
> > > > right?
> > > 
> > > Yes.
> > > 
> > > > I have to confess I do not understand that code. What is the deal
> > > > with setting node id there?
> > > 
> > > The sparse_memory_present_with_active_regions() iterates over
> > > memblock.memory regions and uses the node id of each region as the
> > > parameter to memory_present(). The assumption here is that sometime before
> > > each region was assigned a proper non-negative node id. 
> > > 
> > > microblaze uses device tree for memory enumeration and the current FDT code
> > > does memblock_add() that implicitly sets nid in memblock.memory regions to -1.
> > > 
> > > So in order to have proper node id passed to memory_present() microblaze
> > > has to call memblock_set_node() before it can use
> > > sparse_memory_present_with_active_regions().
> > 
> > I am sorry, but I still do not follow. Who is consuming that node id
> > information when NUMA=n. In other words why cannot we simply do
>  
> We can, I think nobody cared to change it.

It would be great if somebody with the actual HW could try it out.
I can throw a patch but I do not even have a cross compiler in my
toolbox.

> 
> > diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
> > index a015a951c8b7..3a47e8db8d1c 100644
> > --- a/arch/microblaze/mm/init.c
> > +++ b/arch/microblaze/mm/init.c
> > @@ -175,14 +175,9 @@ void __init setup_memory(void)
> >  
> >  		start_pfn = memblock_region_memory_base_pfn(reg);
> >  		end_pfn = memblock_region_memory_end_pfn(reg);
> > -		memblock_set_node(start_pfn << PAGE_SHIFT,
> > -				  (end_pfn - start_pfn) << PAGE_SHIFT,
> > -				  &memblock.memory, 0);
> > +		memory_present(0, start_pfn << PAGE_SHIFT, end_pfn << PAGE_SHIFT);
> 
> memory_present() expects pfns, the shift is not needed.

Right.

-- 
Michal Hocko
SUSE Labs

