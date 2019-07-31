Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A83CC32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:00:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AB18208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:00:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AB18208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94EE08E0007; Wed, 31 Jul 2019 09:00:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FED48E0001; Wed, 31 Jul 2019 09:00:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C84B8E0007; Wed, 31 Jul 2019 09:00:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9448E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:00:44 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y3so42327766edm.21
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:00:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ktVlBFRzuWA2kTN1SRaV7tHOro8iAWlOmU1Ue1MXsZg=;
        b=qMuMsM5GDlTz3H3yWILop85nelxw+XbZIBfD4UrfSgq0bLwx6k0e/WSTHPnskD0n7n
         mKVbJKzgB2Q0QUf+Yg+z2Bp2TQ5ilxmJGMYkAX01aJGyV09nSNFU542/2o6I6BPII3MU
         0101YWTXW+TENUYh9wo6+boxWGcxOM6dUttBL8i5obiryqKf2zgoUDLv0BjE87A7RcNF
         151tvGlUBW5EEnRQWKiKbm671takxGhJy/DU6K6VlweEduVPl4RHMBFXyf6bNf9pYBl2
         trFItg9REryyH3OGciVEtUvtwE72Jsh6DYUzJnMfl0FVndaXzBjbP4GPzcGmf1A2GL2Y
         aEzQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXwAmBsinpMa1AC2QTTQSfHPrs61DYLCNhJV/5mqskuma2pK1Vs
	hbmG9zZd8W95YYgClJfIzajN0CraVaWPs9Agv6EeWxfT2+mx4EnWRwohHOR8j0hVMTmDFjm1+h7
	JyuoBQ7Qo3pWMPPQU3yjPCRI1wotD39Z8KixhxBFW3bGLe+Yi549UUImzMcD6qOg=
X-Received: by 2002:a17:906:1496:: with SMTP id x22mr95379203ejc.191.1564578043741;
        Wed, 31 Jul 2019 06:00:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJ0pz+TSKB0WrlmSsKatH7QkS8WxMHSCk4amtmEtmC5dJOf6pnuenhMzK7st9btkCdEW0r
X-Received: by 2002:a17:906:1496:: with SMTP id x22mr95379052ejc.191.1564578042139;
        Wed, 31 Jul 2019 06:00:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564578042; cv=none;
        d=google.com; s=arc-20160816;
        b=CEkitOwMGVxikIdkO8c5h6p3bHpYYRUZp1lYTrKN5cloRen9SSrIiBomJUn46T0QN5
         YGKIdSLAKMZjlr4cvB3TOmIgCHdkFUgQ/KqLNFmDXwRxkBKvvdSDgH+8lAB+yYAPMTWj
         QqwEqgaSl43OtEB8llWI5HNoJeh6phjmkF4UCO9wGSF2OKUI9Cyl20xmRM8SHTtTHs+i
         vStW6Yq+c12DlwM2ksBU1HCFXU5p7SpFYPGk9r4wz0cWCaaahpZ+cGRB/VUy+CbzOmbn
         L6mx6HBk7Q9q+ktvzgg0ckNpb6esDcs7KWOYsBOBft02Jd9cf4MhXT5wCFTGq9nBE19u
         UObg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ktVlBFRzuWA2kTN1SRaV7tHOro8iAWlOmU1Ue1MXsZg=;
        b=MXCXjCOggg+C6jTu+8qis3aFgUWfD+X2M+zIKdvY61XA9ARvAOadfo8Gx7sQCiEiiw
         S4y7tbOr7r8RU1uFq7pxBgSbWZLal1tqcWQVjNjLPolGllbmV84gIdAHqxw++khYj+bd
         +gFj1BgmYzPjzP4OQOhzhEnWf9LN/HD5+hFXbxSoByklVoFQxqTvbtQ3xrKB2WV8DB0y
         zKd7zyjk2lKWBKnsGErl38EYQadpRiKOnv+v/wPeK9tbAmrzolqfEw6tJ26bRwQy8Qrf
         ASDxjoRLtg6Y3qB8Z4NO6/zV0FE7s6pWf2MZP1rIVlADaVTKOlsTocS3ZGY3tsSGK5Cp
         qEHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f15si18399128ejr.71.2019.07.31.06.00.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 06:00:42 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CB714AEF3;
	Wed, 31 Jul 2019 13:00:40 +0000 (UTC)
Date: Wed, 31 Jul 2019 15:00:37 +0200
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
Subject: microblaze HAVE_MEMBLOCK_NODE_MAP dependency (was Re: [PATCH v2 0/5]
 mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by default for NUMA)
