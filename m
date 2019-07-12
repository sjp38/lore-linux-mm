Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F19A6C742D2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 17:56:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9EC52054F
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 17:56:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="OXL38PEg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9EC52054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4ACDF8E0163; Fri, 12 Jul 2019 13:56:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 437478E0003; Fri, 12 Jul 2019 13:56:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D7858E0163; Fri, 12 Jul 2019 13:56:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 08CB48E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 13:56:51 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x1so7586378qkn.6
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 10:56:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PFVmlVQEMCCclkWvCJY9Wejc6o6dKfzcVtLPB+0UMb4=;
        b=p1DFXhCbTxTwr4D9m3wQLvQQVBNte2R+IAyo8STGfX9wQosgk/kTf0rX1gfIziNcQU
         Tc7nfJWzX+aGoQGN0UsWOfZwZbjZdQ41ZZz4SlIu048WECQJgBZtvFd6ISQz1f9HIqlI
         ZnmMl93DNbOzTZuZXaLMm8drnUOdbaucPTcavbOuX18S1hos+VQnoCCkjsQEPtRCrKEo
         5ey2mQAGLJEkOkYWAtwWJpjU0tv1U4md+0Wd6UULPOJ11udfilPoyrjv/2E/6HiMONh+
         gF0mDwBlpahHw7ZZaA2lC8nIdTbQp7Yts70PtwKe+0DslKtrYksVE9VCJ6sfcLNYiJf/
         M4RQ==
X-Gm-Message-State: APjAAAUaUhxOwPSFlK6cLmHkz0DYh6ijSlf33E24Y/w/YRbdt6F6CmI9
	ypSfF54OgfWgSJGDdIKdtg70m+485IczlEO11lQtxJ+3oUqVWoh0utG5/bNlzf/hBcYCn9ZElBq
	EqlBMUsoLQFZA8DXFZcw8XUCziUeoz6N4l/s7REST23af+vod6XaXLkHvWhI6Wb5uNg==
X-Received: by 2002:ac8:275a:: with SMTP id h26mr7352986qth.345.1562954210824;
        Fri, 12 Jul 2019 10:56:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzF8Cho0xU6JTEF15+bXEsVMa/Wdjxv7LiqfUd6CxfuJx5BVlSLc1SRFTfbYC0xHqeBMyxQ
X-Received: by 2002:ac8:275a:: with SMTP id h26mr7352958qth.345.1562954210249;
        Fri, 12 Jul 2019 10:56:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562954210; cv=none;
        d=google.com; s=arc-20160816;
        b=Dijmq/sEG3aStAWlfktuu7R2C9PqSvU/BBaH4FK9yKKMUy5KpBzdwHt0bTYiFiIAm4
         erHpiit9WBPZIXMHsxqYI0WHoiKfidZ7APSwsNetdNYgjvE5FOqCx+Pog5vYInLS5MRd
         C1KXVqVvKHMVXzfmSdjqMmAdBzeLlyACWbEghd+OI7FLhigM95218sA1b9zp/emjvbHE
         JQN4ixyOaU4l2CughJPwZ/0u7/aR2MKHA8EW3eh9VPj5ie6NIRTW8hG5l0YBUo5lMhNR
         uZS1vTRE8IHCgCLCQC/LFlXJqxGGARNBGOLxS8RnmlPDGJwh1ZQJcIwqk0aa1y023sAF
         rk5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PFVmlVQEMCCclkWvCJY9Wejc6o6dKfzcVtLPB+0UMb4=;
        b=W+EDlJYmAP4w2VVLjajAfv8BxyHCBMkpM52Kg10eGQjldtnOZUdgFmg26xRC0tzzne
         v4lOfMYIVvGi4Nt9HjxhsKaN/gPYRqDwjGPloSKxL6b66StnU/hm2kTFT3DqrIHt5cnJ
         8LfVj6ktGxkB8m+EjTqrIoYjB5IyNkFjF42M74fsl+wX22hTzsSDbWUlM2ylf7f9DLwB
         YkX1Cf4FmQJKhbQMvADpnHCS0LAWL9VeifZXv//Q70tafc+rzbUc0yGc6ciuEFyo/6Wm
         1Ko1y2uQZlSzTvQ3LO2/+BPP3Y///PHijfBtr+xr4AnLX50oyryd5B/ku4DgacIW21HD
         bRhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=OXL38PEg;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id t42si6322500qtc.163.2019.07.12.10.56.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 10:56:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=OXL38PEg;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CHsRrU105742;
	Fri, 12 Jul 2019 17:56:47 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=PFVmlVQEMCCclkWvCJY9Wejc6o6dKfzcVtLPB+0UMb4=;
 b=OXL38PEgYIEwQYsJjNApbLl+0t2sHeSMQvqUPxX/417fBcno3jB9YEdB5dpSzYd1WriO
 vZIWR1w+nSpYskMMSmqlga9y7mobZYEUWCIX8rITvKqJJyhCmKTAR1kfAO4RtwM15MyA
 CTnPoPupmbj3RvCDoxC5iqHkL/vW9mzdxk9luV2B9krAl4Qge+M2DIuJjHc9LsIPgGSb
 uO+rIoKGax+7Dnepzps3T0bqTnk6Bs8orCM79XMOUhGHozPuI1z1sNgSAAN3QVX0O6n0
 BmkhkUUWz4h2DbsWUOQzAXm1o9tGwj2+LkTcrH/nP9RC9MO0eaoTQ+XKTD7l7njMQH+W Og== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2tjm9r6ym8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 17:56:47 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CHqRB7133355;
	Fri, 12 Jul 2019 17:56:46 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2tpefd7ke3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 17:56:46 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6CHuj7l010001;
	Fri, 12 Jul 2019 17:56:45 GMT
