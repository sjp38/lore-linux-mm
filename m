Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFAC3C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 11:50:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F38620700
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 11:50:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="g9uzCEdF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F38620700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=iki.fi
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC8836B0003; Thu, 28 Mar 2019 07:50:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C783A6B0006; Thu, 28 Mar 2019 07:50:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B403C6B0007; Thu, 28 Mar 2019 07:50:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9748E6B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 07:50:37 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c25so3833972qkl.6
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 04:50:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=CcTuxXyWOS0yjLFti3go8bFBxxJeXJfGM9tjdI39VeM=;
        b=jNSyZq46ye87Fx5wGu1VVbbqBX+qUc+pyt/Ubwsqk1ODVxArC2WmICFE4pDbmUcNtQ
         7rPV3XjFMnSq2V4mkFR5hOWT2oNgwthNF96zXz25nWIYjkl6m/O+goVBMu/5Y4hXE0eN
         DxUoIZuSoA9iDLLKbloF0jfmWzVRXC+fzW2Y9vbY1+mGR1E6hk+PbKOAJnoF32xdsZKa
         OpBUXRulx3haCN+XjJrppto/cUzvOBXiZrKjx3SLfm+uVyRZCtZwkRDEc1cIu0qnDfTe
         FUyfzcY/V42b5KycqHTpekOvCOzZHwwA9CRxdZVZeHFuJNonnp/Zem8L5e3CNjg394gP
         CUUQ==
X-Gm-Message-State: APjAAAXoYpH7qSNTRYwB01LgPcM0oF0XtqA2um6JuLrbBcKqMaOE2nPB
	UGrgXkadqnXkXuSmpXI1r8IQzX2dB6r4xsK3L9SEzwVe2HfZZHODCz1ICNdvY2vJU+64pQyiKxR
	+HzXOVr1nvOUmBpUMinTYXNkXlNhdIv595htaEu1S2BDnJ3w/7MFNSeyQI0ehRWs=
X-Received: by 2002:a37:9fc4:: with SMTP id i187mr33830559qke.141.1553773837261;
        Thu, 28 Mar 2019 04:50:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw884hfvawKkGmGI45xJXIumDG93kt5NWG/jz2Nu4rOkIm1r701qfjOp6Kujx52lWEL3J7M
X-Received: by 2002:a37:9fc4:: with SMTP id i187mr33830514qke.141.1553773836485;
        Thu, 28 Mar 2019 04:50:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553773836; cv=none;
        d=google.com; s=arc-20160816;
        b=fQOD5EPcZcAlwecqFuGe1qxVkttScYtlXYxGg00xHK3ia2yWGh9rKDTK9CQBD/dn2F
         ja37J/8ykssmXIGp0IWi3omGIlerg/vKla07/gpJ16UV3NdkMaEm9/FwgOikLAZbxScB
         UjPCHJH4JpoGcBW2W03kqMDgZ+bnGR2wG7rdHXQywkmOwy8GUt/CMjuOpfOxOW8K/0Wl
         ySvvba/kgTtozaWfnBFFoqNLuc9TTzAv3j2w2+zs0+ZoKPmjbP1qqc5YOLHv7YdysnLL
         mf9oPMdy6ABWZJ12ffMAzIjBGEQrJtuBvTvnHRRoiIaXkIRDTHNPR1WTZXIDxorYbUtI
         JPAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=CcTuxXyWOS0yjLFti3go8bFBxxJeXJfGM9tjdI39VeM=;
        b=ZThq1if6FURYsUaZ6n5nqfcu0Piilaq233Bbxd6wQUIrbOWUougBv48ZxNgut9x17p
         ES0i+edmeAMHLd4uip5rGuStw7hOI331qhRnxk2i96zKmm4G224/VX7Qeyoa8b0NWboC
         Tm+gLvpEa5pfSBwNJPWhU6iPcPrsXD/hDPlwGFJtqu3CmRBCwsDIYXTNMTu6wBIRNWys
         3BncIwZPzaUq2/jmD71zzH2miLC6dpwOiHFYZT8z7hBreBy0j0o+UJURW536IB0LrYMy
         ajs83hCHfI8dtR6P9MNywaSXIluYF3uFOa6Xbnzf/QsJAAyMtRboquvlhHLWQclKg/Aj
         cLFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=g9uzCEdF;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id o22si2484722qka.145.2019.03.28.04.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 04:50:36 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=g9uzCEdF;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 217BF21CE7;
	Thu, 28 Mar 2019 07:50:36 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute4.internal (MEProxy); Thu, 28 Mar 2019 07:50:36 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:date:from:in-reply-to:message-id:mime-version:references
	:subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
	:x-sasl-enc; s=fm2; bh=CcTuxXyWOS0yjLFti3go8bFBxxJeXJfGM9tjdI39V
	eM=; b=g9uzCEdF7W61j4UC8oGpsglnHI1//g6wM7CpHOGVrdAJPxQBLnpgEq7jz
	iGFEU/gKwoZASsmip9qqMqs5lvxETwaDxIVtLz0xmG+tZ1toEOpq3gUqJ2UoRQWu
	z1uCOsdFwSfe07ghiAzYFj89Hqa8Pi9Fn/sw7BpvNqKQdpvug1aU9mq2w/+jaz5n
	kZLvEAm2Nrqkvu6yRJUDJpKyEtd2rK+Hpzv5gmGpndf+x+2hr9AcIP5shmNDlXxO
	3vtonBKjQbZ04bJGSgLkL2/mk/G4FVF2mQgXWWJwSxRSrqQCrEmUxZkAbT2qjZ8X
	X/hvAMAvpr7j9bdd5LfCwude8K6fw==
