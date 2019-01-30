Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5D34C282D5
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:13:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92C7B20855
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:13:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92C7B20855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54B2D8E0004; Wed, 30 Jan 2019 03:13:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F9D58E0001; Wed, 30 Jan 2019 03:13:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40F558E0004; Wed, 30 Jan 2019 03:13:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 194958E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:13:51 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u20so27807515qtk.6
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 00:13:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=8WIKT+ka1R019dSa7UZdKNVJ1Tifswcu4yPYK14qpFk=;
        b=LTZMTiN/zM2yiUwrtEQmYAPxeNRKv6n/hee6lfi+guqxQNT8ewvyjkVLmsw1Q/Zvsi
         Jy0R4uB5wbPGMUQBsGMAkIqVcaKO3ulMwc3DQMG3F+clbqkTCVlRpkhskuuh5+nSitSX
         VhEtCcl0dBrw01rhdUeumXNZh1ZrIIIXZRGONugFgdfsmiq2EtYbe5slyZwS5OxC6dMJ
         2Rb37GYsxLzht6zArJvnL6PP+4Jd1nBoda2aKSSJA1+l7Wi/NoeLxEnwk8n6EHYOUAnU
         dg3SBPrId4hyBhEPbyIFjNn6rGgRUjY+LGwINxKb1Mp6c8TU2+uCjxKjp7atIGC9cdDG
         3n2g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukeX1pLTDjTGBMUnsk3jpzf4se/ydlAtoh8XKC9rjMTjdZTpF0yJ
	gHcDQQLnYyzV36UUMqg/8vHI2avlSdLFYvMgEIpcFC/P78mutn3zcrkjZInLaahYvwJzFXE1e0E
	ZahHKP4h0CpSfKFUrm7S6ZJ6Gur8V7EcdMviw9yobOOt5UE0WuqTM9pYYuic+G7mOCQ==
X-Received: by 2002:aed:2ae3:: with SMTP id t90mr28830956qtd.19.1548836030844;
        Wed, 30 Jan 2019 00:13:50 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7Qopkypx3g6dmPUdqTkmuoAMeBISXCnklcCeAHoTIlTgnfNP1HaNcNqR3Sm1xH+p4W0Sab
X-Received: by 2002:aed:2ae3:: with SMTP id t90mr28830913qtd.19.1548836029703;
        Wed, 30 Jan 2019 00:13:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548836029; cv=none;
        d=google.com; s=arc-20160816;
        b=r5uIQT89rTfn0WgbQlgL+DdsBj5yJNFi/IempuZPECroMmH0Wgh0p9x6Kjrs9jcaVV
         /sA8TC9BzMr1zbkG5yctjlJOrSuY1mXqsudjJXWqUnY6mmx331IJugAke3eUfouKuQuC
         uqFL3ic85hBLq4r4mGs9qCCKYlTZnt2PQ+6zVtXW9KJx7fEu1Up1D+FoHl6Rim1f8uGf
         TzhS1pteNCf+JZW/gZyd03MqzbWdnpij6JxlXDP5IiDSEvqr03jNDWPKx70tLQ4Uid5G
         YzynbDTkrMQJl3kx8litm4WWwBh42hG4uHTlyiWqhYj5RY59YxiGr1KZ6Jv1nXAdJTIc
         ph9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=8WIKT+ka1R019dSa7UZdKNVJ1Tifswcu4yPYK14qpFk=;
        b=SVLgZs83LuU6UrBxRsx7KyT4Z7NxeRZkhFdXiApm6uyH1GSkPrpyFr0fvoG6hS6prb
         U9AMdjzQ7Xs9Ll9GDXvyIRP2lEpybElM5WeWNHYpj1iabDj7VwqrRI/2cE6TN7w4KSWp
         NEZqqG7spZ0JKx2+V1SB3AHJfJrzieTblxhs44mcFFSHibWimzX9xR4jtKzIKntPc9FP
         arIRhXBFCyCl+pjwTF4Z0Go/aAIA/SgVUde44eyY+FMtnEZ6k6+14KGqymfDr5E0zHBW
         qJfuxizzzqQC42gHOfjj9g2D7ajZKAl2eDtkBVmXj74JItzr7SKVMu7SD6J0l8UHu9p3
         2c0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y47si566658qtb.175.2019.01.30.00.13.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 00:13:49 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0U89gD1044904
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:13:49 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qb6e0mprt-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:13:48 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 30 Jan 2019 08:13:44 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 30 Jan 2019 08:13:40 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0U8DdBG57606364
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 30 Jan 2019 08:13:39 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 38E904C040;
	Wed, 30 Jan 2019 08:13:39 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2C9724C046;
	Wed, 30 Jan 2019 08:13:38 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.107])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 30 Jan 2019 08:13:38 +0000 (GMT)
