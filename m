Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2EE2C04A6B
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 03:10:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DF9E206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 03:10:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="qPZyJEvF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DF9E206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 122D56B0005; Mon,  6 May 2019 23:10:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0ACC56B0006; Mon,  6 May 2019 23:10:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB7226B0007; Mon,  6 May 2019 23:10:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7D036B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 23:10:38 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id b63so10500576itc.0
        for <linux-mm@kvack.org>; Mon, 06 May 2019 20:10:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Sa+cOJtJx0K5ZUTspQzVWRaHsaM72rSdt2S6cah8KqE=;
        b=lXIxt7P/BgyMAiALmAeZTrVAFWG9JJ0LqlLYjVBS9IZt112FH+eW/1uFzbjrv2Js0D
         lxfo5c19Q//VBYwsP/uXaa85NNgAcIHryrIKKXsJVDgWFm4VtH9yscnoGwdzg8fb0jT1
         Gy3zZepaDUe3Ke6Wvn8QD6pmFQqfgMi30tqddD4bw4jY4Uae6LsgSgIHFNav5yUQpp21
         nu3NVJ3pvm9YNVEuG1MFwaACGergYL+GEDU2KOzuYIoFp8kpp/yh7EOrv4WaVuPLXLFb
         fYqij7TfNtqU3S74MAe1tL60FreoCSIBpqrB+RqjYzXh1jPxNt8UluJf8BIUG8JMhLP2
         CG0g==
X-Gm-Message-State: APjAAAXmaWhlMPMNXXEVJCxlpG1fkh7fhqu34dWuwtMCd2MywF+yK18M
	V3iArNsS/ixjE0iItT4I8/NM5OB083KJedGdTi+jVWuXuZHbvIZAwcjaU7gzNfm1mYVIVaL3YRd
	ZSgDR0BtBOEy0uVNbchqLwzLLfet2jBx8fXEmjO23SuyWLUUtx4N8xwVsrXX/uh6Rcg==
X-Received: by 2002:a24:1c9:: with SMTP id 192mr21316774itk.60.1557198638550;
        Mon, 06 May 2019 20:10:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysBVkOr3NQxmpU8AuR0meXzE4+tSQVgmzBSOelu4EANwb3Dim34pj+C2jslomvwolo9MlC
X-Received: by 2002:a24:1c9:: with SMTP id 192mr21316740itk.60.1557198637794;
        Mon, 06 May 2019 20:10:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557198637; cv=none;
        d=google.com; s=arc-20160816;
        b=ySPHxgTnZ/G1QkLhVqDZ/ebGeZHPPJJm1MsOay9T+8g6s+27aAa1VJdJFV4laS4J8W
         suTEC3uUnKOAnddsbI5kAOKVSU15OV85X+oCMAcBG8/wSmHCajG7Xg3sY8lJndm84br2
         Y89joJlCkBy4VA2qJABJvPhfC9GKQjjfbbotWP3lSWANfxOS66n9LPBKdiekyDgX70/G
         5k1xfBDWNsBZFut7Xpgja9QUe7rJkwd/hKKqoSWTjBXbdSQcsYiGQas+j0Syck8gxCSp
         8VSfceNjD4HktJERv88XZ5ZfG2/jYbNfAksoiQuTdBbqRZd41b1plxgRy9ig8p1E2RI7
         jVOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Sa+cOJtJx0K5ZUTspQzVWRaHsaM72rSdt2S6cah8KqE=;
        b=m2jMCxLM8tMVaDoJUcUMzEOcjFz8GZLZ1qT1l2uJN40PKdccklhY2wSbjPN8mU04il
         MEYD4KhTt7yB2H9PR7qAuRIeaZLpud9DjxBtPcNkhhmLaeo4NylhmHDy36QQ3ry4cpQ6
         Q22Rd/qWPb5xIA862nF5qoIt3nlYgDQEk3GHuvGu9FUfZQIkR6EEH/yg7tAXxIT/dKYv
         /UutDd7DDCwUhCa7E/dcqy0xrHjvytrtMh6Vop1tgXn/5UdRphWbdsBIp9Ry59AeMubp
         /hZahqe7AWM6NQUW63D0WgJJ9xUIKSi9JyuMUOd9QqA64GwoafdOi0aQu4Zih3x8V1IG
         wd6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qPZyJEvF;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x196si9155093itb.17.2019.05.06.20.10.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 20:10:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qPZyJEvF;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4738uBG073685;
	Tue, 7 May 2019 03:10:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=Sa+cOJtJx0K5ZUTspQzVWRaHsaM72rSdt2S6cah8KqE=;
 b=qPZyJEvFwNkpPyu498f2W9cJG3cwo3YzJHpJuUkM4qNXyo0XdOQ9+2nBbN/aGX6t9k1U
 wHeLMsyAc1cE1N+uTUZnW/Iyw54XcN6jiBEm0jAv/cQLsff/0gr7PXOraCv+40U7PJWD
 R/9Fkc7FCq8Z9qdqoT6DH83+M46p62s329nBRNiN69nX2PhdQ2dCEdLOHXuJEXE0hF3p
 GLmiF0TCkWeY+nB04qmMqqK6u9J8x9umk/1yUcK+AKwwac5NjQpKLneDVrp7r8yIEyQW
 1GH7C9dCib2+z68OBCyWe+2gDeM+qGNzSX60HntCF330GSmcl5vC0+RL01+Q5LaL4Rk4 Og== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2s94b0j77m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 07 May 2019 03:10:22 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x473A5lN185360;
	Tue, 7 May 2019 03:10:22 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2s94af7xxr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 07 May 2019 03:10:22 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x473A6JU021461;
	Tue, 7 May 2019 03:10:07 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 06 May 2019 20:10:06 -0700
