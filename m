Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1959AC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 18:02:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA99B21773
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 18:02:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA99B21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E71D6B0006; Wed, 24 Apr 2019 14:02:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76F626B0007; Wed, 24 Apr 2019 14:02:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 612CF6B0008; Wed, 24 Apr 2019 14:02:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CABD6B0006
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 14:02:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f17so5280342edq.3
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 11:02:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=Gj3yYxWtpL6eLXYhjhvl8DmhBIH0PWDW2GhMngaHbvs=;
        b=CnLTjdzRLUViXMmhAEIhMaMooVE29/P03OpGUXbsmyjxSYqeYusfOxsqQJBtWkRKg7
         rFetIccdcD4HJwJYrR3UmoDZjTV7hiAo4LkxEW9+jJjPK/ZQtl1cUyCbCKFIowWIOx4o
         yXTTW2QjCTNHNBM7OCM1O0DACt2PMQqfDPmdJ7NrnOdR/bT1kz1AIuO+PnHDoGRZ51UV
         sZ/oX6w8RRetQvQ3wW5MuKx4e+n8ROttd+Fdi1xIQjSg47heNRPT0Si/k65MghtVdCg1
         QBPv7On0AZEDrOEh2bcbz75lYpySH4GjjK0+h5ocitPzebw8IPl9qWDDTMpF/VYYIRmZ
         zU/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVl/Ur+CfpHeB/lDuLCoQhSycU5wZ0HSge8E9BAwyYo+KelWcLU
	2c0Wt3MPKbSK2FJzJbWlOQhtNzLmi39X/C380Ki+jfuHKy+QFCAeLJx6onbdDc0FlhtfJVyx6Pk
	wx0llh6bFTOnB4itOraSQOAzRbkAUv0NElvi4cpxjzJx8Os2uxmuFFiQQU/2vJLZbBA==
X-Received: by 2002:a50:bb4f:: with SMTP id y73mr20648334ede.168.1556128946644;
        Wed, 24 Apr 2019 11:02:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx72PnuxXi1TX5TWNy0V5ZCc6Bwzf7NE6FtA26tUGKrGKkHOvTi6lUvC+v9QMPERZHKT5PZ
X-Received: by 2002:a50:bb4f:: with SMTP id y73mr20648293ede.168.1556128945846;
        Wed, 24 Apr 2019 11:02:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556128945; cv=none;
        d=google.com; s=arc-20160816;
        b=UKl05nxpWZ9O883rfg9eeNefaw3uJZjLTNrXqNPgBcBBCFuu9ehalmUjRgHwX6ujMt
         T+MIepSy6xNVwVRIQO8lqSefwzsa0QnE/R3nBJ0EI3wptNYDhE/63pcKDn/2BJqDdOPn
         GhR3urpt7Rwqec73/yVHYXvolsDiOE4qHNjYTXOiY4RDiwCPxjKvt6RTLIIk7gxl5TSJ
         npqzRNot24UWx77vTPSqQyH5N88TRMzGX5oTM3+Bl0NmBLT7CMw3+qY1LvoPwexVM9Qh
         pLsVpgbZmtXPWSZi3TJE4e8uxqQqusljtB0v8R3YsWm4u4po6jb4SaEcPO4SRrg0fYki
         NQVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=Gj3yYxWtpL6eLXYhjhvl8DmhBIH0PWDW2GhMngaHbvs=;
        b=fIt0TB5pnwluDIylhIaJt1dB8v/cMOb0jRZnd9KHIiywCfo55sjS3/8NTE3NIMDw2Y
         gmOJ9QqUCx1bZN8CbEfQEXiUXneRmOdsD8YFPRC4451Mzu0LMtM53LgrY7DY67Xwp8Q9
         bT1hvaU8mAw2GIIswFbys/k+7SblQ/WJO0BtLMSvcY8L6zzRYsfks7kRzaghWrmm9vGL
         PaFJNmXs0Ms74WGoyh5KnaJtSwMIeeZfjLwq8sCGfNotvsMNkSfRw2Rv289cOc3YMpIV
         JDAKcvJMtBaBI6y7BnZOQ74A0jFPoP8VMRl9HfWdBoHjLaj2usQJVtyzrxZEg1FPSBs1
         6IYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b21si1356867ejb.190.2019.04.24.11.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 11:02:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3OHrnaN047698
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 14:02:24 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s2vjere75-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 14:02:23 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 24 Apr 2019 19:02:21 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 19:02:19 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3OI2Iad44957784
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 18:02:18 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2AE31A405B;
	Wed, 24 Apr 2019 18:02:18 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9BFE1A405C;
	Wed, 24 Apr 2019 18:02:17 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.22])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 24 Apr 2019 18:02:17 +0000 (GMT)
Date: Wed, 24 Apr 2019 21:02:15 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] docs/vm: add documentation of memory models
References: <1556101715-31966-1-git-send-email-rppt@linux.ibm.com>
 <20190424101455.12cd407e@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190424101455.12cd407e@lwn.net>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19042418-0020-0000-0000-0000033460D5
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042418-0021-0000-0000-00002186C7BB
Message-Id: <20190424180215.GA13535@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240131
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 10:14:55AM -0600, Jonathan Corbet wrote:
> On Wed, 24 Apr 2019 13:28:35 +0300
> Mike Rapoport <rppt@linux.ibm.com> wrote:
> 
> > Describe what {FLAT,DISCONTIG,SPARSE}MEM are and how they manage to
> > maintain pfn <-> struct page correspondence.
> 
> Quick question: should this document perhaps mention that DISCONTIGMEM
> appears to be on its way out?

I suspect it'll take a while until then, but I'll add a sentence about it
being deprecated.
Which reminds me that mm/Kconfig also begs for the corresponding update.
 
> Thanks,
> 
> jon
> 

-- 
Sincerely yours,
Mike.

