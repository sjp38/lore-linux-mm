Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC80EC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:16:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BFFE20850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:16:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="VSjQvEIh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BFFE20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F95A6B026C; Fri, 12 Apr 2019 10:16:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A71D6B026D; Fri, 12 Apr 2019 10:16:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 096596B026E; Fri, 12 Apr 2019 10:16:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id E24F36B026C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 10:16:33 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id k8so9308024itd.0
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 07:16:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=BPdkY8uvxWevickDQvrRSBL40XrHA1/YUdwPSxBXFUo=;
        b=thuA1CqaWtfDemSznGC1q+W9CEnB9PqIXbY425OnXTna7Ne4RynsyypHZEltSh3zhP
         9TphZWGEocKSOBHeuz1nK4l+BMuIYYm77jkGumiBxem9EDC8vTg+qjXE/6qxgwBipDcC
         V/GAWVJsECQPu2JH+gmbNjxL3wIXWvksSjkhPFy59NEtvCBXX0NkWz12umQWMNJ59iJl
         zeGaqWmcl5pkm/BFeLSBp1teaG51ViyqWATDp3Ol8bHou72Tj+huL3okjEO+5u4BxdBs
         UWv0QK/J/72qNvmmygOh9LwjLxJdFERqjTPfKkF/YeAtwDaRjmvdxQBbLjNkT5JV3ndX
         rdXw==
X-Gm-Message-State: APjAAAXpoIJmRxvYFsShkGPa/hZWdqKkIsa2+pB38ceZSyqUfut86MFM
	1hNYk8A0HPbgQoC8bj9R/fqvmnqnPjcDAyeneCJDbXUCaYBJ2gQiq1vyIgJHsxAM0tyEdzviSUQ
	DiZCYT95F1MBpncyC+xKGTmzdQ1hqQqkg3Dv5SO5y9z7teJhMp1Olu3S3FwYZq/f8xg==
X-Received: by 2002:a24:5991:: with SMTP id p139mr11607797itb.99.1555078593591;
        Fri, 12 Apr 2019 07:16:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxChw3jqWrbfVquIg68u3wTRa8tr54mjd750zoM2LRdMIJKXu0UnPRRuqIl3xUGAI7qfuJ5
X-Received: by 2002:a24:5991:: with SMTP id p139mr11607757itb.99.1555078592901;
        Fri, 12 Apr 2019 07:16:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555078592; cv=none;
        d=google.com; s=arc-20160816;
        b=0sxYldfbmS5/qopVR8AihMMVMmweaAMknzMDUsIpN8ANArTxyCAjFG7P960724CrxE
         Q4aJ+vxfeUBnuVMe7bDr/6FBc8yNfsVbTEo5Rp2fu9zhpTCPlBS7vqGMF1wCt9ckv1XQ
         sZ/eiE/Ivo9jnnIrah5URrsURZKvzlzk5oQWxOAtHdalxtYmlomzTQDQ6yyzmr1fMVb2
         Hxgnseta1G+r56PGKze/VnTrED8Kcn+2RAZTgZD4Oxrk3NeaeUrhngNhKKX3AkitKUtk
         KhXA4MFV55/9HA/8nVtjjEKQ/hpbzE+voXnhyNng6Gb5NDODDU1J0aECiBS/q3HqmgZb
         Nhrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=BPdkY8uvxWevickDQvrRSBL40XrHA1/YUdwPSxBXFUo=;
        b=KlHQjeD+vshL8bfCGXiiZu2WM00Gj1XfTMV7kYk0dsg3Tx4M8hxdLGGlPwjKSTZ7wO
         bdw/NnoUwTJFLRT5aEMWsGbrcEUZwMNDe7wAPpGKYho4uHkAKYtO531kkUbQvW+dasw6
         KRC1kc96z4rE/9AezoJTFyNNNm2TJMJxxSbu4n9ElGTTOCxS9k1Z709gg5ULVCgT1IQS
         38NrpreaMtd/KVFCRABLkKVyaVYOIgB4VSbPQrsP3oLiV9bzR30VCTgyvy1ac1dKhn+0
         nS2x6dsMPsYhKCiAEy6uB8cYSxtAmALn+hL+1zssJS0/XDNROGm3wsTE3BGp/cIl2bdW
         LQyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=VSjQvEIh;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id n20si22281207ioj.133.2019.04.12.07.16.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 07:16:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=VSjQvEIh;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3CEEKvW009814;
	Fri, 12 Apr 2019 14:16:28 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=BPdkY8uvxWevickDQvrRSBL40XrHA1/YUdwPSxBXFUo=;
 b=VSjQvEIhHCH3kfAULnZpm7VZhJ1ffyxsfK6+Gz1hIsbxqjEnApmWQLi+dGYzyn/7JL3/
 3Ys16/cFZXQysig9RjmFOitq0KaoTmG+RSTrUIEwEHmONJ1HYmYh0k0pVEeNJ8XrH86w
 NY8Zru9cQn67Eb+rdIv+ohzw5KojrmOOaNJky42BK10U2kWHGPadyVswsSAGYer3Umqw
 Qsf0StlqWuNhV0TIXO60slfc6JiB3tHpyIoORwHhKxz+7QKeuWKjbfmlCTzJCb7+E5YF
 EIxTPLGNt03beiOepuCJh8Z7P3F2udrqiyGEISfL3xwNqRAkdWljVaoup6Cw1aRxrjc0 Yg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2rpmrqppfx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Apr 2019 14:16:27 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3CEG082139441;
	Fri, 12 Apr 2019 14:16:27 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2rtd84jmbf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Apr 2019 14:16:27 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3CEGLqm007552;
	Fri, 12 Apr 2019 14:16:21 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Apr 2019 07:16:21 -0700
Date: Fri, 12 Apr 2019 10:16:49 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Michal Hocko <mhocko@suse.com>, Baoquan He <bhe@redhat.com>,
        Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
        hannes@cmpxchg.org, dave@stgolabs.net, linux-mm@kvack.org
Subject: Re: [PATCH v3] mm: Simplify shrink_inactive_list()
Message-ID: <20190412141649.elmtl7wpmfjnvbsr@ca-dmjordan1.us.oracle.com>
References: <155490878845.17489.11907324308110282086.stgit@localhost.localdomain>
 <20190411221310.sz5jtsb563wlaj3v@ca-dmjordan1.us.oracle.com>
 <20190412000547.GB3856@localhost.localdomain>
 <26e570cd-dbee-575c-3a23-ff8798de77dc@virtuozzo.com>
 <20190412113131.GB5223@dhcp22.suse.cz>
 <4ac7242c-54d3-cd44-2cd9-5d5c746e2690@virtuozzo.com>
 <20190412120504.GD5223@dhcp22.suse.cz>
 <2ece1df4-2989-bc9b-6172-61e9fdde5bfd@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2ece1df4-2989-bc9b-6172-61e9fdde5bfd@virtuozzo.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9224 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=810
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904120094
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9224 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=831 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904120094
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 03:10:01PM +0300, Kirill Tkhai wrote:
> This merges together duplicating patterns of code.
> Also, replace count_memcg_events() with its
> irq-careless namesake, because they are already
> called in interrupts disabled context.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Looks good!

Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

