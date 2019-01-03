Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 348EBC43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 17:15:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4DBF2176F
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 17:15:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="rnP9D241"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4DBF2176F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F62C8E008F; Thu,  3 Jan 2019 12:15:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A49A8E0002; Thu,  3 Jan 2019 12:15:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 546D08E008F; Thu,  3 Jan 2019 12:15:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 269D48E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 12:15:58 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id t13so34279459ioi.3
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 09:15:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=E7J82m7M+NzQi1cKwxCSHrMy1+Tu6ouRR9AjcopMr4U=;
        b=UvIESkapcqguuhcruE0ro0CtdxOX1bZ9Ixk5nwnHQLwz1D4i0UDEJgYC78G515/MSG
         qEZSGH5crADwBKcH4KsBfVskA/jRK8vsNNet1cWq96rOXMMUJsmy2C5Gjr6wi2+hl3pk
         1nzaPIES+cTi8Vf83NJ7sAgh6CWJXl3W0Ebx7To02VkXsh7xU5oSxQz0EgX5Hz30gW1e
         /avetX0CZCx6TMhiDAhVvMPr27ZPb8SFcX30pVNEc86Y1/RH/QgHHxAzu8O3ZbyicMtx
         IRXaVwi4fgaLBYLa0Da5VUTBD5l6nNIExgFNiYoFpevJI0IZNBgGcuCGhIjiBm6SEb6z
         1oTw==
X-Gm-Message-State: AJcUukfI5w/lS90g1hEKrLRHui9G6gHlUzlytI04hqn7Bj7jNAqNOMYh
	ajR/IVhn/yGzWJ8vPJgH6D6Nn8Li4Lj4VrKPQvU/gmEwXqb+AgbAuGpJyUNQO3Yv+i2vIYFY0dI
	KZBKM6PQ23OVXx7Mlds21lpJn5YD4aIuhgYJ3QIaX/ItzLh5yyzxlVNZvbpupGMguWw==
X-Received: by 2002:a6b:4a09:: with SMTP id w9mr35621679iob.260.1546535757892;
        Thu, 03 Jan 2019 09:15:57 -0800 (PST)
X-Google-Smtp-Source: ALg8bN47U3jLK07RBJaTF966gQ12rvfATkUlsDChZlBivp1Y+KK4Jh1ID+Kqs+uAZBGe78/ZQ4pI
X-Received: by 2002:a6b:4a09:: with SMTP id w9mr35621647iob.260.1546535757228;
        Thu, 03 Jan 2019 09:15:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546535757; cv=none;
        d=google.com; s=arc-20160816;
        b=aUpXffULoO8b5qxFs5WJZFqTCbzRcbjNxWbcQhQzcnzG53yPnFLCQDBxSr6pLhO5BF
         SMVcWesQ5rxq+2bmnIYCaWEgwKHjLsMMgh/ho1qKSPbzOFnWhppEQ2l19+pWGM98ubXF
         KYJG666Md1GRSCdxd4bNXfwy9DOKestBySQ4TN2fLSSweBTAdmswxDf7rFxjNt+ls2th
         lTKeDdKmcNaoCtRvaWzuNMaKo93PRatZfW47ar2LNjstSzHaFRdn3GGoVIMV4C2BrEJy
         hublkq6aTJQFHk1kTPtGYu80huFskwLplnYQn8oSVUz7ZJxtc/9yx2Z3VMrHwpZhFCVb
         tzTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=E7J82m7M+NzQi1cKwxCSHrMy1+Tu6ouRR9AjcopMr4U=;
        b=lxl6z0/mhnYmeUtnt3O+UL/yLNbWKZmgUBIwZZcdO5t1d78zZOhf1qnbsFXSNgE516
         E788Dt1nQtW/ktDFEIc2DLZXaN4P5x+SevP5WxEGJgcroQH6mmufGx0xl/w37+gypthX
         2heM5QIFWpugw6leMvw2SBWEkAGHMo1Z+Z6Emh0Urv+IQKk2pnHxgmUqaI7U6qxdBrfm
         vQQgzRSpxLaWDcrhm7mBaznATuW0xhOEKaX5KYTAIrvtNkAV+DbO02gzGZXkxc5GvVoE
         ZCQBhS/3NEVqNU1OI0P2Hv+MQiDTZFupsQEvYxylxjgjO13yZXRIxJ0NOaGvlEYmAN/O
         1s2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=rnP9D241;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id k143si295931itb.43.2019.01.03.09.15.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 09:15:57 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=rnP9D241;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x03HER2q022631;
	Thu, 3 Jan 2019 17:15:53 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 content-transfer-encoding : in-reply-to; s=corp-2018-07-02;
 bh=E7J82m7M+NzQi1cKwxCSHrMy1+Tu6ouRR9AjcopMr4U=;
 b=rnP9D241MZtvi8Gt2p8xXEAIvyfp7uVM0A+ZYlJYDPxaHmtohttZZ3icixcouobDurIw
 1PZ6epHHVOReK4tKazCq87CoTrdwUT8Hh4mTXww3A2TQtJKDmXTPqK2UEJc1gkoQyPoo
 s44ZE3/AqQZje8IzCiaPp7TQRpr63Kcw1oUSKBQOJKwhb4v9GeXsGjd/0uS5fThHaBXu
 1rqo/ErPVzn4icpIa0/GutKMKWmmirr6xRZo6mPYsbYJIwpMK2i40VlACdz17CsjSrYQ
 mUfDOwDVX5UCpM77zsdKwmFjgawHfDJoxRzTUkSI/nNcy1Q1yr9/gWuAcx+TNG61n2T9 HQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2pp0bu0ara-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 03 Jan 2019 17:15:53 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x03HFl9J009926
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 3 Jan 2019 17:15:47 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x03HFlPW016081;
	Thu, 3 Jan 2019 17:15:47 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 03 Jan 2019 09:15:47 -0800
