Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F553C4321B
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 08:14:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF93E2075D
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 08:14:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="eDzzAt6J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF93E2075D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BDDD6B0003; Sun, 28 Apr 2019 04:14:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56CBD6B0006; Sun, 28 Apr 2019 04:14:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45DED6B0007; Sun, 28 Apr 2019 04:14:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10F706B0003
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 04:14:02 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a8so5240804pgq.22
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 01:14:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=H7pSF8CSi3Mqest59wbgaWW0VcSYcjBW94HJQdX6LtQ=;
        b=T4iAs7s1dWiV3SlffNURPFTBgjzohZSVYA6nYUKaV2CB69fDxDGm258La/ltxM57Zd
         DbtBuJ+jS/x4Atdwvrc2/Dz3DMTkNlujOX6fK1QLXUJ6lnW1UaiBlTna+cFUwxc1+ZKE
         0Na1tMVoB7pFynFPAt59vj6evEBGwOZZV1e6+kuX8lxQWZNlWx7gKxuhykaCDVNpxIS6
         35qRBZXEbYIvmmejINHYQpj4+1pzI5rez638IsfUogmaR/8JAQNt5zmjMk1x5jsQtvx4
         4eE7JsXoelT17d4GrrSABMU7ZkJaDGRsNNUgRtFczi55uyuwhmqdZyE5yPZjw2fnd5eY
         ATIg==
X-Gm-Message-State: APjAAAVJT7vK0wGaWX2+vreLY6bow/lXYlmFgQP2dhENGyEM2DFIf1Rb
	mheAYCEelV/tgWwRZ074Vx3BIZzF5Rw/UP0mGqASHulhmKBWrXHC82/L/hNnzTwST9zloP2L7If
	MStVBAymaJ7cBB+c9fC5Pke/iKN9B6Mikc4UXGnauaQvKe7+NzMThfdDSXjQw0iR8mQ==
X-Received: by 2002:a17:902:b210:: with SMTP id t16mr55438070plr.84.1556439241643;
        Sun, 28 Apr 2019 01:14:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHrjRJCGpfHg/1Sr2zMyREKnhkHkX+R36jxzD+4dQIeZb3ceVXjOyha+qQ3CxofYnpOq97
X-Received: by 2002:a17:902:b210:: with SMTP id t16mr55438038plr.84.1556439241113;
        Sun, 28 Apr 2019 01:14:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556439241; cv=none;
        d=google.com; s=arc-20160816;
        b=M57Mo/PuEcInGndyOqP+tnosn7U/fdFBZJsGi/P8rG7fGJrnBSvmP790BCCqFVpqH4
         PKBqwmH0k9TreRMrXJZQ2VgE5FpsU9SPcw6TlA529Gor1OQn4/5oqE3k/cYyHtC8pakT
         RivVcbTYGtyagmBMpGMBpATJyGjSLMu/0sbj2CGTtEtB7yD3/Q6+kuTzIXT6bGpY3Ccz
         rpatHtl4ppCqLn9cPdH6aatYxk84bzAZtcEaiUDT/saOqtmVS8IYzFv0AqhtA8C8yRWz
         1cgMd6nScz8Ia04oivxIUgAQ/GbSk7T6gk79yFJNtSMxzNPpQEcRdFfn9iSd40gvoN1Q
         MWJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=H7pSF8CSi3Mqest59wbgaWW0VcSYcjBW94HJQdX6LtQ=;
        b=AAx8uCxaWbJH1FnVA8N3kktqndRvdQrXPOPbErxCXFDYMKRien/YAi8odFEUp+i5VU
         IndlL2jHvdYxu0LiziTpd1cy+8PmOAPY1jUYMcdccFmAzYBM3B1UdEH+Diyfw/iyroH5
         Y/OCAGv95CoRMFgDuNExdXAjr8e7DmX/ruGcHTnhPNFcZq0bq3BWmxn+YI0JKjA8Zt/5
         easihVYvnwQJLzB6B9T3J+/ld9GugxOROI7mtEYKrvNzMS5aIxkJAPeXWsksiTyeYRtq
         am+nMygOyxbDdyjGu+JxHlIRIqIqKraVYFzdhTPRVMSs1j/5I+FKOv6nyfTGdYYCCvt/
         Eljw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=eDzzAt6J;
       spf=pass (google.com: best guess record for domain of batv+6e876697d14fde6a77e3+5726+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+6e876697d14fde6a77e3+5726+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f62si29147800plb.339.2019.04.28.01.14.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 28 Apr 2019 01:14:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+6e876697d14fde6a77e3+5726+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=eDzzAt6J;
       spf=pass (google.com: best guess record for domain of batv+6e876697d14fde6a77e3+5726+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+6e876697d14fde6a77e3+5726+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=H7pSF8CSi3Mqest59wbgaWW0VcSYcjBW94HJQdX6LtQ=; b=eDzzAt6Jd4hljvq3l+ATNeBe+
	qpl0rfWEg5FVpeoaZDWvRC/hp+cIzXIHkW/+gK4+ZTECZUpwoOdHVdWoVy61+cZPde0uTLt5MD26Q
	4+WAFs1pMnH2K2L93uAhBHF2T3CTL8KPCewNrSaE+G7PhP8SGWuK9rD7thPYwFKZRECdivq1SLlb/
	9UCtNCQex5pXRPwOJZ5Me6Kksb1HFeZfMgirxHYgH/kJfiHy821EK+CeZq0NLkipSnCsLWfPZ91jx
	tVLB2jnoZHjXPknEjE0AMLDfomVTv/9r6DBGjOawGM1NpR2q7lQA2O1IAGaN6oQEoFRpZPLdIzPNe
	0dzcD+bsw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hKewb-00016d-NE; Sun, 28 Apr 2019 08:13:53 +0000
Date: Sun, 28 Apr 2019 01:13:53 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Meelis Roos <mroos@linux.ee>
Cc: Christopher Lameter <cl@linux.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mikulas Patocka <mpatocka@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-parisc@vger.kernel.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>,
	LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org,
	Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
	linux-ia64@vger.kernel.org
Subject: Re: DISCONTIGMEM is deprecated
Message-ID: <20190428081353.GB30901@infradead.org>
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@email.amazonses.com>
 <25cabb7c-9602-2e09-2fe0-cad3e54595fa@linux.ee>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <25cabb7c-9602-2e09-2fe0-cad3e54595fa@linux.ee>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 07:49:57PM +0300, Meelis Roos wrote:
> > > ia64 (looks complicated ...)
> > 
> > Well as far as I can tell it was not even used 12 or so years ago on
> > Itanium when I worked on that stuff.
> 
> My notes tell that on UP ia64 (RX2620), !NUMA was broken with both
> SPARSEMEM and DISCONTIGMEM. NUMA+SPARSEMEM or !NUMA worked. Even
> NUMA+DISCONTIGMEM worked, that was my config on 2-CPU RX2660.

ia64 has a such a huge number of memory model choices.  Maybe we
need to cut it down to a small set that actually work.

That includes fund bits like the 'VIRTUAL_MEM_MAP' option where the
comment claims:

# VIRTUAL_MEM_MAP and FLAT_NODE_MEM_MAP are functionally equivalent.
# VIRTUAL_MEM_MAP has been retained for historical reasons.

but it still is selected as the default if sparsemem is not enabled..

