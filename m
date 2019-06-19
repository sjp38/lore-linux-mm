Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09A47C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 08:14:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2E81206E0
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 08:14:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VTq/5def"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2E81206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 415126B0006; Wed, 19 Jun 2019 04:14:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C52C8E0002; Wed, 19 Jun 2019 04:14:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B4108E0001; Wed, 19 Jun 2019 04:14:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E737A6B0006
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 04:14:22 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w31so11763797pgk.23
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:14:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0ZL0Rt+On3+fcA7ZOTp27GEbaFXAtfEHfk/A4omOFs8=;
        b=L5K4FTzvcvAm1h2S7Gg3b32CxNHc1i3/lGcfijP0S7ng477ufM5u/rWnEeKync8Icz
         OV8zx62Qz4c0hdR6HOLZabMd8dgzAvdP8c9ElGCcCqDmNK3pYqnS7+qtaM9Yc+M+wigp
         Ll6ZDRr2rCjEvJJvPyAMtt5/aRIH/slTWUGbOHXOjcyYJ2a2nj+KsDkcmZ5p2TBqeRIk
         IplDI6aDwbsYg1RgY0BHzdyWuEM8X/EkDgwHKeD261IReeFbU0ObyIBZrOnZXeT/zzCG
         e44nrTTk75V8kr0xsB0uDjVOfIVxJW2sSvkP2230ilhxnPcdA+Q+S03TFiGic8iCAK48
         NAJA==
X-Gm-Message-State: APjAAAWeGnZzbGox4Ww2f1kXmujfCu1nZs1CcNa5CPat7Jym92uyx21H
	trmdxIvQ8tWJa5oVr/jSI/soE34uCj7KaUIgEp74EZ1QOHayI0vr0myWGdMJsiHVRTA7OSrDU0/
	KvJ4MYNOYld+kgOLdEk9TiChqmZkaFyhPF4l8RSKp/lMY3pEMTlLcMlg8zKRiCFJF9w==
X-Received: by 2002:a63:a46:: with SMTP id z6mr6634122pgk.76.1560932062553;
        Wed, 19 Jun 2019 01:14:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0zRhnu9fWaJipaW8r/MdPNtdVa/Om88z1x/MonXvTFah5u2CcMuYCFJNZBqQvwaEXdEmS
X-Received: by 2002:a63:a46:: with SMTP id z6mr6634085pgk.76.1560932061905;
        Wed, 19 Jun 2019 01:14:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560932061; cv=none;
        d=google.com; s=arc-20160816;
        b=l3mvTTI0yVsG9yIYh4HM/wlPp/2vgIWvnWkaWZAkxp6evpr+ewaEYTdugGEb7w/+zF
         R8YN/bzR2kooWiXe6k0sUwNeVr3cvLcI5z6QS+JjVYqbMsy65eHdvHHWKrqQ69PBl9zM
         2Qmew5ZHIHiSvWSgv2+IqgYYm+QlVja/eqTSgL/qsTj5wW6hleoOnVeTVp3u3SSppH0M
         x6XXrLmiE1Q6aMrv4tB51FLgF/IRsNlfmB+z/Ux2MJSmmFG7CDnzt69jMtb7EVb6wXGW
         UB3XGAkcrkhGPshKNKj5A6J9nSjneYIRbKXzEAkAweZ2M6SqIl/wwRoCUwpDg/HZb8ZY
         u4yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0ZL0Rt+On3+fcA7ZOTp27GEbaFXAtfEHfk/A4omOFs8=;
        b=bvO+/oWCJAaq2Rui4ng63elQQ9kGqfIjNi0u+ko1CWhgYspY4FkxR5ui+OXVaOSS5v
         ZVW0tHoxsmkyFKYsjbvyaycFHOLxYrGcS2QrBaMwY9Pq26t/lpBI9QtjvOtPHF6XEqGQ
         /SeaptGWpulu0rhJGbsMeOV2Gw5mcsft9irm6rw7dqr+wBqaGbegVBeYkdopcQN61LdG
         rIlk0TDvnfQurITvCkAkvVxNuugxIhYO4g5IkCvCZU1IfUJGthJZhhsH9gn47VxWgA/0
         oPZZJo8y5vw0lgT/H9JJAdOdM5WpgImr6J5fA0LHNI4aIKtzp5Gr8B4pSbqFKylwKjVi
         abgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="VTq/5def";
       spf=pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i14si2514973pgh.437.2019.06.19.01.14.21
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 01:14:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="VTq/5def";
       spf=pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=0ZL0Rt+On3+fcA7ZOTp27GEbaFXAtfEHfk/A4omOFs8=; b=VTq/5defW3rvl0qSVOJTGq4WO
	PXQkheSR6n7cepjJuJbIsuVqXJAeoO6w1Usz/0OOo4rXXtGYEvT83GQ+qAKZ8bmqtqvMjBo88SJmL
	IIWd00nGQ1ntnsuA6llhTgwbAcNH+LoQHYo8RR3DLgE3rFAmRgqjhTiFPPyQfPWNhfGwJr+UsyQJa
	gMhBPjfITvI13/SnXh1sjD0CDMc7PiYSMIBJUj4LSHubqiu5ZQC8eq0kA/vGy9kJi/xCtwqSUmiY3
	BM7plvYLHHJiXz7AgxGshkFNjukTfR/NZqKEqUb7nNjEyBrB+qHiXhOT0y+6rLL8sO6KZljTddayk
	Pd1lyxT4g==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hdVjU-0006aZ-Cc; Wed, 19 Jun 2019 08:14:16 +0000
Date: Wed, 19 Jun 2019 01:14:16 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@infradead.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 02/12] mm/hmm: Use hmm_mirror not mm as an
 argument for hmm_range_register
Message-ID: <20190619081416.GA24900@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-3-jgg@ziepe.ca>
 <20190615135906.GB17724@infradead.org>
 <20190618130544.GC6961@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190618130544.GC6961@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 10:05:44AM -0300, Jason Gunthorpe wrote:
> I'm thinking to tackle that as part of the mmu notififer invlock
> idea.. Once the range looses the lock then we don't really need to
> register it at all.

Ok.

