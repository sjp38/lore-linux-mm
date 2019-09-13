Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45C41C4CEC8
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 18:23:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C183206A5
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 18:23:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C183206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9814D6B0007; Fri, 13 Sep 2019 14:23:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 932A76B0008; Fri, 13 Sep 2019 14:23:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 847FE6B000A; Fri, 13 Sep 2019 14:23:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0096.hostedemail.com [216.40.44.96])
	by kanga.kvack.org (Postfix) with ESMTP id 62ABB6B0007
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 14:23:48 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 154EA52A4
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 18:23:48 +0000 (UTC)
X-FDA: 75930720936.17.name82_406aab57e72f
X-HE-Tag: name82_406aab57e72f
X-Filterd-Recvd-Size: 2583
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 18:23:47 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 52ACE10C0515;
	Fri, 13 Sep 2019 18:23:46 +0000 (UTC)
Received: from llong.remote.csb (ovpn-125-105.rdu2.redhat.com [10.10.125.105])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0C6FC5C1D4;
	Fri, 13 Sep 2019 18:23:44 +0000 (UTC)
Subject: Re: [PATCH 5/5] hugetlbfs: Limit wait time when trying to share huge
 PMD
To: Mike Kravetz <mike.kravetz@oracle.com>,
 Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
 Will Deacon <will.deacon@arm.com>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>
References: <20190911150537.19527-1-longman@redhat.com>
 <20190911150537.19527-6-longman@redhat.com>
 <ae7edcb8-74e5-037c-17e7-01b3cf9320af@oracle.com>
 <b7d7d109-03cf-d750-3a56-a95837998372@redhat.com>
 <87ac9e4f-9301-9eb7-e68b-a877e7cf0384@oracle.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <3d98ea00-ea0d-a9b1-9e1a-e78a731c20a5@redhat.com>
Date: Fri, 13 Sep 2019 14:23:44 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <87ac9e4f-9301-9eb7-e68b-a877e7cf0384@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.65]); Fri, 13 Sep 2019 18:23:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/12/19 5:43 PM, Mike Kravetz wrote:
> On 9/12/19 2:06 AM, Waiman Long wrote:
>> If we can take the rwsem in read mode, that should solve the problem
>> AFAICS. As I don't have a full understanding of the history of that
>> code, I didn't try to do that in my patch.
> Do you still have access to an environment that creates the long stalls?
> If so, can you try the simple change of taking the semaphore in read mode
> in huge_pmd_share.
>
That is what I am planning to do. I don't have an environment to
reproduce the problem myself. I have to create a test kernel and ask the
customer to try it out.

Cheers,
Longman


