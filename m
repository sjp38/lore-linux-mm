Return-Path: <SRS0=izd7=SX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61ABFC10F14
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 06:39:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E862820869
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 06:39:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E862820869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68DB76B0003; Sun, 21 Apr 2019 02:39:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63C5F6B0006; Sun, 21 Apr 2019 02:39:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52AE66B0007; Sun, 21 Apr 2019 02:39:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7FE6B0003
	for <linux-mm@kvack.org>; Sun, 21 Apr 2019 02:39:11 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id k63so2551761ybf.18
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 23:39:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=NrbLKYy6uwy+++ZsjXno1V8y3/i0EexFCyHxsdB+Qmc=;
        b=X4FTRkux/NeHPt+a0bw6Wh7jipw/nV3MpKO/eYV+oPX1jYuIGpAbwdRovlchWk4ThQ
         NTh5z3KtLxni0N7EgZt8Xo+Y+nuSX10CBp/lZh6mtEoayETfS5wAGJ5K9+sdC3nv5bEd
         bfxbBuJXwArxamGib7TtBn8eQ/sn+UF3nxk0FgWXZ4MKOpm3w+BO7BtSS3wVn068u1fV
         BceP4Ncjw6jw152UpqQ7eIwzZ1h4rhv2AGuGpcp6aFzt2xa6UJmmlC55WbBfJ5MnzgrA
         ftaMOHpcTnjipVWLOWTcQpjqrYUQA99agloNNdgXiNghkTG9krPKvsCmF6JLrOh+nNl1
         E4Jw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXu9Qa/cX1trCWuXg37muxe/7fnz+CAQQ6WoEAVI9zFDPBGFfY/
	CrsuXHoZ8JRJpcM8nDYrfh2sQjnE+vJYrgBpaNZzYQ3PLzINLROa4XS+4Zw91me/5yA2b5VHfY8
	L6i3IslF0e/e42aRskkGHog+QXnhzDSNhrCgZl19MdDPW+VEv6l7VqHC7YcfzTSj7GQ==
X-Received: by 2002:a81:35c2:: with SMTP id c185mr3093695ywa.158.1555828750898;
        Sat, 20 Apr 2019 23:39:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTM0U10tyEWF1DQv8IcZ0LIKXTwEwY8aSnWcPO9fmWqwxJ54Lc6fJh7o0wm6CO8Qr4iRXF
X-Received: by 2002:a81:35c2:: with SMTP id c185mr3093676ywa.158.1555828750215;
        Sat, 20 Apr 2019 23:39:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555828750; cv=none;
        d=google.com; s=arc-20160816;
        b=Dje8pXs+iovEGNbgg+DrF7QtFnh/rhCjFSXQMmI6X4cRqkAk0IW/H3VVpVaUWB8J3U
         Qz+hAWpn5eB0pbrEq735U5FMDAPY88LEY5G9HcHGgMUIJNnJkeJCs7S+to8gRQzKKJMQ
         0WIXpvg1b0HS69YDzHSmrt61Js8Cte6a7HPcZQ+S44IVH/N8JzTyWKytgYbP83YYZteB
         xIOPuv1zisPSveL6fqssGq5WXPTGRafiio1vBPfndD3954FqB9s24zEPsK7fwUVtJ5z4
         d8TQIlLjhpSYzVecq0XS7pPwDyjF/keILvycdWQhZcFLTjPTO/3pV3G4I27f22LCMuxe
         TpbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=NrbLKYy6uwy+++ZsjXno1V8y3/i0EexFCyHxsdB+Qmc=;
        b=00uKEUviECQy9QgcR1391rP2pWpeG0ZlDqDyz2bJPKVY8pQvcnXflcq+qqW+/uythX
         YwkZ7AFenmgpM61mlHusmegdDYdOxdVr+bD36cBsQ3UNMmBEmqtDwpa/hM80jJ6EuwIS
         QzlyucHTCgo4/ygkuIIXYY1TAuuomc1VysVH92tGlAYDzp3JWHq2o1/8Da/s5triieOm
         gTwJBAdqnqlSQlpatf3AqQMKtjwsxg7DTGGfuKYrDH/O22YwXkcQ36T5M0wpVxSCib5q
         0lPaloWF9c29VRs5jP/kiY0YZZCK4WTZ9lsx7ayNNtWJB6YPczBREc0cFT5ThPMhua+7
         ieKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 192si6692653ywe.291.2019.04.20.23.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Apr 2019 23:39:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3L6XWFn113102
	for <linux-mm@kvack.org>; Sun, 21 Apr 2019 02:39:09 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s0gqekwgj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 21 Apr 2019 02:39:08 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 21 Apr 2019 07:39:06 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 21 Apr 2019 07:39:03 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3L6d2FV52625588
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 21 Apr 2019 06:39:02 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 35FB952052;
	Sun, 21 Apr 2019 06:39:02 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 6B7BA52050;
	Sun, 21 Apr 2019 06:39:01 +0000 (GMT)
Date: Sun, 21 Apr 2019 09:38:59 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mikulas Patocka <mpatocka@redhat.com>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        linux-parisc@vger.kernel.org, linux-mm@kvack.org,
        Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
        linux-arch@vger.kernel.org
Subject: Re: DISCONTIGMEM is deprecated
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190419140521.GI7751@bombadil.infradead.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19042106-0016-0000-0000-00000271078B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042106-0017-0000-0000-000032CD6817
Message-Id: <20190421063859.GA19926@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-21_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=460 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904210050
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 07:05:21AM -0700, Matthew Wilcox wrote:
> On Fri, Apr 19, 2019 at 10:43:35AM +0100, Mel Gorman wrote:
> > DISCONTIG is essentially deprecated and even parisc plans to move to
> > SPARSEMEM so there is no need to be fancy, this patch simply disables
> > watermark boosting by default on DISCONTIGMEM.
> 
> I don't think parisc is the only arch which uses DISCONTIGMEM for !NUMA
> scenarios.  Grepping the arch/ directories shows:
> 
> alpha (does support NUMA, but also non-NUMA DISCONTIGMEM)
> arc (for supporting more than 1GB of memory)
> ia64 (looks complicated ...)
> m68k (for multiple chunks of memory)
> mips (does support NUMA but also non-NUMA)
> parisc (both NUMA and non-NUMA)

i386 NUMA as well
 
> I'm not sure that these architecture maintainers even know that DISCONTIGMEM
> is deprecated.  Adding linux-arch to the cc.
> 

-- 
Sincerely yours,
Mike.

