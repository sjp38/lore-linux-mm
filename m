Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62313C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 21:31:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2582B2146E
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 21:31:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2582B2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=talpey.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C622F8E0068; Thu,  7 Feb 2019 16:31:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C11698E0002; Thu,  7 Feb 2019 16:31:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B28248E0068; Thu,  7 Feb 2019 16:31:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87DAC8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 16:31:58 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id 135so2293438itb.6
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 13:31:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LjtdTz4B0bDlg6CYJkuWx5glT0yYPrvsdr/gEXLL0gY=;
        b=gCZ1FAELbp0cvXkQP7SmeCh90MizaxNoR2n2/zJeRPLdJ3gCN70wuYxojRsD0yi8KQ
         bd3TIA7c+l8WPlcedBE13uMmLvWX7L6Qdpy3lolNwqx/M2Si0g5zdh45iaHXhs7NSuSq
         DIngRAA/xUB0xwV7zyXQms/Vq9xJM9JF8a4sbsHXOL2EENXy0fQ3UBndESWDLEakPJXI
         UetSStbO6qTeu6LNS5TXZxnH9aK0MP6aLkLLFQzZCrs3s3thx02v8ALoYTbpCqLccsf3
         /pJ1su08yIPZOuUQ8H/40Grus/yb7k77E0tSgh5hlQEkFBO9SjTzNkaz2xKJ6I9qDrlo
         985g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 173.201.192.239 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
X-Gm-Message-State: AHQUAuaxRszhgu+G2CnJvBMdpe4iDXriYttMiqkXd4b7M9s31QV7aRZy
	edjzG23bMStHcBS5/KtrYUoQQUtErkw+QGGZDOGDVBXviQSfJZ8Qu79KjnFJBO3RmNmgXyvQf1C
	tLAL+3KYDCV+aV1qhVm2ik1hwkSgr5QMK+kJZ66DNAjJzL9CUW0Z4GB/wiOUPd2w=
X-Received: by 2002:a24:7094:: with SMTP id f142mr6220733itc.90.1549575118322;
        Thu, 07 Feb 2019 13:31:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYEJlQA83hLfOYoT12/JRGb0bflij4yXyb3ddIzB8vkqRh+uYI9RHEoZCdO5JAAqEo/uQmo
X-Received: by 2002:a24:7094:: with SMTP id f142mr6220694itc.90.1549575117397;
        Thu, 07 Feb 2019 13:31:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549575117; cv=none;
        d=google.com; s=arc-20160816;
        b=QHnurLxSkqnDHcns/TKodqCyWXjINRIXuRhGeC4dznWjdR+CTKdk1lb3WYdgp895Se
         oczVkSVBNsWp1Pa6BizathVGki0nPzSah/uld36GzcXf2moVFbcpByEXPiHiCruZ5r8y
         DnkdA9MyRQmWeOHh5seWY/g0bEknIeEdIQZtlEmWQ2kfm13sx2+vL497Xf4f0LE7CFWJ
         dTTktU5L5v7aOMNeqT+PBXqX+E1cSzPdta2KWE4cD/NCvp9PivssZ8q1O9vKmb8qBbPQ
         CEExAAr0z/pmV2v0I5p20QWlUrh0ZcB65j50B3MdLEz4lSqn1mNVG7hlAr/mCboQvWUX
         ZBGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=LjtdTz4B0bDlg6CYJkuWx5glT0yYPrvsdr/gEXLL0gY=;
        b=GW4jYDIahZ6gSdcO7U5Ozvz61n/BkZDhsDo3MCp4VLiSMTxM2oo81Lvkm36V+hL8LL
         er8lIGUXTZJzZnk3SWLRZZIxXfmD+qe/wtBZhmkYp2znIdIN/asdJcnDMzKmC7Vxjdux
         W0LVASWBAMCMwjHtEKWw5+mW9Ba2NnKLRHbIqk/b8XiCqs0GemdzLf44BR8TXk2bmU4W
         6PmAWkO+Hw8ZEOe76Vjv1jrf13YAsjtpdMhVBGqlGbPGv3jEiYVFYpvGyaB4jrVLXe6a
         a1Pf7b5Q32Af9TMhhB+JeyVIiImi6BvQLdM4Rvdw5xz4oeq0GjrXKZ7ThlxDrMhG3K2f
         lj/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 173.201.192.239 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
