Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC14FC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 11:40:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98611208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 11:40:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98611208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 289108E0005; Wed, 31 Jul 2019 07:40:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 238DC8E0001; Wed, 31 Jul 2019 07:40:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 128258E0005; Wed, 31 Jul 2019 07:40:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B749B8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:40:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z20so42245309edr.15
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:40:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ol3TW3C6rUEIVuU3GBhsd69ots2FTd5Yn+hWzZ/clnU=;
        b=iZfbsobCir/p+G0QzZTxGY77Xc2ObbywLODvZszfEP9XzHy/u4kqVrsH4eEjY4TKba
         OM9Qjiu3X4riH9aF7IpMrOGFDeEdtZb/7Ft86O5f9upSGwzaOsBkqprI/apD2nssaE2v
         3i4LdHBRAfHwnrFTpRZwkx4OPGYSKpOUc8oA3Kh24rPFeo7bkynZkOlvn4k+zphzqjjs
         fcapF2fz6ukV16cwRmzbyDR49ZbpBaabq9jWVeYCdpfz1CTe9kp+YXcYQgTYbdGySB4F
         j/ZWkutFHKOi02+jd24PCgMatCcfPO+L6Hu8tFzSwRIXfwYOGng/PKd+1anm78h+js8t
         8oiA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVPdWq5lI6yN56DArJLzjXAwOB84jKlmtv2QHMZ5X8Uyg6f0JzX
	6Q4hN4L104vIP0nqGjGTcZbEQwB3LDeFh0gzFzq+Ts4LD4awUcQNoncF56eLfAvweK380OwHDyF
	/4Nv5QHfc/LQP22Pjq9PkxLStV3EDd5n98/9fOq/SfVbyQ/EdRqWk3R8GZTzOVbY=
X-Received: by 2002:a50:d0d6:: with SMTP id g22mr107682828edf.250.1564573219317;
        Wed, 31 Jul 2019 04:40:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+VTYQSjtEVFFQpER9hFJL5EueukNPrJwF24zWkszXLC1JPBlASN63pmSmvmD9LqQQ37nI
X-Received: by 2002:a50:d0d6:: with SMTP id g22mr107682770edf.250.1564573218564;
        Wed, 31 Jul 2019 04:40:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564573218; cv=none;
        d=google.com; s=arc-20160816;
        b=DEikgJJsyzOviRhOFz7MyLaRjK9VBMtgBhXtEHXnRwuDmAc6tZCiZlexKsoAejvWiB
         2atx/02XAXtAHbsGbLAvOJp2f7MQJTsVd56MdlnqLVAu3437/xqquMf77/zcb7se3+ur
         pH4DdMqFN5wxy73hy+nqjEzVP8emJJjc+kiVkpkUWqDX6j6H9chCCiRNbh1k6b1aeeuy
         2j6rmvFhDx9RUDPKwM9tDRp+OzyiF1I0u9XkxyewLlgfZOsLu19ogmw/+Hs2rFuvABpB
         2RGXo3RBuFgEYRdxmgx8MrSwZhiuMmpYhym1FyFIoAONS6yw2IG338mezBB2H+FnKOpT
         dyqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ol3TW3C6rUEIVuU3GBhsd69ots2FTd5Yn+hWzZ/clnU=;
        b=EeXnlcmHBg1FEQ70quCgg+U1qBJz9JSvLmlS9DhKORvTIR2poDxztysknDbODh+DKO
         mSZi4Xte9SAwVKlea3r3xO5FdoG6zB5yjUOuwoW1u+0bK91qX0ftzUBVCS1qWjjeiDwM
         7LuDIGczTKG8qEA5r+J5hey3eszPRj14x4d1pMHX6bwbo8J1wYjufZ6200kKuEqIPAva
         +gGeV3VsLSS9DBNXe5r3U6Ycn8Piy4dKjQRdkB5YI9cal7EzvBZcCl4TIIjyoySrCQnI
         20fpGVV7r0v4mjUoiQnT/6o4YZ2inUOCksP6NDCPLOFdaM9c/UOxG6hkuIyX+G5gpTvS
         Camg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t5si20379303edd.61.2019.07.31.04.40.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 04:40:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4AF45AF04;
	Wed, 31 Jul 2019 11:40:17 +0000 (UTC)
Date: Wed, 31 Jul 2019 13:40:16 +0200
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
Subject: Re: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
Message-ID: <20190731114016.GI9330@dhcp22.suse.cz>
References: <20190712070247.GM29483@dhcp22.suse.cz>
 <586ae736-a429-cf94-1520-1a94ffadad88@os.amperecomputing.com>
 <20190712121223.GR29483@dhcp22.suse.cz>
 <20190712143730.au3662g4ua2tjudu@willie-the-truck>
 <20190712150007.GU29483@dhcp22.suse.cz>
 <730368c5-1711-89ae-e3ef-65418b17ddc9@os.amperecomputing.com>
 <20190730081415.GN9330@dhcp22.suse.cz>
 <20190731062420.GC21422@rapoport-lnx>
 <20190731080309.GZ9330@dhcp22.suse.cz>
 <20190731111422.GA14538@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731111422.GA14538@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 14:14:22, Mike Rapoport wrote:
> On Wed, Jul 31, 2019 at 10:03:09AM +0200, Michal Hocko wrote:
> > On Wed 31-07-19 09:24:21, Mike Rapoport wrote:
> > > [ sorry for a late reply too, somehow I missed this thread before ]
> > > 
> > > On Tue, Jul 30, 2019 at 10:14:15AM +0200, Michal Hocko wrote:
> > > > [Sorry for a late reply]
> > > > 
> > > > On Mon 15-07-19 17:55:07, Hoan Tran OS wrote:
> > > > > Hi,
> > > > > 
> > > > > On 7/12/19 10:00 PM, Michal Hocko wrote:
> > > > [...]
> > > > > > Hmm, I thought this was selectable. But I am obviously wrong here.
> > > > > > Looking more closely, it seems that this is indeed only about
> > > > > > __early_pfn_to_nid and as such not something that should add a config
> > > > > > symbol. This should have been called out in the changelog though.
> > > > > 
> > > > > Yes, do you have any other comments about my patch?
> > > > 
> > > > Not really. Just make sure to explicitly state that
> > > > CONFIG_NODES_SPAN_OTHER_NODES is only about __early_pfn_to_nid and that
> > > > doesn't really deserve it's own config and can be pulled under NUMA.
> > > > 
> > > > > > Also while at it, does HAVE_MEMBLOCK_NODE_MAP fall into a similar
> > > > > > bucket? Do we have any NUMA architecture that doesn't enable it?
> > > > > > 
> > > 
> > > HAVE_MEMBLOCK_NODE_MAP makes huge difference in node/zone initialization
> > > sequence so it's not only about a singe function.
> > 
> > The question is whether we want to have this a config option or enable
> > it unconditionally for each NUMA system.
> 
> We can make it 'default NUMA', but we can't drop it completely because
> microblaze uses sparse_memory_present_with_active_regions() which is
> unavailable when HAVE_MEMBLOCK_NODE_MAP=n.

I suppose you mean that microblaze is using
sparse_memory_present_with_active_regions even without CONFIG_NUMA,
right? I have to confess I do not understand that code. What is the deal
with setting node id there?
-- 
Michal Hocko
SUSE Labs

