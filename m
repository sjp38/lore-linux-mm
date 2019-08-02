Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E597C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 17:44:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39886217F5
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 17:44:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="3JwoFl2z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39886217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3BBE6B0010; Fri,  2 Aug 2019 13:44:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC5356B0266; Fri,  2 Aug 2019 13:44:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C65D56B0269; Fri,  2 Aug 2019 13:44:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7DF6B0010
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 13:44:15 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id v20so19932574vsi.12
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 10:44:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=mFJnWPsLkfWIU418J/eu7cnHB2GNRY14US3jIIdLi0k=;
        b=QU/Nh6cIWeTaIARAMd0e5cDw/FXQ14i+L5sAVpI2zSY68rywtJRPDSlE9V22jHjfpb
         4g4dOT62CvPDO5EF3+ccRhtCWjEz6Lp6EJOpbao25ZTKjSEC0kN1DrZBQ99YuGSMp6IO
         +JaGpNQoYziqheMhtjp2cY8Ql/oUKNM+OWeNM+a7WXJuoEoEwZzdFaocrWTFRYTUHgl7
         kZZvtO8KB4JWhliyskBCWVUEcZcsgxE2iBJ/dSiIl2IF9xFfaqkKFt6eB4hzO4Qh3Nlz
         TYcGQQbxYpua36awXpVRNNbeYLhGb0VBP4qff3Aa9bGuqv51NdGRfbB9Vbnif3v/+ibG
         uekQ==
X-Gm-Message-State: APjAAAWNwjBB0uS1pOcdsIXv/UT5fCJI1dyOQpm97G+LFUAxMyXXagG8
	gNEBk57cZny009hpR7+asZkC9kPSHD57L2E+jwLhihDnxR0w1NYHOPe6FfQNuk+GFGfJCzdVcTN
	k3bjqXH/CO6KieP8NODgUvLsildgQKyi97H86idMMtgv98m5Cy/7o2N5q3BsGIGnskw==
X-Received: by 2002:a67:d46:: with SMTP id 67mr87293444vsn.181.1564767855325;
        Fri, 02 Aug 2019 10:44:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXAqqoSGVUd9lOv9G3XosYzzkzdrhzeHBQ0l13inRv8NA5WAIPYopA1SnESiGQ6I1kS/3t