X-ME-Sender: <xms:CbWcXDAx6_XrYJ8XJKyHMtEt4zgYNRvYaWOfPUb6e_A1vZ67rPz_2Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrkeeggdefgecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefuvfhfhffkffgfgggjtgfgsehtjeertddtfeejnecuhfhrohhmpefrvghkkhgr
    ucfgnhgsvghrghcuoehpvghnsggvrhhgsehikhhirdhfiheqnecukfhppeekledrvdejrd
    effedrudejfeenucfrrghrrghmpehmrghilhhfrhhomhepphgvnhgsvghrghesihhkihdr
    fhhinecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:CbWcXD8gBJkfkAwEoSxiCqpsUlHbjixmccyiiQ_K3KiGVGraPacdSA>
    <xmx:CbWcXFWkqFeKXeIbysLYMKOddL1n-NRlAZB97erQAqIvYgl7JQi0kg>
    <xmx:CbWcXANJYGvSWsn8Jx1w3Hx_aN58rZLtvSpH7mpdVeA3QkaBBvyLUQ>
    <xmx:DLWcXCG2WffXFbdFlAnReQD4gIcRCIBch_q3m9EiurFdAXCu5na9dQ>
Received: from Pekka-MacBook.local (89-27-33-173.bb.dnainternet.fi [89.27.33.173])
	by mail.messagingengine.com (Postfix) with ESMTPA id 2FA65100E5;
	Thu, 28 Mar 2019 07:50:31 -0400 (EDT)
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, cl@linux.com,
 mhocko@kernel.org, willy@infradead.org, penberg@kernel.org,
 rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190327005948.24263-1-cai@lca.pw>
 <c49208bf-b658-1d4e-a57e-8ca58c69afb1@iki.fi>
 <20190328103020.GA10283@arrakis.emea.arm.com>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <8e88b618-e774-de81-ca99-a8ee89f60b5a@iki.fi>
Date: Thu, 28 Mar 2019 13:50:29 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190328103020.GA10283@arrakis.emea.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000006, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Catalin,

On 27/03/2019 2.59, Qian Cai wrote:
>>> Unless there is a brave soul to reimplement the kmemleak to embed it's
>>> metadata into the tracked memory itself in a foreseeable future, this
>>> provides a good balance between enabling kmemleak in a low-memory
>>> situation and not introducing too much hackiness into the existing
>>> code for now.

On Thu, Mar 28, 2019 at 08:05:31AM +0200, Pekka Enberg wrote:
>> Unfortunately I am not that brave soul, but I'm wondering what the
>> complication here is? It shouldn't be too hard to teach calculate_sizes() in
>> SLUB about a new SLAB_KMEMLEAK flag that reserves spaces for the metadata.

On 28/03/2019 12.30, Catalin Marinas wrote:> I don't think it's the 
calculate_sizes() that's the hard part. The way
> kmemleak is designed assumes that the metadata has a longer lifespan
> than the slab object it is tracking (and refcounted via
> get_object/put_object()). We'd have to replace some of the
> rcu_read_(un)lock() regions with a full kmemleak_lock together with a
> few more tweaks to allow the release of kmemleak_lock during memory
> scanning (which can take minutes; so it needs to be safe w.r.t. metadata
> freeing, currently relying on a deferred RCU freeing).

Right.

I think SLUB already supports delaying object freeing because of KASAN 
(see the slab_free_freelist_hook() function) so the issue with metadata 
outliving object is solvable (although will consume more memory).

I can't say I remember enough details from kmemleak to comment on the 
locking complications you point out, though.

- Pekka

