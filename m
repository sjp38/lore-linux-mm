Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E6F8C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 21:44:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 039F320C01
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 21:44:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="roDAct70"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 039F320C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E8C36B0005; Mon,  5 Aug 2019 17:44:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 599B96B0006; Mon,  5 Aug 2019 17:44:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 487A56B0007; Mon,  5 Aug 2019 17:44:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 286546B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 17:44:54 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d26so77114923qte.19
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 14:44:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tUOx2J5+IqGOok0vsUKMad0tL7ZdRLzF7oPP2HBvWO8=;
        b=SQVGFFviKtjmu7mFcD8gALhdmQX7w9i5JfEgL5P2bVb4+u+x/RQselgma+RmdMCTJu
         EAlpJAvL7CXu5kFgHMYJjRSX5y4PNw8jHKk5lpf6ROoZegX+UDf/UaVn+XERFy5AfBjK
         ephsMAy6dnTGGgD5+cHQ9W5d6SkBw9cRkcNbgN4pfvFn+fcCPVT8I0hFLp7TY11tnyMD
         Z4S4DZ1bebB20n9MJyOdm/rx7YsUQ1C9V3LGsuhzQ9/jiwccXg3KJ8qo0t/QAggxlXGa
         Sx3HlD86mjSR3VQd75BVYtUCI+22zFkgTK3WJ7w9KJQpSCNQ5l51mJydqy1tdshbXDNc
         Wjqw==
X-Gm-Message-State: APjAAAWDOuiXZSVssPIzJHqH7j1tHyUh1mJAzTLoq3EiiKi4EpstJYlX
	MJvK4hUO/tMBTBd/eywxzIgF7wzSGEZx4gG5JFGGayAs4WFiljfdRRHnqcwqYaWzp2pdAQN5Ho5
	5KeRHaOp9EVOkj1WS4R4V4JWjiggudx3+7IRn8VUzkUW/Ip8KWJ/mMYkEY2vvjWXaAA==
X-Received: by 2002:a37:a851:: with SMTP id r78mr451555qke.120.1565041493897;
        Mon, 05 Aug 2019 14:44:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgcwjauY35Hcaatjh3BrRQY1VjGnAKQGxCWW+Yxr2fVKNzkhuLALN7oZZUrtlL0NetipxL
X-Received: by 2002:a37:a851:: with SMTP id r78mr451505qke.120.1565041492981;
        Mon, 05 Aug 2019 14:44:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565041492; cv=none;
        d=google.com; s=arc-20160816;
        b=q+Qc/RDJ3hAchYpIzznHY+XGt7RtcVzSKWEW/xEPwJ4T6UTCtxLmgq8mv/xvSIQpXQ
         dicgwzU2lm1+ESRTT5QM5HFqtrnj9e3pZ2AfndF6EYCa8xiz3UdWMvt83ClncqTiQaC6
         OZ8hQ8HGFRhUhCwa8cAgHOBmcaqqiAhBYz5y80kZgOPomVJCJCkDZfN0ukioXtDnEWE1
         um6AVkAVe52T3XgLc//p+OhkGTuyZ4O1VNr/RPt6smsnJT8QxvRQa8NOcwsK8DOg/E6P
         7DsAflPMeXdROzx2uaUsvzuSrH1v9g+j22E/8cYPRfBsN+8CPW7Rr2NnW5NAhLZxqp8t
         XJnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tUOx2J5+IqGOok0vsUKMad0tL7ZdRLzF7oPP2HBvWO8=;
        b=qUXP1jQf6+ME3gV8nfTHrXR8FwwlqQB03FVU38ku40pIls2v6ZarkTDvpC7FTEDyxt
         lJ8hkqflvkT9qnLz9lyEZ32XoScIxftzy/6QkwTl0r4shVfcXiEDhZh9m7OX/Y5SQpKf
         2gq576g+q0EAdwprO8xb1KHlR5svxKrNPfdcq3eYM8ptTrwqagUq5V1bti36dLvZw3SB
         G5ggZUWdUdUoklfwiGlaWeVnRZU7GF7RCnYWQCLpKHrswejQ++CdrCIPgPFRmNLRgUAM
         3Nh4VNlwcoORcAoF641vFk5yd80ctkmjpY+XR93VwB1hdQhdT0/Hnn6L70IjZchPpEsv
         h0bQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=roDAct70;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id d21si9220005qto.3.2019.08.05.14.44.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 14:44:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=roDAct70;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x75LiKM7173657;
	Mon, 5 Aug 2019 21:44:40 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=tUOx2J5+IqGOok0vsUKMad0tL7ZdRLzF7oPP2HBvWO8=;
 b=roDAct70rERrM9LJeZpTB0ALEj6JmUbx9r2BUDe9eYkRwnu4cbDthpksWZnaMsWPQqSl
 X8bCxZNg1D5jgMxBICmBA6HCxH60Ea45b2jNIoqtFR8JuLSaVs4Jg+YJ0ASHx4QthPq/
 ykCipDJOKswNvVZt8SwaIEiefVw02cByNX74uWxQ6UcOm6ocxIttnvw9V0//k1ItGPER
 9NLSZeqeqLdrVRd/+Bv+K0MGmtGin7OifIdzeoPkGiOGZUYk7FL+05e73rulgijApQH3
 MZaE39spfNmOBJzsaWUsTkSSmJ5PgKZcvx48jZNDlbpKGbWDKoer6ZFc4fH1//1uOO5l 9g== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2u527phue0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 05 Aug 2019 21:44:40 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x75Lgxhr024688;
	Mon, 5 Aug 2019 21:44:39 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2u51kmxmfy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 05 Aug 2019 21:44:39 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x75LiZW3027456;
	Mon, 5 Aug 2019 21:44:35 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 05 Aug 2019 14:44:35 -0700
