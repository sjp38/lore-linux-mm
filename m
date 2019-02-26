Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C913C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 23:07:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A5C2218CD
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 23:07:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ywXTDDJ+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A5C2218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94E7A8E0003; Tue, 26 Feb 2019 18:07:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FD8B8E0001; Tue, 26 Feb 2019 18:07:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C5F58E0003; Tue, 26 Feb 2019 18:07:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 485848E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 18:07:40 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id v125so3419995itc.4
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 15:07:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KtH8YR8boDh/kFz1GRhF//TXEVdCzcoFIHHXCarlfc4=;
        b=Lo35x5DDHogFBzlBv0kq8DLrNAW3Jwg1QlRFe0pZj4VVXhp9oxSjz7b2N4aFPzptef
         1kLRdUDf2QfeSKzE7vLeOhrG9cCdSxX14WTROsXKBeHR5wB059mUNklIFxiImuH3/R5U
         iasQHRW6jZ8TYv55PJHrQXIlMzxjJa8smf+g+rc+gfprKcysfP44yR/edFo82/dTz+Q5
         3CFD0++FgeQE5fmXenusrkMIi4PGFzV34o4JF5xJigBoImIpsyDq2JZyybAfp8BpZEZB
         pfBu7n8Lk+tAwoQf70tkgfATRO36aiHFEQqAFhxbFXTRZyLoZz5Gn/yK9sM517gNjG2Y
         1KNw==
X-Gm-Message-State: APjAAAWeUhGa+NvDxPPZTfk5q0RFUokLze8unXXFZoTr7TpkAHsvVyk6
	7aiPjNzcG31vmlX2QQy/PcuvApad02zr5AhsD/pxIY0PS6kNlqQfpCKVaKId49q7ypnpfhVSmhb
	dNF3v1n1ZSBbQLp2TofcLEXwb4+R/i6yJ9sAL9ykfhkKzjxyKrAw1Yb/GdhIfrQu7Mw==
X-Received: by 2002:a24:d55:: with SMTP id 82mr2619162itx.21.1551222459989;
        Tue, 26 Feb 2019 15:07:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbOzTwTy6OSkqSmUVFCuPJ6/BUrUzOEiqbuQzu5PxurYC8Q1Iv//58NzKHFgoQuKdQST1J/
X-Received: by 2002:a24:d55:: with SMTP id 82mr2619119itx.21.1551222459092;
        Tue, 26 Feb 2019 15:07:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551222459; cv=none;
        d=google.com; s=arc-20160816;
        b=Ghc2qico1ZAq6H+aqCgDWoAo48WEJyD192dxD+GN9WSAPiNyCvRXVVcmxi5QgfACWu
         SdqyKO6cR3TyvpN658vKUNUesmP6PU+eYcDAV4dBLft+4xm1gUblMtAx0guFNSzOfMiG
         hgVRLamu4Zh6nYuBJ3N5bsU9276kZnOKtt1aQ94uE6Y3gjraXzy7DtQ9bR/7Yw1SMCXM
         uxQgdQZZpS77F9kow5EiWx+EZx4w4C46q9AzH9a8LsAR03nzGkOmakfe9jCrSXwVpMk6
         9cFCLyKu1p/gdGOsc705dKTmV4jcqGvVBdXuRQN8x0nV+8eyC6TEDBLSSXdoSOdTFcRp
         tW5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KtH8YR8boDh/kFz1GRhF//TXEVdCzcoFIHHXCarlfc4=;
        b=pGrNi/GoXschsPzejfI3NhPrYIZQQapEA62zxHecrX/HZ5DUv8AHZgnvNhIQYUViFW
         f0svHrIANq0WOi4hhaRBpb3QXAYfzEd1JHDpVksXPzB0esGIKVW0J1rxLohph+s1BVYo
         M8DlqLPTUVwQVLg2Ub2H0DFkFl01SiM+b6u43il+laDusAeRQEfW01/Yv/xdv/kh/sJH
         dI4Jbej+nST8Xr5y0JMbFlzFmHXtzC0+dYLtrZbiHiQCf1wfmS8HeswQZBMc9uPF9Wo0
         MBIAbexY7SC8ZT/qDy9Plox7ixNtn+lbZEkoL7D95kalXcPS0TLFsK2hN8TFE4OKqIb7
         kSpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ywXTDDJ+;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id h133si258284itb.59.2019.02.26.15.07.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 15:07:39 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ywXTDDJ+;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1QN4hQt191453;
	Tue, 26 Feb 2019 23:07:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=KtH8YR8boDh/kFz1GRhF//TXEVdCzcoFIHHXCarlfc4=;
 b=ywXTDDJ+9PL6p7HMdSiuoZmX6q4G/nkhtacmd9Yut7q+4vGkYlqezV5kw7P5cet8D64G
 aHECJqVxlWTAZ88yA3hQNfSOnkwvsTNRYYWXfFLfwNYmmvpqivJ7xKZLV333CTQKSL1N
 lkjz3+OkpggCvSm+Ipiq4UWESkyiJc58XH/BvanvWj0TfzUt6DTr4xWy7GI7nxt6VYS+
 QZ1h1UYtZtfAXfgX+huMFska8XsvrwT8mNlQIh0dBPdhmEnCs4ScUD0/6uT6TGPg68Gz
 s/n09CY6/qAPR2zBcQ1YjcwWZDcC1zddrdY4FXzah50rMlzCWcrUHSuclBlBokxPRj2c bw== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2qtxtrqjke-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Feb 2019 23:07:29 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1QN7Mdu015611
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Feb 2019 23:07:22 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1QN78VO017915;
	Tue, 26 Feb 2019 23:07:08 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 26 Feb 2019 15:07:07 -0800
Date: Tue, 26 Feb 2019 18:07:29 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
        "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
        Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        Tim Chen <tim.c.chen@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
        Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>,
        Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>,
        Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>,
        Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V8] mm, swap: fix race between swapoff and some swap
 operations
Message-ID: <20190226230729.bz2ukzlub3rbdoqp@ca-dmjordan1.us.oracle.com>
References: <20190218070142.5105-1-ying.huang@intel.com>
 <87mumjt57i.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mumjt57i.fsf@yhuang-dev.intel.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9179 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 lowpriorityscore=0
 mlxlogscore=794 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902260155
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 02:49:05PM +0800, Huang, Ying wrote:
> Do you have time to take a look at this patch?

Hi Ying, is this handling all places where swapoff might cause a task to read
invalid data?  For example, why don't other reads of swap_map (for example
swp_swapcount, page_swapcount, swap_entry_free) need to be synchronized like
this?

