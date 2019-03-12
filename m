Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B16CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 07:02:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14E98214AF
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 07:02:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14E98214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C1C18E0003; Tue, 12 Mar 2019 03:02:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 871F08E0002; Tue, 12 Mar 2019 03:02:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 739858E0003; Tue, 12 Mar 2019 03:02:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 484728E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 03:02:02 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 207so1416940qkf.9
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 00:02:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=CShsMBlxXfY535+SrphUvOicpkh/PZyiijB0eVXHwpM=;
        b=II1R+ISH0P8RuTkZOj0OdDG5x3C35Lh2nE6WpfLwuTuZX/88yih0nzKGR9Mcnej6xT
         1zqH059NIB7UefXmJHamEHvBOI4rwMK04oZPvmfEOE713ZoVv48H/MsiaUEDnlT3LdnS
         nVDfFCXlmHbW3nTkdk4WBWTqLelPwurMvZOmhJywxmNrEnI3JxQYZ62xFv2Lev7we0EW
         klXKjf2oZKfgXKWuuUVdMPu/qmBs6JKjOWDsl9RQ6ooD++qdwLVLUjCIykD3YVBThNoh
         +zyX5qWx2JiZZu8+MX2iyruIv37jd0z4WW0fF06nIES9yaGr8xatJkloKSAnUv0Bp1wA
         bEbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVPvrVCl1WqeJj0HBbzdnrpSnjwJTq9+saWRBo5s9XKELrWpCeb
	C9qCnDD/jWqxb4W2dowbVoPGGIuxtyv/NiUnEHlbehLXS8loFNq7hCKUc/k/sWvH+S0qcBM6ZWV
	xqm1doQe4fAI0C7FWyleXNdVlhw1CPo89dq1t30KCfvi8Q01u6wlFastX5trMKiRTGA==
X-Received: by 2002:ad4:438b:: with SMTP id s11mr9091175qvr.124.1552374122075;
        Tue, 12 Mar 2019 00:02:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0827fyAP1Ll9y4Cb4tnWiXVoGbdCfsp2nGPTjfkTtk467mZIqsPPgcHNB1YjKqRDWgppK
X-Received: by 2002:ad4:438b:: with SMTP id s11mr9091143qvr.124.1552374121313;
        Tue, 12 Mar 2019 00:02:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552374121; cv=none;
        d=google.com; s=arc-20160816;
        b=ZH36QOGG5EkLJ9phUTuAsMTp8Attw2r560bseRUP65LbdtRk2gYYX5s4rvMgVKAiZk
         sdYAmDV52+bF5nyd9iantEmxb9hSdrk1eO4D39S+WGEnBoR9pMWUdDin/ZHeSW2h4wau
         TyJmgp4bNm2LVABwyZgSCSCi1N3M6D01BR3ph66i0AfW8Kak6MnOiS+2/gPWRycurgNZ
         mnVDLDfFrejRLi4uM4VDjyKJ4ABOijPNUpfakU4yhv+nR0MrIQw+XzwCrrMdBit8N3Ko
         nkD8Frp/oy84pAwKEginriukNjNqmKkjqNWcZiRI84loes3wVv1/20l4pxZyKsXPK63H
         37gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=CShsMBlxXfY535+SrphUvOicpkh/PZyiijB0eVXHwpM=;
        b=0XEicKAPXdXvAKaPioXMVp0lou9tPaKPhVMI8P28yXCHzLr9mX28EEVshbvUpFumZU
         HcoMRKDb3ew2TipKl9+mnIQQ8imoWaEsnsl6FeijyYbYdUjAmBq235HLPgvIXxaSRwxA
         nVSTXvWI2NxfWnt/ipzxlO3Jvj7q4VukH3HRUzIG1PbZtU3fcAay5Rrmd5dPnoUtoReN
         sBSUHYki+MQLX3p1EYsMgUXj4FIpLKpj6uAskLAgGw08H1X6LioIVe2Fx4API1ouiUjn
         tX6F0tFZZBzv354Mwy0uibWGqb1vYp6ANQGGjwBXLaZ3c/kJc0huYFEKcD4dd6/9GnfK
         NLpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z22si3053776qtj.293.2019.03.12.00.02.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 00:02:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2C6tqJ5098498
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 03:02:00 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2r66q04578-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 03:02:00 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 12 Mar 2019 07:01:58 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 12 Mar 2019 07:01:51 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2C71oPe55771332
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Mar 2019 07:01:50 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C76D34C194;
	Tue, 12 Mar 2019 07:01:50 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 237144C191;
	Tue, 12 Mar 2019 07:01:49 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 12 Mar 2019 07:01:49 +0000 (GMT)
