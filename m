Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0584CC0651F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 03:23:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0AAD21852
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 03:23:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="BvDOOgZZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0AAD21852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E0D38E0003; Thu,  4 Jul 2019 23:23:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 490A28E0001; Thu,  4 Jul 2019 23:23:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37F1B8E0003; Thu,  4 Jul 2019 23:23:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0158E0001
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 23:23:17 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id m26so8324912ioh.17
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 20:23:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=47wq6zSwqlBqXAKDNtdVAABXSaO0oASysFivQ8oCp8o=;
        b=HxlQRSPDQJjcf9WR86mphYHy7V2MhD30XA7RP4d6Dz81iGDyscO/KyDLJC/tzi64mD
         9iLfSuuQlbSfuRhYAjoU315rk60ClXNDFrn0kTpKL44kwvzKpIQYcRHfvYDzGbeK4zoi
         DDPjwREa0c1UTzf8k1jGBNt9x8Y7KUk7mqbAKAFDONN4fFpMhxzw7DiJ6O4iwDUrFXGB
         zSIg9ePoTwZAtyzC3O13fyxC0giEBV6XmwfYTJo816yjYvFe4pqqockikjn88Nc423DM
         8Fhzw//bzpIyvWF1JLNlKTDP0okZkeV+sAc3Y26zVf23jpSUHF8FBmWUriU7l4n75CTy
         zPcA==
X-Gm-Message-State: APjAAAXNwaelT0vLXAwdHNQdN62wZfcAQtxr8PihZo5vZwcm7xT7bBrN
	GAnefkgGGk86IQzOnMSUEmvIcoHxxdTmMbu/PtPW7kpPbJG8d2/QC3ozMQ3j3M77E7AD3SIz15S
	pKfPEe+aLYzu0S/dsEV5ovYbHG0GsSxR2yFoBE4xMHpA/+KpnmakAvFAbphoSp3Crkg==
X-Received: by 2002:a02:6a22:: with SMTP id l34mr1660330jac.126.1562296996878;
        Thu, 04 Jul 2019 20:23:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy48Xt0qFP4pJKv4H0O5HA5HmTUcuyeiXyT414xPaI+JZ10bW+h468d2skVMcXiYCdGsApG
X-Received: by 2002:a02:6a22:: with SMTP id l34mr1660303jac.126.1562296996365;
        Thu, 04 Jul 2019 20:23:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562296996; cv=none;
        d=google.com; s=arc-20160816;
        b=fBU4OKSHIIhps8u4tIGxEIHuotOFUvrhjbhTZSi0ollMaoaGNHbYTyLVaSUzPu2eXv
         9xkEiccs/quRE2eKZdQa0B7SC5IxAEPIYYe99aIa0eNYQ3EaJBWXvUzWyk9MgJ/6QxSZ
         S3THQOhvwPillFOaOaKBqZLxqrOH7tr1R64cttHKifQUG1w6TE/YZO94EPnYjP+cvfSu
         u7O9lylVQtoqA2dfefQ1eWq2ZoQgCq1rklk5vdXU9olZepHhQHBAuIDKXY/Uzgwdh516
         sxemw7ck3B5EHKxo40uQJ4gLIiMBYpZXvc49LOxEM8OnLh0C2k5WRFwzKQSlxU1ai5a5
         HO6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=47wq6zSwqlBqXAKDNtdVAABXSaO0oASysFivQ8oCp8o=;
        b=xrQ2kFcPQcKTcc4EIvr5WyO0AoC14+gt/gNvlSWUhVNHcrLQINHPs5ySvZqoPtr0UB
         r3mcp+BTgE76v8CvC+WCT3mT038odwr4NoMg+Y16TTyZL8Nr2HeSucxCkkrVxURlM2JO
         PMYM4GYdnDFE729y1aLcm9fkpOCxMcszbReC9MTDDVBShR4OdoA7WTY5huPsZz28PiP4
         mJdKKinn8908daDUEmWWRgp8R2r25bjyGrIm3nPoFleqE8v/6RYDP3em621yQZ6RjE58
         frf2gbBJKPROiwHIUP7x3JoQ7HsBYVUoRS2cvc5QWEEF9pF7qrOO7i3jPJ7UwvtD2ma6
         cEWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=BvDOOgZZ;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 190si11684541jau.63.2019.07.04.20.23.16
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 04 Jul 2019 20:23:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=BvDOOgZZ;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=47wq6zSwqlBqXAKDNtdVAABXSaO0oASysFivQ8oCp8o=; b=BvDOOgZZqM9q76ywqtMSOtZ5rx
	4Yd/UFEsS1GbqcB1rh/9KgGpfLcWP0U1xWMX2d6RQm6pH2Y3b4L6yCf5UREw5z4M2lek5I5v5tqQG
	zeuxzyBWysZzObFCZgufRB/0uPOuIGeMiuKVjtQaNpEeW+5m4hIe2wMkPQUgcEr749i0GTBTNnL/s
	OVbyuzmWvBKTW+zo+rotD9KtchIGCSHtkp5IvEJ5H1vylQAew65hVblOCVzVQi+8phNLDiV5kRC0j
	D52fKegavaYmacCiyuD8u1pXFBflKpuU/8uUkhvg2vdl+n8bdtXiSn/QEGDUqB4ROMIo5pidwjHqM
	54BfyB3Q==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hjEoW-0007BD-CQ; Fri, 05 Jul 2019 03:23:09 +0000
