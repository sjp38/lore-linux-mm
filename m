Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E429DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:04:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C80A2173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:04:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C80A2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 481248E0004; Tue, 26 Feb 2019 02:04:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42F868E0002; Tue, 26 Feb 2019 02:04:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 320B58E0004; Tue, 26 Feb 2019 02:04:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E4D1D8E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:04:38 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id g197so9790045pfb.15
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 23:04:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=bHKFuhTo34ZxCqOR1S7cithEyI6p/bS5m3EuXPilXxU=;
        b=Bxs30sAykhBboC6dFqBo+GaioWydDnylYf2bvg/4gcfkdr7S2cPn04L8eJoamXH8ew
         ol1wkbkutR1iwuCfKBqOr35mdvCDZLDgS5zSMoV0flP4JjJ94uQYIuwzjSPf2JqWSqbA
         d0ooZUal8c+u+CRhSIanz/MpWHCA/VbQulXMJW9YUnVyQWrbDkBrywbJbLNwjrRZjdOQ
         4EzmQk8BO5RNF5lZB8H40gyxTRrsuPDBbn5HAD1KNj5Gm1eQxSNZ0UPo4VMR502nIsT3
         2NWVAmSHmiadkET2FmrKjRqBK2vwwyJR/4BeyX6F+Nw8vdz0CMjD3tHv2gGQUHWl/8CP
         iUBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuai7OMdmNDvYv+qnOm4SGJyefm0WKpWEGhmNhdWHoR747Knfl92
	KWGlxkn2q31i2tQ+CxiR41I8C4Q0SfvJ+TEZAiOk0y8hGqCgDcUVdc7JzUiIpKcMfJy8sn6vt9g
	nBUoI8OfueHEdQvjlbjrp+54SnmpwcQnN4V91uBe9S3COUEYhuZNJn+5dOPqTUiLCuQ==
X-Received: by 2002:a17:902:a514:: with SMTP id s20mr24765218plq.242.1551164678529;
        Mon, 25 Feb 2019 23:04:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZoL22LPxWymV6fTduFmoyigo9Yu5sb76afTch5ppby9IvBp5kRMjeRXJv2CJk6LpHnztJz
X-Received: by 2002:a17:902:a514:: with SMTP id s20mr24765165plq.242.1551164677694;
        Mon, 25 Feb 2019 23:04:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551164677; cv=none;
        d=google.com; s=arc-20160816;
        b=KZhM8FurY1JlhFAcD9cjgyPnIetqFTXYSpPy1utro+NK1aZZRlYxWD7PskfESJuzoE
         8hcTpT5TXIzPYroCrBeRdIhqdS68nIz7z4644FoLljKNPhMPOM+0lMkHD3Aok4x5Pxvw
         ckna5/OfEP86jz/GJ7P+DEndH3n9RRGzb0lbexVbPKnpHKPyezMWHG1KnD5RMxaHb09c
         lILqqmM79el2NIwXm6Wq4oYXUEWSobkPIQEvvbtxDBJkRRpEjbrsfUEJDYk0kxEN8liJ
         3LC/W76zR264V/JWqsjjx0mBKaSJ1e6nWCQpFzjfims9+A1zmwBfeZAtoTcUKYuceGRN
         eB+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=bHKFuhTo34ZxCqOR1S7cithEyI6p/bS5m3EuXPilXxU=;
        b=TDkI87TfJHsoQXCPNMdSs8t5Zbxzq8dnLSMDBEbozGJOZM7KwVj48l+o1qbOE6BFgc
         8NR/GtNjn6o2MgyXf/xCSObliPGvpsvs9sWBkT5Vny2IOaOJ9qKGo78L9GtTFHvXorIS
         LIrpwpDHF8uLAxw1ppnitPQyWEyicWvkKYAnZzFp6NMLk6jb0cT34vlo/Hco/tRQ2Mel
         aXS30uzBzF3PbJP/xA50bA7Cc36FHRbOF7gh1NcQJPl7Kj/zMQMULfCBUoc5JQpHixOl
         GA3gFvv+B4FlIiO04UAeuHQJ4Utb7vwDbM3YoaJqeQlYkhgxrE5PgZQfk8ILl3W1AWDp
         Twng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c19si12044530plo.410.2019.02.25.23.04.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 23:04:37 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1Q74S21057576
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:04:37 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvykq3ak1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:04:36 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Feb 2019 07:04:34 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Feb 2019 07:04:29 -0000
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1Q74S5L40435868
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 26 Feb 2019 07:04:28 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 985C142041;
	Tue, 26 Feb 2019 07:04:28 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 42EF342045;
	Tue, 26 Feb 2019 07:04:27 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Feb 2019 07:04:27 +0000 (GMT)
Date: Tue, 26 Feb 2019 09:04:25 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>,
        Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
        Marty McFadden <mcfadden8@llnl.gov>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 24/26] userfaultfd: wp: UFFDIO_REGISTER_MODE_WP
 documentation update
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-25-peterx@redhat.com>
 <20190225211930.GG10454@rapoport-lnx>
 <20190226065342.GJ13653@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226065342.GJ13653@xz-x1>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022607-0020-0000-0000-0000031B4A24
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022607-0021-0000-0000-0000216CAE19
Message-Id: <20190226070307.GE5873@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902260054
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 02:53:42PM +0800, Peter Xu wrote:
> On Mon, Feb 25, 2019 at 11:19:32PM +0200, Mike Rapoport wrote:
> > On Tue, Feb 12, 2019 at 10:56:30AM +0800, Peter Xu wrote:
> > > From: Martin Cracauer <cracauer@cons.org>
> > > 
> > > Adds documentation about the write protection support.
> > > 
> > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > > [peterx: rewrite in rst format; fixups here and there]
> > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > 
> > Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> > 
> > Peter, can you please also update the man pages (1, 2)?
> > 
> > [1] http://man7.org/linux/man-pages/man2/userfaultfd.2.html
> > [2] http://man7.org/linux/man-pages/man2/ioctl_userfaultfd.2.html
> 
> Sure.  Should I post the man patches after the kernel part is merged?

Yep, once we know for sure what's the API kernel will expose.
 
> Thanks,
> 
> -- 
> Peter Xu
> 

-- 
Sincerely yours,
Mike.

