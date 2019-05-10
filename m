Return-Path: <SRS0=ybLw=TL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 065B1C04A6B
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 01:00:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FD8B217D7
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 01:00:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="td/xf/W+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FD8B217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00C146B0006; Fri, 10 May 2019 21:00:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F00686B0007; Fri, 10 May 2019 21:00:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC7886B0008; Fri, 10 May 2019 21:00:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC3166B0006
	for <linux-mm@kvack.org>; Fri, 10 May 2019 21:00:53 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id s24so5558673iot.0
        for <linux-mm@kvack.org>; Fri, 10 May 2019 18:00:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lm+P6joQ1QqptWVYne/zYLFwZLOPp9hC9fwmLqLR9Ro=;
        b=ZIQ5IJBOHLCPkG/8fOaBaqt6B4uBbqBCocq+6FBZOqk4LsqVIP62JPR+PfBfOPlXt/
         3KsWDtwyyYXz6gM/StA9HaTvatkAM9LY+HGNz3tokwRqLuYe1cCbRir8kgNrp/0e1ijb
         2J872Wj6Zp5nNQ1TVnuO7MIdQ0E+LRNbqxT0H0czc0RBMGU/1DPJcxsH8q1+VNIA3pTq
         jvshL2neCXlDii6i/WUPx8jx8Y3UO+CnYXko5/buHjFTU2TSy/D8Er4U6UutkL2zGylP
         TXczy5rEX6PtU1voKNAwsZcg6s9xQtGB9PKdwqzv/UZLTwZnhPKNdBjyus+WAFBgsJsM
         fw5A==
X-Gm-Message-State: APjAAAWQ6eq+U24Ao6DZzjD751eoZAYaHufRKiOy7Re0w0MFt4DSKBSa
	q7TQAkAdFHkMYgYT3IoXrjhwZfm8fGKp5MqC3uZMVouJWZio9QYV9r1vEFnJovQqUs8cJCM8sHb
	CtUg8dtQJXQEJd5SEsLpnS4TdFS+Coih7iqIuHiKUtaVPYiK44nmVq1bIKn1R/bBtEA==
X-Received: by 2002:a02:cc29:: with SMTP id o9mr10757825jap.6.1557536453562;
        Fri, 10 May 2019 18:00:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcm+byyDjwY3ufvSaayFfBD4Dfun4CZT9yKmDcqRYWlAdmLG8P2avPJ1vpoUqCK88d6ZyI
X-Received: by 2002:a02:cc29:: with SMTP id o9mr10757785jap.6.1557536452850;
        Fri, 10 May 2019 18:00:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557536452; cv=none;
        d=google.com; s=arc-20160816;
        b=RtOspr3lb3hF1S7NH3az8ccSyP9Ff/P/7otf9GrGEsTPi7Wuagf4QwByLSfm9dSGyg
         pkdMvsmGbKmwp6vjiY7Z+/ZTtdZ7VJi9vN6KX9e1q+Es/AbKSzrAmiCwW8C+q5Tzipmc
         HGbKunLNW2tu2VJW9hmLV1GiPoeQDGThLT7gx5gzXm13K3KbOBgb/+Nn8ZYFv8z8lvlr
         TcYjw0HJ+URIWjv+YnQFX//LbAv1e5fEznKZqA2grmhWU4azHhKkiYBhv0kNuQ/YPCMv
         Grp/QLPMSIWUovc8D1mc4sOvnU9edzJjDtiN9AXqzKBQodsNL9PYURvRT6B+n1CXlLcy
         0cNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lm+P6joQ1QqptWVYne/zYLFwZLOPp9hC9fwmLqLR9Ro=;
        b=WLmykgIld/1mwUl8Vx13a5Bx8BJrNeLcao6ceCS5Jgh+vvEfNIv7wtuUz29mTlfJF3
         GcaqERMSrWkY3Xom1UpFPoKS75P6ny/dfnenIAxYjYNSWtLK+77XLxrbPo11xo/Zi8sB
         enZQr5Z3NUYiuqfNlZdgazfF84t3UYhHtQD+ymwUFPL5Q0JZkZ/E7SAnABQX1/jo4GeR
         HmVk9p8klQm68PwLYscUo40rNA9eKI2pItQgKk8vv/gsbpnDMS6SGAAJNEENcPVApb5V
         YWhz4yKLJWlzyCP+q9vD5I6YgFyl/CNHCOJ4mkzhDk1pt77BkdDIUJ9vnSq1TO0pWCrw
         D9/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="td/xf/W+";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id e64si4657822itc.58.2019.05.10.18.00.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 18:00:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="td/xf/W+";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4AImlKq162457;
	Fri, 10 May 2019 18:51:02 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=lm+P6joQ1QqptWVYne/zYLFwZLOPp9hC9fwmLqLR9Ro=;
 b=td/xf/W+Z9aWLrHlGQLQiwCMCwzeOWjcRpVANJYKzil+953fmdouUrbLlXOS2Ias9SLp
 JqUEvctI7bxyDscWoF239yQMPET4VBnVy+9FDbzFbrwIVffbxLi53qlbO0YrORj5Rt9K
 CaV+W17rZN+kytcmoSmP1yP9JcRuZI47zlh7m7ial/bitpXaA2VeFm4M9qnQGIjNA027
 lcujM49R0xccSR7DjzqPO9DTcVY/6A4xpDCnrgA47wFHBagJ94SvWXRHzjoNKuqmm34R
 ImKRHopIpOhDzdvlc+eWmmVtEyUQn7ddpjoS+Gw20LhK1NGKiIq/08dyPjEmOB846myK wg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2s94bgk0qk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 18:51:02 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4AIm7St170695;
	Fri, 10 May 2019 18:49:01 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2schw0jxd5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 18:49:01 +0000
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4AImxDS009316;
	Fri, 10 May 2019 18:49:00 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 10 May 2019 11:48:59 -0700
Date: Fri, 10 May 2019 14:49:00 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Bruce ZHANG <bo.zhang@nxp.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "guro@fb.com" <guro@fb.com>, "mhocko@suse.com" <mhocko@suse.com>,
        "vbabka@suse.cz" <vbabka@suse.cz>,
        "jannh@google.com" <jannh@google.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>, mgorman@techsingularity.net
Subject: Re: [PATCH] mm,vmstat: correct pagetypeinfo statistics when show
Message-ID: <20190510184900.tf5r74rtiblmifyq@ca-dmjordan1.us.oracle.com>
References: <1557491480-19857-1-git-send-email-bo.zhang@nxp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557491480-19857-1-git-send-email-bo.zhang@nxp.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905100122
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905100122
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

All of this is true, but why do you think it's wrong?

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

