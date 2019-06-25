Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A280C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:03:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB98420883
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:03:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ksyT2XyN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB98420883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D2D16B0005; Tue, 25 Jun 2019 14:03:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 284F38E0003; Tue, 25 Jun 2019 14:03:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14B968E0002; Tue, 25 Jun 2019 14:03:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E7ADA6B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 14:03:56 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k13so20879744qkj.4
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 11:03:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=q3PQ3FdT4Cu9ZFxkmPMEB5w+ChSGz6mW1jtUBkoDAvw=;
        b=W3qnI7o6DjA0d6v095eoaCj5L3Lcx3yvYK5+742qncZI0Nxx8UfDkAgGGLcPevs9xX
         KVecspCQPvSULwez7ApV4tCSzEXzXVGBTxNeIzvqA3Xz+PIc5ABB2F8r5vr6JBXLyqC6
         mwTYz9nqrA9uSRSPN+SvH+mxTfm9XFdZ3fk9d4oITAV/ShnQWt9JoOlWkvGbupnzvM1R
         3bT9R1yRplCbeoPIl4q4PS56i0cEwGoksrmgMOhlmJ0ihkBrN+uQ0QHdWvvHjK/Y4zl4
         fmhrI6WvxSS0RYVyhj1z+EPx+ZvAHwMhQRKczlI+p+rS8NGw7nYcoHpuxdU/c2UbTvAv
         MLuQ==
X-Gm-Message-State: APjAAAU3IRHFqJtY1nrzkg8KxxIsKIANgBM07gGdndDvwg5CZN+jTNjS
	iWQlJyzmXUQmsXCHwbvrkes7A2h7WcXJAipO43E/y8gi2KXfIGNUJ5PdBjUlH8T9FjlD07UekNa
	+yeywbym84KIeoK1ql4p4mwBcAp/gPtK+uBqTaSHhOHgrKfq4d7QrWoK9sfJUG5l8ZQ==
X-Received: by 2002:a0c:8705:: with SMTP id 5mr8668177qvh.32.1561485836715;
        Tue, 25 Jun 2019 11:03:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwP1XgU5e3ZyaocBr6IQVxMeQb1qJYNWLguhlzebC8vZJGWH7LyqyeRgD3WxQkv3uTh2pBJ