Message-ID: <20190731130037.GN9330@dhcp22.suse.cz>
References: <20190712121223.GR29483@dhcp22.suse.cz>
 <20190712143730.au3662g4ua2tjudu@willie-the-truck>
 <20190712150007.GU29483@dhcp22.suse.cz>
 <730368c5-1711-89ae-e3ef-65418b17ddc9@os.amperecomputing.com>
 <20190730081415.GN9330@dhcp22.suse.cz>
 <20190731062420.GC21422@rapoport-lnx>
 <20190731080309.GZ9330@dhcp22.suse.cz>
 <20190731111422.GA14538@rapoport-lnx>
 <20190731114016.GI9330@dhcp22.suse.cz>
 <20190731122631.GB14538@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731122631.GB14538@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 15:26:32, Mike Rapoport wrote:
> On Wed, Jul 31, 2019 at 01:40:16PM +0200, Michal Hocko wrote:
> > On Wed 31-07-19 14:14:22, Mike Rapoport wrote:
> > > On Wed, Jul 31, 2019 at 10:03:09AM +0200, Michal Hocko wrote:
> > > > On Wed 31-07-19 09:24:21, Mike Rapoport wrote:
> > > > > [ sorry for a late reply too, somehow I missed this thread before ]
> > > > > 
> > > > > On Tue, Jul 30, 2019 at 10:14:15AM +0200, Michal Hocko wrote:
> > > > > > [Sorry for a late reply]
> > > > > > 
> > > > > > On Mon 15-07-19 17:55:07, Hoan Tran OS wrote:
> > > > > > > Hi,
> > > > > > > 
> > > > > > > On 7/12/19 10:00 PM, Michal Hocko wrote:
> > > > > > [...]
> > > > > > > > Hmm, I thought this was selectable. But I am obviously wrong here.
> > > > > > > > Looking more closely, it seems that this is indeed only about
> > > > > > > > __early_pfn_to_nid and as such not something that should add a config
> > > > > > > > symbol. This should have been called out in the changelog though.
> > > > > > > 
> > > > > > > Yes, do you have any other comments about my patch?
> > > > > > 
> > > > > > Not really. Just make sure to explicitly state that
> > > > > > CONFIG_NODES_SPAN_OTHER_NODES is only about __early_pfn_to_nid and that
> > > > > > doesn't really deserve it's own config and can be pulled under NUMA.
> > > > > > 
> > > > > > > > Also while at it, does HAVE_MEMBLOCK_NODE_MAP fall into a similar
> > > > > > > > bucket? Do we have any NUMA architecture that doesn't enable it?
> > > > > > > > 
> > > > > 
> > > > > HAVE_MEMBLOCK_NODE_MAP makes huge difference in node/zone initialization
> > > > > sequence so it's not only about a singe function.
> > > > 
> > > > The question is whether we want to have this a config option or enable
> > > > it unconditionally for each NUMA system.
> > > 
> > > We can make it 'default NUMA', but we can't drop it completely because
> > > microblaze uses sparse_memory_present_with_active_regions() which is
> > > unavailable when HAVE_MEMBLOCK_NODE_MAP=n.
> > 
> > I suppose you mean that microblaze is using
> > sparse_memory_present_with_active_regions even without CONFIG_NUMA,
> > right?
> 
> Yes.
> 
> > I have to confess I do not understand that code. What is the deal
> > with setting node id there?
> 
> The sparse_memory_present_with_active_regions() iterates over
> memblock.memory regions and uses the node id of each region as the
> parameter to memory_present(). The assumption here is that sometime before
> each region was assigned a proper non-negative node id. 
> 
> microblaze uses device tree for memory enumeration and the current FDT code
> does memblock_add() that implicitly sets nid in memblock.memory regions to -1.
> 
> So in order to have proper node id passed to memory_present() microblaze
> has to call memblock_set_node() before it can use
> sparse_memory_present_with_active_regions().

I am sorry, but I still do not follow. Who is consuming that node id
information when NUMA=n. In other words why cannot we simply do

diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index a015a951c8b7..3a47e8db8d1c 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -175,14 +175,9 @@ void __init setup_memory(void)
 
 		start_pfn = memblock_region_memory_base_pfn(reg);
 		end_pfn = memblock_region_memory_end_pfn(reg);
-		memblock_set_node(start_pfn << PAGE_SHIFT,
-				  (end_pfn - start_pfn) << PAGE_SHIFT,
-				  &memblock.memory, 0);
+		memory_present(0, start_pfn << PAGE_SHIFT, end_pfn << PAGE_SHIFT);
 	}
 
-	/* XXX need to clip this if using highmem? */
-	sparse_memory_present_with_active_regions(0);
-
 	paging_init();
 }
 
-- 
Michal Hocko
SUSE Labs

