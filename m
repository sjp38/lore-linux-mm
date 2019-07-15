Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EC8AC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 08:23:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0BC4214C6
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 08:23:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="fOaRolnv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0BC4214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 526716B000D; Mon, 15 Jul 2019 04:23:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D5BA6B000E; Mon, 15 Jul 2019 04:23:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C41C6B0010; Mon, 15 Jul 2019 04:23:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC1B6B000D
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 04:23:55 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id f22so19011358ioh.22
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 01:23:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LW+DBcVS9oyDDsJmOLra8xpi1dc7wYTn6BTkn7k6LvI=;
        b=hFb4xSyKi/Ymr9PAYL6QSYE9D9S4GIGu0Su+RwWOG+XhrRc3p/LMYior3NuL1blZTo
         T8E3j5tVXjyOnd3eA3zAD5Xe6gJ3dZZwGjD5i6RrDnOL2FnIIkZKR1hQ9LNH5YavgbM9
         3PTgLmNzbAbqAHWU8R/TCN9WjFePb19RbwUeatvXdj9buAs7N9kydmfUoh84zCHzl3hi
         mjCU2MDMqMY54SWk77jmYOE7eBy6Z8Y7iks6VIobFWbwcazXCgUc/IJNwlETlg9jaNvM
         nH/gpyuI8KBoD82NF2W+w5tqYo8QzeWnELOiEdEwTRRbct0OJAxrB9x7Smx9UNCaYApS
         DoyA==
X-Gm-Message-State: APjAAAVS4kBcimXyLZQz53gHamS1qVzSE6KfBxeiRuPzVrlJ4yi1HJ58
	roup0vycbAOKf6SgT1rDK35f9h/k0Tm4By7T1lD9gWsb+MMIVlnGSmqaQ7STcM9KP3znfWzBhaf
	MDYz66SpTAf07uyQPwXcOqn7pXD9IBskV998jFBc/jCFAjHovmgLwd20vM+V4fP6pFQ==
X-Received: by 2002:a05:6638:c8:: with SMTP id w8mr27197953jao.52.1563179034836;
        Mon, 15 Jul 2019 01:23:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcY1kT9jcbdkEFF9BWkRwcy4kwHqIBs1lJp2biSB1O0bx7JyA9+eIjw3UrzsavKOCJRR3M
X-Received: by 2002:a05:6638:c8:: with SMTP id w8mr27197905jao.52.1563179034062;
        Mon, 15 Jul 2019 01:23:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563179034; cv=none;
        d=google.com; s=arc-20160816;
        b=YRUpDfhgX1m7ppVWfsz/0uAhO4ph7gMBhgJh8trj/BJ6b9a6oTbFzLQbt0sTnqCb27
         gUxukBBvT3d75svmTmmBbd7XGE/z2pT01TVDNUxrzCMjIQgYYK6JFRFogx7ndcTK9B5C
         oFSU6njFmVFiZu4aRTSf8z3mzHJNSdWlqSP6qnFYMMe3xtClxWl5+YTmqfBCxDoKNjmV
         ywvi+8pqVIo4KYLvLgIPW+p1TW1cErBByCkuwH9vzbCOXXCTHVKJ3Kftp7mGxiW093N+
         BjEu7cIsZSbI8YPKqOstBCqGt73wuMFWjhKf2mkf/rTPeOW1RElQ/wQDYRaf4wmPFaBl
         6OaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=LW+DBcVS9oyDDsJmOLra8xpi1dc7wYTn6BTkn7k6LvI=;
        b=owrgjHGUxZZC6IToEVm3tIbHewZFhqgM47ZQb99/2ZwGw4nYW1Ck3+ebH6wxac+d9p
         EulXBEzWqSTj+JcP0pAGJpAEsULdF9I2HwH1z26yUcVTFLjxA0/u4wjfZ0ivh7pqd2R2
         LxX9nxDY7OyclUFiodAoWcTl0upTnidxYufCoU4mJubD30y0NSrFb3ofjjYPiTxw5DE+
         rx0azwxKu4OrvJHjc8/dzfs+G2+MlnVKdCR7k91NWQ/3n3stqDfaC76hLlH1+ftiWh9n
         /ZMMwMa3EyKtQqIc4wDhIdIvYyJe/QxXJWNXIjoGtzCsQyDXA2SXBFaSZ3ARMu6USa0q
         8CLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=fOaRolnv;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q139si26540751iod.84.2019.07.15.01.23.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 01:23:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=fOaRolnv;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6F8Islg030262;
	Mon, 15 Jul 2019 08:23:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=LW+DBcVS9oyDDsJmOLra8xpi1dc7wYTn6BTkn7k6LvI=;
 b=fOaRolnv2ZDHS2Exy04imAS1bU4vFOS2IeLppcGLAZkthhxkzSW6YdtEtRK+VZ/1t8g+
 mWzdx/PrPqsIMT1rfzyRzlNqddFnczL0HhEOt6OzP7q0VZRxTVUqr4J/XGjuF4Mb/J60
 A/e69AKDT8tUutMIQInJOg2qlFg48tthoFbqB6VSECx/ReHIJRSH//zDKamV4Jw3VNXl
 Eh4enfETBToLntLjAHw2KXs6FoY0zNmI4BNmHT+Od2T7T75axmFBiM9WOwU6bQAY6p4e
 NsrTusUAhJuR8clrtGBTOzr0MNHu2LsBV+c7HXr3g++51RazT4d/4hbRNUrsK0tdhzMC yQ== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2tq6qtd21w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 15 Jul 2019 08:23:23 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6F8MeFM123723;
	Mon, 15 Jul 2019 08:23:23 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2tq6mm59ea-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 15 Jul 2019 08:23:23 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6F8NKm2017595;
	Mon, 15 Jul 2019 08:23:20 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 15 Jul 2019 01:23:19 -0700
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>,
        Dave Hansen
 <dave.hansen@intel.com>, pbonzini@redhat.com,
        rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
        x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
        liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
        rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
 <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
 <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
 <20190712125059.GP3419@hirez.programming.kicks-ass.net>
 <alpine.DEB.2.21.1907121459180.1788@nanos.tec.linutronix.de>
 <3ca70237-bf8e-57d9-bed5-bc2329d17177@oracle.com>
 <alpine.DEB.2.21.1907122059430.1669@nanos.tec.linutronix.de>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <fd98f388-1080-ff9e-1f9a-b089272c0037@oracle.com>
