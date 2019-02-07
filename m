Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B370FC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:42:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7979320863
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:42:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7979320863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=talpey.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BDD48E0040; Thu,  7 Feb 2019 10:42:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 043D98E0002; Thu,  7 Feb 2019 10:41:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4F898E0040; Thu,  7 Feb 2019 10:41:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id B66518E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 10:41:59 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id o205so472452itc.2
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 07:41:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=yx6OYh4SVd4BvCc8EgitLgQ1ev8LJawYFYMN8Ftz4HI=;
        b=NMZl7Tpdc1iQ4bgQMNc+1MgQw+p9fqDb0ujMZgMEug8TIhWqZTZtIxjwz5K5nMFtkD
         q5rGBfAOgnuXesFQMXC50tKe9jP2fBmS+T9qUxlw8qci/jK3Mr+cfXdSzJ6QlI1w8lFU
         EwmZ2VF/hkuOMo2h3jALCBTTnlqPqRaAEkFttW1VjwLtqucAVL95pfOIZZiqyiKtrWkD
         HuQF/QDvqyqkz23oV+d4zChq73A7+ci0SEc40asDfmOFWEgWJ8jVyv28t01WWZ81+JOO
         73xT6Bf5PwZWHkTOiQw89M8ZRzS5w7NenaXMj6q0GnhmCMW013cuE40I7mNRocpdYU3s
         HPlA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 68.178.252.105 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
X-Gm-Message-State: AHQUAuYRe4m0PUF+ukSk4ipTNYxa6Pe3g+Qa+3b5kRBapfjsR0SV7+A0
	3IEaj6gwhv6yQZ9WS1iRORglecCUeFs0fA/bIFUUZsYiYIYkcyHBB1bpOdORUBDa7Hr4rX16mJi
	Yb7d9Hi0B5QjZi4vAgjUGnOYylbQu2reEQ0liTXHNPmDC+8O3I0PuzI1PjV6DmnA=
X-Received: by 2002:a5d:8545:: with SMTP id b5mr1665985ios.288.1549554119514;
        Thu, 07 Feb 2019 07:41:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYZCXWQq1LeKdSTwVayE2Sr4JPAI2DFeVS/Tz3Kc1bn2kvNiEDXkqLhmaIXhiVWXKHgkHkw
X-Received: by 2002:a5d:8545:: with SMTP id b5mr1665946ios.288.1549554118807;
        Thu, 07 Feb 2019 07:41:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549554118; cv=none;
        d=google.com; s=arc-20160816;
        b=oGnlbjIPVoBuglP2xgUknztvpjvjBIhEKDSo2RkDRzXuBcYWuUhRlKFz726UfV780S
         +Gs9dCvK406iKF315Aw8PwlrfNbK7S4XLCpO9TQfobHZxxNWXuPiRZWr0HHKxI1VwPbu
         NCUCaQpXZ2Stl8ZDKMnoPuJhzg33syVIINARLSBqjL2KLsGmR4RrqlHGXIyorcy+oR58
         lOgG6oQqqjJzP4HTz2Wco1Jvxal2kyt/fPZt+GlLR6BnBS28xY4eBOJJOsVZt8kmXYWL
         TeVnsE4hsm+8vuV2sqazruN5UYSZOQzsLlJCTtTvdzqsAlwo3dnN+WNicVEN+rIvrjjQ
         PRiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=yx6OYh4SVd4BvCc8EgitLgQ1ev8LJawYFYMN8Ftz4HI=;
        b=GU5PAx0ZtkSobb5wjmWvfMIyUVx5MSdq0WOdfwEtAeWjBcB1p0qWsfklDPcfT2ToKp
         35oOhTzPGRmXHMB7RfUrogPis2kUMIHIMhziMVdB/b1K5c0xfLhFI1To2bWzHKuWFBtV
         kjVn1Z5OoNA+w53CoTnXCdJCZdr1szRzda5zUoT/90xz4aCxQ4UoRfqGS1goqO0cJB/g
         oMK3odSYrlLnwSt79d/hMoR4udlNrvCiLPeJn7kyejhSnAq46BK1PkrRhIwoV+BXXY9e
         aozNyWX/JZGxYHUKIOtcLjxI985vT1v53vdgOux72LpootFllvMQ8OKgSBgr7Va79vMm
         fB2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 68.178.252.105 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
Received: from p3plsmtpa11-04.prod.phx3.secureserver.net (p3plsmtpa11-04.prod.phx3.secureserver.net. [68.178.252.105])
        by mx.google.com with ESMTPS id w8si1740250itw.56.2019.02.07.07.41.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 07:41:58 -0800 (PST)
