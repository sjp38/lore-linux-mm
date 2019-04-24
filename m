Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C229C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 02:32:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05A2A218D3
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 02:32:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05A2A218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 633FF6B0007; Tue, 23 Apr 2019 22:32:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E45E6B0008; Tue, 23 Apr 2019 22:32:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D4426B000A; Tue, 23 Apr 2019 22:32:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F31276B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 22:32:00 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f17so3996406edq.3
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 19:32:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=fEa3JOUbGsOnEgEQWnRoThOH7r3kOP5ZNmmP02Yq4X8=;
        b=WdXbhnIoDl+RkhtG5Fd4JCIw3FqGBBg6DGDfcZLB9bYdT2Q6VA6vvGtfqEpKSiSlUX
         KJUSnSlV3A33Rg6U6l01r6EHSmTEgFcOt4AaQKxi04LYo1n25bs8ToBhrzWX1JBzJ/bn
         OtyRdjpe2x+lZyQ62MPzwJywvHkN7prEc9vZCYOJPz+iWLolLSFXl+XTVfaI9mpzE9bb
         31dC8vVC+rcL7/qDnjjjR5tpZmCpesFKrBm91xsrlRDE7IqSWAcVBAWBslHOeLtoSv5j
         EQ1M1x8BjpXemD11kCA8+RuW8mT5cqRtWVOyEW4qmxNKXr1GdameCHkINhwpjIN2F3vp
         +bgw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAURziJP3fN3eJca/kFrZata01BSViW9t3EWtUe/EfkZT0NR7apO
	CNNwO6FwjPycAdxjvMxj/EZSm06Er8UNnmFrmMOclV2lgkZTBLMSGYa6hSTvK5P+G7CDbooMTkr
	mrWjIWLGOAe18zdavxmIZ2H7iMaI9B/Lksh0GH3pbvSE7O//XH68nHQ1sh/LD/Zo=
X-Received: by 2002:aa7:c5c4:: with SMTP id h4mr18873075eds.19.1556073120536;
        Tue, 23 Apr 2019 19:32:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy55iO9SmewWG788/daoun8f6Tr4VcYXbQF+gnQLQSnm+1w3B37Bk6AnEblnd/SIupZblY+
X-Received: by 2002:aa7:c5c4:: with SMTP id h4mr18873044eds.19.1556073119799;
        Tue, 23 Apr 2019 19:31:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556073119; cv=none;
        d=google.com; s=arc-20160816;
        b=enBB1hf782Hbvxeb5MoNonQlZx4oLhtd0GY8pQssOKRgOy1HcduUT6UlpqOxoJfdqE
         dQU4YBsuOAOoS9GBY3byag807crBVy6tNoTwI1X6KVyKdxjI7e2skavLF/ni9mdXaqHr
         5k2rewdNHm4lcR6L3DwkpugeKUJuqB5LFS5DvHuCJN/c+gX4n3nhRXbQXU6mE5aZz+Va
         sGk39TcKvJJGUVZ6bBP3SXQpBxw+NCaFwHCx6VABrc1n/sGsA0+mU6If7NTaTXINUheI
         8qBfaD0Dd09whzeX8rg+1LEe04YES2uE56ejgLtLLSmpcJ8uCWjhJXTUXw5nNH0OXaaT
         bAGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:mail-followup-to
         :message-id:subject:to:from:date;
        bh=fEa3JOUbGsOnEgEQWnRoThOH7r3kOP5ZNmmP02Yq4X8=;
        b=mLRtfc92/ZVbhvpyqcfFn2RFMZYb0FDJxK5F+Ke4HdtIm97Q/wa4SmDxgP0XbCXDyv
         ob+jBnWPGuZVf7r4NKPYtZn+Um1c6Zxl5V862S9PHQYOty0uLvXFowBBwptLbZlckdai
         gaGX9vk3oi8uNWHQfk2xBtxZ101Yfozyq/rUwDz0WCkozcvw9jZsBXqsCchpZpa/H2eq
         +RcIeGABE/RIez3hAJSYgVlj+TsF/IwL6ZF2ntU6fqAtlsMZWmugHoqMTnLTn6rA+Z0K
         GlO14kSR2S4g77CQO6MwnpcWBriOWSFMZxXTvnIxky9DsLo5+JpATx2mekKefXaf4zBI
         cG1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g23si3272283ejm.69.2019.04.23.19.31.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 19:31:59 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0466CAF1F;
	Wed, 24 Apr 2019 02:31:59 +0000 (UTC)
Date: Tue, 23 Apr 2019 19:31:52 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
To: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	akpm@linux-foundation.org, Alexey Kardashevskiy <aik@ozlabs.ru>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>,
	linuxppc-dev@lists.ozlabs.org, jgg@mellanox.com
Subject: Re: [PATCH 5/6] powerpc/mmu: drop mmap_sem now that locked_vm is
 atomic
Message-ID: <20190424023152.vrnyx4r4oapt7vdy@linux-r8p5>
Mail-Followup-To: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	akpm@linux-foundation.org, Alexey Kardashevskiy <aik@ozlabs.ru>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>,
	linuxppc-dev@lists.ozlabs.org, jgg@mellanox.com
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
 <20190402204158.27582-6-daniel.m.jordan@oracle.com>
 <964bd5b0-f1e5-7bf0-5c58-18e75c550841@c-s.fr>
 <20190403164002.hued52o4mga4yprw@ca-dmjordan1.us.oracle.com>
 <20190424021544.ygqa4hvwbyb6nuxp@linux-r8p5>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20190424021544.ygqa4hvwbyb6nuxp@linux-r8p5>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Apr 2019, Bueso wrote:

>On Wed, 03 Apr 2019, Daniel Jordan wrote:
>
>>On Wed, Apr 03, 2019 at 06:58:45AM +0200, Christophe Leroy wrote:
>>>Le 02/04/2019 =E0 22:41, Daniel Jordan a =E9crit=A0:
>>>> With locked_vm now an atomic, there is no need to take mmap_sem as
>>>> writer.  Delete and refactor accordingly.
>>>
>>>Could you please detail the change ?
>>
>>Ok, I'll be more specific in the next version, using some of your languag=
e in
>>fact.  :)
>>
>>>It looks like this is not the only
>>>change. I'm wondering what the consequences are.
>>>
>>>Before we did:
>>>- lock
>>>- calculate future value
>>>- check the future value is acceptable
>>>- update value if future value acceptable
>>>- return error if future value non acceptable
>>>- unlock
>>>
>>>Now we do:
>>>- atomic update with future (possibly too high) value
>>>- check the new value is acceptable
>>>- atomic update back with older value if new value not acceptable and re=
turn
>>>error
>>>
>>>So if a concurrent action wants to increase locked_vm with an acceptable
>>>step while another one has temporarily set it too high, it will now fail.
>>>
>>>I think we should keep the previous approach and do a cmpxchg after
>>>validating the new value.
>
>Wouldn't the cmpxchg alternative also be exposed the locked_vm changing be=
tween
>validating the new value and the cmpxchg() and we'd bogusly fail even when=
 there
>is still just because the value changed (I'm assuming we don't hold any lo=
cks,
>otherwise all this is pointless).
>
>  current_locked =3D atomic_read(&mm->locked_vm);
>  new_locked =3D current_locked + npages;
>  if (new_locked < lock_limit)
>     if (cmpxchg(&mm->locked_vm, current_locked, new_locked) =3D=3D curren=
t_locked)

Err, this being !=3D of course.