Subject: Re: mmotm 2019-07-04-15-01 uploaded (gpu/drm/i915/oa/)
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Brown
 <broonie@kernel.org>, linux-fsdevel@vger.kernel.org,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-mm@kvack.org, Linux-Next Mailing List <linux-next@vger.kernel.org>,
 mhocko@suse.cz, mm-commits@vger.kernel.org,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 dri-devel <dri-devel@lists.freedesktop.org>
References: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org>
 <80bf2204-558a-6d3f-c493-bf17b891fc8a@infradead.org>
 <CAK7LNAQc1xYoet1o8HJVGKuonUV40MZGpK7eHLyUmqet50djLw@mail.gmail.com>
 <CAK7LNASLfyreDPvNuL1svvHPC0woKnXO_bsNku4DMK6UNn4oHw@mail.gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <5e5353e2-bfab-5360-26b2-bf8c72ac7e70@infradead.org>
Date: Thu, 4 Jul 2019 20:23:06 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <CAK7LNASLfyreDPvNuL1svvHPC0woKnXO_bsNku4DMK6UNn4oHw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/4/19 8:09 PM, Masahiro Yamada wrote:
> On Fri, Jul 5, 2019 at 12:05 PM Masahiro Yamada
> <yamada.masahiro@socionext.com> wrote:
>>
>> On Fri, Jul 5, 2019 at 10:09 AM Randy Dunlap <rdunlap@infradead.org> wrote:
>>>
>>> On 7/4/19 3:01 PM, akpm@linux-foundation.org wrote:
>>>> The mm-of-the-moment snapshot 2019-07-04-15-01 has been uploaded to
>>>>
>>>>    http://www.ozlabs.org/~akpm/mmotm/
>>>>
>>>> mmotm-readme.txt says
>>>>
>>>> README for mm-of-the-moment:
>>>>
>>>> http://www.ozlabs.org/~akpm/mmotm/
>>>
>>> I get a lot of these but don't see/know what causes them:
>>>
>>> ../scripts/Makefile.build:42: ../drivers/gpu/drm/i915/oa/Makefile: No such file or directory
>>> make[6]: *** No rule to make target '../drivers/gpu/drm/i915/oa/Makefile'.  Stop.
>>> ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915/oa' failed
>>> make[5]: *** [drivers/gpu/drm/i915/oa] Error 2
>>> ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915' failed
>>>
>>
>> I checked next-20190704 tag.
>>
>> I see the empty file
>> drivers/gpu/drm/i915/oa/Makefile
>>
>> Did someone delete it?
>>
> 
> 
> I think "obj-y += oa/"
> in drivers/gpu/drm/i915/Makefile
> is redundant.

Thanks.  It seems to be working after deleting that line.

-- 
~Randy