Date: Wed, 30 Jan 2019 10:13:36 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Peter Xu <peterx@redhat.com>,
        Blake Caldwell <blake.caldwell@colorado.edu>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
        Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>,
        Andrei Vagin <avagin@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>
Subject: [LSF/MM TOPIC]: userfaultfd (was: [LSF/MM TOPIC] NUMA remote THP vs
 NUMA local non-THP under MADV_HUGEPAGE)
References: <20190129234058.GH31695@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129234058.GH31695@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19013008-0020-0000-0000-0000030E29CD
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013008-0021-0000-0000-0000215F2B77
Message-Id: <20190130081336.GC17937@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-30_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901300064
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

(changed the subject and added CRIU folks)

On Tue, Jan 29, 2019 at 06:40:58PM -0500, Andrea Arcangeli wrote:
> Hello,
> 
> --
> 
> In addition to the above "NUMA remote THP vs NUMA local non-THP
> tradeoff" topic, there are other developments in "userfaultfd" land that
> are approaching merge readiness and that would be possible to provide a
> short overview about:
> 
> - Peter Xu made significant progress in finalizing the userfaultfd-WP
>   support over the last few months. That feature was planned from the
>   start and it will allow userland to do some new things that weren't
>   possible to achieve before. In addition to synchronously blocking
>   write faults to be resolved by an userland manager, it has also the
>   ability to obsolete the softdirty feature, because it can provide
>   the same information, but with O(1) complexity (as opposed of the
>   current softdirty O(N) complexity) similarly to what the Page
>   Modification Logging (PML) does in hardware for EPT write accesses.
 
We (CRIU) have some concerns about obsoleting soft-dirty in favor of
uffd-wp. If there are other soft-dirty users these concerns would be
relevant to them as well.

With soft-dirty we collect the information about the changed memory every
pre-dump iteration in the following manner:
* freeze the tasks
* find entries in /proc/pid/pagemap with SOFT_DIRTY set
* unfreeze the tasks
* dump the modified pages to disk/remote host

While we do need to traverse the /proc/pid/pagemap to identify dirty pages,
in between the pre-dump iterations and during the actual memory dump the
tasks are running freely.

If we are to switch to uffd-wp, every write by the snapshotted/migrated
task will incur latency of uffd-wp processing by the monitor.

We'd need to see how this affects overall slowdown of the workload under
migration before moving forward with obsoleting soft-dirty.

> - Blake Caldwell maintained the UFFDIO_REMAP support to atomically
>   remove memory from a mapping with userfaultfd (which can't be done
>   with a copy as in UFFDIO_COPY and it requires a slow TLB flush to be
>   safe) as an alternative to host swapping (which of course also
>   requires a TLB flush for similar reasons). Notably UFFDIO_REMAP was
>   rightfully naked early on and quickly replaced by UFFDIO_COPY which
>   is more optimal to add memory to a mapping is small chunks, but we
>   can't remove memory with UFFDIO_COPY and UFFDIO_REMAP should be as
>   efficient as it gets when it comes to removing memory from a
>   mapping.

If we are to discuss userfaultfd, I'd like also to bring the subject of COW
mappings.
The pages populated with UFFDIO_COPY cannot be COW-shared between related
processes which unnecessarily increases memory footprint of a migrated
process tree.
I've posted a patch [1] a (real) while ago, but nobody reacted and I've put
this aside.
Maybe it's time to discuss it again :)

> Thank you,
> Andrea
> 

[1] https://lwn.net/ml/linux-api/20180328101729.GB1743%40rapoport-lnx/

-- 
Sincerely yours,
Mike.

