Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEB40C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 21:11:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A68812067D
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 21:11:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="iuT/ehJL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A68812067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45C3E8E0006; Wed, 31 Jul 2019 17:11:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40C988E0001; Wed, 31 Jul 2019 17:11:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D4A98E0006; Wed, 31 Jul 2019 17:11:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB0B8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 17:11:12 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id o16so62626583qtj.6
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 14:11:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=rGOpE1K1seHogZ0v0vORCXGLdurKCucP7xDezduMaQg=;
        b=gx0LYv8h+5wgKJcl6Ejtx35J6lyKvNzRn5ihH9JcadyZyWi4kRAdx6B1MOwHTIt3wy
         pZiqEyH/XiNaZzXasNy2AdCHNJ8jbfyFzQ2SwBgUoxFJSda68xI0V4M5MkpHIs1vxT2L
         2wdhQsm9Jy/Wv/4ITkDmwDixoDBiaDumh4cWXnta0zP+IAiKH5HdbJPRCsQJTWOPwF3P
         G9zM18oW0e7B/hPIWrDLeFnQ4kv7/7QsMurlpZZLW2w4v/AXcbZD0FP2j7MDrbNbxnKL
         0wYN1/g0yBTFQxlQMrtUCtx06hCsjPFVzDtkz7zjx9gKzR46wHRd5IEjTEsm1p91ufc2
         lccQ==
X-Gm-Message-State: APjAAAUagbY2+eutKMi9crwZGlyfEG1bUe+5oyd5ZthYMnwQvZp64lm0
	Io26ZgZ5ovizJeNa5an1UmDp3WlcGZZWru/8JyFUD7YA1Cgq71dPQgNvRhmL/GfUXMidGzzGfX+
	B+eaZ9FCiagaVpOqCQxhwpG3MyZPRzXouz0QymlAdGbA454su2/FyaRWs6Gd8cySSUg==
X-Received: by 2002:a37:7ec7:: with SMTP id z190mr82650282qkc.347.1564607471811;
        Wed, 31 Jul 2019 14:11:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVrFrpiZ6uMo0Jzbn4za11qPwIOxfc8QHN5CdCrd0sfFmEK5VCj4uVttRLC0IaCPSyiOZt
X-Received: by 2002:a37:7ec7:: with SMTP id z190mr82650249qkc.347.1564607471310;
        Wed, 31 Jul 2019 14:11:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564607471; cv=none;
        d=google.com; s=arc-20160816;
        b=oXePgKs8NqBjDhMVbiCaR1Rw2lcBRL1KGMiehJN/3P2RskX7opL8xV+ea7sT9nLrbT
         AqEeO4fENos7QrIW6seZvQ87kZKBXLYEaAVs3WiAX71Yu1hntQNpkrUhmEfIG+TOuYTd
         vuLGordKWe+YaFDMa6cIWDhC38h6HIiJYLQV95lBCyO9FUXLWfBP4gZzBdAMQjNUsTZj
         efrWmI8QM9QIVz91LDZ1aPm9T9Pdvao6fZRE7y/AD2ImuoKvHg8YhHTom9V/7KwlsCJV
         AO4yz3w2Y12xjxLfJF1HbDDmDqW4AIj0jtxAN6urqXFNh+fMKNvqPC4+WIN7Cu8Sjl1K
         H2OQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=rGOpE1K1seHogZ0v0vORCXGLdurKCucP7xDezduMaQg=;
        b=kiWfYX1RJS9vqGwfpFx1ffq3+itaAJy8sd37qgwRCcTEtLOErEkiKx9WyzpKAJRd3L
         VB/S929PA7Rp45nt43H2gmPPyTnzDh9wjfJzXOJs6aRzGXoaA7nqIe41sJoD2D2Elylp
         3WqunKrfNSoBjlTafg0iRc4s4kaXslUN59cFE9pgsG3vR3E0M7teajClmTvx29TRmPbl
         LwYpaIq4FJFxSa6qVQcXhDrwhYKzX5FxOaOMbX/ZBWZJ3rPbuWzMIrnPgdGV8v8Qghy7
         siXjOkckHm7guWYX08zLJgnl1PVZmeHi6veIBgPX56KO+HUES74hOMoRC40ZSFD5Q6Tx
         inyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="iuT/ehJL";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id q68si2074204qkb.286.2019.07.31.14.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 14:11:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="iuT/ehJL";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6VL8vL4165405;
	Wed, 31 Jul 2019 21:11:07 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=rGOpE1K1seHogZ0v0vORCXGLdurKCucP7xDezduMaQg=;
 b=iuT/ehJLyJhBOy1y/iDHREcUYlOM80E8e3wO2yHP2CAjoqR8TuG0bym9TdariihNbvCX
 GTbIRNMRNzd/EEDQoKkYjz2ot09j3WUc+hmC+3VRvfzR44MuuBPxczIeLMYSpS423JKy
 mOMy7rt2OB4wZ++gyjtQ+tEIi9tMHNTtrYdnxjfweFoI6iAqfkV6DS5vQ3BlWmgDoFqf
 SbK4cJrdDRv267vO2WzikXriwA7oTdMxvjbkko4f9Aaw401TQL5wYydvSak9fGo1hMz/
 unC3SW8WkJFW1d8YxafNQsWmLNPWUJ+4cxeUUf9gq3EYtIbJvMMAi/4Fqa7ZCzt9909S ww== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2u0ejpqrpd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 21:11:07 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6VL7nx2168911;
	Wed, 31 Jul 2019 21:11:07 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2u2jp5gn3d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 21:11:07 +0000
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6VLB2BH024191;
	Wed, 31 Jul 2019 21:11:02 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 31 Jul 2019 14:11:02 -0700
Subject: Re: [RFC PATCH 1/3] mm, reclaim: make should_continue_reclaim perform
 dryrun detection
To: Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hdanton@sina.com>,
        Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        Andrew Morton <akpm@linux-foundation.org>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-2-mike.kravetz@oracle.com>
 <20190725080551.GB2708@suse.de>
 <295a37b1-8257-9b4a-b586-9a4990cc9d35@suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <f6e25e52-bb02-6d79-b9fd-3acc8358ec45@oracle.com>
Date: Wed, 31 Jul 2019 14:11:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <295a37b1-8257-9b4a-b586-9a4990cc9d35@suse.cz>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9335 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907310212
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9335 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907310212
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/31/19 4:08 AM, Vlastimil Babka wrote:
> 
> I agree this is an improvement overall, but perhaps the patch does too
> many things at once. The reshuffle is one thing and makes sense. The
> change of the last return condition could perhaps be separate. Also
> AFAICS the ultimate result is that when nr_reclaimed == 0, the function
> will now always return false. Which makes the initial test for
> __GFP_RETRY_MAYFAIL and the comments there misleading. There will no
> longer be a full LRU scan guaranteed - as long as the scanned LRU chunk
> yields no reclaimed page, we abort.

Can someone help me understand why nr_scanned == 0 guarantees a full
LRU scan?  FWICS, nr_scanned used in this context is only incremented
in shrink_page_list and potentially shrink_zones.  In the stall case I
am looking at, there are MANY cases in which nr_scanned is only a few
pages and none of those are reclaimed.

Can we not get nr_scanned == 0 on an arbitrary chunk of the LRU?

I must be missing something, because I do not see how nr_scanned == 0
guarantees a full scan.
-- 
Mike Kravetz

