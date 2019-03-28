Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D6BFC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 06:05:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4FDD20700
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 06:05:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="z/PJ0bvM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4FDD20700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=iki.fi
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6031C6B0003; Thu, 28 Mar 2019 02:05:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5898E6B0006; Thu, 28 Mar 2019 02:05:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 451236B0007; Thu, 28 Mar 2019 02:05:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7346B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 02:05:41 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id l187so16685996qkd.7
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 23:05:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=jqtazJHsx+b9ct1DOtMFjfvs6F8nSs4P+e+seowAwTM=;
        b=s/Qb8Mz8nJEC6ucuBr9cjTmxxsffx1f2WjmnkjnDiSTV7fUT48kKwpf4+nd54vCtjB
         2Y20bYF0ynDP2QJhsCiO+GgtUVGPS/tDhawcjeqDfmLwfuN7wlTW7ZYO768WIZKgZcwt
         4JZ7W4xuSMtznT3V7Mco4EGyhVHytLeEyuCjEs6p77903XOfCx+OYmCv4YqmGkqC9lsM
         Wvov/2v3ioiVEPTvNVRlG7aSkY2Evq/vZlUs3fusJqwUvO9D+uKkHzBHT+EUiUmaM5ZK
         0wLXnDA5uE4HZGyZL1ghv0QK1PUn2oYsDxpzAjN8K9Z2+UBVKDgSNMOgaJOBAxPTVj0+
         M0pQ==
X-Gm-Message-State: APjAAAXJ3QGyj5WsTk3xjxo0S3jR3u1c6904gf6Fgv5Iohs0Ku6Kxjl2
	E0TDyfgAzn0vW5OGAHR62q6wudUq/iErd1Jidiv8E3iDJJQYvEzPO89dacwERgZJMtOvEF10+ou
	tlrgGBic2urtp9IL8gL1bAP4LrQpx2ToKREw/K76WuQXxIh60L2ne4zaOQLYb9+A=
X-Received: by 2002:ae9:f202:: with SMTP id m2mr31849237qkg.52.1553753140755;
        Wed, 27 Mar 2019 23:05:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx404b2mRE+mV7ndZAAF+3WXB4Doru1URW71InRQ/ucoS3JSrPhXJs2rB25n3amIhzx8hgl
X-Received: by 2002:ae9:f202:: with SMTP id m2mr31849214qkg.52.1553753140164;
        Wed, 27 Mar 2019 23:05:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553753140; cv=none;
        d=google.com; s=arc-20160816;
        b=u6UtdhkadpEH23aVDpOhLOWQNzCqlKwx0Ko9WI3L+U4md4KZeppVa7sfBj7899i1zI
         gODTtEFduw150e3gt6EPHX8Mm/Sn01owx4FyMBPWYZrVx1DePqWKFID80UtfRX6v1zi3
         2794qKKVo7nq5Po9y1/F1/mMt+niBAINJS4SNomURY049L9w6woSJ5GtgmKzYMLMucZJ
         HtAz4+CRmjYe4ORUY14rmRAXRwgcrRqE+wElQkhqfN+nYreLvus0R28FtEusYSotEWic
         xwCPcxfF3C3J2iKcsZCaFeFU1mJLVRrZEMYO/meQLQIRRhu6wBqdwWo4Lzw9EqRcp/vl
         P5og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=jqtazJHsx+b9ct1DOtMFjfvs6F8nSs4P+e+seowAwTM=;
        b=cbtMl9EhhD/cDqEaNJtursYjRQ6X3zPZR0owLkzDVLy9/2eP3kifKfZ/dnm4VZgANd
         UW9f+oRC35tQdYQFeXWwVoh+X/4kw9llWh8hWydpkD5YEGBtpGA9xBTcmNFLv/JXLHCm
         T50zuALbMR4GYzYt0n36dJcDqP11L6SNKmF1vkiDJDbX0M1qGT44goDGNQMe+oL5/lc/
         5jOph6a759qbd7DtIowfVrSzdIE+FIjiNfJp9veK1DFhIsmtcnb5sezcGjDlpi+dvTks
         EZH990fQqsx/UaN1vEEJA5PGi4wtFnH6T1YQQCWRBO0RlH8BLEFmPF93xCTlPLjvkCEh
         JN/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="z/PJ0bvM";
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id l88si798804qtd.251.2019.03.27.23.05.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 23:05:40 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="z/PJ0bvM";
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id B8EF92106A;
	Thu, 28 Mar 2019 02:05:39 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute4.internal (MEProxy); Thu, 28 Mar 2019 02:05:39 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:date:from:in-reply-to:message-id:mime-version:references
	:subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
	:x-sasl-enc; s=fm2; bh=jqtazJHsx+b9ct1DOtMFjfvs6F8nSs4P+e+seowAw
	TM=; b=z/PJ0bvMjNqjIRFMSifCfyHzH4pwkBOj+fX7DVLxdUaCOxD3o3cpxDRTU
	TRIBku+dtNMhmuuDTsJZyE98dZWQtKmh6upJVYkQuC/PYNZ88jAOpdwJox5DBg4T
	awNU+jHqh92Enu/+aAZu0g4M48fuCumuGVGkbqlhw67MkLWYBLQli03Aq3RiTc+E
	9BnomWRH0LnvQSeF6xTr/dEUpA1H3zqvL0knmozMCbfYjFxifMUethwluvXr+9/E
	ptaAaEoCnHnbpZvRjF08qSRxYZX1G2mQArmnInOut1SXQWT+18itpmE5GSyVL3iY
	X5zzyDmyu3NxX41Sq6JLSSHiXMGlQ==