X-Received: by 2002:a67:d46:: with SMTP id 67mr87293408vsn.181.1564767854371;
        Fri, 02 Aug 2019 10:44:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564767854; cv=none;
        d=google.com; s=arc-20160816;
        b=QVe7tI1SwxXut7g/ncdobdU3hj+lfIwYHb6FZPq9XkCQ4GZB0MJk0BqB+nrHesYQ/e
         aOFsppABviw+cCc6jMjoUhM1xIN/aGC616jFW+mZtGJ068ul87Rjtt6RgYLPVmbouimJ
         fPyqTBl18o3Mqz1dOXnEzDnFKB+HXP46sD8bDJ3ql7EBAN2NRZIWy+vlwAqfvsSqupvp
         k10z9OocVONocFrpsn7SfH5QK3+W9HWLnP2us35Sendlrz2fWJldyKlq+3SWKbkJ8Wkx
         YBE1kVNU9o692Homk2um2LQDOb93ksX0l1iEAzu3jMavaIODfQqRo17AAXPlNC8D92Mo
         apQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=mFJnWPsLkfWIU418J/eu7cnHB2GNRY14US3jIIdLi0k=;
        b=HiObHvddoyFPyiHzzfYU7juI7p/58GVm3V6GWHwZYUEn/LZQXLuwvwlfVucz23ZD+S
         3778x4h5zdCETGyc5ozlHrpsNInGvdFTVGNKVeKRoHfL9ruqJzy9ejfFtWLpXTfa/X/m
         8qWdISH3TAReDYyaZ5/eyml9D7qvKjcu/NldIHgAaNbKtDbohlAmt7pEAS10glpNMbwi
         CDvzHbuCXsvZRrjFFl3/fLdYOEhLbduZhZNFxqgJ1M4tXrL4aLrd8w2fLKtAqoiZOU88
         +Kx0RAPj0E031bGDCuTL2/qQWnGAN1x29PEI4u+IH1/0FHQfSAvhxi2hGtwwVSIyG5Z8
         d77Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=3JwoFl2z;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i10si25341253vsq.387.2019.08.02.10.44.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 10:44:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=3JwoFl2z;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x72HchFe091893;
	Fri, 2 Aug 2019 17:44:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=mFJnWPsLkfWIU418J/eu7cnHB2GNRY14US3jIIdLi0k=;
 b=3JwoFl2ztyfkO51CHb5kld6rr2eul1DUa0E4QkCVPaQoPn7oc5XqE3fcRaecVhFc+++w
 +1Ca+nxRTuHfrGGiAZqsaePGrlmeduRLiGheEtee95dUZGTjkFxstSfLKM0erTUKZkaE
 rbmCwDKdnzS7kauNKjkKDBrAfXcbolKqZPaF88AAuD//LB1dZPpGdXLaOn7csTRuelBm
 70uhBFCJ2fr3SPAkXqWhbhQDMNZmiC/UOXVtg49TsFty2ixz9g7k4RjkcXxUYPuhnvXD
 64Jd+Lt3Go6njos8eoDWy3lFvFXaGwdEKfwnkRvHaAZ20dgWIP77FXc4C/FeYIjSsq0q +Q== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2u0f8rkk11-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 02 Aug 2019 17:44:08 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x72HgfZf029870;
	Fri, 2 Aug 2019 17:44:07 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2u349f6pm0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 02 Aug 2019 17:44:07 +0000
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x72Hi4pM002517;
	Fri, 2 Aug 2019 17:44:04 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 02 Aug 2019 10:44:04 -0700
Subject: Re: [RFC PATCH 2/3] mm, compaction: use MIN_COMPACT_COSTLY_PRIORITY
 everywhere for costly orders
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
        Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes <rientjes@google.com>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-3-mike.kravetz@oracle.com>
 <278da9d8-6781-b2bc-8de6-6a71e879513c@suse.cz>
 <0942e0c2-ac06-948e-4a70-a29829cbcd9c@oracle.com>
 <89ba8e07-b0f8-4334-070e-02fbdfc361e3@suse.cz>
 <2f1d6779-2b87-4699-abf7-0aa59a2e74d9@oracle.com>
 <88e89521-9be2-3886-2155-c7f8d9c22bbb@suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <45eb7fdb-9390-74d7-6198-6d14a9c78939@oracle.com>
Date: Fri, 2 Aug 2019 10:44:03 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <88e89521-9be2-3886-2155-c7f8d9c22bbb@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9337 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908020185
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9337 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908020184
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/2/19 5:05 AM, Vlastimil Babka wrote:
> 
> On 8/1/19 10:33 PM, Mike Kravetz wrote:
>> On 8/1/19 6:01 AM, Vlastimil Babka wrote:
>>> Could you try testing the patch below instead? It should hopefully
>>> eliminate the stalls. If it makes hugepage allocation give up too early,
>>> we'll know we have to involve __GFP_RETRY_MAYFAIL in allowing the
>>> MIN_COMPACT_PRIORITY priority. Thanks!
>>
>> Thanks.  This patch does eliminate the stalls I was seeing.
>>
>> In my testing, there is little difference in how many hugetlb pages are
>> allocated.  It does not appear to be giving up/failing too early.  But,
>> this is only with __GFP_RETRY_MAYFAIL.  The real concern would with THP
>> requests.  Any suggestions on how to test that?
> 
> Here's the full patch, can you include it in your series?

Yes.  Thank you!

-- 
Mike Kravetz

