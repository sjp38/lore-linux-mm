Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88A26C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:23:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46BAC2147A
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:23:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="VOiSvB1T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46BAC2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1BCD6B0005; Tue, 30 Apr 2019 11:23:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCC2C6B0008; Tue, 30 Apr 2019 11:23:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBB156B000A; Tue, 30 Apr 2019 11:23:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 855796B0005
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 11:23:36 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id p12so2301584plk.4
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 08:23:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UL8akE2341IVNeapyyvljzXu78o4iHQf73fw4k3T+ck=;
        b=IT8THVQN/RmU9XEzEI/Mkn+xIWD+tdAzrOspo6YDhx/aJowoexoJlA/I83FBJIkprR
         qv+WE66hnnoh7p8h+DShGNjMBYz2c4+KqcXHqsMkFugIy/YhtoiY8n5knE2p6fjmcuua
         BpIiHdlsBjx08gRhIpSYveXZcXMabz0u/WVzLCaUdJ7Y+/v36mP/2WHJPRQYUr0vGhHS
         KhSTbVymLa8DHm+8EoFRfSHqck3o+N3/3e5lpUAhZw0nL9naiv2d2SsXvfMRVlsPKdsW
         xGyTbMS4fgkPqGHUsQns7XRhNB27ZOQJKK0G73K6dh7iFX+GftSz+6OvK/E783QUeK5O
         UDVA==
X-Gm-Message-State: APjAAAWb4X8vhZLyBRxox+3Zw9BRuUgb3RUS+bUsc+Ej5EnuR2Laq5Ec
	qIbkeYoisYjgGvbIjQW4VX4hJagZacsiiDI479xNX9oOfANZJ8W3f7jwY5nYUk0qRQBaa7+u4Vr
	j91In/m+SoNAZl28yUzAYZatcQZsONVsMCOa1YknRs6uwx9ub1nB6NZaGFToItWHeJA==
X-Received: by 2002:a65:5886:: with SMTP id d6mr14180918pgu.295.1556637816164;
        Tue, 30 Apr 2019 08:23:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhm874YiOcJUF12QM/DF6/KDR2fUngNW7p1ak99HSr6tYDg+e42LlPsreJgdgSZhx5IOZV
X-Received: by 2002:a65:5886:: with SMTP id d6mr14180688pgu.295.1556637814254;
        Tue, 30 Apr 2019 08:23:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556637814; cv=none;
        d=google.com; s=arc-20160816;
        b=FXJpZNlivqbAHqQeaPsqQPi/KAxa5+ocpt/EFpY5TxnCeSdjkDUFf6kJGaJQkn99BX
         AgbMpdp3yCB097shLJvqhYznG04uKv1QT2LI9RWq4VML9p0NX4PQKApnoNSF6VAB09Ne
         Z+5gJRCWQQJBsqRfXnBcUzoD3tGIcpU8Ork2Mx9l1ZNDJTeYxI42yFxqdb226LBOqJm5
         SgyJJ2zpwh+SQUm2Dh+Xzi+dGxaP97ut887Onu48eA/B9FYnypIWIgFwXZUdjjPJXq9D
         hK2uu50McrnKIDbkd0TH/LAo/eN80UgowKaIjenKzmCcr2TCbgHxoLoe7RzJAKUZPhCT
         3J/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UL8akE2341IVNeapyyvljzXu78o4iHQf73fw4k3T+ck=;
        b=qt6xRos/tZTvhez3HwpVobEEbG+gyHvfS+ZEUZNfivsWaPX+865Hi4tGhcb4dCAFbs
         Nhg8gN7EuECSpAvUDw5uxGt2TfNEfGJHfRXsFtzlY7Thrzm3DAlyMUPYp9G1s36iSLSj
         ZIx83ylgLO1CKruM3Yh3mVT81FutfW8DiUL72ENhC9AUFNhfL95VpbnXcBEPZiInojqE
         VHa8hJU2x9kiU29eJCy+2HGjMwJ5QmRXJtKl1tw1nBRuWlD0/+wYqPyzTg0pvcV4ClTJ
         xykbbgYJqv9q2afmGyGPs/HeYPnMKicrZIHFhW8b8QQFSqPGbskKQxxQDCDujrItWTSr
         CrcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=VOiSvB1T;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id l13si9055064pgh.88.2019.04.30.08.23.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 08:23:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=VOiSvB1T;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3UFL2xB106914;
	Tue, 30 Apr 2019 15:23:30 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=UL8akE2341IVNeapyyvljzXu78o4iHQf73fw4k3T+ck=;
 b=VOiSvB1TwdwOo69mSHaxccRH1E6odKRb5cOsUUsQj440V3vY4aZGKv421ikURYdOycP1
 ct3/4rP7d0MUlAPcv4YPSgnSqVLLsTHp1efDmDWRoFHN/TbyVl7Nx8S6xEkgreOgl3Mo
 FJ03P711Q1Gil53/qs5cTp+moK6EjU1Vzzysc7tTx80vgeITZFT2h4iyFuk4fNrnJHNo
 lhaUY6LbzNyNyD+zEmynqFtKpGHzGPJfop9VidTOC647tGPs/KyejCRNHHdIgbIzPsnz
 uqbGuXFgAxL5Gx6w4FxjbB04SSgXNUw8XtxiLYA2+NWWktTQSjF5AmCZRZ8rJPpPQVWT RQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2s5j5u1ynh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Apr 2019 15:23:29 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3UFNC3A118995;
	Tue, 30 Apr 2019 15:23:29 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2s4ew1a8qp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Apr 2019 15:23:28 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3UFNRcM008288;
	Tue, 30 Apr 2019 15:23:27 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 30 Apr 2019 08:23:26 -0700
