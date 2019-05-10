Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA6A5C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 22:32:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 471262084A
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 22:32:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Im7/W2PP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 471262084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A683E6B0003; Fri, 10 May 2019 18:32:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A18756B0005; Fri, 10 May 2019 18:32:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DEE76B0006; Fri, 10 May 2019 18:32:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E4546B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 18:32:37 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id w25so5333809ioc.1
        for <linux-mm@kvack.org>; Fri, 10 May 2019 15:32:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HQU/yTn++wPSBAcGmojosLc1CYCiplH6O/ztlYTzsZI=;
        b=HHBfvBgFBObxitGuPGp2X8qU821ZeN5ETo2MlGkz96RJ+OPd2VhcnHOHNyymV5OXcQ
         R9TsayIhfgdJZRaftztZmXXK3u8ncaRuPUB2bE9v4ZlQ5uDYMoAdZ+rPd0HnA7stN5f+
         pMVVqoTCcpaIzvZfsALy64PuIqEIqZZQtDUVf8pFylAZjWcRklxR1f+OZ27Kv0gTdlgs
         ywBPhc4eRUbdjsf1jr8jvlsp4aFrf/V2CHdXFZwrdEhrMX4EzcuRe5udB4VLUsvgFlh3
         8c8ZR2eVl8JggwGWR10LmS5pNQGzA1tWQXT7Y4SaCEJYDO7NmNV/rhO3WNXJYgnKdcC9
         AXiQ==
X-Gm-Message-State: APjAAAVXWvpj8qNcaGwwj36fGTKqvKGnQXy53KT8kEKBmaVegOcMPKEX
	gUnF9Sa+1NvOpgSBNAWYXDEp7mXwHXG830jB084NVx/0gFGlvqJ8OWyyVu6jjctat8hzQQF2A/v
	FpqG0I4f8WxA992V4QfCVPTWmmZkrrh05wqTFh+FYIEJvFdogeGgu2HqmO2Gh9gUJZQ==
X-Received: by 2002:a24:5255:: with SMTP id d82mr1766098itb.104.1557527557116;
        Fri, 10 May 2019 15:32:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmrEjt2ftufUeFDLv6+ymdBZr/I4dEhA8jmBDpTvP+zlGxhVcY2qaXPKGiBNY0I98uOHe/
X-Received: by 2002:a24:5255:: with SMTP id d82mr1766047itb.104.1557527556353;
        Fri, 10 May 2019 15:32:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557527556; cv=none;
        d=google.com; s=arc-20160816;
        b=a6W576F3bCq+qhREnltVvwU3GGNsmJxGAAt471HkgGp2dniq7ulKYBMHErJcb37f+w
         oc2qZLHD28lBz2Og2xs/tQDU634RgZVEvg/JMoHlHYn0GWa7jWy40vD+kqigXR2h18lZ
         /RpwGpCvr8X5PT16HvyQM3RHr5wD4cLGpk03sXOj3X7uB+F3nvvP9qpzKvYyV8Gykibh
         DUtn3bvLDqp1Z9vk5fwjInkpDJvy3Bz/zu75Ze+gvKZGHV/Bvs/NCdd+5+uWXpfDm98s
         jU486PbKNuSadEx/Lx9dmMsLPOYSgjxA7/VLulOip7Y5WnjozER8E3SYi59KBjQKNIyt
         1ntg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=HQU/yTn++wPSBAcGmojosLc1CYCiplH6O/ztlYTzsZI=;
        b=XjEcYUVPOl1sjluAwWvIDnHuoY4g2YpNuCfmbpVxp5T5w2PPJgLZAoik8kliDD3TiK
         BVknfgcAkC/lS7VU09w2Rr+oKWeoqRMiO1y7CLRY8IXJJnbVOtUPZxPeNoqTcuLFeSsK
         b2Hi65tn9zDeoD6sVVUNYlPDdayDzEGt3nSJ6qjhv0qx2Mh6snXbMECgt53kFsh9cud+
         7Y+a7Zb50cc24O+3fgyUvkYp/0kp04RqM7sXZbAHnq1hh6KD8h/kz1XPyosZWvptk6d0
         xbV5iBLNxEG2JEhRtxGp9/V/8apaNpZzUib1PurK+SQTTlaql6rdTD3wXg0qdUR1dLjG
         rBwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="Im7/W2PP";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id n139si4460555itn.51.2019.05.10.15.32.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 15:32:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="Im7/W2PP";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4AK45wh039777;
	Fri, 10 May 2019 20:13:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=HQU/yTn++wPSBAcGmojosLc1CYCiplH6O/ztlYTzsZI=;
 b=Im7/W2PPPpHfDTA/f/veY3VgqZbdhJmOMX+Ew+sizNZyO5+bt1NW9T3xkxLS4OdwhHV1
 nprMbTBXGwMkfd/2FGxRKZKnDITdod8ChKTvVgqax7ypDvFtrZCSzd0Xntea4Rf/2Uu3
 lJOrCEsv9LdQhGuoDWd/CWKXJgoyMwBJYNmNvGj2egrPJKYUgdpypnJxkHFQ3dWl1PHv
 0HSgLcqKOX5lqRCtCimDkafzE5f3nsMeR2kqdTE/xBipAXtXEQ5zErsh4nYC0jUQWNAJ
 N5wm83cY4/i3Ud0cN5nPDCjjk5ysreUyeddMWP2H/9LK5855BoE42m5O1RquLY9MsmK9 UQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2130.oracle.com with ESMTP id 2s94b6kduy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 20:13:33 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4AKD9m6168502;
	Fri, 10 May 2019 20:13:33 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2schw0m3an-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 20:13:33 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4AKDUR0014393;
	Fri, 10 May 2019 20:13:30 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 10 May 2019 13:13:30 -0700
