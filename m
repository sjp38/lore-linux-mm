Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 361E6C0650E
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 01:19:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBF8A218A3
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 01:19:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="sSzW9TRD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBF8A218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 823116B0006; Thu,  4 Jul 2019 21:19:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FA618E0003; Thu,  4 Jul 2019 21:19:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70FB08E0001; Thu,  4 Jul 2019 21:19:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5130F6B0006
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 21:19:56 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id k21so8129062ioj.3
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 18:19:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=sMXRgiUX1St8pf2vFdCJ5XAY8S//wPffXNJgq0u7mgI=;
        b=CObe+p/CADW/tOWA5zbtsRTjgwxTLVH8usqqap9NqHcMJXrUvryEYjQbit6omJG24g
         qBa0nK8XH9hV+yKhcwwV45WUo65cWrqQ4hlxIzQqAF6jfSQ6frpmEZs3mavMfJmUUdHp
         KiPu3LzF4E6bbF1OfayShu5vyGA/6pMDFz63SKEqqG+CeFZFykQOKL9LwFqok4pccsMf
         3wmpGfeNph/2Boz4TtmABJYSmZ89zT/3la67G+EETGE81EvFMXAhj1OA1hoVNDuP0Zqk
         OonsfJOlRU9dLpsfGim1BUwplqREhvlGC+LsU7UV15zciucwgKJyuSFp7WdjoGbGeoO/
         EOyQ==
X-Gm-Message-State: APjAAAWa1Dy3iM7lGw3Ov/z23EihuFcN1QWmw8OIaLUe3Ff+h4fXlgEP
	2/UsmNzUUjunvE7fZpmnqrDBmp7Wgq6dqdaNvfudp97H4S8Rt8rNixh1pVn0jD/qCT3Arh0+uFx
	qN3LPi4OWvNA0JJbosi75OlESnM0qhEcHGYgjgDoFnHPW8pwLKi0boFpqvTuaQ7kLHQ==
X-Received: by 2002:a02:1441:: with SMTP id 62mr1191414jag.21.1562289596136;
        Thu, 04 Jul 2019 18:19:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLe3KVetjpDcKUWjp/ebJMDtb9Li60AOucEoLEGdpYX36us4eltpjN7ucqWh2FAHAqGQ9d
X-Received: by 2002:a02:1441:: with SMTP id 62mr1191379jag.21.1562289595565;
        Thu, 04 Jul 2019 18:19:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562289595; cv=none;
        d=google.com; s=arc-20160816;
        b=CtWMoXy/wJ8w+5N8B16Dwe49imNskJGo8rC4AzAxF0eyRN/8NH6ZGHLquWNOTG4xH1
         dZJBtixYFakUTDoy90z2Q2fZCc6TSSa2TbQxfFxdeJhlBby5Rj8aYTMAoCsT5DlQkjQb
         hkolXGmG0p+0XX0CewwijeUApZCPBhqA6yF2FDwMq4QKuoE46q2fgEfEnbFDFWLmryUy
         VUrZ6+IpxBRCmxbNw8+S+MLqWyB+loLF59Pi6tUNDxb+hor0k/X1ODCl/PAMP9xUAWsz
         E+ygdX/0iv5Etq6yHDwthwis/d5yxN0+sk/wj5lX2oTp7uro3LVUfCp7Z2l70PhTJBLo
         OcJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=sMXRgiUX1St8pf2vFdCJ5XAY8S//wPffXNJgq0u7mgI=;
        b=BA/0+nCez6SUHzUNFVJP8E3K0FSZwG7i2II6ARhSGn6nhEeiCrD1R+yNyfUo/vl1LZ
         WV2aTgBbv0XT8/ydw22maMYvul4j/KSFdFOCocxvRijebAI9fWVGYzUAXIfme93wmLUb
         f+SeMET4Fh3aLwcJRbPkrL8knb/3Agcs0JQ8q0UNhKJszEufuN7OgaiApnujR3i5+7Y8
         DfxcGHPNvils8wS4b/hPfIApBbQYTF5DsU8iUT8wNLAsh1zZ4iJjTQchEwHu8QdTTa61
         dBmXFgGVDyr+CRyPEhGz4qb3X7YcxliEtGrNqHdq5Uu//pIwvJQPFvwlxqUh55Fpecfb
         ZvJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=sSzW9TRD;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id o4si11522879jao.68.2019.07.04.18.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 04 Jul 2019 18:19:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=sSzW9TRD;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:Subject:Sender:
	Reply-To:Cc:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=sMXRgiUX1St8pf2vFdCJ5XAY8S//wPffXNJgq0u7mgI=; b=sSzW9TRDObDlpQ3hPHMqVMDV+2
	/BK4mqdFc1ao6uAafeVWe9hOq2z91t1CiGapZyghouo+T/GqDrY+pCPChC83Gfjpxp61ZjZmNjf+i
	DcjwpwIVaEu9Kr2bYm1nlj8YW51ATZBnmaxDDz0uvSUkK0Cp7Tm3rxMGBCdB9EiFS6e8AhQrnKO8C
	TdfYJmp9l8zSJsH8ySZAfI/6apbt9hE5Po/dbtwniqRUPLvcl8RW/P3ULS3Aq4kCUEALcBKK9tOdC
	7m5eX4fuYHpLujfae/IYtEljs06/Vsz+S3erD3FPy1sO6fTv9r1SdSSEGmn36NzoLr9So15wVxnUu
	keG/DMsw==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hjCt7-0006mu-N1; Fri, 05 Jul 2019 01:19:45 +0000
Subject: Re: mmotm 2019-07-04-15-01 uploaded (gpu/drm/i915/oa/)
To: akpm@linux-foundation.org, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
 mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
 dri-devel <dri-devel@lists.freedesktop.org>,
 linux-kbuild <linux-kbuild@vger.kernel.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>
References: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org>
 <80bf2204-558a-6d3f-c493-bf17b891fc8a@infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <63db23ac-c642-3e0c-58a4-81df991ad637@infradead.org>
Date: Thu, 4 Jul 2019 18:19:43 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <80bf2204-558a-6d3f-c493-bf17b891fc8a@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/4/19 6:09 PM, Randy Dunlap wrote:
> On 7/4/19 3:01 PM, akpm@linux-foundation.org wrote:
>> The mm-of-the-moment snapshot 2019-07-04-15-01 has been uploaded to
>>
>>    http://www.ozlabs.org/~akpm/mmotm/
>>
>> mmotm-readme.txt says
>>
>> README for mm-of-the-moment:
>>
>> http://www.ozlabs.org/~akpm/mmotm/
> 
> I get a lot of these but don't see/know what causes them:
> 
> ../scripts/Makefile.build:42: ../drivers/gpu/drm/i915/oa/Makefile: No such file or directory
> make[6]: *** No rule to make target '../drivers/gpu/drm/i915/oa/Makefile'.  Stop.
> ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915/oa' failed
> make[5]: *** [drivers/gpu/drm/i915/oa] Error 2
> ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915' failed
> 

[+ linux-kbuild]

It seems to have something to do with "modules.order".

But!!!
# CONFIG_DRM_I915 it not set

-- 
~Randy