X-ME-Sender: <xms:MWScXFLNbNKbGACaNhtY5UStBfFOaAAxZJ2pqIio7nT-xyQxD9daCA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrkeefgddutdduucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucenucfjughrpefuvfhfhffkffgfgggjtgfgsehtje
    ertddtfeejnecuhfhrohhmpefrvghkkhgrucfgnhgsvghrghcuoehpvghnsggvrhhgsehi
    khhirdhfiheqnecukfhppeekledrvdejrdeffedrudejfeenucfrrghrrghmpehmrghilh
    hfrhhomhepphgvnhgsvghrghesihhkihdrfhhinecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:MWScXGoOwmTOW2dtGsnspGGLTM5WNmfYafpzfQwRxUwzKVoMP9JHIA>
    <xmx:MWScXAbJzY-VsjNDId0KEq-dNAKP8z67g82-SVvUt95KQqJlwzMgiw>
    <xmx:MWScXDx78KJoHhRBnnl9M5t2PeOP0lOuVN2oerYnmln0dQFEK-VCRg>
    <xmx:M2ScXCgc2C_dn1hu1072izvJdboWuKCbli32GmHWAscee-WN5tNI9A>
Received: from Pekka-MacBook.local (89-27-33-173.bb.dnainternet.fi [89.27.33.173])
	by mail.messagingengine.com (Postfix) with ESMTPA id 039F9E442F;
	Thu, 28 Mar 2019 02:05:34 -0400 (EDT)
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
To: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org
Cc: catalin.marinas@arm.com, cl@linux.com, mhocko@kernel.org,
 willy@infradead.org, penberg@kernel.org, rientjes@google.com,
 iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190327005948.24263-1-cai@lca.pw>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <c49208bf-b658-1d4e-a57e-8ca58c69afb1@iki.fi>
Date: Thu, 28 Mar 2019 08:05:31 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190327005948.24263-1-cai@lca.pw>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 27/03/2019 2.59, Qian Cai wrote:
> Unless there is a brave soul to reimplement the kmemleak to embed it's
> metadata into the tracked memory itself in a foreseeable future, this
> provides a good balance between enabling kmemleak in a low-memory
> situation and not introducing too much hackiness into the existing
> code for now.

Unfortunately I am not that brave soul, but I'm wondering what the 
complication here is? It shouldn't be too hard to teach 
calculate_sizes() in SLUB about a new SLAB_KMEMLEAK flag that reserves 
spaces for the metadata.

- Pekka

