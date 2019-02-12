Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 580FBC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:43:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14514205C9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:43:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="PEmZ+96T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14514205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A81C88E0012; Tue, 12 Feb 2019 08:43:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A31668E0011; Tue, 12 Feb 2019 08:43:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9485B8E0012; Tue, 12 Feb 2019 08:43:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8E88E0011
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:43:58 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id a65so15777354qkf.19
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:43:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=eq9wdECYMR6FfFXhYXIqDMoTxwHXZRqxPmhn7WTEhWM=;
        b=h3t8aEvX77rlQo845ga/ANX3vXbW3wUgKBReYpqz5mDc/ctWifi4gnx7TbXUiOfzU8
         JuBlcktEm+BV7IKE25ojk9+2UOlgBNnPJrtD5y4xteK2YTOz2jHfOYDnvUNO6FQBnvxD
         vBJxKud6EWw4+JSJ7N5jSoKyIk2P9qUhBNg1rBHG7akT7ywEBeXjWmy6ECMFQclAaEe/
         F9MM7NPMNEsE6cGgaFUEpDdJ6A3Z/c2ulBaL2Lp9WmQIphStJiBop590ivm7Uc5XlnNK
         G91sbS7YZN5crhEvQytzgaG/9PlO0WyhG9r2n2CIpn8qYGfrdC23ICrjFz4dT5wTBJHi
         l8Aw==
X-Gm-Message-State: AHQUAua7B0ux+6gsuPu+d+R62m+AxMGF9kY9ldSAwhM86A6pvmF0fmkB
	KdpLvM+ZhxfHaKixdbvcHSiJLrZUI1pJpPPRE5cSgG1yE57r5XBUlX78ztibypkvUgGGG0s6HGw
	dtMYZW3+RlvsbvjAQWN88hOyALhXN3EOM6ooMZa9ONQl5uGk4vcg0g0ffbRRGt8MGqxEFzcLl8N
	lSK9jYrS2mBc0bscGQ18XKhk5z9sVx4QFFPcX9F2pQty6E7XXjixtE+UtraP9x3wCc+Q3ksUOkN
	LLsny8bNe5Wn0PsmA2jg6Yc4qq6B7ibEeAheYmINKC0yAKCuXEeF/Fb/OP2yn8KGAn07HblvKUO
	eHkvT5oo9vx0fb91OP91fzHHo6Vatvn6swqYBtPkBM8J3TE7aIASrRYxydrkYUOzgbkCorPYqK+
	k
X-Received: by 2002:ad4:4391:: with SMTP id s17mr2726455qvr.32.1549979038132;
        Tue, 12 Feb 2019 05:43:58 -0800 (PST)
X-Received: by 2002:ad4:4391:: with SMTP id s17mr2726433qvr.32.1549979037712;
        Tue, 12 Feb 2019 05:43:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549979037; cv=none;
        d=google.com; s=arc-20160816;
        b=qOZ7xbnq0MzheNxnZ2/SkeyGKVSWrsXbOnkJyvhjTCA/BIJ+bNvZE3RXfD8iLrwk+G
         75/H8ioopHdkyPVsgJQUcSqbQU+6o9sXazUgxDoX+pV/Bi7Qwh+xNvWlbDgP6oTx7Oz6
         OBERX95vYmLKBKZ4Tg1E6xVWJNgaFc4BQk1ad+tsqxesakWouCotC5qqIk1iJ55wUra6
         gKskuhSWHQRtGyKtjeKIGFowY6kegs0JRXb0pbwMyDwnx/m5KT4wImlU29HT4XiaOQKF
         wLus9CR8vU22eflaee5RS5v++XOLcLIzAUsGXnADkrrU+6Lm3tyN+VzF1gyAfpwKEJrD
         pHyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=eq9wdECYMR6FfFXhYXIqDMoTxwHXZRqxPmhn7WTEhWM=;
        b=RXTpGdX/T5sk0P684Wa3ANxGM+yubIdtWMrnsbMGWfr4cYIRF79ni6HBpBEgQh5uDL
         H3ehf5u2sueOTlznCXGI6whsQq+f5zua7Y6FNTSviX+9PoHUtcpL2KzxX+e3G2dJBuwT
         vs+gXaSvO8BnNzqJvBEf6tEyyQJUAnJe4Jg30XLYf+PLRMSoDjIwU81XdQaJSrCHfV3u
         zAiqshBaifn3jlkfo42QKznGPlIRikvL5KvdqIa/ZTny3QJufdk6npem/Vqiygf9VTrz
         BX2OXRyQJjUQgMvHaSb2mr37VOMEEQrm1XjatgsNswopUBYeuM7uXW2jMM2ZMXhefa14
         dk1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=PEmZ+96T;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h54sor16019099qth.8.2019.02.12.05.43.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 05:43:57 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=PEmZ+96T;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=eq9wdECYMR6FfFXhYXIqDMoTxwHXZRqxPmhn7WTEhWM=;
        b=PEmZ+96TmrtUkddsIdG0S+vEeKfftnWa6W5pDhKJTyImN+jP3U7fuWuDGmaNvQaRn+
         Lr/tky/AqY6PkXnnqSOqT2uhLIU7VgGP6M8BnCIvSKicwiiwHBlliHGA+0T4nYh5kUt9
         l6iJ6aQfZuDar9SsoknWe/I0oeMLhu859hg357lOB8SjDNbKO5y5tf2iaOyAsAxARId3
         WTeZRRnTgMjwnsZcvl6v3kGf1VSqapq0qdQsMY6KA72M3j5LsfTC7RDwYKpundRM8TX8
         hjVvpITa70FG2KnceDBuqLTNHXE0y2EkFYNBo053H2oGQkfU/bTeKtH5Eq+m33BbrXlm
         l1pg==
X-Google-Smtp-Source: AHgI3Iar74h4+BwVDj6515n4LqlgZMVGZCbmvTMKiewv5hmXfBmxQwUeP0Ioxi0oO6xi8orAKYo5Bw==
X-Received: by 2002:ac8:1413:: with SMTP id k19mr2845254qtj.134.1549979037461;
        Tue, 12 Feb 2019 05:43:57 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id 41sm16627913qtm.71.2019.02.12.05.43.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 05:43:56 -0800 (PST)
Subject: Re: [PATCH 5/5] kasan, slub: fix conflicts with
 CONFIG_SLAB_FREELIST_HARDENED
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 kasan-dev <kasan-dev@googlegroups.com>,
 Linux Memory Management List <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Vincenzo Frascino <vincenzo.frascino@arm.com>,
 Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>
References: <cover.1549921721.git.andreyknvl@google.com>
 <3df171559c52201376f246bf7ce3184fe21c1dc7.1549921721.git.andreyknvl@google.com>
 <4bc08cee-cb49-885d-ef8a-84b188d3b5b3@lca.pw>
 <CAAeHK+zv5=oHJQg-bx7-tiD9197J7wdMeeRSgaxAfJjXEs3EyA@mail.gmail.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <c92d6890-a718-a968-9937-13bdfeda773c@lca.pw>
Date: Tue, 12 Feb 2019 08:43:55 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <CAAeHK+zv5=oHJQg-bx7-tiD9197J7wdMeeRSgaxAfJjXEs3EyA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/12/19 8:26 AM, Andrey Konovalov wrote:
> Hm, did you apply all 6 patches (the one that you sent and these five)
Yes.

