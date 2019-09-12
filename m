Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3933AC4CEC5
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 16:44:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D213A20830
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 16:44:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="jCafRrJi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D213A20830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CC176B0003; Thu, 12 Sep 2019 12:44:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 355436B0006; Thu, 12 Sep 2019 12:44:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21D0B6B0007; Thu, 12 Sep 2019 12:44:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0095.hostedemail.com [216.40.44.95])
	by kanga.kvack.org (Postfix) with ESMTP id EF3006B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 12:43:59 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 48D8762E9
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 16:43:59 +0000 (UTC)
X-FDA: 75926840598.08.brick14_5cf45c26cb845
X-HE-Tag: brick14_5cf45c26cb845
X-Filterd-Recvd-Size: 4241
Received: from aserp2120.oracle.com (aserp2120.oracle.com [141.146.126.78])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 16:43:58 +0000 (UTC)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8CGhdQh088519;
	Thu, 12 Sep 2019 16:43:49 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=EB/p5338NYK4pzHsk6TBuBlAMNpbEMjQOcbfPa1pTQQ=;
 b=jCafRrJiLWmf9PMwQwF3AQ5GwyOUrMFaTKoak7fyLTjhfpvBEwfryr6f+qpkTtAycMnC
 Ek8O93/PErFd/DhTtMsYJAHFpYqkZRMNVmZa+VqbYyc8455i4rkK6JpQUIMAUJIa1LHF
 DIRRwdujfsNWYrvn9nm0oLWu+LciByGLAyv3yyMki3b96p8VADNpao/k/LFCmxf8wQOE
 cQSXRqJz307e+aoHlIVVeY6AFM62+dwjstXLL9T8DNsn6NIAguH29YeTouKFvcbHQMnD
 ydn/mkbe6plveb4unWpgJOXqELB4KUg+ltQeThuC9RXEIH1NZ73dXIaJLz9IefNnT1e1 iw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2uw1jyhnvw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 12 Sep 2019 16:43:49 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8CGhe1s010201;
	Thu, 12 Sep 2019 16:43:48 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2uyrdgkbaf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 12 Sep 2019 16:43:48 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x8CGhSW9018583;
	Thu, 12 Sep 2019 16:43:28 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 12 Sep 2019 09:43:28 -0700
Subject: Re: [PATCH 5/5] hugetlbfs: Limit wait time when trying to share huge
 PMD
To: Waiman Long <longman@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>
References: <20190911150537.19527-1-longman@redhat.com>
 <20190911150537.19527-6-longman@redhat.com>
 <ae7edcb8-74e5-037c-17e7-01b3cf9320af@oracle.com>
 <b7d7d109-03cf-d750-3a56-a95837998372@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <87ac9e4f-9301-9eb7-e68b-a877e7cf0384@oracle.com>
Date: Thu, 12 Sep 2019 09:43:27 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <b7d7d109-03cf-d750-3a56-a95837998372@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9378 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=664
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1909120174
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9378 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=710 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1909120174
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/12/19 2:06 AM, Waiman Long wrote:
> If we can take the rwsem in read mode, that should solve the problem
> AFAICS. As I don't have a full understanding of the history of that
> code, I didn't try to do that in my patch.

Do you still have access to an environment that creates the long stalls?
If so, can you try the simple change of taking the semaphore in read mode
in huge_pmd_share.

-- 
Mike Kravetz