Date: Mon, 6 May 2019 23:09:57 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        Alan Tull <atull@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>,
        Alex Williamson <alex.williamson@redhat.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Christoph Lameter <cl@linux.com>,
        Christophe Leroy <christophe.leroy@c-s.fr>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Mark Rutland <mark.rutland@arm.com>,
        Michael Ellerman <mpe@ellerman.id.au>, Moritz Fischer <mdf@kernel.org>,
        Paul Mackerras <paulus@ozlabs.org>,
        Steve Sistare <steven.sistare@oracle.com>, Wu Hao <hao.wu@intel.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
        "kvm-ppc@vger.kernel.org" <kvm-ppc@vger.kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "linux-fpga@vger.kernel.org" <linux-fpga@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm: add account_locked_vm utility function
Message-ID: <20190507030957.3qp7yflco6ckcj5q@ca-dmjordan1.us.oracle.com>
References: <20190503201629.20512-1-daniel.m.jordan@oracle.com>
 <20190503232818.GA5182@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190503232818.GA5182@mellanox.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9249 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905070018
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9249 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905070018
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 03, 2019 at 11:28:22PM +0000, Jason Gunthorpe wrote:
> On Fri, May 03, 2019 at 01:16:30PM -0700, Daniel Jordan wrote:
> > Andrew, this one patch replaces these six from [1]:
> > 
> >     mm-change-locked_vms-type-from-unsigned-long-to-atomic64_t.patch
> >     vfio-type1-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
> >     vfio-spapr_tce-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
> >     fpga-dlf-afu-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
> >     kvm-book3s-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
> >     powerpc-mmu-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
> > 
> > That series converts locked_vm to an atomic, but on closer inspection causes at
> > least one accounting race in mremap, and fixing it just for this type
> > conversion came with too much ugly in the core mm to justify, especially when
> > the right long-term fix is making these drivers use pinned_vm instead.
> 
> Did we ever decide what to do here? Should all these drivers be
> switched to pinned_vm anyhow?

Well, there were the concerns about switching in [1].  Alex, is there an
example of an application or library that would break or be exploitable?  If
there were particular worries (qemu for vfio type1, for example), perhaps some
coordinated changes across the kernel and userspace would be possible,
especially given the amount of effort it's likely going to take to get the
locked_vm/pinned_vm accounting sorted out.

[1] https://lore.kernel.org/linux-mm/20190213130330.76ef1987@w520.home/

