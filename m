Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50173C742BD
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 15:00:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DF6A2084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 15:00:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DF6A2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EB448E0156; Fri, 12 Jul 2019 11:00:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99D1B8E00DB; Fri, 12 Jul 2019 11:00:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88C558E0156; Fri, 12 Jul 2019 11:00:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF328E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 11:00:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z20so8069060edr.15
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:00:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Y4rdHT8ns+/qlQs4dDFRKnFzQql9GdNMRGofrwhGk5o=;
        b=SyC+4SLRGigkt5ynOrPpY7iZsnQ8GICHEmwYSuwG7Egm2Fgr8xagFXbAVaORC3ncoV
         q1m7oPBbIlC8aCSjxG/1IspaOVC7yPkxKr4rTTHdncqS4vDm1WXZdUqtqoYzS5cNxHgL
         577ZRkBK+mAvlPC2wj6hmqprw3ukZ5/dKYNww33wu+5Yajm3m2vDvG0fhDZXn53z7MV8
         AzsacdmVgWy3aC+YHBQkEWfS1C2Qd4dy/hktgsVJpwAvwbpS1fGBNhwA7Mbugc+gfFO0
         X3DMmEy5i6nz5iKsals/u7JlZZcNrIPjrBNeLy7kGvtK+I6rc3mxsJSNbwd5RdKiUtrV
         RCIw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUfWg3pwGcmmCgC619FZdc9/PNPR1exbMKcD9DjR8GidyrK2PJD
	b9TaQFgwUEJhUpU9UhYyEOYG3lJFi1w105onIykP/DMuBsUr0HoQz2j12oxzIcyOYeICx/+nUDc
	NZ8zBFyaSk+JwjjCNV+4YgS9E+01TKnNfL+nWEY1JJZwRvuIubwNIBgogIIU0hdE=
X-Received: by 2002:a17:906:b315:: with SMTP id n21mr8529348ejz.312.1562943611806;
        Fri, 12 Jul 2019 08:00:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWXj4jDWyIA6UqhAz7MP2pADrwkMQObyN4SyRVdi+3YewVWgUHLKrzJBcjR8ujHVukeqUr
X-Received: by 2002:a17:906:b315:: with SMTP id n21mr8529272ejz.312.1562943611047;
        Fri, 12 Jul 2019 08:00:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562943611; cv=none;
        d=google.com; s=arc-20160816;
        b=jK6eSCnKBoC04pezSTyfHBLfV9ZDqYaE9TgWklCv+YoyWKAbtPBJrezRpSpC/gukkL
         9j8iLPtpOxqhF1ul13iKve8Xe+DmslbfHi9EHRaBjMnRNPqnbBQ6N5ZX7MAsNV9s5RNS
         rxNOP4sAD6/d3aRdJU3P8poL/hMLoIizcuUWbqkpUEBpn2bt3hbVnayw2bbRXdrA2Gsu
         JVvfSxB1f0vrMv0MGYqoH50ARwaDTlP4a0P5B/JDVjyfsetTuL66WT29Xep4ttnroVaT
         CdVEVTnSPSugVPCmBu7kPodY1wHYrg3DTtvVBbe4YptbCxe7l80F2er4yj/QLOn5d8lA
         9rtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Y4rdHT8ns+/qlQs4dDFRKnFzQql9GdNMRGofrwhGk5o=;
        b=gjc9FWQYTNXQj2gTlKnSHmLkObuzUiF4wPohqlHhx9RSHdrKJbvr29cT++uvuTpvjk
         AEShElEWPhj7slGWrwT5o5O7XuM2bjhGf4+jf4gVsQqjLdSwe3F9zAx7JPtjG80NBsTG
         4th78caCrZAnNh+O/lavquLquElSJCTCMuDSWVrR+gn/2wpuY6Esf2tfi5GVHcEX8oJR
         +H/WBjNlo96hKY4mJi2bdhMw+0PJW1KSjjcoMZsePxcoiq//25z3XGiUDDi3NDOWrCde
         T/lrLH/gxJWC+4tTeh+hYy3C+Q9NqlhzKeNGscK5VFajq7TOqomVm9yYVE5Ie041jn8S
         fbHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rl7si5142541ejb.342.2019.07.12.08.00.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 08:00:11 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C4457ABE9;
	Fri, 12 Jul 2019 15:00:09 +0000 (UTC)
Date: Fri, 12 Jul 2019 17:00:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Will Deacon <will@kernel.org>
Cc: Hoan Tran OS <hoan@os.amperecomputing.com>,
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
	Mike Rapoport <rppt@linux.ibm.com>,
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
	"David S . Miller" <davem@davemloft.net>, willy@infradead.org
Subject: Re: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
Message-ID: <20190712150007.GU29483@dhcp22.suse.cz>
References: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
 <20190712070247.GM29483@dhcp22.suse.cz>
 <586ae736-a429-cf94-1520-1a94ffadad88@os.amperecomputing.com>
 <20190712121223.GR29483@dhcp22.suse.cz>
 <20190712143730.au3662g4ua2tjudu@willie-the-truck>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190712143730.au3662g4ua2tjudu@willie-the-truck>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 12-07-19 15:37:30, Will Deacon wrote:
> Hi all,
> 
> On Fri, Jul 12, 2019 at 02:12:23PM +0200, Michal Hocko wrote:
> > On Fri 12-07-19 10:56:47, Hoan Tran OS wrote:
> > [...]
> > > It would be good if we can enable it by-default. Otherwise, let arch 
> > > enables it by them-self. Do you have any suggestions?
> > 
> > I can hardly make any suggestions when it is not really clear _why_ you
> > want to remove this config option in the first place. Please explain
> > what motivated you to make this change.
> 
> Sorry, I think this confusion might actually be my fault and Hoan has just
> been implementing my vague suggestion here:
> 
> https://lore.kernel.org/linux-arm-kernel/20190625101245.s4vxfosoop52gl4e@willie-the-truck/
> 
> If the preference of the mm folks is to leave CONFIG_NODES_SPAN_OTHER_NODES
> as it is, then we can define it for arm64. I just find it a bit weird that
> the majority of NUMA-capable architectures have to add a symbol in the arch
> Kconfig file, for what appears to be a performance optimisation applicable
> only to ia64, mips and sh.
> 
> At the very least we could make the thing selectable.

Hmm, I thought this was selectable. But I am obviously wrong here.
Looking more closely, it seems that this is indeed only about
__early_pfn_to_nid and as such not something that should add a config
symbol. This should have been called out in the changelog though.

Also while at it, does HAVE_MEMBLOCK_NODE_MAP fall into a similar
bucket? Do we have any NUMA architecture that doesn't enable it?

Thanks!
-- 
Michal Hocko
SUSE Labs

