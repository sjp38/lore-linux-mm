Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B5C2C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 20:39:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 301DD214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 20:39:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ezsCfB0c";
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="c9WzmLm8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 301DD214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9375B6B0006; Fri,  9 Aug 2019 16:39:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E83D6B0007; Fri,  9 Aug 2019 16:39:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D5756B0008; Fri,  9 Aug 2019 16:39:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 552A86B0006
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 16:39:06 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id k1so25546337vsq.8
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 13:39:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LYD1snKMlHvkWp294kI8LRCWSYWhhgJkoYcRSNCNcg8=;
        b=mKQgHAzeJsk0qCGcRCmeLVGGOWQgfMeeDJ59CMTxtVhaiJucpAdcWi2v1KgP1JMuuD
         vzcBBTfErbgwawcn9jLyhXL5A4s8KpjqwM+ai+MfoSWUgu7BCyLrqRYZ5Rgq5H5JlzOu
         6BnOMSZ1UasG2TV7MZF9piZ3ve26Kz4UQYT4denJHwCB3voLooo2UGDQLi75jAWwgad6
         swnsqILoG3c0M9wBGiBUhbP+eesl5qDLPijXHiqZ4CIFj+gdPSvM/MrAPbpP3t+7ZrHg
         yhBGIG1lrcNzcTrA6i0FCJHzjYhVyIKZGuBbWWmmzflXcuSg4bLBm4SASjp0MYJCNWFA
         MVuQ==
X-Gm-Message-State: APjAAAUJtSIbuvaMEnF5n+P18NPK/Jm7HVaTQVNq3NvcF8rwzKkNetWR
	oTdQ6yS+nwV6j8YKuaEGUW9abAR40unqdvQe71UnZwWirss/UhDym/NuvyfKWF55xS/l1cU3bg0
	/ZNQI+cTyApU8Qojw5rnF+9Fqk1AIAWr46xignCNJwIpX6D6eyYPmxKzK6sS+lQHNVg==
X-Received: by 2002:ab0:32d8:: with SMTP id f24mr815798uao.121.1565383145992;
        Fri, 09 Aug 2019 13:39:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhuGqL68KpbnkCdOfzLTERpPilgSJoXHDzPhtCtaYV1S/5VS4eUgsWkGw9E0m5/PSlFN1K
X-Received: by 2002:ab0:32d8:: with SMTP id f24mr815746uao.121.1565383145015;
        Fri, 09 Aug 2019 13:39:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565383145; cv=none;
        d=google.com; s=arc-20160816;
        b=nTwuKEErCmlfagCCvwwZtc/j5OXk2qqobRXmQmxegocWus+AvylEcjXBWZnmY3Uxa0
         OoWX2skFL8HU/H9VMZatIzc+iMSR1URS/irW5P4SA3j8veeDJSrdAH/gEOoIsyLZ1Ya2
         lucFfmRH4A/ld1D735xM4GZTKHLTmYQrWVl6DIVHPzDT8FXK/azrNWMplA4CL1AGP+fb
         jniehds78hN0ijUZjQmDIobwgjNmMBYNbNiDrbypYGGdW43g+YKpGZWPCI+pHZID/Swe
         5U4wn8BFgNanz1k2eGyK+yzY3+0sn0KuPm2JoXBkSaaSqOYlmqZIz4pqHAaqtas9QJ3d
         S4wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature:dkim-signature;
        bh=LYD1snKMlHvkWp294kI8LRCWSYWhhgJkoYcRSNCNcg8=;
        b=TrwibWUzPyFFiyUx7RR1wpZ0fkUjOYwP6ZzWzwyHUrI5jE8tTpLwrv3WfxOpaSQODm
         emvbs7bYUe/u4jMUuAaDa7kX8Fk4vP0y170omFchgr+ttm0zJu5Zuc9fk8gxrl9HNvjs
         49OL75vgYJFeFIUhxcYdwGRXvDjBQ06c6T7pdd4Qm/vXgFndAWcdlp+gL9bfaBGDSfWp
         5VgdnYv0U1JNH/Tfedshl8NX+3FbxpryMMwot+mQrUrA5v0lI0hfiKCTgiHPNp6/t4Q4
         8EXFaJaLo0Vfxn1/bZfmtn+VHhjubYK3Ec/LacnFx/FS3otsLo0bq/139niiGfrvXXZt
         atoA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2019-08-05 header.b=ezsCfB0c;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=c9WzmLm8;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o78si682977vkd.37.2019.08.09.13.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 13:39:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2019-08-05 header.b=ezsCfB0c;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=c9WzmLm8;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x79KT8Z7033406;
	Fri, 9 Aug 2019 20:39:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=LYD1snKMlHvkWp294kI8LRCWSYWhhgJkoYcRSNCNcg8=;
 b=ezsCfB0ccRtKFM/FVNeNmizjTfDVi2F19OS3Pcd+azyflbwiFFJPY/w9RB71ws8Q4Bym
 5B0h67PGJ00hMzT1ZTbRWfis+fZ5Gi73ESPzQxqmuB8Ue7yd1woRPma7sgswrDd3HCYJ
 k5Q6XN7jr9Avwqjey9vnsER2Jl1jqW/PigjRLpnoCrkm1Q5EGr7HBphDkp+T6eMKFbna
 SFqJ18sx2NF52Im6q9ueeJYJnYCTSQP/FWjcn2F7bB5DBOuhfiUuTbpmVgEXUskqrPTi
 lqB1Pur98Db77Nrwb65JmqZtFWv2PtZ0fAMZLe9hf/EpKW/FKm/+oZCzhBG0yVw9ZTo0 VQ== 
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=LYD1snKMlHvkWp294kI8LRCWSYWhhgJkoYcRSNCNcg8=;
 b=c9WzmLm8sd1JvJz89wNy75Btc6RYbJaGXeYI2l5NW4Bbk4gpxP2gx4i15t0OilFAbUjc
 6dA4vvinjOdft22mr9TBrukqtIgD2NE11HFTkc9+Md3xBB5hv4mwBKisT3nMKdZCy4lS
 9CAjTPRW/xhARtkzlaNCA7p797JFvfqsy8puQDc9w1daOmfOFMAQylUpJkVfwyjnP9yq
 Qb1eDDFmtg1Nfi8ningW6fEmvshpeXiCfY/LFI11v9DJihBj4Mx05mxNccPRsqdPXgef
 NWCzAGiba68jlgVuxyclXfBvD9ynmexYTMnSxil0vbvc9lc+q1mR1b1sc/tSdcvlCJxp Mg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2u8hgpa0yu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 09 Aug 2019 20:39:00 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x79KT3NW113900;
	Fri, 9 Aug 2019 20:38:59 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2u8x9fw136-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 09 Aug 2019 20:38:59 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x79KcucC005635;
	Fri, 9 Aug 2019 20:38:57 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 09 Aug 2019 13:38:56 -0700
