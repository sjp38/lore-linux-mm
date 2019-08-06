Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEEBDC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:29:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FEF92070D
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:29:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="iig6OvdK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FEF92070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A71F6B000D; Tue,  6 Aug 2019 11:29:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 058BA6B000E; Tue,  6 Aug 2019 11:29:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E62166B0010; Tue,  6 Aug 2019 11:29:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id C760A6B000D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 11:29:38 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id p193so37878320vkd.7
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 08:29:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mwKRUbvea1RoZlHkju0Jgt8karMzwfEnhDclcwgcZ5k=;
        b=kHJD+cKZ9L+OkWylVwEWJvCDe2JPC968HP6BlFJSKhgYwjdvCbzPguhuk9H64t2vc1
         YprBUfC2vyzFy6tybWalvmvi4j0Mo1vKeRwrVMDMr5YrLVYag/nMOibH4nSPv+gLMr4l
         Pn67RC55tBf1Zx5ntOzsU2xVFHhQajeplnwF+94rjbeecDgApfg30AIsHKhgKGAwwufg
         8Mxrv63lP2rJmC51RVMRvu1h1V4evcP6XQZXoK7XZ1Lr9wdQxqTzghH76mNnfL4pONaw
         BP7ERPopV6xGbbXJMPg04FNd+jyJEJBSc0u9uAn2pfcGEm4F4nK+Pg7GrG2YxLga81It
         0rDw==
X-Gm-Message-State: APjAAAUn/W9V8xFiYEuMBrO/YbOI4LcYRFYrR5Rz1cvsnO5DntWsCy/O
	1GyCheCyd9E/1Q/nDCBc1U+9TXYPHtnUmNcojfgsXZFvrD3yAjDvHTQFiCBlHFTX/n/WNSE2HSq
	25n4QJ+BgXJCVDMw5Ub76UDoGzclCQBVtEo34tP5pXhEKoBpY8V0dal0X1NPN28gYhA==
X-Received: by 2002:a67:f8d4:: with SMTP id c20mr2565224vsp.239.1565105378580;
        Tue, 06 Aug 2019 08:29:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWJ0SMMWeOKubpvL0fwPjpejeL9SJK76kcZn1zLT7nvDopkmeIMJ6lXUt7XQlEf3roAXGq
X-Received: by 2002:a67:f8d4:: with SMTP id c20mr2565182vsp.239.1565105377968;
        Tue, 06 Aug 2019 08:29:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565105377; cv=none;
        d=google.com; s=arc-20160816;
        b=Rb6WK+Q9wpx1C4Iq2QIN/jHx825ktzujPp9i5RB7Mt3+fQE6DsQa47jrq5K+oEOFIy
         jBXR9asW7mFr9MCwIkyQpzli5kx3H8MGEIkfD5IUEjNdqanUerQOv/2T+Zk8TN8R++Ei
         MxOsqdgfN6IMXauQZrWxDxo0bz9SeU3wcwQ2FshwYeIGTykYZj4lNc7hnUEXGf+NaLnC
         dO8pO1IlhT4sNk8L2829tEKERl7STStaEoGC5RlmVO5Hw90kmdyqPzc7xVQ3zG07R5CR
         WDcgNVVPwTK1aYmSBtgCIqwEJuze9Y4B9+GtfQ3E8GJso79fFUPhyVmxaudUWbr7mtFJ
         fQxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mwKRUbvea1RoZlHkju0Jgt8karMzwfEnhDclcwgcZ5k=;
        b=09vXcSuNFeAhM2VgpTRyfTBfvPYdzE+xWPxSAFnsctLdanzfciLP5fxZJJ1FUk0DaK
         PXNVFVrjEFjGNLy0XTczrBQuUhZgzTM8ntEUl/5DKBdvpkvX0ygpuYHxWGXu+qda+IG2
         q29sX1vpKRTLmY7jmS79D7nS34fPoZZMj1Z/+pk+g39WVo8NiSzxvzm01w1s2W4xipTy
         KMT5gmS9xpt8E2XNEvdlvTpirwHN8eydXBekI7g/xoNL32k4VBCN5O44lDoWhI1CEav5
         N67x4Vg5G5eo2TSUvgj0lbx4ucAETKGP3BvUAAOYagcSd3r6apmi1UoWusGADSWL8TVr
         xcUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iig6OvdK;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 123si18746849vsu.37.2019.08.06.08.29.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 08:29:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iig6OvdK;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x76FOAhJ069454;
	Tue, 6 Aug 2019 15:29:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=mwKRUbvea1RoZlHkju0Jgt8karMzwfEnhDclcwgcZ5k=;
 b=iig6OvdK7UxDLlknJ1toSnH2yi64wvYF+aLrAnHBB/pIt0JXlxAu5wPqXqkksQwhkhI4
 NcqrdG1H1GzCWFcTKX1OIIYBYbnzKNfv15BIBMuyXp6mB1ee03fYFIdmPdqtk0gSBH4+
 TGAVQNYg2w4kjKb6hZJaBAp/LwHPkb8Q6ByghVT4Wc3qan/CWqwmVJgJOE2Po3r0vopA
 Pxg6sy850+H2hCVMPmBXYk0gxuoA0NGXrWD+TF69bU/Gep59Umc0dED89QOAfC+zwLTD
 yyz6MGEpooNMlolbCvbjSqkZFXj4fxO13ntx9uDCVIg/xri/pLcuwDHfHQ1BS0WU6bVt qA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2120.oracle.com with ESMTP id 2u527ppvfc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 15:29:23 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x76FGvP2005403;
	Tue, 6 Aug 2019 15:29:22 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2u7666nukg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 15:29:22 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x76FTJtK013350;
	Tue, 6 Aug 2019 15:29:20 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 06 Aug 2019 08:29:19 -0700
Date: Tue, 6 Aug 2019 11:29:18 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux MM <linux-mm@kvack.org>,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Christoph Lameter <cl@linux.com>,
        Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
Message-ID: <20190806152918.hs74nr7xa5rl7nrg@ca-dmjordan1.us.oracle.com>
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz>
 <CALOAHbD6ick6gnSed-7kjoGYRqXpDE4uqBAnSng6nvoydcRTcQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbD6ick6gnSed-7kjoGYRqXpDE4uqBAnSng6nvoydcRTcQ@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=938
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908060150
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=986 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908060150
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 04:23:29PM +0800, Yafang Shao wrote:
> On Tue, Aug 6, 2019 at 3:35 PM Michal Hocko <mhocko@kernel.org> wrote:
> > Considering that this is a long term behavior of a rarely used node
> > reclaim I would rather not touch it unless some _real_ workload suffers
> > from this behavior. Or is there any reason to fix this even though there
> > is no evidence of real workloads suffering from the current behavior?
> > --
> 
> When we do performance tuning on some workloads(especially if this
> workload is NUMA sensitive), sometimes we may enable it on our test
> environment and then do some benchmark to  dicide whether or not
> applying it on the production envrioment. Although the result is not
> good enough as expected, it is really a performance tuning knob.

So am I understanding correctly that you sometimes enable node reclaim in
production workloads when you find the numbers justify it?  If so, which ones?

