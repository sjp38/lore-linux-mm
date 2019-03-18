Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 211DCC10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 14:29:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFE402085A
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 14:29:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFE402085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77A8B6B0005; Mon, 18 Mar 2019 10:29:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72BA96B0006; Mon, 18 Mar 2019 10:29:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F3CA6B0007; Mon, 18 Mar 2019 10:29:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 086C36B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:29:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z98so4797813ede.3
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 07:29:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MVtYnd4dn5ajxYSbLicJB7zk2YmGKH1F75DdfqHKHyc=;
        b=Q4LjpEg8/CP60E+C1c1jutwBH9XR6/67h3dzPNNOMBAHQLdIqixoVA1SnHacl52VY7
         yUfVZ+xJ6kibciUq+UD94QR5AyXEiODXnVYel46g9BnCUASh43KeUt11iUk6icZ93BL/
         Zit3YH0gdTTOWiaRz7yyo9uGcUVl6llPOpd4oYfxSKtsxzSRnIHJZFKs2LYM1J2M6Vj8
         Oo+L/H7K4yLAhkaaJF5OodgR/JnRBJXytppYAWudzwglAQS/YmdYcffYWREMXoSdAg8M
         TYnOZj71AOE4p6WomCXl/XVpX+X2rZlUiMesS1kNLX3zCpG/kwhIZLAVJoSB3M4pfbzC
         HIag==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWgiOHjkLIjGMh45fOm+tZJuJbZw+fwpBXpMWH5i6mM62FsStmD
	MzPjgZme+RzezhhAJAeENG6UP+G278FEv9z4P1CrYRkojIHwEoZJz9rG248IBx4MIdqU+JWWXzQ
	BtOIaZfWnbfoHvrofK+RhGYHMAknqASvF6Cm73SK3j/vTOPC69iOXcV26Ggj+JOk=
X-Received: by 2002:a17:906:3fd1:: with SMTP id k17mr11169523ejj.87.1552919358525;
        Mon, 18 Mar 2019 07:29:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3gY5CdcOntmNVPOzxC2kS3kY5reTxrROzMvoZ9rDkVrMFHHSH9ALnt9sADiJQz1tecYeJ
X-Received: by 2002:a17:906:3fd1:: with SMTP id k17mr11169480ejj.87.1552919357601;
        Mon, 18 Mar 2019 07:29:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552919357; cv=none;
        d=google.com; s=arc-20160816;
        b=T0GSVXdyqPFNE4EH6WQltM+HEfQTV8BSA8zlQC4BpIk1EomAYAx0gyDh7ADU9EAQye
         HYoZ0souc5Ob9hqbSGNJDSm5eRw6BYihVlGD9Iw+Z1kXQqtCUv1BPqpNhjgmMcEeu47o
         y+dJ+6BwIEMDNps9jeDxzg9exKFQKxp4e6lRm5M1rz/QIDG2iaqe95LRw+XpZPH4aGkv
         2vT6mGZZAtF/vM1hL9nasEMDNr5/pOHXFbqHFvH8Fp7SMwsByr6AEGAvYjfOLraOu/Ix
         aSQgN06GrK1uOSP0eJpoXWSAN1p/f7ixtFIvYpT4Z0l6iPrssOCfU0FVnEmhB1D4n3Q6
         RzLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MVtYnd4dn5ajxYSbLicJB7zk2YmGKH1F75DdfqHKHyc=;
        b=GrZTEH9HI7aOiPc37lLMTft+C+7W0lUkBfWL5A3IFSuq9wdb0I7zLd33pgkrGNmpeX
         5hCHR+omloy5yBhjzPYiaZ/JQRNeMLnjW7/mExVrn4UuqAH0glJwdadb2MPA3VG65Tak
         t78fmRY9Wu9AcmyG2kBq1VPA45W1YErVjdvY35wIbvdevZ59QEoPMJU3JeySmxTwJP7i
         Lv6COcrDYLlzzjb1Hv6a+qv0E92sgNWuSMbcfUD8xF1t6ZzrVYNG09t7AI+P6OMrshbB
         E1Z0SHPr9nHps5L3Y39Ds/XbqdyuSubVyaHttoJqyl5uZ7CcDJ79A/BHi1mD/onX3eA+
         phqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3si2841367ejh.147.2019.03.18.07.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 07:29:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A70D1ACC5;
	Mon, 18 Mar 2019 14:29:16 +0000 (UTC)
Date: Mon, 18 Mar 2019 15:29:16 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"minchan@kernel.org" <minchan@kernel.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [External] Re: mm/cma.c: High latency for cma allocation
Message-ID: <20190318142916.GK8924@dhcp22.suse.cz>
References: <SG2PR02MB3098E44824F5AA69BC04F935E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190318130757.GG8924@dhcp22.suse.cz>
 <SG2PR02MB309886996889791555D5B53EE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190318134242.GI8924@dhcp22.suse.cz>
 <SG2PR02MB30986F43403B92F31499E42AE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <SG2PR02MB30986F43403B92F31499E42AE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 18-03-19 14:02:09, Pankaj Suryawanshi wrote:
>> > I have the system(vanilla kernel) with 2GB of RAM, reserved 1GB for CMA. No swap or zram.
>> > Sorry, I don't have information where the time is spent.
>> > time is calculated in between cma_alloc call.
>> > I have just cma_alloc trace information/function graph.
> 
>> Then please collect that data because it is really hard to judge
>> anything from the numbers you have provided.
>
> Any pointers from which i can get this details ?

I would start by enabling built in tracepoints for the migration or use
a system wide perf monitoring with call graph data.
-- 
Michal Hocko
SUSE Labs

