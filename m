Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A7DFC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 15:33:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5002B2075C
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 15:33:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="SlyLnGBX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5002B2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABCB16B000E; Wed,  5 Jun 2019 11:33:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6C9D6B0010; Wed,  5 Jun 2019 11:33:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95C196B0266; Wed,  5 Jun 2019 11:33:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5FAE06B000E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 11:33:22 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id w14so16300462plp.4
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 08:33:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=OZ1kDdTgN4wvLaPyCNbaBt4ZZAol0O1Af0n8ppQn/zU=;
        b=j5o1UYMkT84B7mYUJdEhE2CuPXtg/fWHKiShp9yZCNmeRAc8Ue36xBJzpnxInygPNE
         lsJ9sqvRkZ5cF4sdsJIDNmnjs/Fcizr+wI4qtaKhGD3Ifnzug4C5i1SMUOHp2MqA1Fk6
         ir09t4D0dYo7k5mw9bSzwKrFzWX+vIa/5XqS4mr1MiYhPVAGcuQrsl3rs4jhJFsjyDZD
         HEEh4NxdViZKfC5aZ/Nhhfk6LWjbeWNDOC0ncmB8kN/EXWvCbkbjE65zlUTVV2CfHSVm
         OgOlqTpE2BZEOI42CopFNY9yEvfwJvL3c9DrKDOgKU+2m8rsQ7HBI3nuP6VIWnIeH7XD
         FXnA==
X-Gm-Message-State: APjAAAWKJaTOw6XXYrdp3sao8ktvKlgMb2C4nLqxcHi8Rpe7vzhx2vcG
	3TTv3/1ZP6fWHR5tkf5Z8RvPvEifiCNe1np7Ibx6awoKeYyQYqWwJqp82mlZGnG3vXIbmlrjCs3
	ahKQQb+5JU+yunf4pKpHL+CIUiDY61aaljFLVt7jlF13LZ7gDPwSoDcCb/aZlek7BNw==
X-Received: by 2002:aa7:8b57:: with SMTP id i23mr3979115pfd.54.1559748801924;
        Wed, 05 Jun 2019 08:33:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJuBAyRPLIM5W8coDcLbSrQcKPUWYH8PQ6iZ4wnQEp0n2rQe7tg9obfTKPtGwW5mTv3+pQ
X-Received: by 2002:aa7:8b57:: with SMTP id i23mr3978995pfd.54.1559748801063;
        Wed, 05 Jun 2019 08:33:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559748801; cv=none;
        d=google.com; s=arc-20160816;
        b=r0kbAsRNYVXF8Z+GjWkLVCc613h+vy5mMEMWZoLI8qGG5R7IYu9hPKgImN/2PztZ9v
         +kY1fca3XqXtrCssnTccqCU5ou5grjWCmV4037J35mVd3DNH7pYrh8tFtzipqfGvgoNl
         1ZoWk2FH+IViBLl7EbtSP15L26gnyfxTo4LqGIRajEeA3w7lqrIJWikc8fpkH7swtmEW
         uRvYWlFCWyjkr5Zw7e6yDqDTpbXazOCD/ypJNEv/2yayIPpQtP3ob4QhPt1Byw1B7UAN
         hQFJEE3XYF22CyQhAXOma8mHOxXbWx0wCjS3IN6NP/kfZ6/FwAKs7ZLCaB2k89bVR7oV
         O34A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=OZ1kDdTgN4wvLaPyCNbaBt4ZZAol0O1Af0n8ppQn/zU=;
        b=AutW6FL7kYyt1HgoFdowTJ4NaoLQJM3h8PEbc2GNLNGvYySVnERp1Gpv7ZAdBwHsDT
         aGdSB6mE8MkM5SCO14/RgwHAVv8rVLLzmZTAZY4GhhITUXeOCfM4op+MwC10T+3kmu0B
         osDztF+LZaP/rOBuxjUCTKhtV9da1wVv7aX5N73ppIn8V787bDJo05JX6XVof/m5pyiS
         iy/U0w84sN9so0le85lLHCAgUuC/+x7OfPJDoFZDFigFOyJjF8qGm2ZGlRsqKJgri3jC
         GUaBK3BASmzIPwAMMoP2Jp5gKWQ1jDl8heSg84BigbbP4+wk+CxIWuloaJ/IF7JZZU/6
         DlUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=SlyLnGBX;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q20si17562800pjp.24.2019.06.05.08.33.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 08:33:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=SlyLnGBX;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x55FUgFC039576;
	Wed, 5 Jun 2019 15:32:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=OZ1kDdTgN4wvLaPyCNbaBt4ZZAol0O1Af0n8ppQn/zU=;
 b=SlyLnGBXh3+Z/kVO/l6MtBnlb/hL9gKjC3CliEvgg9yYkyraDbOZv+xE+6/BydM6W02j
 8MXGwY8TYLi9z4jDghyFakXxGwlgaO/5kJ8bM0ljtmVE5iNv+yMVB/XAftSP04CwlxCC
 8m65gs3Ntc74ibhVNhve9meTwuBtHY8lwgRfnhEe978fwYosu2Eak5nBKaQbFqjbwddC
 +49tb1GrtXJ0gZJ8J362dwJw6BoCfGDK+bw0HVfdk2ZHuWWbThgQUwUoO1llvAB8Mjys
 D6PbUMcQj+WDcrplRbfyv4etIOFyiBLU7D4hfEO6EoR6Ovny60qaCVxHjA7EUq4pg0fV Pg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2sugstkees-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 05 Jun 2019 15:32:44 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x55FWgi1133961;
	Wed, 5 Jun 2019 15:32:43 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2swnhc6sy2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 05 Jun 2019 15:32:43 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x55FWSXg025273;
	Wed, 5 Jun 2019 15:32:30 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 05 Jun 2019 08:32:28 -0700
