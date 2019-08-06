Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE1BAC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:27:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 683972075B
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:27:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Ppt8cSQN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 683972075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09CF56B0008; Tue,  6 Aug 2019 13:27:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04EF86B000A; Tue,  6 Aug 2019 13:27:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7F6C6B000C; Tue,  6 Aug 2019 13:27:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id BCDE46B0008
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 13:27:12 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id n199so35500572oig.6
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 10:27:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=KBUngTRZprbO++Eb+szGpPG6NefHy8tBupTeXYUVbsM=;
        b=eV0V0UaDVgijCimjz4iv+RNEycGvTIX9dEwG+/MeHHVgXJBauHljN9hgjRHO+sEoEa
         /DDyq7O/kyV0pw+VFbWJuwQ6ts8eDsjocXcu9Uym3MT68eRxKkPPSkygcRTzZmxZbD0D
         MPIVyjkKmbZ2akAfXHP/1iHePINOX2slrU1B9ftG+cTWWFPYnoEcfvZZJemIpk2jFgzs
         GuhHfQTR1gT8MJ8dovB1i9zNIpq3wuEjc7wBg9HsLV5ktCGxJ1AqEyXcaWVjriOLeMbu
         UHF1Ofi0z7kvfISWL0ZjWnE/vyRtdtuAN3lpojauZt5I1LBDmWFBYOo2xbT0lEj55LM6
         xYBA==
X-Gm-Message-State: APjAAAX7ZCvaGzgliHiG1WIHjqFS+aUp9eb7GQLzTfL9Xn180mtviZ23
	uL+JoRIMYqLk49raIujFWJZFrhO7cGq3p57/UoZFTS8/rbbNuJSwecofXCn1I1Sa+LKkN8a5maX
	bHaf3duL1jD9RtZoBtU7MUG4ALDUUSx63NzaYhnHG1UMsqbDxRv7eY+Bg7SPl2C6ErQ==
X-Received: by 2002:a6b:da1a:: with SMTP id x26mr4658722iob.285.1565112432395;
        Tue, 06 Aug 2019 10:27:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwns0+THFz3qPN0BeQxUF68GfACxAzy9DkENpbBwMBPYsva/KZjn+cKrnaUUp2GZu/Il+HC
X-Received: by 2002:a6b:da1a:: with SMTP id x26mr4658688iob.285.1565112431823;
        Tue, 06 Aug 2019 10:27:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565112431; cv=none;
        d=google.com; s=arc-20160816;
        b=v7UKQjqZts3RWwu5mVZxDlYnvIWzDDUxyLRZIlZOf5nkCl4GMdcZwde0wylqv+LY1x
         KByuWWrVkuq3mDp4ip128+15+N23IcqZoPp0kvOLHmuHMz1Ifdr0pLCa4H7RsjRUUZCs
         HE74dlNkqaMKX1ht8BFwbtnJ8LwzUlrzi44HasAureT2JS6x5o5Wvt0q7t8cpe75/LlL
         v2dz4w4APGlVCvAyJ+mfBII8PzWsmikWorbo7t2ZL1B+YSStHg8dl31wF0O6LSjV+xgr
         PViOMrsHu9AaGsNq04ZnUNWIZHnqkKutr6DBvZwacCd3mQNiJdwNK0CQumYkLSmJ9f2H
         jsaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=KBUngTRZprbO++Eb+szGpPG6NefHy8tBupTeXYUVbsM=;
        b=wWNLy3CneAG8wsIJmHSuBjfSBvSIS80VCn+MrtwZatJhaBQcxJJIqqV4vBOeSNu2Uk
         xYt/mmDlLTHBTJK9w1WCn7ofqPwt+nE22Ti5Lj5J/BwlXodR9pmJzpH5Da8lKd+hey3m
         dS657+pSawPzmLLFcxDYasNoVOiD+Aejz9rqld9szdfzliNFqyQmHzsk+Oy7cRzkTRch
         NYSLBbzKy5VQnkZFb96ehcOVNogFEQPSJoH62ja1yfXcltwXRUYcG706z8wbM8qTI57n
         1CtjXk+xbaRbKpEqRbxByRh44dlfIfbnSoECm8wLz0FiTiTl9F0i6FESLoGj83+WnnXT
         6YEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Ppt8cSQN;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i14si100156130ion.103.2019.08.06.10.27.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 10:27:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Ppt8cSQN;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x76H9EFo095481;
	Tue, 6 Aug 2019 17:27:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=KBUngTRZprbO++Eb+szGpPG6NefHy8tBupTeXYUVbsM=;
 b=Ppt8cSQNMuK0Cq/KrKDv4sBs6V+5euexG+kJuUAW2rZ7KE1SqIiiyZen2HOIhzNtXxBp
 pqA01ddnGl2HWm/Ur+o9dovrqpeyz2bYPYz6MHnAuX/SHTUdwG3skheWxl3F45Yp+n0X
 YQdLb3l9sliqNLCd4G1eAD0kjGxi2qxVLWDSW7vmR1QEdXD5D/qRvQkqMqHoORK6cKqY
 x8Z2roijL6BTgtENjwGtPr5tncFhjidN7BjumSLgbQsj1ngea6xPSnMk228ZF7ndBOxb
 D2MZJ4OWR2Cr5V2blscrfjrat6zEHeZmfVq/qQYf9U2iT7ohsao4TntqWImMPPdBCZ0m 4Q== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2u52wr7jgk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 17:27:08 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x76H8NB6141112;
	Tue, 6 Aug 2019 17:27:07 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2u75776pns-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 17:27:07 +0000
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x76HR6K4005006;
	Tue, 6 Aug 2019 17:27:06 GMT
Received: from [10.159.248.227] (/10.159.248.227)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 06 Aug 2019 10:27:06 -0700
Subject: Re: [PATCH v3 1/2] mm/memory-failure.c clean up around tk
 pre-allocation
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
References: <1564092101-3865-1-git-send-email-jane.chu@oracle.com>
 <1564092101-3865-2-git-send-email-jane.chu@oracle.com>
 <20190801090651.GC31767@hori.linux.bs1.fc.nec.co.jp>
From: Jane Chu <jane.chu@oracle.com>
Organization: Oracle Corporation
Message-ID: <cad86094-c9ce-7bc1-5342-2bb03b512e71@oracle.com>
Date: Tue, 6 Aug 2019 10:26:49 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190801090651.GC31767@hori.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp; format=flowed; delsp=yes
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908060156
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908060156
X-Bogosity: Ham, tests=bogofilter, spamicity=0.003160, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Naoya,

Thanks a lot!  v4 on the way. :)

-jane

On 8/1/2019 2:06 AM, Naoya Horiguchi wrote:
> On Thu, Jul 25, 2019 at 04:01:40PM -0600, Jane Chu wrote:
>> add_to_kill() expects the first 'tk' to be pre-allocated, it makes
>> subsequent allocations on need basis, this makes the code a bit
>> difficult to read. Move all the allocation internal to add_to_kill()
>> and drop the **tk argument.
>>
>> Signed-off-by: Jane Chu <jane.chu@oracle.com>
> 
> Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> # somehow I sent 2 acks to 2/2, sorry about the noise.
> 