Received-SPF: neutral (google.com: 68.178.252.105 is neither permitted nor denied by best guess record for domain of tom@talpey.com) client-ip=68.178.252.105;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 68.178.252.105 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
Received: from [192.168.0.55] ([24.218.182.144])
	by :SMTPAUTH: with ESMTPSA
	id rloKgn9rxZBM2rloKgnqGf; Thu, 07 Feb 2019 08:41:58 -0700
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Doug Ledford <dledford@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
 Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dave Chinner <david@fromorbit.com>, Christopher Lameter <cl@linux.com>,
 Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
 Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
 linux-rdma <linux-rdma@vger.kernel.org>, linux-mm@kvack.org,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>,
 Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <20190207035258.GD6173@dastard> <20190207052310.GA22726@ziepe.ca>
 <CC414509-F046-49E3-9D0C-F66FD488AC64@oracle.com>
 <6b260348-966a-bc95-162b-44ae8265cf03@talpey.com>
 <f000f699219a8f636dccfbe1fde3e17acdc674a4.camel@redhat.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <ea175620-3dc2-c7f0-1590-02080216edf8@talpey.com>
Date: Thu, 7 Feb 2019 10:41:55 -0500
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <f000f699219a8f636dccfbe1fde3e17acdc674a4.camel@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CMAE-Envelope: MS4wfAF0L4q5BF+i2qxDq6hVvHGMzH5m66vAghTMsoCkgYnCEuoe07eEabPDGQlm6rBhVYK4mOVWeWaN7kbjDPuwZW8nockMHBDnB3CIZXqsP97b07ggiqww
 Nv2u9ttTGXvumDNmU0vN4fXpYKLUMOBx4x5rwGMR4lQte/LdVOt55sDnjTM+3rCdpFSnwvZ81RTtpSTdU7it/LCQFPyNSgzaZ1O9KSiIDabXKUN5cL9UpQsU
 JrkRBbkkqkr11pTwg1bZJlV1BTbQZtB3iRPV7GWphJ61sP1VRQOHc7grpvaGhR0ZPS3pEV2AjOur6Nw39jhi6JrS4k0Qb08h1KjxHBFlUfq3fs+W9IOPU8Y0
 nw9zamydxuFzxd+9KpYzH6s/45BGeQTYMDiTYg+TItDHeVawvuPn/rIZX9bs1XFpxJZaOxvfw8vGmVOmDzlQPn3a2CXFf3Zo1MhJVOh7wsdCCqZwTWtWeUqv
 QIZiqwzc8du2ffu+BKmpZbubSDsHiYNcE099rQPsIV9sDcv7Owa1y1Xdt1C02EfEdz+J9suziPFR78Dz0vNDVyM3gbwu4n4hkVBsWqyFdcBu1hD5i6cTMHLc
 E9RVNFQdAITsHGHYTI8ZHwSq3uwDJXPM0GCYCzqLxRIHdJIukv5UdLOZXxXrfzccK2A=
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/7/2019 10:37 AM, Doug Ledford wrote:
> On Thu, 2019-02-07 at 10:28 -0500, Tom Talpey wrote:
>> On 2/7/2019 10:04 AM, Chuck Lever wrote:
>>>
>>>> On Feb 7, 2019, at 12:23 AM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
>>>>
>>>> On Thu, Feb 07, 2019 at 02:52:58PM +1100, Dave Chinner wrote:
>>>>
>>>>> Requiring ODP capable hardware and applications that control RDMA
>>>>> access to use file leases and be able to cancel/recall client side
>>>>> delegations (like NFS is already able to do!) seems like a pretty
>>>>
>>>> So, what happens on NFS if the revoke takes too long?
>>>
>>> NFS distinguishes between "recall" and "revoke". Dave used "recall"
>>> here, it means that the server recalls the client's delegation. If
>>> the client doesn't respond, the server revokes the delegation
>>> unilaterally and other users are allowed to proceed.
>>
>> The SMB3 protocol has a similar "lease break" mechanism, btw.
>>
>> SMB3 "push mode" has long-expected to allow DAX mapping of files
>> only when an exclusive lease is held by the requesting client.
>> The server may recall the lease if the DAX mapping needs to change.
>>
>> Once local (MMU) and remote (RDMA) mappings are dropped, the
>> client may re-request that the server reestablish them. No
>> connection or process is terminated, and no data is silently lost.
> 
> Yeah, but you're referring to a situation where the communication agent
> and the filesystem agent are one and the same and they work
> cooperatively to resolve the issue.  With DAX under Linux, the
> filesystem agent and the communication agent are separate, and right
> now, to my knowledge, the filesystem agent doesn't tell the
> communication agent about a broken lease, it want's to be able to do
> things 100% transparently without any work on the communication agent's
> part.  That works for ODP, but not for anything else.  If the filesystem
> notified the communication agent of the need to drop the MMU region and
> rebuild it, the communication agent could communicate that to the remote
> host, and things would work.  But there's no POSIX message for "your
> file is moving on media, redo your mmap".

Indeed, the MMU notifier and the filesystem need to be integrated.

I'm unmoved by the POSIX argument. This stuff didn't happen in 1990.

Tom.