Date: Tue, 30 Apr 2019 08:23:25 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
        Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
        Dave Chinner <david@fromorbit.com>,
        Ross Lagerwall <ross.lagerwall@citrix.com>,
        Mark Syms <Mark.Syms@citrix.com>,
        Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v7 3/5] iomap: Fix use-after-free error in page_done
 callback
Message-ID: <20190430152325.GD5200@magnolia>
References: <20190429220934.10415-1-agruenba@redhat.com>
 <20190429220934.10415-4-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429220934.10415-4-agruenba@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9243 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904300095
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9243 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904300094
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 12:09:32AM +0200, Andreas Gruenbacher wrote:
> In iomap_write_end, we're not holding a page reference anymore when
> calling the page_done callback, but the callback needs that reference to
> access the page.  To fix that, move the put_page call in
> __generic_write_end into the callers of __generic_write_end.  Then, in
> iomap_write_end, put the page after calling the page_done callback.
> 
> Reported-by: Jan Kara <jack@suse.cz>
> Fixes: 63899c6f8851 ("iomap: add a page_done callback")
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/buffer.c | 2 +-
>  fs/iomap.c  | 1 +
>  2 files changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index e0d4c6a5e2d2..0faa41fb4c88 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -2104,7 +2104,6 @@ void __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
>  	}
>  
>  	unlock_page(page);
> -	put_page(page);
>  
>  	if (old_size < pos)
>  		pagecache_isize_extended(inode, old_size, pos);
> @@ -2160,6 +2159,7 @@ int generic_write_end(struct file *file, struct address_space *mapping,
>  {
>  	copied = block_write_end(file, mapping, pos, len, copied, page, fsdata);
>  	__generic_write_end(mapping->host, pos, copied, page);
> +	put_page(page);
>  	return copied;
>  }
>  EXPORT_SYMBOL(generic_write_end);
> diff --git a/fs/iomap.c b/fs/iomap.c
> index f8c9722d1a97..62e3461704ce 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -780,6 +780,7 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
>  	__generic_write_end(inode, pos, ret, page);
>  	if (iomap->page_done)
>  		iomap->page_done(inode, pos, copied, page, iomap);
> +	put_page(page);
>  
>  	if (ret < len)
>  		iomap_write_failed(inode, pos, len);
> -- 
> 2.20.1
> 