Received: from localhost (/10.159.245.178)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Jul 2019 10:56:45 -0700
Date: Fri, 12 Jul 2019 10:56:44 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Jan Kara <jack@suse.cz>
Cc: Amir Goldstein <amir73il@gmail.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>, linux-xfs <linux-xfs@vger.kernel.org>,
        Boaz Harrosh <boaz@plexistor.com>, stable <stable@vger.kernel.org>
Subject: Re: [PATCH 3/3] xfs: Fix stale data exposure when readahead races
 with hole punch
Message-ID: <20190712175644.GQ1654093@magnolia>
References: <20190711140012.1671-1-jack@suse.cz>
 <20190711140012.1671-4-jack@suse.cz>
 <CAOQ4uxh-xpwgF-wQf1ozaZ3yg8nWuBvSyLr_ZFQpkA=coW1dxA@mail.gmail.com>
 <20190711154917.GW1404256@magnolia>
 <20190712120004.GB24009@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190712120004.GB24009@quack2.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9316 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907120181
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9316 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907120182
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 02:00:04PM +0200, Jan Kara wrote:
> On Thu 11-07-19 08:49:17, Darrick J. Wong wrote:
> > On Thu, Jul 11, 2019 at 06:28:54PM +0300, Amir Goldstein wrote:
> > > > +{
> > > > +       struct xfs_inode *ip = XFS_I(file_inode(file));
> > > > +       int ret;
> > > > +
> > > > +       /* Readahead needs protection from hole punching and similar ops */
> > > > +       if (advice == POSIX_FADV_WILLNEED)
> > > > +               xfs_ilock(ip, XFS_IOLOCK_SHARED);
> > 
> > It's good to fix this race, but at the same time I wonder what's the
> > impact to processes writing to one part of a file waiting on IOLOCK_EXCL
> > while readahead holds IOLOCK_SHARED?
> > 
> > (bluh bluh range locks ftw bluh bluh)
> 
> Yeah, with range locks this would have less impact. Also note that we hold
> the lock only during page setup and IO submission. IO itself will already
> happen without IOLOCK, only under page lock. But that's enough to stop the
> race.

> > Do we need a lock for DONTNEED?  I think the answer is that you have to
> > lock the page to drop it and that will protect us from <myriad punch and
> > truncate spaghetti> ... ?
> 
> Yeah, DONTNEED is just page writeback + invalidate. So page lock is enough
> to protect from anything bad. Essentially we need IOLOCK only to protect
> the places that creates new pages in page cache.
> 
> > > > +       ret = generic_fadvise(file, start, end, advice);
> > > > +       if (advice == POSIX_FADV_WILLNEED)
> > > > +               xfs_iunlock(ip, XFS_IOLOCK_SHARED);
> > 
> > Maybe it'd be better to do:
> > 
> > 	int	lockflags = 0;
> > 
> > 	if (advice == POSIX_FADV_WILLNEED) {
> > 		lockflags = XFS_IOLOCK_SHARED;
> > 		xfs_ilock(ip, lockflags);
> > 	}
> > 
> > 	ret = generic_fadvise(file, start, end, advice);
> > 
> > 	if (lockflags)
> > 		xfs_iunlock(ip, lockflags);
> > 
> > Just in case we some day want more or different types of inode locks?
> 
> OK, will do. Just I'll get to testing this only after I return from
> vacation.

<nod>

--D
> 
> 								Honza
> 
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

