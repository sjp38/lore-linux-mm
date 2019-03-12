Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9CEAC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 13:53:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91CA8214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 13:53:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91CA8214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 256F98E0003; Tue, 12 Mar 2019 09:53:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 206BB8E0002; Tue, 12 Mar 2019 09:53:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F7FC8E0003; Tue, 12 Mar 2019 09:53:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF1FD8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:53:32 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id o135so1990219qke.11
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 06:53:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=Bafzwra03unlq9sNsDcu+GafVaU7H8EP+iRO+JOu7mw=;
        b=SkRJ/9QpzEbHldU4tvsG5/w/Aj/Xk2ChIosZJgNqFvDqKP0oBgrdUecUrJKw3AB5jj
         fQyc2ZJWc4f2csyHZHjGUUgqh6eQ6TuyAhgSCg7ZYZTmTsnwY9wOU/3maFmOguXSf6kf
         VWkMROcj414dDphtBR+YAZ6IFmT+ncY9Wf58OQcborrW/P66e4g/fbbh6J1pITXLE4i3
         QRwMrIF/2eys4UoU7fyNsv92J4q+bMrIew/GgivTe51jV5In7X3WZAehMWDklPokqGQR
         gQB+2UyLhMXecNrjfdLDCfmxJVrH5gG6PV3hBQsiJ3js81YcPLzcdbZcWd09LD23nCwN
         HKiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXHvAc4r0kggQ/l24FB26LxN9SpugjnTkC/lpPJ3dEMD8gKq4xw
	8QAlBrBQsbyy15yxWI6F599ccVnQ7I7OJiWH3ojYHtrmRrZhgV49D95q/WfjR41gJ1LLRduo8R2
	EBhjHaDxp6ZvGLdYJ3tWC3vr7pFfqMCFIV5t8v6hW4ukZsveTxxcJvH89CN7wyrvqEQ==
X-Received: by 2002:ac8:2b6f:: with SMTP id 44mr30021066qtv.366.1552398812713;
        Tue, 12 Mar 2019 06:53:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGk0D7H0zH4L1KHurL0lu7q3NvGt5dtpR5C2KW8XPnAvN4gPUSyk4TkbDOT2Mh1ij1sm1y
X-Received: by 2002:ac8:2b6f:: with SMTP id 44mr30021026qtv.366.1552398812085;
        Tue, 12 Mar 2019 06:53:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552398812; cv=none;
        d=google.com; s=arc-20160816;
        b=UeIqSKSKd21tZeOlhblZw4Kwt8dQf8okIkjRQUNreCXA6dHXZj2H07PHoHrI1hrgOS
         sgRWr2OuOZnLVImiuXC0bi3C9sisqyxa7viTgQIn5h+7zB4ZIEQ70VqkIz5ihDcy2QiW
         RVq7XZ9qpGQNKJjah4keDJQmeH8EhmFvC05Rtkyp4DOUgoLTWSIyePDBnVVFumeSLcvi
         RX48RyyWul55qoC/ySBuMK7v142Deewl6EHGpWdnAHWc/j7SfGWMxrnbk1mJruQ/usSM
         sqD6OTaK3PFEpvc7gN/vYZZewYf2v1UXPdiFxVXetLdWkgJoev/eXcGEETMh9V5+QwPQ
         gPEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=Bafzwra03unlq9sNsDcu+GafVaU7H8EP+iRO+JOu7mw=;
        b=0GNZpYs4yHHxgEBL4rw68Nx/W49K6573HR7rBYkH4KPotC8WAAeoblXSRXgRZ+WWKS
         lhBFwtkf0aXvieyGokq3HpZ/fn8IJUKW5pM42KU409uu9dZHcQtSbr47kTXG7rDHEGCG
         dxfavmLMrDOwxKtX/m3lKuSxZ8OZ+XaEJAL+aGtVEZbK4XilVNftS4Owry25svAbtMPI
         CGpHBcQ+F257DREaiwqQYsUocUwDT5oJiBsIsp+yuXwyXki4zPkMI928EHj/xbdpkSUu
         eFlsEgYpGBkAC4uLL9EH8wGhdm29/QwA3fri1p6EgriOYmk3Lt/l7L8QLfFSIUrryxmd
         bOgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f129si1355251qkb.56.2019.03.12.06.53.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 06:53:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2CDYjno073916
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:53:31 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2r6dejjt90-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:53:31 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 12 Mar 2019 13:53:28 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 12 Mar 2019 13:53:21 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2CDrKpf31588396
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 12 Mar 2019 13:53:20 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 72642A4059;
	Tue, 12 Mar 2019 13:53:20 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C2510A4053;
	Tue, 12 Mar 2019 13:53:18 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 12 Mar 2019 13:53:18 +0000 (GMT)
Date: Tue, 12 Mar 2019 15:53:17 +0200
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
Subject: Re: [PATCH 1/3] userfaultfd/sysctl: introduce
 unprivileged_userfaultfd
References: <20190311093701.15734-1-peterx@redhat.com>
 <20190311093701.15734-2-peterx@redhat.com>
 <20190312065830.GB9497@rapoport-lnx>
 <20190312122633.GE14108@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312122633.GE14108@xz-x1>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19031213-0008-0000-0000-000002CBB02B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19031213-0009-0000-0000-00002237D009
Message-Id: <20190312135316.GA22990@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-12_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=863 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903120097
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 08:26:33PM +0800, Peter Xu wrote:
> On Tue, Mar 12, 2019 at 08:58:30AM +0200, Mike Rapoport wrote:
> 
> [...]
> 
> > > +config USERFAULTFD_UNPRIVILEGED_DEFAULT
> > > +        string "Default behavior for unprivileged userfault syscalls"
> > > +        depends on USERFAULTFD
> > > +        default "disabled"
> > > +        help
> > > +          Set this to "enabled" to allow userfaultfd syscalls from
> > > +          unprivileged users.  Set this to "disabled" to forbid
> > > +          userfaultfd syscalls from unprivileged users.  Set this to
> > > +          "kvm" to forbid unpriviledged users but still allow users
> > > +          who had enough permission to open /dev/kvm.
> > 
> > I'd phrase it a bit differently:
> > 
> > This option controls privilege level required to execute userfaultfd
>                       ^
>                       +---- add " the default"?
> 
> > system call.
> > 
> > Set this to "enabled" to allow userfaultfd system call from unprivileged
> > users. 
> > Set this to "disabled" to allow userfaultfd system call only for users who
> > have ptrace capability.
> > Set this to "kvm" to restrict userfaultfd system call usage to users with
>                                                                       ^
>                          add " who have ptrace capability, or" -------+
> 
> > permissions to open "/dev/kvm".
> 
> I think your version is better than mine, but I'd like to confirm
> about above two extra changes before I squash them into the patch. :)

I like your changes.
 
> Thanks!
> 
> -- 
> Peter Xu
> 

-- 
Sincerely yours,
Mike.

