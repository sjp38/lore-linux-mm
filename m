Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 645FFC282C7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 06:06:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2923C20881
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 06:06:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="hWLG/PWP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2923C20881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=iki.fi
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6EF58E0002; Thu, 31 Jan 2019 01:06:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1C728E0001; Thu, 31 Jan 2019 01:06:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E3CE8E0002; Thu, 31 Jan 2019 01:06:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 61E5C8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:06:39 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w15so2440525qtk.19
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:06:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Yk5nlLPa0XwAnU0MnfRKQ56oJkU6bGDWISof55rW3pI=;
        b=U9d0bDQhp/pP9n5e4BqTLywfrx/A+rfj579M79yqVLNe1C/NbIxKheRshgj44xW6Ua
         49xyOnY2bhWhbdoPLbwm/Q1EYawS5l6d8fyxSyMwAXPPcCyyEmN2EasyC8Oa2OQKPgNy
         7FKQloNH9ms40xhwcEnOKlIWImfug/8b3d8AfNFrrzmotAp1beAb2HSSvSu3PNsZAsm/
         CIhK58A0VqAifuJPaJXkfaDu609UPuO6fFzzZrQatzjneRJ+ho0uchlWnqf3IseUPbwR
         mNIvvYDRgRSSnF69IZqo5u5PemOY/mEGjCIwhb7NVq7sm4tLATSMC+xtH2PxGA0A6y1/
         +XHg==
X-Gm-Message-State: AJcUukdfyblgbskLuIhA4Akx5zIdxluYxf/fimsprmx09BSaTfym67Mh
	iebNWX/f6PbvEYUtGpjLELE4FZ2648ewCl3TIP+Z1LpOKzWztt8KcTeOqjZl/UAA26ojFwQmiiO
	yZw25/MS0/g4Us+9SubUFeo+Xrl9iI47NY7gROSj1dfcqy4cqNSgzG35FDJ8Q4o4=
X-Received: by 2002:a37:c401:: with SMTP id d1mr29542270qki.254.1548914799184;
        Wed, 30 Jan 2019 22:06:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4VM9oVa7JjM1mEDRhX42zxFzEZ9zAXgC8ZoKvtMLifQwpfS+6+AVK086PviX5Y9utimL0I
X-Received: by 2002:a37:c401:: with SMTP id d1mr29542255qki.254.1548914798758;
        Wed, 30 Jan 2019 22:06:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548914798; cv=none;
        d=google.com; s=arc-20160816;
        b=Ie+7DpW/Zhtv+DYSWd8+pGvEoMspejZii+K4Wgbo71mTtKH9Mc8SMzmR87uv1K09J9
         M21UnQjufJMjXaQ5tCW7FEabbnuljNYSckuuHYOi9NRZ58P9hDzqfbtiGY2cnjgvIvll
         1A/B231+T6bZfoQsfZq+qEglyjtc6EdDe4mVBYcz+K1E+9/uLxjYeU6AUvhqs6F67/9k
         j/YSaMGHhXXdl+djJ8K3LIS9zgoK3ePOyxmkX/tl0dnPp5cwtjfLvkB3wMIhe1exn5aG
         vqOWG9vzI2uiGDoGIhNFeZRwR1DYcK0UPJMSasIDT95cDzMR3XBw3NznuuivRHNCUsel
         l//A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=Yk5nlLPa0XwAnU0MnfRKQ56oJkU6bGDWISof55rW3pI=;
        b=fOi9qshLFfoIACn+I4GXFcusnLhRzS5zsxsDmIbouqFDQGA35B8bXmHfR6McVTOsCy
         vRci4O7meY0atNsjQjRMMFproSfRSDZhVMz3vf/1xA8aJcpYM5c3kdnhBELz/RIQXAx9
         AMsDhUJGblO9EfF53pqHXnyRIuOfMJ4mGvNN4Pza2/VVvC/A0ByJEgRI9LoMcZH1l0n4
         NcBvqQAnQ8VJ1Okk/iQfkqePdkSUPposyLW62jS+4ikj9euJNraaSpjQX/DbLgmYSou5
         1d3vMTnTo2DySEFOn+Jo6Gr15tajwySs4fTMAGysbZQ8sl/x6a2H1j6mtSuzLsZDwppA
         0iQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b="hWLG/PWP";
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id x1si2588988qkc.167.2019.01.30.22.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 22:06:38 -0800 (PST)
Received-SPF: neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b="hWLG/PWP";
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 789742201A;
	Thu, 31 Jan 2019 01:06:38 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute4.internal (MEProxy); Thu, 31 Jan 2019 01:06:38 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:date:from:in-reply-to:message-id:mime-version:references
	:subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
	:x-sasl-enc; s=fm1; bh=Yk5nlLPa0XwAnU0MnfRKQ56oJkU6bGDWISof55rW3
	pI=; b=hWLG/PWPy3481WAJREI/3+VHljCjhbFyxYUM+WYW73Pnev6o24jDdooHJ
	uFniUBPJwv3FiN3ej9a0j0tpBtQQdXxDLwF6/cbm9cFAnq2GVVN9kSfb3o91XrHp
	YR3FlQbKarDcHixL6UmCHukPGPQLpg9uSnqYCUz3V8f1LktZD8M6FnNC1yLYGiSO
	+ZSX4sfe/FkRr+8pWN7EhGOqIk0IALcCkejDHM+1EOupC15o+YvdfVxfybwiBZ23
	nxyFdTWG1S1C/7R2IJjCk+tPjAHniwHFcGEGLNNqxlvO2diPxJQS6kgmPNek/e4H
	z/XDzekUEhHXHrCPhZ5VQN5W7tY4w==