Date: Mon, 15 Jul 2019 10:23:15 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1907122059430.1669@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9318 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907150099
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9318 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907150099
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/12/19 9:48 PM, Thomas Gleixner wrote:
> On Fri, 12 Jul 2019, Alexandre Chartre wrote:
>> On 7/12/19 5:16 PM, Thomas Gleixner wrote:
>>> On Fri, 12 Jul 2019, Peter Zijlstra wrote:
>>>> On Fri, Jul 12, 2019 at 01:56:44PM +0200, Alexandre Chartre wrote:
>>>> And then we've fully replaced PTI.
>>>>
>>>> So no, they're not orthogonal.
>>>
>>> Right. If we decide to expose more parts of the kernel mappings then that's
>>> just adding more stuff to the existing user (PTI) map mechanics.
>>   
>> If we expose more parts of the kernel mapping by adding them to the existing
>> user (PTI) map, then we only control the mapping of kernel sensitive data but
>> we don't control user mapping (with ASI, we exclude all user mappings).
> 
> What prevents you from adding functionality to do so to the PTI
> implementation? Nothing.
> 
> Again, the underlying concept is exactly the same:
> 
>    1) Create a restricted mapping from an existing mapping
> 
>    2) Switch to the restricted mapping when entering a particular execution
>       context
> 
>    3) Switch to the unrestricted mapping when leaving that execution context
> 
>    4) Keep track of the state
> 
> The restriction scope is different, but that's conceptually completely
> irrelevant. It's a detail which needs to be handled at the implementation
> level.
> 
> What matters here is the concept and because the concept is the same, this
> needs to share the infrastructure for #1 - #4.
> 

You are totally right, that's the same concept (page-table creation and switching),
it is just used in different contexts. Sorry it took me that long to realize it,
I was too focus on the use case.


> It's obvious that this requires changes to the way PTI works today, but
> anything which creates a parallel implementation of any part of the above
> #1 - #4 is not going anywhere.
> 
> This stuff is way too sensitive and has pretty well understood limitations
> and corner cases. So it needs to be designed from ground up to handle these
> proper. Which also means, that the possible use cases are going to be
> limited.
>
> As I said before, come up with a list of possible usage scenarios and
> protection scopes first and please take all the ideas other people have
> with this into account. This includes PTI of course.
> 
> Once we have that we need to figure out whether these things can actually
> coexist and do not contradict each other at the semantical level and
> whether the outcome justifies the resulting complexity.
> 
> After that we can talk about implementation details.

Right, that makes perfect sense. I think so far we have the following scenarios:

  - PTI
  - KVM (i.e. VMExit handler isolation)
  - maybe some syscall isolation?

I will look at them in more details, in particular what particular mappings they
need and when they need to switch mappings.


And thanks for putting me back on the right track.


alex.

> This problem is not going to be solved with handwaving and an ad hoc
> implementation which creates more problems than it solves.
> 
> Thanks,
> 
> 	tglx
> 