Date: Thu, 3 Jan 2019 09:16:02 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, ying.huang@intel.com,
        tim.c.chen@intel.com, minchan@kernel.org, akpm@linux-foundation.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v4 PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
Message-ID: <20190103171602.frjmcagwwqtzwqka@ca-dmjordan1.us.oracle.com>
References: <1546145375-793-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190102230054.m5ire5gdhm5fzecq@ca-dmjordan1.us.oracle.com>
 <76d8727a-77b4-d476-af89-9ae1904ec8cd@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <76d8727a-77b4-d476-af89-9ae1904ec8cd@linux.alibaba.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9124 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=760
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901030152
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001687, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103171602.IYzfRq5uIanY3V-FjVLGnXvsl6q1b-bROHrMn0UKMJ0@z>

On Thu, Jan 03, 2019 at 09:10:13AM -0800, Yang Shi wrote:
> How about the below description:
> 
> The test with page_fault1 of will-it-scale (sometimes tracing may just show
> runtest.py that is the wrapper script of page_fault1), which basically
> launches NR_CPU threads to generate 128MB anonymous pages for each thread, 
> on my virtual machine with congested HDD shows long tail latency is reduced
> significantly.
> 
> Without the patch
>  page_fault1_thr-1490  [023]   129.311706: funcgraph_entry: #57377.796 us | 
> do_swap_page();
>  page_fault1_thr-1490  [023]   129.369103: funcgraph_entry: 5.642us   | 
> do_swap_page();
>  page_fault1_thr-1490  [023]   129.369119: funcgraph_entry: #1289.592 us | 
> do_swap_page();
>  page_fault1_thr-1490  [023]   129.370411: funcgraph_entry: 4.957us   | 
> do_swap_page();
>  page_fault1_thr-1490  [023]   129.370419: funcgraph_entry: 1.940us   | 
> do_swap_page();
>  page_fault1_thr-1490  [023]   129.378847: funcgraph_entry: #1411.385 us | 
> do_swap_page();
>  page_fault1_thr-1490  [023]   129.380262: funcgraph_entry: 3.916us   | 
> do_swap_page();
>  page_fault1_thr-1490  [023]   129.380275: funcgraph_entry: #4287.751 us | 
> do_swap_page();
> 
> With the patch
>       runtest.py-1417  [020]   301.925911: funcgraph_entry: #9870.146 us | 
> do_swap_page();
>       runtest.py-1417  [020]   301.935785: funcgraph_entry: 9.802us   | 
> do_swap_page();
>       runtest.py-1417  [020]   301.935799: funcgraph_entry: 3.551us   | 
> do_swap_page();
>       runtest.py-1417  [020]   301.935806: funcgraph_entry: 2.142us   | 
> do_swap_page();
>       runtest.py-1417  [020]   301.935853: funcgraph_entry: 6.938us   | 
> do_swap_page();
>       runtest.py-1417  [020]   301.935864: funcgraph_entry: 3.765us   | 
> do_swap_page();
>       runtest.py-1417  [020]   301.935871: funcgraph_entry: 3.600us   | 
> do_swap_page();
>       runtest.py-1417  [020]   301.935878: funcgraph_entry: 7.202us   | 
> do_swap_page();

That's better, thanks!