X-ME-Sender: <xms:bJBSXJ--i1fPaGS1NeiMrFc7xzN-ubx7jqZGL-svX4JCS2J4QcVA2Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrjeehgdeltdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhepuffvfhfhkffffg
    ggjggtgfesthejredttdefjeenucfhrhhomheprfgvkhhkrgcugfhnsggvrhhguceophgv
    nhgsvghrghesihhkihdrfhhiqeenucfkphepkeelrddvjedrfeefrddujeefnecurfgrrh
    grmhepmhgrihhlfhhrohhmpehpvghnsggvrhhgsehikhhirdhfihenucevlhhushhtvghr
    ufhiiigvpedt
X-ME-Proxy: <xmx:bJBSXB_5exGb10HWfGFIVzKaHBayp2ynVWIEo68CsTeK9j-GcTiOKw>
    <xmx:bJBSXCDZ2R844n9li386vg6dj-xYlQ-97WkVWkHXD2pEgDyqMG60eg>
    <xmx:bJBSXBw8U0GNB8blDS_rk9HrM8oAGprOt2hI_GH9CHVYUmc6GPIb8g>
    <xmx:bpBSXOPkEljF7rpGLeewkXIDIQEmD0U-EFUobAV-B2kcYCq7v0a5Hw>
Received: from Pekka-MacBook.local (89-27-33-173.bb.dnainternet.fi [89.27.33.173])
	by mail.messagingengine.com (Postfix) with ESMTPA id 531D210086;
	Thu, 31 Jan 2019 01:06:34 -0500 (EST)
Subject: Re: [PATCH 0/3] slub: Do trivial comments fixes
To: "Tobin C. Harding" <me@tobin.cc>, Christopher Lameter <cl@linux.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190131041003.15772-1-me@tobin.cc>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <01ec2c57-4ece-5ee1-4d0d-d2f24695f482@iki.fi>
Date: Thu, 31 Jan 2019 08:06:31 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:60.0)
 Gecko/20100101 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190131041003.15772-1-me@tobin.cc>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 31/01/2019 6.10, Tobin C. Harding wrote:
> From: "Tobin C. Harding" <tobin@kernel.org>
> 
> Hi Christopher,
> 
> Here is a trivial patchset to wet my toes. This is my first patchset to
> mm, if there are some mm specific nuances in relation to when in the dev
> cycle (if ever) that minor (*cough* trivial) pathsets are acceptable
> please say so
> 
> This patchset fixes comments strings in the SLUB subsystem.
> 
> As per discussion at LCA I am working on getting my head around the SLUB
> allocator.  If you specifically do *not* want me to do minor clean up
> while I'm reading please say so, I will not be offended.

For the series:

Reviewed-by: Pekka Enberg <penberg@kernel.org>