Date: Mon, 5 Aug 2019 17:44:31 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
        Michal Hocko <mhocko@kernel.org>,
        Yafang Shao <shaoyafang@didiglobal.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RESEND] mm/vmscan: shrink slab in node reclaim
Message-ID: <20190805214219.fxida5zojihauo7d@ca-dmjordan1.us.oracle.com>
References: <1564538401-21353-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1564538401-21353-1-git-send-email-laoar.shao@gmail.com>
User-Agent: NeoMutt/20180716
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908050219
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908050219
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Yafang,

On Tue, Jul 30, 2019 at 10:00:01PM -0400, Yafang Shao wrote:
> In the node reclaim, may_shrinkslab is 0 by default,
> hence shrink_slab will never be performed in it.
> While shrik_slab should be performed if the relcaimable slab is over
> min slab limit.

Nice catch, I think this needs

Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")

> If reclaimable pagecache is less than min_unmapped_pages while
> reclaimable slab is greater than min_slab_pages, we only shrink slab.
> Otherwise the min_unmapped_pages will be useless under this condition.
> A new bitmask no_pagecache is introduced in scan_control for this
> purpose, which is 0 by default.
> Once __node_reclaim() is called, either the reclaimable pagecache is
> greater than min_unmapped_pages or reclaimable slab is greater than
> min_slab_pages, that is ensured in function node_reclaim(). So wen can
> remove the if statement in __node_reclaim().

Why is the if statement there to begin with then, if the condition has
already been checked in node_reclaim?  Looks like it came in with
0ff38490c836 ("[PATCH] zone_reclaim: dynamic slab reclaim"), but it's not
obvious to me why.  Maybe Christoph remembers.

I found this part of the changelog kind of hard to parse.  This instead instead
of above block?

    Add scan_control::no_pagecache so shrink_node can decide to reclaim page
    cache, slab, or both as dictated by min_unmapped_pages and min_slab_pages.
    shrink_node will do at least one of the two because otherwise node_reclaim
    returns early.

Maybe start the next paragraph with

  __node_reclaim can detect when enough slab has been reclaimed because...

> sc.reclaim_state.reclaimed_slab will tell us how many pages are
> reclaimed in shrink slab.
...

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 47aa215..1e410ef 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -91,6 +91,9 @@ struct scan_control {
>  	/* e.g. boosted watermark reclaim leaves slabs alone */
>  	unsigned int may_shrinkslab:1;
>  
> +	/* in node relcaim mode, we may shrink slab only */

                   reclaim

> @@ -4268,6 +4273,10 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  		.may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
>  		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
>  		.may_swap = 1,
> +		.may_shrinkslab = (node_page_state(pgdat, NR_SLAB_RECLAIMABLE) >
> +				   pgdat->min_slab_pages),
> +		.no_pagecache = !(node_pagecache_reclaimable(pgdat) >
> +				  pgdat->min_unmapped_pages),

It's less awkward to do away with the ! and invert the condition.

