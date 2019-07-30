Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88521C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 08:14:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 463402087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 08:14:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 463402087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C16E98E0005; Tue, 30 Jul 2019 04:14:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC5EE8E0001; Tue, 30 Jul 2019 04:14:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB5878E0005; Tue, 30 Jul 2019 04:14:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 621FA8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 04:14:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l14so39869668edw.20
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:14:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=b97PnS2zcat3tcxSxcZWjM6MUVW6bv9b2SSOH1KUqNQ=;
        b=r1Gg8zsSjXCmqAnmq38l8GY6+RtjMJ72LZTGr58ZgJahb8mumMbpC4ya7PMX3D4sWS
         Won71eWGI4oEl69C1P2Tce+8QnoJ1rNhVB2XqCZROjWmhB5d3e+5DzpK+euFLamIPmy4
         VKaFZFUdG2vdhm9LFggzPT0BFYAq2YhXlL0jQa3K6qqsTn17/3AiS2nsdlcsTx4UQFwX
         PG1taD+8RHmFIO6zpsyquk3geFQIU7u/gCaUyqZKJRCI4SmhbZiWv1Mlv0K5Zk/sXxd+
         P4tTB5PQtUxOxioAEXBQe/nBTWy2l7Djer8RWLoZ6d5fcMhSDpiEMOJv5EJyeIbbRwSe
         12FA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXYLt92oZIY1yJwtC93uovSfP0k9ZCWsfyvMVPGNZsc9CVkSAqt
	jHWtchpGMX/NGSPKp1mvmfqnCiSTI/8U3MGjNiLDeyVuvvrDmpnYN7Bx/GoYfDU3WZB6iKtSGQp
	nr3zKL7b7fJulYL/DWoTpsLJbBbSje7LSepTfJk0pnRgKtcSoUrai13ArD7lurMk=
X-Received: by 2002:a17:906:d78d:: with SMTP id pj13mr87226067ejb.301.1564474459968;
        Tue, 30 Jul 2019 01:14:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxevgbqDX4emuZC+71405Gej20oKIrwPgZMe5ytniSGpQHVxfplBqtvl4ioOwWuj08ot+R
X-Received: by 2002:a17:906:d78d:: with SMTP id pj13mr87226020ejb.301.1564474459232;
        Tue, 30 Jul 2019 01:14:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564474459; cv=none;
        d=google.com; s=arc-20160816;
        b=uY63/JWr0G/WnZ+i91QMpKsG7R/Pb8cbGX00sJaKHA2nsRdz7P/0xYBRPZV1nOv0ZS
         K9PaJWVNutmuOXOR3EOl6B+JUOM1xBzjNCS55fjPD7OBjvGdqXqJBiJeRAw6SmebBXs+
         PYA+mRcDZNz7wbAd0rO563G8KScY7rbeVa6104/4LD/31ZbUAvEFydJkIYUpeeJoC3Ko
         hyF1lucjdAK6LquLgeTowQ5ZFjdBm8QYPTaGb/rASGxsU5bYpVs/hzZjP9vn7BGrqqEn
         yoHa1Fv1q5UFnxealaO9zAKztsb8DwHSla5ta5lCrkoO9g6DIcJuU/AeSdmftDbUgj0a
         nQVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=b97PnS2zcat3tcxSxcZWjM6MUVW6bv9b2SSOH1KUqNQ=;
        b=zNrfxIzzyu1+NM3H/Q3ArysEI/GvkaRN7JabTchqH7kzX9qPFFTvAboYWhVu4QMY34
         P/IPwW0PcT7KGI3QoAt32k4PxOS92MiPcbXk3OgTex0+Gl6LpOabsKspcBIt9KLIiJy+
         vumDl/ip3Nn1FI3vRjA9vUl2n5JTIxqh51aVqzB1a05vemoylENtZnZt3GCUkIuQM4sL
         w4+HH62V/Xuxh+8QQQD5gsJmTB/1T9Z9sGTpR7h8HBCNBrhHCTyfvnVMBn8iQ9bQUFeO
         nvWL4l1CFpRIm4b5kAdtTCUFGvTHtEL/UcuUdXb+w2DETOXZSfJ9sBlpgsw43dvDzJ/g
         odcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y24si18186370edm.354.2019.07.30.01.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 01:14:19 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 59F32ABE9;
	Tue, 30 Jul 2019 08:14:18 +0000 (UTC)
Date: Tue, 30 Jul 2019 10:14:15 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Hoan Tran OS <hoan@os.amperecomputing.com>
Cc: Will Deacon <will@kernel.org>,
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
	"David S . Miller" <davem@davemloft.net>,
	"willy@infradead.org" <willy@infradead.org>
Subject: Re: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
Message-ID: <20190730081415.GN9330@dhcp22.suse.cz>
References: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
 <20190712070247.GM29483@dhcp22.suse.cz>
 <586ae736-a429-cf94-1520-1a94ffadad88@os.amperecomputing.com>
 <20190712121223.GR29483@dhcp22.suse.cz>
 <20190712143730.au3662g4ua2tjudu@willie-the-truck>
 <20190712150007.GU29483@dhcp22.suse.cz>
 <730368c5-1711-89ae-e3ef-65418b17ddc9@os.amperecomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <730368c5-1711-89ae-e3ef-65418b17ddc9@os.amperecomputing.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Sorry for a late reply]

On Mon 15-07-19 17:55:07, Hoan Tran OS wrote:
> Hi,
> 
> On 7/12/19 10:00 PM, Michal Hocko wrote:
[...]
> > Hmm, I thought this was selectable. But I am obviously wrong here.
> > Looking more closely, it seems that this is indeed only about
> > __early_pfn_to_nid and as such not something that should add a config
> > symbol. This should have been called out in the changelog though.
> 
> Yes, do you have any other comments about my patch?

Not really. Just make sure to explicitly state that
CONFIG_NODES_SPAN_OTHER_NODES is only about __early_pfn_to_nid and that
doesn't really deserve it's own config and can be pulled under NUMA.

> > Also while at it, does HAVE_MEMBLOCK_NODE_MAP fall into a similar
> > bucket? Do we have any NUMA architecture that doesn't enable it?
> > 
> 
> As I checked with arch Kconfig files, there are 2 architectures, riscv 
> and microblaze, do not support NUMA but enable this config.
> 
> And 1 architecture, alpha, supports NUMA but does not enable this config.

Care to have a look and clean this up please?

-- 
Michal Hocko
SUSE Labs

