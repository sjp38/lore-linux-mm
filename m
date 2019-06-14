Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BE68C31E50
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 23:34:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 182BB217D6
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 23:34:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="fteRuuju"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 182BB217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABB1F6B0006; Fri, 14 Jun 2019 19:34:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A44F06B0007; Fri, 14 Jun 2019 19:34:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E62F8E0001; Fri, 14 Jun 2019 19:34:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6456B0006
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 19:34:01 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id v11so4590169iop.7
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 16:34:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=xC57jn87JyXy7UEJGYT3I0BpBDnQuaSrP5i3P1QlI6I=;
        b=A6LHFf4a/9TzWaHgBb56gu/ZTHNQWyJJzBditBElX/ek0RKNxiM/h4bZDl2rILDb1O
         jbgMH6SX/azB0QAU7nFzLw1nL3xJ9caxQd9rOGvsQvTKRYGnMuPRbYOZbNeQS7SBNBN0
         mmIQdqaPXUqm67Z5lxxR5mH5tTjcCooOl4cSfBOpbebeBU4U6XKAo2wVdEbw5AUhQvek
         wyEehpRL9Lvk0G/eMLoOEDvDalNkSr+OsCZDc2WpYOkB9XRlCstq18UWRPgjHF9ygHC1
         0hPUfyxRIx7nWL5feCh+7kd5bxtYvbWUt97mnk0uKwuoMCbLOqmXI4n4IRwWja8cnyQc
         5gsg==
X-Gm-Message-State: APjAAAXHUlTw6mjlIW8Wi8flsP9n3DW8eozvbpw5aerSj9qCkqqHcb+j
	cbNcLsTsi6gMCuwNfZ+r3UjXYuv5s66Djr/D+E42fKOrPG1FyYgtqcoRrsIJFVmscX2XYmt7MLJ
	zYjSOjyq1z4BPYuRNlqZ2K+DwGJIRYBErOJjE3Y1NDUbMlMFWAY5+4GI1TvqQe9fzlg==
X-Received: by 2002:a6b:6409:: with SMTP id t9mr21103255iog.270.1560555241189;
        Fri, 14 Jun 2019 16:34:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+KRN96MzAVnASFrCA9C9jMYC8YE7olvVYNsUIK9eqfIY3PTCMg1BUTSI/ZVMB+jorNfqQ
X-Received: by 2002:a6b:6409:: with SMTP id t9mr21103214iog.270.1560555240283;
        Fri, 14 Jun 2019 16:34:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560555240; cv=none;
        d=google.com; s=arc-20160816;
        b=BJ1ywsKMUg65iL5UNTi9F7n5YSE1KY+RdbRfqje6hZYZC+DRWeqzUr+leVu592RL2N
         MjW9jQAWUi1SeinbE3v6AQhAgNiDGyvFohzetX+Gc/QusRLqLVRB11c04qpFbvGITVHj
         NkOu/b9l6cLdnE8scWB1poBtHYrdhp+HHL9A6osVivxuIAw3168j0STN2SXRLyOE4mJZ
         JU6z9X4xRCeCpsajT2lI8gv+wihZEHRVLsyMn+U2vas6+dUJ71LHGCAQVeRXzsyqyVD1
         9V3biatkwL573sBxqXt9kAsKRhxqxWOyVIKtPokYbjaU9uLCTWkH1jTyyCLk8+cLFvgW
         whHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=xC57jn87JyXy7UEJGYT3I0BpBDnQuaSrP5i3P1QlI6I=;
        b=1IITGWM9h5Dxr15uQgLCuspuwcZ2x3h78XLR+JdA4TrwcWflx56vS4lRqh3KZ6rEkQ
         W50L46Ba7NUyf30r84HoDaKJTYfV7vkc9Q1yOYoWprlSd4mZu1DQXUq3qrUaa/QBduwM
         vrBai7Q1cmQzrUXceainS6bfMRznIT3K23yVaZ9juLRrIDj9DK7qix0FYvA7KEgwHyFj
         TPesMyfx36yDDFPGDaNbMfaL/2DmYx5xSeYTkzJEutKN8BXubIDSa10ZlAUaMYM9u7Bl
         +Nbt0HG+aFgSJNwSwYOZvF4L+IZYZVqU0z5g4gKDVazJCi/EUvv1HZ/IonFzYreXFbwJ
         uasQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=fteRuuju;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id p24si4383128iol.54.2019.06.14.16.33.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 16:34:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=fteRuuju;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5ENXaBH134612;
	Fri, 14 Jun 2019 23:33:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=xC57jn87JyXy7UEJGYT3I0BpBDnQuaSrP5i3P1QlI6I=;
 b=fteRuujufu3CmIQ0hpxr3+DyF3Am163I32ktIzUzd9sOepWWRmqepsAtq8Gxt4y4VAog
 LM2vzoQo1R5A/xCc7g6UYg0Q4MATHrE8QxJ6wLY2uu5nhFEZ/G/LZOgDkYOMtF7OFpZ9
 1ixxkQkAA0WPyqDBLwCYi0TktWyxmkGyOhPBL2JbS142d+gNM+gVbRvH2zIMyW3c1S01
 oQFRK0HZS3jkXyMKG4wQjuSD2eOZoUx5c+PvJXBvlxFZYpjdzHUq52EZYK6QaurDHB5h
 0vd5nkpD5p4NYWyj4QcAjFe30PQNSHNx/1oFZuDMchT0o+UNU6VZGKOZp8BWI/1PzvWw Iw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2t04eu9srg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 14 Jun 2019 23:33:57 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5ENWsED162221;
	Fri, 14 Jun 2019 23:33:56 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2t0p9t7n0b-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 14 Jun 2019 23:33:56 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5ENXtO0029569;
	Fri, 14 Jun 2019 23:33:55 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 14 Jun 2019 16:33:55 -0700
Subject: Re: [PATCH 2/3] hugetlbfs: Use i_mmap_rwsem to fix page
 fault/truncate race
To: Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>,
        stable@vger.kernel.org
References: <20181203200850.6460-3-mike.kravetz@oracle.com>
 <20190614215632.BF5F721473@mail.kernel.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <f8cea651-8052-4109-ea9b-dee3fbfc81d1@oracle.com>
Date: Fri, 14 Jun 2019 16:33:53 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190614215632.BF5F721473@mail.kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9288 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906140187
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9288 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906140187
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/14/19 2:56 PM, Sasha Levin wrote:
> Hi,
> 
> [This is an automated email]
> 
> This commit has been processed because it contains a "Fixes:" tag,
> fixing commit: ebed4bfc8da8 [PATCH] hugetlb: fix absurd HugePages_Rsvd.
<snip>
> 
> How should we proceed with this patch?
> 

I hope you do nothing with this as the patch is not upstream.

-- 
Mike Kravetz

