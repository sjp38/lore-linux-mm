Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33C17C282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 11:52:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4283218AC
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 11:52:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4283218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 827C18E0002; Wed, 30 Jan 2019 06:52:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D8358E0001; Wed, 30 Jan 2019 06:52:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EDA68E0002; Wed, 30 Jan 2019 06:52:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42BE68E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 06:52:04 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 42so28077961qtr.7
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:52:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=OQLs5dpww+MxhRQxSxsfzgajn/aLBITrFiX1+3QcXFU=;
        b=Nxm57Yl504dlRFXDN8rLfVXTdBnuzQJBG3g9DISwm3hRX1O2VOWhI2E9ISEGg3zPAD
         sGQ3R7WMkyS46AypCMt9zjH8f5C2euScHySjYWwDEsN4FOLAVyyJ0FGl2OZLIoR7G1pk
         k4SXo6KXhqvFbvG03YdGYhOGdIbiCsBpILvTHLqZzY/iHCdlrXrOoHjYsIzwUMoP+WWH
         zQWRzl6PsQlfdpQ6RUnboLdbAcCD5cjnlww9StAUxSmfJ4cYdLhUa+hH60SVQKgJ6yvc
         CF+DvZfe+XPSjZOJ4hbxjIlexBRtvZR+4QrtGPzTBvRqTSPnogbothTe23gOHnrLfA37
         JXEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUuke9DNLvwBqw/l0Rax+K8XBPNsNg88aP+PTJ8khQzx14/6eR5Ibt
	kU9/NUeNXcFYu7CVR5rlZhiqyHcm+Wv3U+K2p7s6ZmLZhQCaaMv/9hjfWXKPvu3xl8dEUJETosA
	jpR/wNW+Ddp7NblsDdLxwnsivc/GK/ZfcFLfABJf5qkmrZyapS3NaFWh8MDRzyUc9hQ==
X-Received: by 2002:a0c:878d:: with SMTP id 13mr27968066qvj.8.1548849123997;
        Wed, 30 Jan 2019 03:52:03 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7iyP4onEOrgXSKzlJHauiitbi/uHZIiwfpF9qfg0UkqNlvoLR/mKyUdl+lmUM+MSy9V8EC
X-Received: by 2002:a0c:878d:: with SMTP id 13mr27968022qvj.8.1548849123111;
        Wed, 30 Jan 2019 03:52:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548849123; cv=none;
        d=google.com; s=arc-20160816;
        b=z44XT0YUpUTd7MIhN82DgHmHPnvO5X2lTiqPD4VBQ8GLwdI5fjkvHr7UVBtsN1lGUS
         bPh4Glvcp9+0KBZ+isrf3vRZkBksauZ02T+l4qj/Jak48wXD2z/yQReL92xmMyq3CP67
         k6X1xxUdfQ0zwFTDpmyffGgbolsTk+nPg3KgEGwIYNbnoeaiQBnPG9qvpJNw0FWZg5Qi
         TlloPFZ4HhYWSFnk86uv2e4RFKZW5MHeK1PrG+vLygfyTT1SnIwHdBK52+8dO+DOurV0
         uzselkLf4AeXSfr7x2ouUSq51YCE3txcu13CSYHRiUHe4l8NCM8+cbsL2g8HM459ZgpD
         pWMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=OQLs5dpww+MxhRQxSxsfzgajn/aLBITrFiX1+3QcXFU=;
        b=Ksal7/3JHuuWXRtrl55V+Cghyymrid2bzG1Ut+IwEOrO3MQqecNDz1A+sC7lOeq81r
         4aS+ZlCU5KtAcMZpWgMnYKbo6DuC6mni3PXsBVIlo4dyGvp4gGOMeVS+a6vw6fxX2Goq
         Thct2wDiAL7qRRRYgmW3WhMo2bpA+yqdr6zMOPREtL2CxFxiMILYUK1luigoD86ajmoI
         W155DOgEnm1XHgCnNSddiFn9kBOfyjx9Ao69uwQEfe9NrfCoTfzG2JF4IQNyTxXv9FYz
         zyeeT7+5pq08b0dPVOmRySNgRTRQ8Lw4f3BUMKhQRIg+fH7+5zV2QcKQXaGIWcpnMemu
         3RqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o63si902583qka.164.2019.01.30.03.52.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 03:52:03 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0E6C0A7865;
	Wed, 30 Jan 2019 11:52:02 +0000 (UTC)
Received: from [10.36.117.149] (ovpn-117-149.ams2.redhat.com [10.36.117.149])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 156CB10A3944;
	Wed, 30 Jan 2019 11:51:57 +0000 (UTC)
Subject: Re: [LSF/MM TOPIC] Page flags, can we free up space ?
To: Jerome Glisse <jglisse@redhat.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Michal Hocko <mhocko@kernel.org>
References: <20190122201744.GA3939@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <596246f1-5ebc-7088-e303-00983984e864@redhat.com>
Date: Wed, 30 Jan 2019 12:51:57 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <20190122201744.GA3939@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 30 Jan 2019 11:52:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 22.01.19 21:17, Jerome Glisse wrote:
> So lattely i have been looking at page flags and we are using 6 flags
> for memory reclaim and compaction:
> 
>     PG_referenced
>     PG_lru
>     PG_active
>     PG_workingset
>     PG_reclaim
>     PG_unevictable
> 
> On top of which you can add the page anonymous flag (anonymous or
> share memory)
>     PG_anon // does not exist, lower bit of page->mapping
> 
> And also the movable flag (which alias with KSM)
>     PG_movable // does not exist, lower bit of page->mapping


I would really like to see an easier way to spot if a page is movable.

__PageMovable() can produce way to many false positives.

movable will usually not be paired with other flags you mentioned as of now.

If many of these flags are not used in combination, we could merge some
of the flags into a number field. Valid combinations would get a number
assigned.

To keep it simple, only flags that are completely exclusive might be a
candidate. But not sure if we really have many of these.

> 
> 
> So i would like to explore if there is a way to express the same amount
> of information with less bits. My methodology is to exhaustively list
> all the possible states (valid combination of above flags) and then to
> see how we change from one state to another (what event trigger the change
> like mlock(), page being referenced, ...) and under which rules (ie do we
> hold the page lock, zone lock, ...).
> 
> My hope is that there might be someway to use less bits to express the
> same thing. I am doing this because for my work on generic page write
> protection (ie KSM for file back page) which i talk about last year and
> want to talk about again ;) I will need to unalias the movable bit from
> KSM bit.
> 
> 
> Right now this is more a temptative ie i do not know if i will succeed,
> in any case i can report on failure or success and discuss my finding to
> get people opinions on the matter.
> 
> 
> I think everyone interested in mm will be interested in this topic :)
> 
> Cheers,
> Jérôme
> 


-- 

Thanks,

David / dhildenb

