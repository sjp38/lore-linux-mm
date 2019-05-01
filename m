Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BCA3C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 15:06:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CEC621670
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 15:06:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="QPg18rZz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CEC621670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98D406B0006; Wed,  1 May 2019 11:06:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9163F6B0008; Wed,  1 May 2019 11:06:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 790726B000A; Wed,  1 May 2019 11:06:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5286B0006
	for <linux-mm@kvack.org>; Wed,  1 May 2019 11:06:49 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j18so11142278pfi.20
        for <linux-mm@kvack.org>; Wed, 01 May 2019 08:06:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Q8eGFCnQ0LTZ5owUi28FCcA36LPqeTtkuqRUrAAOMqQ=;
        b=gXVWYIlEwxDYgQv6bmsgnDYWXbLLqFmjzA1EqjVIZHJYat4NuMOIZrqPvNJmyB3n/b
         VmGGPVkal45tvtyl2/Ivbcuc45HJv6Gjv/Rq720nLxkPBk5YDlSUN0jEJI1QyNGGeCyv
         iH81Un5pR0d81BRbXQRvF6l2UUqRBwb261WapWvraOnVMw1YxxVTlBcEzEAsUR4mmxF2
         NudORG08b8cboCeW0Nd0/vB4KvPbtXHaVCPV2kGYcOwPDRhp9DAYtdyiJqaxFH/lij59
         J9HOaFoiZRO3mkCFT6D7lSkEKqdgMNCWfGpjaKHVJ3u9ZDiBGXEyK3fZnXN40/fYZR8N
         ocQQ==
X-Gm-Message-State: APjAAAV6/VBEVd31w0fdVqoZQYCgsG3QLoFdB8XpCdwKKUz3OQUsPCA6
	UUs5K6nFdq8UjMWHNo2ZeOiGg0tEUOlzb5pMlZPOK5wtGEfI7bF7t0jiIZEqYRJ9wHbDJ7A83Ow
	GeCgP4Vu4+QZ34BMsQolExIg/9Z28xq9/UONrimrF8QV46w56sUtBQqcMdX6nKizaRQ==
X-Received: by 2002:a63:1301:: with SMTP id i1mr28490474pgl.226.1556723208898;
        Wed, 01 May 2019 08:06:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBoVUISSVngdzNdpYoMnqw6N6zoZDOcLcw+1Y4XY08+a4WB2I//WJrHn7V5F5vXh6/ySMZ