Date: Fri, 10 May 2019 16:13:30 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Bruce ZHANG <bo.zhang@nxp.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "guro@fb.com" <guro@fb.com>, "mhocko@suse.com" <mhocko@suse.com>,
        "vbabka@suse.cz" <vbabka@suse.cz>,
        "jannh@google.com" <jannh@google.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>, mgorman@techsingularity.net
Subject: Re: [PATCH] mm,vmstat: correct pagetypeinfo statistics when show
Message-ID: <20190510201330.qqbzzapxe2t4nv2l@ca-dmjordan1.us.oracle.com>
References: <1557491480-19857-1-git-send-email-bo.zhang@nxp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557491480-19857-1-git-send-email-bo.zhang@nxp.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9253 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905100131
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9253 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905100131
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 12:36:48PM +0000, Bruce ZHANG wrote:
> The "Free pages count per migrate type at order" are shown with the
> order from 0 ~ (MAX_ORDER-1), while "Page block order" just print
> pageblock_order. If the macro CONFIG_HUGETLB_PAGE is defined, the
> pageblock_order may not be equal to (MAX_ORDER-1).

All of this is true, but why is it wrong?                            
                                                                                 
It makes sense that "Page block order" corresponds to pageblock_order,           
regardless of whether pageblock_order == MAX_ORDER-1.                            
                                                                                 
Cc Mel, who added these two lines.

> Signed-off-by: Zhang Bo <bo.zhang@nxp.com>
> ---
>  mm/vmstat.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 6389e87..b0089cf 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1430,8 +1430,8 @@ static int pagetypeinfo_show(struct seq_file *m, void *arg)
>  	if (!node_state(pgdat->node_id, N_MEMORY))
>  		return 0;
>  
> -	seq_printf(m, "Page block order: %d\n", pageblock_order);
> -	seq_printf(m, "Pages per block:  %lu\n", pageblock_nr_pages);
> +	seq_printf(m, "Page block order: %d\n", MAX_ORDER - 1);
> +	seq_printf(m, "Pages per block:  %lu\n", MAX_ORDER_NR_PAGES);
>  	seq_putc(m, '\n');
>  	pagetypeinfo_showfree(m, pgdat);
>  	pagetypeinfo_showblockcount(m, pgdat);
> -- 
> 1.9.1
> 

