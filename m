Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BAC9C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:36:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C892120856
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:36:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C892120856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C6996B0005; Tue, 26 Mar 2019 05:36:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 674DE6B0006; Tue, 26 Mar 2019 05:36:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 563BF6B0007; Tue, 26 Mar 2019 05:36:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 06F0A6B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:36:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m32so5024530edd.9
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:36:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=olgQLUm8qPvdrni+8mfKE5xgj8wNub8yZO7T2nyrR7A=;
        b=tcizFgbISODSsNln5zEe8bdSHx3JmaRJk6z9Ln8XoMGSx/oaUZRjwcQy+34tMkzvyJ
         3tvvuWswjA2XiCmWCkW/raDdoVlVZJDjHwuCdf/EnghPWFrMkiL/1eHiTNRs1yCxgyhO
         yr6dc+e1o1v3ohHvaKuf+1JmE2i0WTeK1YFE6rInRUIEbHFkGBB7FLh9URsoJKoSMT1P
         1PFhj+R+vdNPhDTCAAdwcFRAmbtqVFq0kl6DIj45EEqwbc4cmNKJtZjm8sLFugctmM0V
         /mtqVIBk9zpV9kpXtYs8eZP17eKJoaDCj6WAwFPIZX3RNyZ7e1LWrsUza4+c7A/r/H7k
         Bffw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUwhIBlxQKVJZtUyJuyvU0Ia7VPKaMqlz6ljYk3astzljSLFnxI
	UpX3xN/cb89+KKIVu11MwNUqCrM9jdm57rIVwNfDp7iXZuR2dGVvlMBmNCH0fVuHVRI9oSbHASu
	PszycaFLWOnBXO6ii63qYtur/O7uci9jnT8/8HIzwuG6ApVpOentlz6ieOq5MWLE=
X-Received: by 2002:a50:97b8:: with SMTP id e53mr18275553edb.4.1553593014594;
        Tue, 26 Mar 2019 02:36:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynmiUn+BJGvrXIqWfrVTUlRb5ckaTgOS5m6FRYWZ869nGNy9YaJ6xrEIw/d5luLtFnqsOG
X-Received: by 2002:a50:97b8:: with SMTP id e53mr18275518edb.4.1553593013946;
        Tue, 26 Mar 2019 02:36:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553593013; cv=none;
        d=google.com; s=arc-20160816;
        b=EabqCME0M245q3q5NsafzIzYW5HPakvnE9I3ivd5PkXklRNgrc5cwZYUkdEtiiqdrA
         cmAnBFE97X1ed3BfhB5LNzzm6iPJsID3FcfecLRtvs715uCMQn6PMewGMoBx1HNnUmSg
         3RM+uMKovdQZAipKokYzZ+QjyAWVRF+fiCVuTrqr/bJtqfQwAMMVgMqFi7hFuRUniMna
         zo4ytjflrjABrwLQGldQ2AUexvW08N+S65euoN9ugBCMas0+cNIIWDV1t4isMKa3V2uQ
         yTu8vGoRk5lQhA5nGPxsdqQVBasFLCJbUUhGvoFMTqn4bWcK9DQImoI+W6zvhQ4q0Gup
         U6fQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=olgQLUm8qPvdrni+8mfKE5xgj8wNub8yZO7T2nyrR7A=;
        b=mzIRnb5sDamseJkiXcIR6+taSwtvrc3U6oxWvACYE8gyeeN8PU8rMzfdxxynqPyTRu
         vairteMObJTInDHQmr7qmy1O4KxGV+IJqHHFKnWIG0S+BqTCz2+8lkixeuuYdR1c4zad
         MTQOoPi7lprw+Vbga2Qfrm5UQVCQ99Oo+GVHXjTca+c+OSFk4RHBW5B0FriZws5OEXcB
         xSDmHLAnTICIby7GmpHwo+9mCyfK4tclKJBtTKKETjO5x8p4aYNI9sFnFrY5llBuNBKI
         GullZzRulGPkdq2bke98JkhH+pWEtm25Rv43lNyMRFXjEhyawhpBRhrycmzxQzCWZXnK
         dFsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si161774edk.312.2019.03.26.02.36.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:36:53 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 93599AD3E;
	Tue, 26 Mar 2019 09:36:52 +0000 (UTC)
Date: Tue, 26 Mar 2019 10:36:51 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Vlastimil Babka <vbabka@suse.cz>,
	"aneesh.kumar@linux.ibm.com" <aneesh.kumar@linux.ibm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"minchan@kernel.org" <minchan@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>
Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
Message-ID: <20190326093651.GM28406@dhcp22.suse.cz>
References: <SG2PR02MB309841EA4764E675D4649139E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <56862fc0-3e4b-8d1e-ae15-0df32bf5e4c0@virtuozzo.com>
 <SG2PR02MB3098EEAF291BFD72F4163936E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <4c05dda3-9fdf-e357-75ed-6ee3f25c9e52@virtuozzo.com>
 <SG2PR02MB309869FC3A436C71B50FA57BE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <09b6ee71-0007-7f1d-ac80-7e05421e4ec6@virtuozzo.com>
 <SG2PR02MB309864258DBE630AD3AD2E10E8410@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB309824F3FCD9B0D1DF689390E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190326090142.GH28406@dhcp22.suse.cz>
 <SG2PR02MB3098FAEA335228CFB56F1668E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <SG2PR02MB3098FAEA335228CFB56F1668E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 09:16:11, Pankaj Suryawanshi wrote:
> 
> ________________________________________
> From: Michal Hocko <mhocko@kernel.org>
> Sent: 26 March 2019 14:31
> To: Pankaj Suryawanshi
> Cc: Kirill Tkhai; Vlastimil Babka; aneesh.kumar@linux.ibm.com; linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org; khandual@linux.vnet.ibm.com
> Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
> 
> [You were asked to use a reasonable quoting several times. This is
> really annoying because it turns the email thread into a complete mess]
> 
> [Already fix the email client, but dont know the reason for quoting Maybe account issue.]

You clearly haven't

> As i said earlier, i am using vanilla kernel 4.14.65.

This got lost in the quoting mess. Can you reproduce with 5.0?
-- 
Michal Hocko
SUSE Labs