Received: from p3plsmtpa07-10.prod.phx3.secureserver.net (p3plsmtpa07-10.prod.phx3.secureserver.net. [173.201.192.239])
        by mx.google.com with ESMTPS id h12si392490itl.64.2019.02.07.13.31.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 13:31:57 -0800 (PST)
Received-SPF: neutral (google.com: 173.201.192.239 is neither permitted nor denied by best guess record for domain of tom@talpey.com) client-ip=173.201.192.239;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 173.201.192.239 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
Received: from [192.168.0.55] ([24.218.182.144])
	by :SMTPAUTH: with ESMTPSA
	id rrH0gsWspMXCVrrH1g3W9f; Thu, 07 Feb 2019 14:31:56 -0700
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Ira Weiny <ira.weiny@intel.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jason Gunthorpe <jgg@ziepe.ca>,
 Dave Chinner <david@fromorbit.com>, Doug Ledford <dledford@redhat.com>,
 Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>,
 Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org,
 linux-rdma <linux-rdma@vger.kernel.org>, linux-mm@kvack.org,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>,
 Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>
References: <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <20190207035258.GD6173@dastard> <20190207052310.GA22726@ziepe.ca>
 <CC414509-F046-49E3-9D0C-F66FD488AC64@oracle.com>
 <6b260348-966a-bc95-162b-44ae8265cf03@talpey.com>
 <20190207165740.GB29531@iweiny-DESK2.sc.intel.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <93012d17-d3f9-76d5-e6e0-ea39198db5a9@talpey.com>
Date: Thu, 7 Feb 2019 16:31:53 -0500
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190207165740.GB29531@iweiny-DESK2.sc.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CMAE-Envelope: MS4wfNPBqiYWIPsqmJZqH2jytLAnIXKzGFJfDAQMUwijHbk9kJ8s97vSl4fnvGK6Eap6I3FFyYm5i7ddpt0pKnwEWuRGa1RIZVwDGf8TZLWSk9RU2ZvvrpNh
 Mkr/3cQUSXkgWKpICJJMV9/5Ql6fi+6Bfj7FG64fMPKAJ2rdJcdYD5IJdRsg1lD8qUd5EEhEe9B+hHys7VkQLU+5aw5XRN975P0xGY8BvaM0yim85LM35Dxu
 UU8Fi5VKSHrDIZDngF5mJCjJxszaPVzOHmbwhD04CyY/+0W6STERnASpIUMFH1JuxENPdW0ACHV6yVRp0TXeO1j5dbtHH+5TJLklB7bdDswnS1r/WXSoxGoK
 7JbF3m+lSgudUxZoh7PDoCe/rgh0CwMyMbT4jJVGWrC/yEzulQVo1syLVmfbKMgYOJZlezEXr2jG2ArW6LpDvFr3SgDWZ19SliffBBxKl/pQ8iysc78ba985
 Q1uxsQMmdIGPEnpPds6RNv8VEmRZVT5Xh+MxsYGR36slWZhsKBnEu63sv/spsSTs9fBES04WftDTS99AX9l3eHC0w7BU1EVaR7C3OFP8+AEXb1jeL0LRRyVh
 qpm9exdHAnKH3mUs/5itFSWS4LtSdgqQiu/iLEaArj5R7Fu1wMuGwm7EzP0fjNY8ZiU=
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/7/2019 11:57 AM, Ira Weiny wrote:
> On Thu, Feb 07, 2019 at 10:28:05AM -0500, Tom Talpey wrote:
>> On 2/7/2019 10:04 AM, Chuck Lever wrote:
>>>
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
> How long does one wait for these remote mappings to be dropped?

The recall process depends on several things, but it certainly takes a
network round trip.

If recall fails, the file protocols allow the server to revoke. However,
since this results in loss of data, it's a last resort.

Tom.