X-Received: by 2002:a0c:8705:: with SMTP id 5mr8668104qvh.32.1561485835898;
        Tue, 25 Jun 2019 11:03:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561485835; cv=none;
        d=google.com; s=arc-20160816;
        b=ENK/0tBPuK1/LbumUHg9PyvWlUJ4N46uwmHJ0Rubuj6N1VHPQJVHjoLRdws0lCVbsW
         R/UuLgJKcqR6WF4MlEMfvT5VDOAUsCIK3qUsxqDhoLfRK0Mh39UTvSytGaz27N2DgrvP
         yguj9U+AGCtwwRjxm7Scc8wsEoDsFnuneYQRueBFKpu0zxNOv9YdrIrKuY9UV5gPtLKF
         7F+YzrJ6P9oaHqlhpMQbPcj48PxP5M5yhkIBZzbhLbKOOh764TfyZXxOYKpLi6D3RE81
         uEVNpRU+WaW2qYlin+08MoPvNckxcpggOb9qMc6HV43Xa6YY9Pm1jY6FfOZeNm8jSLZw
         WCLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=q3PQ3FdT4Cu9ZFxkmPMEB5w+ChSGz6mW1jtUBkoDAvw=;
        b=eySGFwmw1FFAAwPiYVdxdaVd/qgL0GY9BiwRTQamXMHtmIIwWk8AqFsqprqrgwH41D
         SnezGCGicmoh1c02djM9Sy6R9LgnCRp4I56Ns5U+yjCix0Y+0i20jtm4Rq0BLZZEvegH
         B72rhjKwSJXO83EWckUmPP/XaXYrSFPDOqBzsQssd/R1CVF8IkbnPqjq5p4/A9vIIdSI
         x8N8uQwfqAUIN/EdhfZpI+Sblj9NQ5+X89WExjhKjtvfX5T99xoOFysrVtjer498JiNI
         SeOOGJWdxAnBduMuTxY8GRDICMVRFTMj7g43PrgCTtYej7jIs+TuKRKSr34HQOu3jqe3
         y7iQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ksyT2XyN;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d53si10345839qvd.148.2019.06.25.11.03.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 11:03:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ksyT2XyN;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5PHwd8B149230;
	Tue, 25 Jun 2019 18:03:42 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=q3PQ3FdT4Cu9ZFxkmPMEB5w+ChSGz6mW1jtUBkoDAvw=;
 b=ksyT2XyNq/sBFuNf0kcEOahW5dSfpRm2xoyvLHIl5Mejyeb4JLMflOsVy5quxvpN67j2
 IsKXQAf1HGSoM5FioAjK6ozKyUInygd/ml7l4zpRXtxh/UWz20oKY/FTMlcYaDZBA7N9
 MY/zMgGVdosxoetsazUmPfKqNstqSPWvasVhjypJJqeFcHhDaP62mxpCpMaNSfCtaBX3
 JdFoGt472fc1h8ZFinUmpgHsBMZcZBqagXk/T9NnnQ5VQ3pfbtpwxQaYR4yLbxZKG58n
 MOx1qf1doyupoPytNdwt2e/QYdozJOX4KCvtmdKWmiW/VFWoTbAzfyslOGA2S3jKu5TS Qg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2t9brt61nv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 25 Jun 2019 18:03:42 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5PI2jR6140649;
	Tue, 25 Jun 2019 18:03:41 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3020.oracle.com with ESMTP id 2t9p6ub7ds-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 25 Jun 2019 18:03:41 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5PI3fsX143158;
	Tue, 25 Jun 2019 18:03:41 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2t9p6ub7dj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 25 Jun 2019 18:03:41 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5PI3VCg025882;
	Tue, 25 Jun 2019 18:03:31 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 25 Jun 2019 11:03:31 -0700
Date: Tue, 25 Jun 2019 11:03:26 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        ard.biesheuvel@linaro.org, josef@toxicpanda.com, clm@fb.com,
        adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk, jack@suse.com,
        dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org,
        reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH v4 0/7] vfs: make immutable files actually immutable
Message-ID: <20190625180326.GC2230847@magnolia>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
 <20190625103631.GB30156@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625103631.GB30156@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9299 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=904 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906250136
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 03:36:31AM -0700, Christoph Hellwig wrote:
> On Fri, Jun 21, 2019 at 04:56:50PM -0700, Darrick J. Wong wrote:
> > Hi all,
> > 
> > The chattr(1) manpage has this to say about the immutable bit that
> > system administrators can set on files:
> > 
> > "A file with the 'i' attribute cannot be modified: it cannot be deleted
> > or renamed, no link can be created to this file, most of the file's
> > metadata can not be modified, and the file can not be opened in write
> > mode."
> > 
> > Given the clause about how the file 'cannot be modified', it is
> > surprising that programs holding writable file descriptors can continue
> > to write to and truncate files after the immutable flag has been set,
> > but they cannot call other things such as utimes, fallocate, unlink,
> > link, setxattr, or reflink.
> 
> I still think living code beats documentation.  And as far as I can
> tell the immutable bit never behaved as documented or implemented
> in this series on Linux, and it originated on Linux.

The behavior has never been consistent -- since the beginning you can
keep write()ing to a fd after the file becomes immutable, but you can't
ftruncate() it.  I would really like to make the behavior consistent.
Since the authors of nearly every new system call and ioctl since the
late 1990s have interpreted S_IMMUTABLE to mean "immutable takes effect
everywhere immediately" I resolved the inconsistency in favor of that
interpretation.

I asked Ted what he thought that that userspace having the ability to
continue writing to an immutable file, and he thought it was an
implementation bug that had been there for 25 years.  Even he thought
that immutable should take effect immediately everywhere.

> If you want  hard cut off style immutable flag it should really be a
> new API, but I don't really see the point.  It isn't like the usual
> workload is to set the flag on a file actively in use.

FWIW Ted also thought that since it's rare for admins to set +i on a
file actively in use we could just change it without forcing everyone
onto a new api.

--D