Subject: Re: [RFC PATCH] hugetlbfs: Add hugetlb_cgroup reservation limits
To: Mina Almasry <almasrymina@google.com>,
        =?UTF-8?Q?Michal_Koutn=c3=bd?=
 <mkoutny@suse.com>
Cc: shuah <shuah@kernel.org>, David Rientjes <rientjes@google.com>,
        Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>,
        akpm@linux-foundation.org, khalid.aziz@oracle.com,
        open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
        linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org
References: <20190808194002.226688-1-almasrymina@google.com>
 <20190809112738.GB13061@blackbody.suse.cz>
 <CAHS8izNM3jYFWHY5UJ7cmJ402f-RKXzQ=JFHpD7EkvpAdC2_SA@mail.gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <fc420531-f0fe-8df5-57fe-71a686bf2a71@oracle.com>
Date: Fri, 9 Aug 2019 13:38:54 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAHS8izNM3jYFWHY5UJ7cmJ402f-RKXzQ=JFHpD7EkvpAdC2_SA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9344 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=743
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908090201
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9344 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=780 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908090201
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/9/19 11:05 AM, Mina Almasry wrote:
> On Fri, Aug 9, 2019 at 4:27 AM Michal Koutný <mkoutny@suse.com> wrote:
>>> Alternatives considered:
>>> [...]
>> (I did not try that but) have you considered:
>> 3) MAP_POPULATE while you're making the reservation,
> 
> I have tried this, and the behaviour is not great. Basically if
> userspace mmaps more memory than its cgroup limit allows with
> MAP_POPULATE, the kernel will reserve the total amount requested by
> the userspace, it will fault in up to the cgroup limit, and then it
> will SIGBUS the task when it tries to access the rest of its
> 'reserved' memory.
> 
> So for example:
> - if /proc/sys/vm/nr_hugepages == 10, and
> - your cgroup limit is 5 pages, and
> - you mmap(MAP_POPULATE) 7 pages.
> 
> Then the kernel will reserve 7 pages, and will fault in 5 of those 7
> pages, and will SIGBUS you when you try to access the remaining 2
> pages. So the problem persists. Folks would still like to know they
> are crossing the limits on mmap time.

If you got the failure at mmap time in the MAP_POPULATE case would this
be useful?

Just thinking that would be a relatively simple change.
-- 
Mike Kravetz