Date: Wed, 5 Jun 2019 11:32:29 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Tejun Heo <tj@kernel.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, hannes@cmpxchg.org,
        jiangshanlai@gmail.com, lizefan@huawei.com, bsd@redhat.com,
        dan.j.williams@intel.com, dave.hansen@intel.com, juri.lelli@redhat.com,
        mhocko@kernel.org, peterz@infradead.org, steven.sistare@oracle.com,
        tglx@linutronix.de, tom.hromatka@oracle.com, vdavydov.dev@gmail.com,
        cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, shakeelb@google.com
Subject: Re: [RFC v2 0/5] cgroup-aware unbound workqueues
Message-ID: <20190605153229.nvxr6j7tdzffwkgj@ca-dmjordan1.us.oracle.com>
References: <20190605133650.28545-1-daniel.m.jordan@oracle.com>
 <20190605135319.GK374014@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605135319.GK374014@devbig004.ftw2.facebook.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9279 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906050097
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9279 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906050096
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Tejun,

On Wed, Jun 05, 2019 at 06:53:19AM -0700, Tejun Heo wrote:
> On Wed, Jun 05, 2019 at 09:36:45AM -0400, Daniel Jordan wrote:
> > My use case for this work is kernel multithreading, the series formerly known
> > as ktask[2] that I'm now trying to combine with padata according to feedback
> > from the last post.  Helper threads in a multithreaded job may consume lots of
> > resources that aren't properly accounted to the cgroup of the task that started
> > the job.
> 
> Can you please go into more details on the use cases?

Sure, quoting from the last ktask post:

  A single CPU can spend an excessive amount of time in the kernel operating
  on large amounts of data.  Often these situations arise during initialization-
  and destruction-related tasks, where the data involved scales with system size.
  These long-running jobs can slow startup and shutdown of applications and the
  system itself while extra CPUs sit idle.
      
  To ensure that applications and the kernel continue to perform well as core
  counts and memory sizes increase, harness these idle CPUs to complete such jobs
  more quickly.
      
  ktask is a generic framework for parallelizing CPU-intensive work in the
  kernel.  The API is generic enough to add concurrency to many different kinds
  of tasks--for example, zeroing a range of pages or evicting a list of
  inodes--and aims to save its clients the trouble of splitting up the work,
  choosing the number of threads to use, maintaining an efficient concurrency
  level, starting these threads, and load balancing the work between them.

So far the users of the framework primarily consume CPU and memory.

> For memory and io, we're generally going for remote charging, where a
> kthread explicitly says who the specific io or allocation is for,
> combined with selective back-charging, where the resource is charged
> and consumed unconditionally even if that would put the usage above
> the current limits temporarily.  From what I've been seeing recently,
> combination of the two give us really good control quality without
> being too invasive across the stack.

Yes, for memory I actually use remote charging.  In patch 3 the worker's
current->active_memcg field is changed to match that of the cgroup associated
with the work.

Cc Shakeel, since we're talking about it.

> CPU doesn't have a backcharging mechanism yet and depending on the use
> case, we *might* need to put kthreads in different cgroups.  However,
> such use cases might not be that abundant and there may be gotaches
> which require them to be force-executed and back-charged (e.g. fs
> compression from global reclaim).

The CPU-intensiveness of these works is one of the reasons for actually putting
the workers through the migration path.  I don't know of a way to get the
workers to respect the cpu controller (and even cpuset for that matter) without
doing that.

Thanks for the quick feedback.

Daniel