X-Received: by 2002:a63:1301:: with SMTP id i1mr28490388pgl.226.1556723207861;
        Wed, 01 May 2019 08:06:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556723207; cv=none;
        d=google.com; s=arc-20160816;
        b=drHp74/RXNYgwzjLXc5kT346ltGFtVcFYSpI4xf0v9dNP+0lOGvP6mxCgkIz57VFqH
         pnahLuiMXIhAW5dXDP++cV2guNbWDyzGPSZnOrafyedR5q8Z6+chIK1fC69WphnwXahu
         jx1LE/Kv7Qtg/xgd94bxBptxN9XkqyORNhCFLujVWnvZ4cwYDEcZeW9pfycm/4Qek149
         ITtoK5Y2B4J/u9oJ/cw4YIVPmGxVEQjvLvrkLAovZf10bPXxhONvo5u4thZqJ8JfN3cj
         fDCLe+fKcdSr4wHTNS8GpQfxAds11kO8cpS9fWWuofHYwEhz+5JkBKPMS3vrX75Kdq0i
         XDAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Q8eGFCnQ0LTZ5owUi28FCcA36LPqeTtkuqRUrAAOMqQ=;
        b=IVqUdW9THHy9ItiHVvMjQotHZxYgjXV3zjB8IXFVLDv74wdvLFwWugFRS5BxEVPgon
         Cg0NGDea/nUlR2WvXNTdMjtkDrNPv4r4YdoYs++Pg12UyK9UnNfGFyorsCKdhGu0FAqW
         t4O+kpPWVlZDKJoREUBGRdhcdp8k4rJS44uKIER+ionrZq8JZh6wjrkwKzcFnJr8mTZp
         U3shseZidh4I5OOKNaJqCCZgzAv74wJ0eHZp1iy4Xvv5ByJIcHxkaD/9gIP0EiZXpTXx
         gWcwy2wDfO7LMTOG+bRY56Je5wMHQALnJcS5kinNqycmflxkTWnf8DGMie+JYUERcQCv
         C0ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=QPg18rZz;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id a17si41386927pfn.95.2019.05.01.08.06.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 08:06:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=QPg18rZz;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x41ExMG3168304;
	Wed, 1 May 2019 15:06:42 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=Q8eGFCnQ0LTZ5owUi28FCcA36LPqeTtkuqRUrAAOMqQ=;
 b=QPg18rZz1fDX726lTOySzky3amPtJJUw6SD7G0DDF5/b/Q8BdfUVQdFCD+qjAme3MQBQ
 35uCtb22qCOLQsVnPL8Ne9MPtoTpPCoyJxKtSc2M2NvnV3p/QGMJl5AQPD1om2PPT0l1
 wLm3GwTRyF/HTKS8nMrL3+md+IPUgf4sv1xtXb74snMNqeqmo9A0IBTVc1hhot5M7bvX
 QIxWFgDF39qDaWsa89ROith7S4en1arnd4ozOqg+ZgtrVQnPjLiTjHkZHu7kk7ESdMLO
 qEqxPLDUG6Z7zFPwzHyIF4OVPK/7qpNOe1HQxzLTRhOmrT3XQK2AgEdjKaM0+A7ki+st yA== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2s6xhyb4wa-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 01 May 2019 15:06:41 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x41F535g143581;
	Wed, 1 May 2019 15:06:41 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2s6xhgj8bb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 01 May 2019 15:06:41 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x41F6cto020498;
	Wed, 1 May 2019 15:06:38 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 01 May 2019 08:06:38 -0700
Date: Wed, 1 May 2019 08:06:37 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>, cluster-devel@redhat.com,
        Christoph Hellwig <hch@lst.de>, Bob Peterson <rpeterso@redhat.com>,
        Jan Kara <jack@suse.cz>, Ross Lagerwall <ross.lagerwall@citrix.com>,
        Mark Syms <Mark.Syms@citrix.com>,
        Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v7 0/5] iomap and gfs2 fixes
Message-ID: <20190501150637.GG5217@magnolia>
References: <20190429220934.10415-1-agruenba@redhat.com>
 <20190430025028.GA5200@magnolia>
 <20190430212146.GL1454@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190430212146.GL1454@dread.disaster.area>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9243 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905010096
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9243 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905010096
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 07:21:46AM +1000, Dave Chinner wrote:
> On Mon, Apr 29, 2019 at 07:50:28PM -0700, Darrick J. Wong wrote:
> > On Tue, Apr 30, 2019 at 12:09:29AM +0200, Andreas Gruenbacher wrote:
> > > Here's another update of this patch queue, hopefully with all wrinkles
> > > ironed out now.
> > > 
> > > Darrick, I think Linus would be unhappy seeing the first four patches in
> > > the gfs2 tree; could you put them into the xfs tree instead like we did
> > > some time ago already?
> > 
> > Sure.  When I'm done reviewing them I'll put them in the iomap tree,
> > though, since we now have a separate one. :)
> 
> I'd just keep the iomap stuff in the xfs tree as a separate set of
> branches and merge them into the XFS for-next when composing it.
> That way it still gets plenty of test coverage from all the XFS
> devs and linux next without anyone having to think about.
> 
> You really only need to send separate pull requests for the iomap
> and XFS branches - IMO, there's no really need to have a complete
> new tree for it...

<nod> That was totally a braino on my part -- I put the patches in the
iomap *branch* since now we have a separate *branch*. :)

(and just merged that branch into for-next)

--D

> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

