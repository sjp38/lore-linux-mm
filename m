Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41468C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:39:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2F9720700
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:39:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="wDb1seI9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2F9720700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 951616B0010; Wed,  3 Apr 2019 12:39:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D7AA6B0266; Wed,  3 Apr 2019 12:39:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7779A6B0269; Wed,  3 Apr 2019 12:39:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 535136B0010
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 12:39:49 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id b1so17209400qtk.11
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 09:39:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=NjqszMs7E3gOIGdwaUNs0dj+AbjCWmOyC3cb7a2Lz70=;
        b=Q7tqVIT0vP/GPr+5PEXtuAPlWkqIHwO2JGJgZsaB5oNEFTGGDDM4MoCwOakOj0c3HS
         s9S8trFZgYijr4jqLn8M3F/zN5/rlXJwmToHKFwB2mzsliViFHPS8kBEpBMiBIV81UDM
         qFPVX5COzIhXH8nM0eAphBAQktu61YltMvxI3jXPmWALGCthB1yFCQ8uq1ZZ5xPvDJ2y
         qYFg/B7YZrxBeDgSCIPHZI/4roUNmmPNTCMrv3AatxeQc56DXp9GQ048qnPVB8DXzEoV
         +wwNW7LE3g9TDIknfxk5Fk6cPrkS040xGLDEVQj86dk6H9kjVgkk244J8j1Pam1Mqrzx
         ab1Q==
X-Gm-Message-State: APjAAAXsRcJDPwRlYUdkM+9eLyZF59VCfrMUQipzird3NzGfUnHI4X/S
	xD4Gg+xTomtclzScBDc0FsP0ErxE72wWznAI5aA+lDwNVPPrceSwEjq15HV5UxDMni1xO7RggH1
	BVwKknkUBlZ2RPcHOzOquBt4NR9FZGZmYPLPj7Tl5D6W1IPktXSXWEXjEwedXHQR+pw==
X-Received: by 2002:a0c:e014:: with SMTP id j20mr469530qvk.172.1554309589077;
        Wed, 03 Apr 2019 09:39:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzezrsz/uObHPAVq6CXU323NcxYSx3wvbfHl8A7tLrn9rDti5yvw9rlu0K5ecUR2Ec3bpx
X-Received: by 2002:a0c:e014:: with SMTP id j20mr469489qvk.172.1554309588371;
        Wed, 03 Apr 2019 09:39:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554309588; cv=none;
        d=google.com; s=arc-20160816;
        b=D0GcB18B4Rwi6LBriGEQZBtKu1gufv94yurWY8TNNEcGR3Wue1DxzmcnJWlw6gwdSI
         e0MQ83f8R3pJ2GCVd6c8uoeL83JIAcG2DD4LHZUsxrSsFIgjAYnOIhmQkA92tc84RBF3
         /YYxmFgDO6XSWfBBgVDZKx+zpE1y+hcVMMbHo+8hLhis/21eEtuLDSdD/u4CUdhD80Io
         PVqwfp/gyJlS+8OavmjBxtxkxeGHzjjE4RAvs6gYZ0K9XrqZ+dRdXYBKw0PVkdTP915g
         AhVw52DMYFKyxfy0T//tc3/lWfWPFjDAYlOMVBLWGrauDbMMqb/WU6HEkBaWBRj05q9o
         HsKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=NjqszMs7E3gOIGdwaUNs0dj+AbjCWmOyC3cb7a2Lz70=;
        b=vwubLMKrzIsP1T2/iZscTzoE+mTnDeczqec3FcJs40rEmO7Kz5DxYA5EDAgtvYXfTb
         OqFQtE0+STGajX4v2C1hQR2YCADWkZwn5RzCDH/VPzpySn7JXjNLoBZrKTAMeSjkZwDz
         YBhF82O5SMncubFkHAUyuWNqGyof01HTHlhtbnl/GOpZTxGrHZJWSnxa2cGlZrX4wecH
         V95IUYoj+zf0emzH6T1RvPCRqvjCt4tlzDjfzP8U2BpApJJAW2NyMJNd55XHMNbLSUwg
         y2YZos+h+QV3dwNzBQSuzvyrsBoOOa+yN2br69cdztowlQE3iFZ0iJq22TEb1V2US9JG
         CQIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=wDb1seI9;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id w55si1270893qtc.350.2019.04.03.09.39.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 09:39:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=wDb1seI9;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33GY8DS123283;
	Wed, 3 Apr 2019 16:39:41 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 content-transfer-encoding : in-reply-to; s=corp-2018-07-02;
 bh=NjqszMs7E3gOIGdwaUNs0dj+AbjCWmOyC3cb7a2Lz70=;
 b=wDb1seI92hgo522RHXd4reMB9zkAqMls9VSvgcdjUxogKDD5J+hXR5nIQ6e1RF5nvfeJ
 yvo1WDLR0+cay945s5CowFcHd3jjzFZsf4NS8tDvswsKUon3j/9rmrDfnflM2DN40AQC
 p89U9xrMzz6NfdNVkdZKpfv+QO+E+XcrFHW3a3bW3Yscf6TYAeMXf/MfLJT019LJdBfK
 qdoyh/i9H5STZJHeLFWFhiumH7e2qsq6PZgeEevBUBevAR/O89c1IO+XNEmBYeTXoSRa
 fe8vgBSoITQUVaIUvHmDjdmDSMaVpIu9e2EuZje9U7/e6xrb5k3v7b3RkbJWxOWfEWrK Jw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2rhyvta869-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 16:39:41 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33GdLsm003451;
	Wed, 3 Apr 2019 16:39:40 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2rm9mj5jn4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 16:39:40 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x33GdZSM008090;
	Wed, 3 Apr 2019 16:39:36 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 09:39:35 -0700
Date: Wed, 3 Apr 2019 12:40:02 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
        Davidlohr Bueso <dave@stgolabs.net>,
        Alexey Kardashevskiy <aik@ozlabs.ru>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>,
        Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH 5/6] powerpc/mmu: drop mmap_sem now that locked_vm is
 atomic
Message-ID: <20190403164002.hued52o4mga4yprw@ca-dmjordan1.us.oracle.com>
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
 <20190402204158.27582-6-daniel.m.jordan@oracle.com>
 <964bd5b0-f1e5-7bf0-5c58-18e75c550841@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <964bd5b0-f1e5-7bf0-5c58-18e75c550841@c-s.fr>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030113
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030113
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 06:58:45AM +0200, Christophe Leroy wrote:
> Le 02/04/2019 à 22:41, Daniel Jordan a écrit :
> > With locked_vm now an atomic, there is no need to take mmap_sem as
> > writer.  Delete and refactor accordingly.
> 
> Could you please detail the change ?

Ok, I'll be more specific in the next version, using some of your language in
fact.  :)

> It looks like this is not the only
> change. I'm wondering what the consequences are.
> 
> Before we did:
> - lock
> - calculate future value
> - check the future value is acceptable
> - update value if future value acceptable
> - return error if future value non acceptable
> - unlock
> 
> Now we do:
> - atomic update with future (possibly too high) value
> - check the new value is acceptable
> - atomic update back with older value if new value not acceptable and return
> error
> 
> So if a concurrent action wants to increase locked_vm with an acceptable
> step while another one has temporarily set it too high, it will now fail.
> 
> I think we should keep the previous approach and do a cmpxchg after
> validating the new value.

That's a good idea, and especially worth doing considering that an arbitrary
number of threads that charge a low amount of locked_vm can fail just because
one thread charges lots of it.

pinned_vm appears to be broken the same way, so I can fix it too unless someone
beats me to it.

