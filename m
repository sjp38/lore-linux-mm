Return-Path: <SRS0=ybLw=TL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18DBAC04AB1
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 04:00:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E95221479
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 04:00:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="qqWw4eDn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E95221479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04A016B0003; Sat, 11 May 2019 00:00:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3C886B0005; Sat, 11 May 2019 00:00:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2BBD6B0006; Sat, 11 May 2019 00:00:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id C46056B0003
	for <linux-mm@kvack.org>; Sat, 11 May 2019 00:00:28 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id z2so5689583iog.12
        for <linux-mm@kvack.org>; Fri, 10 May 2019 21:00:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HQU/yTn++wPSBAcGmojosLc1CYCiplH6O/ztlYTzsZI=;
        b=gUx8foo1SMNBFCq/02K9UZSafpEce+9TJAUynlVGgxNBGQFaOZCR6AHFWMZr9Tfgtf
         Zkgu151lQApIDo269i8pP8IMNHsByCIdKUxbbDGN/lQJeipkIOTJtUj5VqXFr8qPeMlW
         kMEmey4bn5yGJBynyKbIrRApJEEtYj/Sq8WrucGNPBI7osgWDbycmiObuvVTt0zBjoo/
         NP9UN1cfHinbqPd+Om0ukC1S3zGJoHSegkCoYXTY3tmSOliyU9HA+PUyoZHf/G5NMJTW
         x2w8AWBf1gAfLNIefd3T7Z9q/g+hkKIFDIUln8JFDcUqIMP3dpY0ojWKaaVR/vbVxC99
         WhJA==
X-Gm-Message-State: APjAAAWLSiKF2lznfZYfdO3PEAvasgiIxZHrzadaWBy/vmxCbQAW1i5l
	NNEmy7X3++4SDqbc65vkYG1DbyXFMV2PohybKAOnsfM3YIlCEDotD+C3g/B6gzgXjZIRLHUyNhi
	tX9kLIYiJU2J5KbbOVzbaj2yIN7b03tmUhZqlqoiz8nEICFMQ7JEfgs29NBVo5ZYt8Q==
X-Received: by 2002:a02:c6d8:: with SMTP id r24mr10345219jan.93.1557547228536;
        Fri, 10 May 2019 21:00:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxH9N7iG5YNgDwmXLVPd7jIGMZOs+5DVq1+ZmUz2yLS5WaMvSV+HpXJBCh0Htyk08tvr1q4
X-Received: by 2002:a02:c6d8:: with SMTP id r24mr10345179jan.93.1557547227582;
        Fri, 10 May 2019 21:00:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557547227; cv=none;
        d=google.com; s=arc-20160816;
        b=VHe4wx3Kja5Z7Utloz2vMoSI9dAfvvBNq365edseo6Fo3lpMhXi8KubJGpUZ979CRO
         cHXBgWfQmuuLeUr8XIzGn+xhbuWPssKG1K4L/YEY4toGZ546nkpqLrdZYyKABx8ew6Vd
         eSqsCxE4CxHjSA2b2iiISFAX/YpcZx7XOUVrklzvuLsUotzF3WvEN8mc6PlwyVGtpcQh
         lloJ95Lxct1L1RMMAgEvzR+M2nZesXhXTpLKoDTjoYuAac+cQLaNnk/bM/6+EU66MbWH
         3p/YfjySHpw1ag58GwmQTB8hQAQAv3my4gPw2VdDr9oPFXNXdte6P2vLCDwVDmm0ng9A
         FCAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=HQU/yTn++wPSBAcGmojosLc1CYCiplH6O/ztlYTzsZI=;
        b=lTdhXpz2y2w5XlBvJBKBKAtoLFbPkuYVnr+JW7maSMwOSzsxEZ31SxHOtqYDK+NK/n
         ltYiBqOvy9rvi8GNCMpBq35QML+ISC51ZoNiLRhXAXgwPM37wwAz6nfdXqsjf2WGiVZr
         5+n47Up9PpobQRS23YQXU/JjV2YC7U0yp9QvJMf2sS1f4RzvIprw06BwjW5LktV+Q0pF
         bld2Umwur6wujC5GqyPRaM2MDtV7+uxyRhADAigZS94O2fxm87rrwNj6XgSHbRtyYlVy
         xYT2l7xZECgkDxWQ399LDBBgzNjU451FVIJffuznPpzVllyUqjE8SFweC6rbCqu9ismo
         ADXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qqWw4eDn;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id g11si4239509ioq.13.2019.05.10.21.00.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 21:00:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qqWw4eDn;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4ALJeqp094644;
	Fri, 10 May 2019 21:25:01 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=HQU/yTn++wPSBAcGmojosLc1CYCiplH6O/ztlYTzsZI=;
 b=qqWw4eDnTPwrFdZ8Sfwv2TAww4/8wHZFtDss+9Y+/9yakVIUU9fZawamL3xQczlg9/47
 md0SWbe/ThwPXVI6X6mGYMXKHfJaXeJ0W0Ip8+oygmlSxDevirQDj3ZvcpQZKskee+Cv
 mZyrHDiB5BRyW2Hs8YLFb56kiqm8IxZihHxHI7FF8oHidP3QdZJii42tgW61o4g6bdPA
 vTTVQcgxpTO0xTlf2l3mpcx0olVjQJ+JfrBFAAIJmlQPqgjV7za7rRbE/IM7Zv9P9vj2
 0/rGSUBX2PGHD7/soQE2KnRFVc1MeIC1rt/kVNKu/EDpYKQGyQdAj9RH04MIU5X0O1Wu UQ== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2s94b6kp0d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 21:25:01 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4ALNX3A054568;
	Fri, 10 May 2019 21:25:00 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2s94ahkhy7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 21:25:00 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4ALOvYJ022471;
	Fri, 10 May 2019 21:24:58 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 10 May 2019 14:24:57 -0700
Date: Fri, 10 May 2019 17:24:55 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Bruce ZHANG <bo.zhang@nxp.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "guro@fb.com" <guro@fb.com>, "mhocko@suse.com" <mhocko@suse.com>,
        "vbabka@suse.cz" <vbabka@suse.cz>,
        "jannh@google.com" <jannh@google.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>, mgorman@techsingularity.net
Subject: Re: [PATCH] mm,vmstat: correct pagetypeinfo statistics when show
Message-ID: <20190510212455.mzmk2p6awhm33xjm@ca-dmjordan1.us.oracle.com>
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
 engine=8.0.1-1810050000 definitions=main-1905100136
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9253 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905100136
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

