Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12CC3C48BE4
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 14:51:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D872B2084E
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 14:51:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D872B2084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67AB28E0002; Thu, 20 Jun 2019 10:51:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62A658E0001; Thu, 20 Jun 2019 10:51:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CB758E0002; Thu, 20 Jun 2019 10:51:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 133508E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:51:53 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y5so2131909pfb.20
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 07:51:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=SywieFVKx7T1f0KHrwhdoJYu25lYqXr9SdGdNU1qMxo=;
        b=GGMGKHNg9PjgTHaD1BkGn+4dzeAXiVyfbOUDOfj9RjpVeYbWzrqDrX5wc+Ly3S4PIt
         6KQrfsy4a6AW+gAUUoCGm+DufWP6mMRZAzFoZ0+f9hFXJVBbHcpuK5b+bmchi5KiPl6Z
         kuDXBu10rqqAiHqCxMDW2p07DrHU9v5NjvGYC4MleUNtCVTcYR2dCH1lZR/dG0VL8DcS
         UxybQim0J5bo8xFjXaPDAkjf2it0qBAG10ugBdZJh5jHeb2zFtmyoroWhdbopSdAHnPg
         dGTv6B3rucgVuCcrX9OCdBK4+fQkfM6UhOiauP82F+4Vrkh0GMZW8bBc1zwyDhKJCxZt
         sJ3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU21/wuoSwigvJkmUYDVq5dhQePsg15GOD4tnQPwVBc7Pi0U5rM
	HXk5ILpSLzQr9HKjlZOnLLa4TqDMIuGaoEqOhMXpz/IRT14JySAzPs8BKZjO/EV9ZbanyFY8fYW
	mFO99X1PBbw/RQ3z/AtBCx2e83Eyw0ko5Q6ozrJ8O7ekv+TAIUzdZ3CPcFgb6E1JP6Q==
X-Received: by 2002:a17:90a:32ed:: with SMTP id l100mr34293pjb.11.1561042312758;
        Thu, 20 Jun 2019 07:51:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCm5skoBISTIFoCpeHLOe1EjNGVy4Q6jVqmaULSnhZXBQua0uR+iMSGDFwicDz+Iq5grxn
X-Received: by 2002:a17:90a:32ed:: with SMTP id l100mr34234pjb.11.1561042311638;
        Thu, 20 Jun 2019 07:51:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561042311; cv=none;
        d=google.com; s=arc-20160816;
        b=zPbtXL+qbtV3YV3g4GUzL5BcURE8zs7Xw2sg7GvXku3o9cTp2HfjAu1dKhGQJ5x/dT
         qqs8c0CWKhXR8Ie/0rRaKiPQTri6jKoFvRHrcTBqvE+1zD5bc4KAXHiIsBf1ZfLGXJOR
         ZizPWh7ZwZxtN303BHcO44ShmhD8PvXJgHnttdZ/ivAb7hF48NmqAXQZFct1xCfdpjQQ
         byhaI4AFGoBs+AIZSSlxXR+nD9N2sg756A7GRUiIF8y0qmQvQ415kAgZSuSYYlE3W+38
         5bmeddk0bMMXXEe6quhkX9pxnV0DxZPqNIYedUqiWRSqc43ObHr6AfHL63XSFhYys/bg
         s1Mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=SywieFVKx7T1f0KHrwhdoJYu25lYqXr9SdGdNU1qMxo=;
        b=g2Rf4fKojTAI595+BejQvjecPHJLh08z5XisIyfmZfHLwWZy7Hp6j0HnvBxrFrOupo
         880cWtnZ4AiP03+xoo0tTSpSZN89dItKjC/8l/b0mTaJ1Gl+9swXOh5UfJtrBEXml2rW
         yT1S1lb/C8bW7iKwn7CkuWKO5zLA9nKqOoh3/P88V7xfwLElCTpgxENH3Jnbqbulrpug
         RaU3eUo4DS2SvrhQf6uwRfvKXDbC7Wjsd/gK5STqZJj3BkMXIyBvTnhiPs9buv0ZQE08
         UR+nSZvOdDjk+gIlW+wO9OHnvNat5fz9MjY189l0gYgSJKIy4Ut9SXJDzN0tvdlYoAe2
         Nr5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id u62si5790907pgu.334.2019.06.20.07.51.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 07:51:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Jun 2019 07:51:51 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,397,1557212400"; 
   d="scan'208";a="243650388"
Received: from bekenney-mobl.amr.corp.intel.com (HELO [10.251.12.53]) ([10.251.12.53])
  by orsmga001.jf.intel.com with ESMTP; 20 Jun 2019 07:51:50 -0700
Subject: Re: [PATCH] slub: Don't panic for memcg kmem cache creation failure
To: Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>,
 Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cgroups <cgroups@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
References: <20190619232514.58994-1-shakeelb@google.com>
 <20190620055028.GA12083@dhcp22.suse.cz>
 <CALvZod4Fd5X91CzDLaVAvspQL-zoD7+9OGTiOro-hiMda=DqBA@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <e7ce6ea7-50fc-78ad-1394-4da11cba7ad3@intel.com>
Date: Thu, 20 Jun 2019 07:51:50 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CALvZod4Fd5X91CzDLaVAvspQL-zoD7+9OGTiOro-hiMda=DqBA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/20/19 7:44 AM, Shakeel Butt wrote:
>> I am wondering whether SLAB_PANIC makes sense in general though. Why is
>> it any different from any other essential early allocations? We tend to
>> not care about allocation failures for those on bases that the system
>> must be in a broken state to fail that early already. Do you think it is
>> time to remove SLAB_PANIC altogether?
>>
> That would need some investigation into the history of SLAB_PANIC. I
> will look into it.

I think it still makes sense for things like the vma, filp, dentry
caches.  If we don't
have those, we can't even execve("/sbin/init") so we shouldn't even bother
continuing to boot.

Maybe we should turn off SLAB_PANIC behavior after boot.  We don't want
a silly driver or filesystem module that's creating slabs to be causing
panic()s.