Date: Tue, 12 Mar 2019 09:01:47 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>,
        Hugh Dickins <hughd@google.com>, Luis Chamberlain <mcgrof@kernel.org>,
        Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
        Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
        Marty McFadden <mcfadden8@llnl.gov>, Maya Gokhale <gokhale2@llnl.gov>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        linux-fsdevel@vger.kernel.org,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
References: <20190311093701.15734-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311093701.15734-1-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19031207-0020-0000-0000-000003218323
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19031207-0021-0000-0000-00002173AB87
Message-Id: <20190312070147.GC9497@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-12_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=736 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903120052
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Peter,

On Mon, Mar 11, 2019 at 05:36:58PM +0800, Peter Xu wrote:
> Hi,
> 
> (The idea comes from Andrea, and following discussions with Mike and
>  other people)
> 
> This patchset introduces a new sysctl flag to allow the admin to
> forbid users from using userfaultfd:
> 
>   $ cat /proc/sys/vm/unprivileged_userfaultfd
>   [disabled] enabled kvm
> 
>   - When set to "disabled", all unprivileged users are forbidden to
>     use userfaultfd syscalls.
> 
>   - When set to "enabled", all users are allowed to use userfaultfd
>     syscalls.
> 
>   - When set to "kvm", all unprivileged users are forbidden to use the
>     userfaultfd syscalls, except the user who has permission to open
>     /dev/kvm.
> 
> This new flag can add one more layer of security to reduce the attack
> surface of the kernel by abusing userfaultfd.  Here we grant the
> thread userfaultfd permission by checking against CAP_SYS_PTRACE
> capability.  By default, the value is "disabled" which is the most
> strict policy.  Distributions can have their own perferred value.
> 
> The "kvm" entry is a bit special here only to make sure that existing
> users like QEMU/KVM won't break by this newly introduced flag.  What
> we need to do is simply set the "unprivileged_userfaultfd" flag to
> "kvm" here to automatically grant userfaultfd permission for processes
> like QEMU/KVM without extra code to tweak these flags in the admin
> code.
> 
> Patch 1:  The interface patch to introduce the flag
> 
> Patch 2:  The KVM related changes to detect opening of /dev/kvm
> 
> Patch 3:  Apply the flag to userfaultfd syscalls
 
I'd appreciate to see "Patch 4: documentation update" ;-)
It'd be also great to update the man pages after this is merged.

Except for the comment to patch 1, feel free to add

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> All comments would be greatly welcomed.  Thanks,
> 
> Peter Xu (3):
>   userfaultfd/sysctl: introduce unprivileged_userfaultfd
>   kvm/mm: introduce MMF_USERFAULTFD_ALLOW flag
>   userfaultfd: apply unprivileged_userfaultfd check
> 
>  fs/userfaultfd.c               | 121 +++++++++++++++++++++++++++++++++
>  include/linux/sched/coredump.h |   1 +
>  include/linux/userfaultfd_k.h  |   5 ++
>  init/Kconfig                   |  11 +++
>  kernel/sysctl.c                |  11 +++
>  virt/kvm/kvm_main.c            |   7 ++
>  6 files changed, 156 insertions(+)
> 
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

